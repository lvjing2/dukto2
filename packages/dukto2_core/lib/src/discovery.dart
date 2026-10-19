import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'models.dart';
import 'transfer.dart';

/// Announcements are candidates, never trusted identities. Confirm over HTTPS
/// before listing; file transmission still requires the user's code comparison.
class PeerDiscovery {
  static const defaultPort = 45878;
  static const defaultTransferPort = 45879;
  // Local-link multicast works on Android devices that reject 239.x groups.
  // This remains dukto2's own protocol and port, not LocalSend discovery.
  static final group = InternetAddress('224.0.0.167');
  Peer _local;
  Peer get local => _local;
  final int port;
  final int transferPort;
  final bool subnetFallback;
  final bool useMulticast;
  final Duration probeTimeout;

  /// Optional local cache of addresses explicitly confirmed by the user.
  final File? knownPeersFile;
  final _knownPeers = <String, Peer>{};
  Future<void> _cacheWrites = Future.value();
  bool _reconnecting = false;
  final _changes = StreamController<List<Peer>>.broadcast();
  final _peers = <String, Peer>{};
  final _pending = <String>{};
  final _lastProbe = <String, DateTime>{};
  RawDatagramSocket? _socket;
  Timer? _timer;
  Timer? _scanTimer;
  final _burst = <Timer>[];
  StreamSubscription<RawSocketEvent>? _subscription;
  List<NetworkInterface> _interfaces = [];
  bool _closed = false;
  bool _refreshing = false;
  bool _scanning = false;
  int _generation = 0;
  DateTime _lastInterfaces = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastScan = DateTime.fromMillisecondsSinceEpoch(0);

  PeerDiscovery(
    Peer local, {
    this.port = defaultPort,
    this.transferPort = defaultTransferPort,
    this.subnetFallback = true,
    this.useMulticast = true,
    this.probeTimeout = const Duration(milliseconds: 800),
    this.knownPeersFile,
  }) : _local = local;
  void updateLocal(Peer peer) {
    if (peer.id != local.id ||
        peer.fingerprint != local.fingerprint ||
        peer.port != local.port) {
      throw ArgumentError(
        'Changing discovery identity requires a new instance',
      );
    }
    _local = peer;
    announce();
  }

  Stream<List<Peer>> get changes => _changes.stream;
  List<Peer> get peers =>
      _peers.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  Future<void> start() async {
    if (_closed || _timer != null) return;
    await _loadKnownPeers();
    await refresh(force: true);
    if (_closed) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_closed) return;
      final before = _peers.length;
      _peers.removeWhere(
        (_, peer) => DateTime.now().difference(peer.lastSeen).inSeconds > 18,
      );
      if (_peers.length != before) _changes.add(peers);
      for (final peer in peers) {
        unawaited(_confirm(peer.host, peer.port, expected: peer));
      }
      announce();
      unawaited(_reconnectKnown());
      if (DateTime.now().difference(_lastInterfaces).inSeconds >= 5) {
        unawaited(refresh());
      }
      if (_peers.isEmpty &&
          DateTime.now().difference(_lastScan).inSeconds >= 120) {
        unawaited(scan());
      }
    });
  }

  /// Rejoin interfaces after Wi-Fi/VPN changes or resume. The public stream stays
  /// alive, and an unavailable multicast socket does not disable HTTPS scans.
  Future<void> refresh({bool force = false}) async {
    if (_closed || _refreshing) return;
    _refreshing = true;
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      String key(List<NetworkInterface> values) =>
          (values
                  .expand(
                    (i) => i.addresses.map((a) => '${i.name}:${a.address}'),
                  )
                  .toList()
                ..sort())
              .join(',');
      final changed = key(interfaces) != key(_interfaces);
      _lastInterfaces = DateTime.now();
      if (!force && !changed && _socket != null) return;
      _interfaces = interfaces;
      _generation++;
      _scanTimer?.cancel();
      for (final timer in _burst) {
        timer.cancel();
      }
      _burst.clear();
      await _subscription?.cancel();
      _socket?.close();
      _socket = null;
      if (_closed) return;
      if (changed && _peers.isNotEmpty) {
        _peers.clear();
        _changes.add(peers);
      }
      _lastProbe.clear();
      unawaited(_reconnectKnown());
      try {
        final socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          port,
          reuseAddress: true,
          reusePort: !Platform.isAndroid && !Platform.isWindows,
        );
        if (_closed) {
          socket.close();
          return;
        }
        _socket = socket;
        if (useMulticast) {
          socket.broadcastEnabled = true;
          socket.multicastHops = 1;
          socket.multicastLoopback = true;
          for (final interface in interfaces) {
            try {
              socket.joinMulticast(group, interface);
            } on SocketException {
              /* Skip unusable adapters. */
            }
          }
        }
        _subscription = socket.listen(
          (event) {
            if (event != RawSocketEvent.read) return;
            Datagram? packet;
            while ((packet = socket.receive()) != null) {
              try {
                if (packet!.data.length > 4096) continue;
                final data =
                    jsonDecode(utf8.decode(packet.data))
                        as Map<String, dynamic>;
                if (data['app'] != 'dukto2') continue;
                final candidate = Peer.fromJson(data, packet.address.address);
                if (candidate.fingerprint == local.fingerprint) continue;
                unawaited(
                  _confirm(candidate.host, candidate.port, expected: candidate),
                );
              } on Object {
                /* Unrelated or malformed datagram. */
              }
            }
          },
          onError: (Object _) {
            // A transient ICMP/VPN error is not proof that the socket is dead.
          },
          onDone: () {
            if (identical(_socket, socket)) _socket = null;
          },
        );
      } on SocketException {
        // Keep running: known endpoints, subnet fallback and manual IP work.
      }
      for (final delay in [100, 600, 2600]) {
        _burst.add(Timer(Duration(milliseconds: delay), announce));
      }
      _scanTimer = Timer(const Duration(seconds: 3), () {
        if (_peers.isEmpty) unawaited(scan());
      });
    } finally {
      _refreshing = false;
    }
  }

  bool _preferred(String host) => _interfaces
      .where(
        (i) => !RegExp(r'^(utun|tun|tap|ppp|ipsec|rmnet|lo)').hasMatch(i.name),
      )
      .expand((i) => i.addresses)
      .any(
        (a) =>
            a.address.split('.').take(3).join('.') ==
            host.split('.').take(3).join('.'),
      );

  /// Bonjour supplies only an address. The actual HTTPS identity is still
  /// checked here, and the UI still requires the user's code comparison.
  Future<void> confirmEndpoint(String host, int port) async {
    final address = InternetAddress.tryParse(host);
    if (address?.type != InternetAddressType.IPv4 || port < 1 || port > 65535) {
      return;
    }
    await _confirm(host, port);
  }

  /// Remember an endpoint after code comparison, without granting future sends
  /// or receiver consent. A reused IP must still match this identity.
  Future<void> rememberPeer(Peer peer) async {
    if (_closed ||
        InternetAddress.tryParse(peer.host)?.type != InternetAddressType.IPv4 ||
        peer.port < 1 ||
        peer.port > 65535) {
      return;
    }
    _knownPeers.remove(peer.fingerprint);
    _knownPeers[peer.fingerprint] = peer;
    while (_knownPeers.length > 32) {
      _knownPeers.remove(_knownPeers.keys.first);
    }
    await _confirm(peer.host, peer.port, expected: peer);
    announce();
    final file = knownPeersFile;
    if (file == null) return;
    final data = jsonEncode([
      for (final value in _knownPeers.values)
        {...value.toJson(), 'host': value.host},
    ]);
    _cacheWrites = _cacheWrites.then((_) async {
      try {
        await file.parent.create(recursive: true);
        final temporary = File('${file.path}.tmp');
        await temporary.writeAsString(data, flush: true);
        await temporary.rename(file.path);
      } on FileSystemException {
        // A cache failure must not block the current connection.
      }
    });
    await _cacheWrites;
  }

  Future<void> _loadKnownPeers() async {
    final file = knownPeersFile;
    if (file == null) return;
    try {
      if (await file.length() > 32768) return;
      final data = jsonDecode(await file.readAsString()) as List;
      for (final item in data.take(32)) {
        try {
          final value = item as Map<String, dynamic>;
          final host = value['host'] as String;
          if (InternetAddress.tryParse(host)?.type !=
              InternetAddressType.IPv4) {
            continue;
          }
          final peer = Peer.fromJson(value, host);
          _knownPeers[peer.fingerprint] = peer;
        } on Object {
          // Ignore damaged entries independently.
        }
      }
    } on Object {
      // Missing or damaged caches do not disable local discovery.
    }
  }

  Future<void> _reconnectKnown() async {
    if (_closed || _reconnecting) return;
    _reconnecting = true;
    try {
      final pending = _knownPeers.values.toList();
      var index = 0;
      Future<void> worker() async {
        while (!_closed && index < pending.length) {
          final peer = pending[index++];
          await _confirm(peer.host, peer.port, expected: peer);
        }
      }

      await Future.wait(List.generate(4, (_) => worker()));
    } finally {
      _reconnecting = false;
    }
  }

  Future<void> _confirm(String host, int targetPort, {Peer? expected}) async {
    final key = '$host:$targetPort';
    final now = DateTime.now();
    if (_closed ||
        _pending.length >= 8 ||
        _pending.contains(key) ||
        (_lastProbe[key] != null &&
            now.difference(_lastProbe[key]!).inSeconds < 5)) {
      return;
    }
    final generation = _generation;
    _pending.add(key);
    _lastProbe[key] = now;
    if (_lastProbe.length > 512) _lastProbe.remove(_lastProbe.keys.first);
    try {
      final peer = await TransferClient.probe(
        host,
        targetPort,
        timeout: probeTimeout,
      );
      if (_closed ||
          generation != _generation ||
          peer.fingerprint == local.fingerprint ||
          (expected != null &&
              (peer.fingerprint != expected.fingerprint ||
                  peer.id != expected.id))) {
        return;
      }
      if (_peers.length >= 128 && !_peers.containsKey(peer.fingerprint)) return;
      final previous = _peers[peer.fingerprint];
      // Do not let a later VPN announcement replace a working Wi-Fi address.
      if (previous != null &&
          _preferred(previous.host) &&
          !_preferred(peer.host)) {
        return;
      }
      _peers[peer.fingerprint] = peer;
      _changes.add(peers);
      if (previous == null || !useMulticast) announce();
    } on Object {
      /* Failed candidates never enter the visible device list. */
    } finally {
      _pending.remove(key);
    }
  }

  /// Bounded fallback on directly connected private IPv4 /24 segments only.
  /// It probes identity metadata, never offers or sends files. It is intentionally
  /// conservative: larger/VPN subnets remain available through manual IP.
  Future<void> scan() async {
    if (_closed || _scanning || !subnetFallback) return;
    _scanning = true;
    _lastScan = DateTime.now();
    final generation = _generation;
    try {
      final addresses = _interfaces
          .where(
            (i) =>
                !RegExp(r'^(utun|tun|tap|ppp|ipsec|rmnet|lo)').hasMatch(i.name),
          )
          .expand((i) => i.addresses)
          .map((a) => a.address)
          .toSet();
      final prefixes = addresses
          .where((a) {
            final b = a.split('.').map(int.parse).toList();
            return b[0] == 10 ||
                (b[0] == 192 && b[1] == 168) ||
                (b[0] == 172 && b[1] >= 16 && b[1] <= 31);
          })
          .map((a) => a.split('.').take(3).join('.'))
          .toSet()
          .take(2);
      final hosts = [
        for (final prefix in prefixes)
          for (var n = 1; n < 255; n++) '$prefix.$n',
      ].where((a) => !addresses.contains(a)).toList();
      var index = 0;
      Future<void> worker() async {
        while (!_closed && generation == _generation && index < hosts.length) {
          if (_pending.length >= 8) {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            continue;
          }
          final host = hosts[index++];
          await _confirm(host, transferPort);
        }
      }

      await Future.wait(List.generate(8, (_) => worker()));
    } finally {
      _scanning = false;
    }
  }

  void announce() {
    if (_closed) return;
    final socket = _socket;
    if (socket == null) return;
    final bytes = utf8.encode(jsonEncode({'app': 'dukto2', ...local.toJson()}));
    // Unicast can cross routed subnets even when multicast cannot. This also
    // lets a manually connected device discover the initiator in return.
    for (final peer in peers) {
      try {
        socket.send(bytes, InternetAddress(peer.host), port);
      } on SocketException {
        /* A disappeared endpoint will expire normally. */
      }
    }
    if (!useMulticast) return;
    for (final address in _interfaces.expand((i) => i.addresses)) {
      try {
        socket.setRawOption(
          RawSocketOption(
            RawSocketOption.levelIPv4,
            RawSocketOption.IPv4MulticastInterface,
            address.rawAddress,
          ),
        );
        socket.send(bytes, group, port);
      } on SocketException {
        /* Continue on remaining interfaces. */
      }
    }
    try {
      socket.send(bytes, InternetAddress('255.255.255.255'), port);
    } on SocketException {
      /* HTTPS fallback remains available. */
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _generation++;
    _timer?.cancel();
    _scanTimer?.cancel();
    for (final timer in _burst) {
      timer.cancel();
    }
    await _subscription?.cancel();
    _socket?.close();
    await _cacheWrites;
    await _changes.close();
  }
}
