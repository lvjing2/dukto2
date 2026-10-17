import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'models.dart';

/// Best-effort IPv4 multicast + broadcast. Manual IP connection is always available.
class PeerDiscovery {
  static const defaultPort = 45878;
  static final group = InternetAddress('239.255.77.77');
  final Peer local;
  final int port;
  final _changes = StreamController<List<Peer>>.broadcast();
  final _peers = <String, Peer>{};
  RawDatagramSocket? _socket;
  Timer? _timer;
  StreamSubscription<RawSocketEvent>? _subscription;
  List<InternetAddress> _interfaces = [];

  PeerDiscovery(this.local, {this.port = defaultPort});
  Stream<List<Peer>> get changes => _changes.stream;
  List<Peer> get peers =>
      _peers.values.toList()..sort((a, b) => a.name.compareTo(b.name));

  Future<void> start() async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
      reuseAddress: true,
      reusePort: !Platform.isAndroid && !Platform.isWindows,
    );
    _socket = socket;
    socket.broadcastEnabled = true;
    socket.multicastHops = 1;
    socket.multicastLoopback = false;
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    _interfaces = interfaces
        .expand((interface) => interface.addresses)
        .toList();
    for (final interface in interfaces) {
      try {
        socket.joinMulticast(group, interface);
      } on SocketException {
        /* Some VPNs do not support multicast. */
      }
    }
    _subscription = socket.listen(
      (event) {
        if (event != RawSocketEvent.read) return;
        Datagram? datagram;
        while ((datagram = socket.receive()) != null) {
          try {
            final packet = datagram!;
            if (packet.data.length > 4096) continue;
            final json =
                jsonDecode(utf8.decode(packet.data)) as Map<String, dynamic>;
            if (json['app'] != 'dukto2') continue;
            final peer = Peer.fromJson(json, packet.address.address);
            if (peer.id == local.id ||
                (_peers.length >= 128 && !_peers.containsKey(peer.id))) {
              continue;
            }
            _peers[peer.id] = peer;
            _changes.add(peers);
          } on Object {
            /* Ignore unrelated or malformed datagrams. */
          }
        }
      },
      onError: (Object _) {
        // A VPN/interface may reject multicast asynchronously. Keep listening on
        // the remaining interfaces; manual HTTPS connections are independent.
      },
    );
    announce();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final before = _peers.length;
      _peers.removeWhere(
        (_, peer) => DateTime.now().difference(peer.lastSeen).inSeconds > 12,
      );
      if (_peers.length != before) _changes.add(peers);
      announce();
    });
  }

  void announce() {
    final bytes = utf8.encode(jsonEncode({'app': 'dukto2', ...local.toJson()}));
    final socket = _socket;
    if (socket == null) return;
    // The default multicast route can point at a VPN. Advertise on every IPv4
    // interface explicitly; the 4-byte option is an in_addr in network order.
    for (final address in _interfaces) {
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
        /* Not every VPN supports multicast. Continue with the Wi-Fi interface. */
      }
    }
    try {
      socket.send(bytes, InternetAddress('255.255.255.255'), port);
    } on SocketException {
      /* Manual connection remains available. */
    }
  }

  Future<void> close() async {
    _timer?.cancel();
    await _subscription?.cancel();
    _socket?.close();
    await _changes.close();
  }
}
