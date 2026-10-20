import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dukto2_core/dukto2_core.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late DeviceIdentity local;
  late DeviceIdentity remote;
  late HttpServer endpoint;
  late Peer remotePeer;
  late PeerDiscovery discovery;
  late RawDatagramSocket udp;
  late int discoveryPort;
  var available = true;
  var requests = 0;
  var failNext = false;
  Completer<void>? hold;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('dukto2-presence-');
    local = await DeviceIdentity.loadOrCreate(
      Directory('${directory.path}/local'),
    );
    remote = await DeviceIdentity.loadOrCreate(
      Directory('${directory.path}/remote'),
    );
  });
  tearDownAll(() => directory.delete(recursive: true));

  setUp(() async {
    available = true;
    requests = 0;
    failNext = false;
    hold = null;
    endpoint = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      remote.securityContext(),
    );
    remotePeer = Peer(
      id: remote.id,
      name: 'Remote',
      host: '127.0.0.1',
      port: endpoint.port,
      fingerprint: remote.fingerprint,
    );
    endpoint.listen((request) async {
      requests++;
      final failed = !available || failNext;
      failNext = false;
      try {
        await hold?.future;
        request.response.headers.contentType = ContentType.json;
        request.response.statusCode = failed ? 503 : 200;
        request.response.write(
          jsonEncode(failed ? {'error': 'offline'} : remotePeer.toJson()),
        );
        await request.response.close();
      } on Object {
        // Presence timeouts close held test connections.
      }
    });
    addTearDown(() async {
      if (hold != null && !hold!.isCompleted) hold!.complete();
      await endpoint.close(force: true);
    });
    final reserve = await RawDatagramSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    discoveryPort = reserve.port;
    reserve.close();
    discovery = PeerDiscovery(
      Peer(
        id: local.id,
        name: 'Local',
        host: '127.0.0.1',
        port: 1,
        fingerprint: local.fingerprint,
      ),
      port: discoveryPort,
      useMulticast: false,
      subnetFallback: false,
    );
    addTearDown(discovery.close);
    udp = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(udp.close);
    await discovery.start();
    await discovery.confirmEndpoint('127.0.0.1', endpoint.port);
    expect(discovery.peers.single.id, remote.id);
  });

  void broadcast(String event, {Peer? peer}) {
    udp.send(
      utf8.encode(
        jsonEncode({
          'app': 'dukto2',
          ...(peer ?? remotePeer).toJson(),
          'event': event,
        }),
      ),
      InternetAddress.loopbackIPv4,
      discoveryPort,
    );
  }

  test(
    'a disconnected peer expires after three seconds without a departure',
    () async {
      final disappeared = discovery.changes.firstWhere(
        (peers) => peers.isEmpty,
      );
      available = false;
      final elapsed = Stopwatch()..start();
      // Small scheduling allowance; the production deadline itself is exactly 3 s.
      await disappeared.timeout(const Duration(milliseconds: 3250));
      expect(elapsed.elapsed, lessThan(const Duration(milliseconds: 3250)));
      print('No departure: removed after ${elapsed.elapsedMilliseconds} ms');
    },
  );

  test('a hanging endpoint cannot extend the three-second deadline', () async {
    hold = Completer<void>();
    final disappeared = discovery.changes.firstWhere((peers) => peers.isEmpty);
    await disappeared.timeout(const Duration(milliseconds: 3250));
    expect(discovery.peers, isEmpty);
  });

  test(
    'one missed heartbeat recovers without removing an online peer',
    () async {
      final removals = <List<Peer>>[];
      final subscription = discovery.changes
          .where((peers) => peers.isEmpty)
          .listen(removals.add);
      addTearDown(subscription.cancel);
      failNext = true;
      await Future<void>.delayed(const Duration(milliseconds: 4200));
      expect(requests, greaterThanOrEqualTo(4));
      expect(discovery.peers.single.id, remote.id);
      expect(removals, isEmpty);
    },
  );

  test('a departure triggers a fresh HTTPS check and fast removal', () async {
    final disappeared = discovery.changes.firstWhere((peers) => peers.isEmpty);
    available = false;
    final elapsed = Stopwatch()..start();
    broadcast('offline');
    await disappeared.timeout(const Duration(milliseconds: 900));
    expect(requests, 2); // Not blocked by the candidate's five-second throttle.
    print('Departure: removed after ${elapsed.elapsedMilliseconds} ms');
  });

  test('forged departure cannot remove a reachable device', () async {
    broadcast('offline');
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(requests, 2);
    expect(discovery.peers.single.id, remote.id);
  });

  test('departure for a different identity or endpoint is ignored', () async {
    broadcast(
      'offline',
      peer: Peer(
        id: 'forged',
        name: 'Remote',
        host: '127.0.0.1',
        port: remotePeer.port,
        fingerprint: remote.fingerprint,
      ),
    );
    broadcast(
      'offline',
      peer: Peer(
        id: remote.id,
        name: 'Remote',
        host: '127.0.0.1',
        port: remotePeer.port + 1,
        fingerprint: remote.fingerprint,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(requests, 1);
    expect(discovery.peers.single.id, remote.id);
  });

  test(
    'unverified online broadcasts do not keep an unavailable device alive',
    () async {
      available = false;
      final spam = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => broadcast('online'),
      );
      addTearDown(spam.cancel);
      final disappeared = discovery.changes.firstWhere(
        (peers) => peers.isEmpty,
      );
      await disappeared.timeout(const Duration(milliseconds: 3250));
      expect(discovery.peers, isEmpty);
    },
  );

  test(
    'a removed endpoint can be rediscovered without the old throttle',
    () async {
      available = false;
      final disappeared = discovery.changes.firstWhere(
        (peers) => peers.isEmpty,
      );
      broadcast('offline');
      await disappeared.timeout(const Duration(seconds: 1));
      available = true;
      await discovery.confirmEndpoint('127.0.0.1', endpoint.port);
      expect(discovery.peers.single.id, remote.id);
    },
  );

  test('eight occupied candidate slots do not delay presence checks', () async {
    final listeners = <ServerSocket>[];
    final connections = <Socket>[];
    final probes = <Future<void>>[];
    addTearDown(() async {
      for (final socket in connections) {
        socket.destroy();
      }
      for (final listener in listeners) {
        await listener.close();
      }
      await Future.wait(probes);
    });
    for (var i = 0; i < 8; i++) {
      final listener = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      listeners.add(listener);
      listener.listen((socket) {
        connections.add(socket);
        socket.listen((_) {}, onError: (Object _) {});
      });
    }
    await Future<void>.delayed(const Duration(milliseconds: 650));
    for (final listener in listeners) {
      probes.add(discovery.confirmEndpoint('127.0.0.1', listener.port));
    }
    await Future<void>.delayed(const Duration(milliseconds: 550));
    expect(requests, greaterThanOrEqualTo(2));
    expect(discovery.peers.single.id, remote.id);
  });

  test('a stale departure check cannot evict a newer confirmation', () async {
    available = false;
    final oldRequest = hold = Completer<void>();
    broadcast('offline');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(requests, 2);
    await discovery.refresh(force: true);
    available = true;
    hold = null;
    await discovery.confirmEndpoint('127.0.0.1', endpoint.port);
    oldRequest.complete();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(discovery.peers.single.id, remote.id);
  });

  test('closing discovery ignores an in-flight presence response', () async {
    final pending = hold = Completer<void>();
    await Future<void>.delayed(const Duration(milliseconds: 1150));
    expect(requests, greaterThanOrEqualTo(2));
    await discovery.close();
    pending.complete();
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
}
