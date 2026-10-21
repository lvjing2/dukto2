import 'dart:async';
import 'dart:io';

import 'package:dukto2/src/controller.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter_test/flutter_test.dart';

Peer peer({
  String id = 'pc',
  String host = '192.168.1.2',
  String? fingerprint,
}) => Peer(
  id: id,
  name: id,
  host: host,
  port: 45879,
  fingerprint: fingerprint ?? 'a' * 64,
  supportsText: true,
);

class ReadyController extends Dukto2Controller {
  ReadyController({required super.connection});
  @override
  bool get ready => true;
}

void main() {
  test(
    'a transient miss preserves online status but does not approve a send',
    () async {
      var reachable = true;
      final connection = PeerConnection(
        probe: (p) async {
          if (!reachable) throw const SocketException('temporary loss');
          return p;
        },
      );
      addTearDown(connection.dispose);
      connection.watch(peer());
      expect(await connection.check(), isTrue);
      reachable = false;
      expect(await connection.check(), isFalse);
      expect(connection.state, PeerConnectionState.online);
      reachable = true;
      expect(await connection.check(), isTrue);
      reachable = false;
      expect(await connection.check(), isFalse);
      expect(connection.state, PeerConnectionState.online);
    },
  );

  testWidgets('a slow verified response remains usable', (tester) async {
    final connection = PeerConnection(
      probe: (p) async {
        await Future<void>.delayed(const Duration(milliseconds: 1200));
        return p;
      },
    );
    connection.watch(peer());
    await tester.pump(const Duration(milliseconds: 1200));
    expect(connection.state, PeerConnectionState.online);
    connection.dispose();
  });

  testWidgets('hanging probes expire and concurrent checks share one request', (
    tester,
  ) async {
    var requests = 0;
    final connection = PeerConnection(
      probe: (_) {
        requests++;
        return Completer<Peer>().future;
      },
    );
    connection.watch(peer());
    final first = connection.check();
    final second = connection.check();
    await tester.pump(const Duration(seconds: 2));
    expect(await first, isFalse);
    expect(await second, isFalse);
    expect(requests, 1);
    expect(connection.state, PeerConnectionState.offline);
    connection.dispose();
  });

  test('a new selection does not inherit the previous online grace', () async {
    var reachable = true;
    final connection = PeerConnection(
      probe: (p) async {
        if (!reachable) throw const SocketException('offline');
        return p;
      },
    );
    addTearDown(connection.dispose);
    connection.watch(peer());
    expect(await connection.check(), isTrue);
    reachable = false;
    expect(await connection.check(), isFalse);
    expect(connection.state, PeerConnectionState.online);
    connection.watch(peer(id: 'new'));
    expect(await connection.check(), isFalse);
    expect(connection.state, PeerConnectionState.offline);
  });

  test('identity changes bypass the transient-failure grace', () async {
    var target = peer();
    final connection = PeerConnection(probe: (_) async => target);
    addTearDown(connection.dispose);
    connection.watch(peer());
    expect(await connection.check(), isTrue);
    target = peer(fingerprint: 'b' * 64);
    expect(await connection.check(), isFalse);
    expect(connection.state, PeerConnectionState.identityChanged);
  });

  test('reachability is independent of nearby discovery and recovers after failure', () async {
    var reachable = true;
    final connection = PeerConnection(
      probe: (target) async {
        if (!reachable) throw const SocketException('offline');
        return target;
      },
    );
    final c = ReadyController(connection: connection);
    addTearDown(c.dispose);
    c.select(peer());
    expect(c.peers, isEmpty);
    expect(c.connectionState, PeerConnectionState.checking);
    expect(c.canSendToSelected, isFalse);
    expect(await connection.check(), isTrue);
    expect(c.canSendToSelected, isTrue);
    reachable = false;
    await connection.check();
    expect(c.connectionState, PeerConnectionState.online);
    await connection.check();
    expect(c.connectionState, PeerConnectionState.online);
    await connection.check();
    expect(c.connectionState, PeerConnectionState.offline);
    expect(c.canSendToSelected, isFalse);
    reachable = true;
    await connection.check();
    expect(c.canSendToSelected, isTrue);
  });

  testWidgets('periodic checks detect offline and recover without discovery', (
    tester,
  ) async {
    var reachable = true;
    final connection = PeerConnection(
      probe: (p) async {
        if (!reachable) throw const SocketException('offline');
        return p;
      },
    );
    connection.watch(peer());
    await tester.pump();
    expect(connection.state, PeerConnectionState.online);
    reachable = false;
    await tester.pump(const Duration(seconds: 1));
    expect(connection.state, PeerConnectionState.online);
    await tester.pump(const Duration(seconds: 1));
    expect(connection.state, PeerConnectionState.online);
    await tester.pump(const Duration(seconds: 1));
    expect(connection.state, PeerConnectionState.offline);
    reachable = true;
    await tester.pump(const Duration(seconds: 1));
    expect(connection.state, PeerConnectionState.online);
    connection.dispose();
  });

  test(
    'the same address with a different ID or certificate is never online',
    () async {
      for (final changed in [peer(id: 'other'), peer(fingerprint: 'b' * 64)]) {
        final connection = PeerConnection(probe: (_) async => changed);
        connection.watch(peer());
        expect(await connection.check(), isFalse);
        expect(connection.state, PeerConnectionState.identityChanged);
        connection.dispose();
      }
    },
  );

  test(
    'late results for old selections do not change the new device status',
    () async {
      final oldResult = Completer<Peer>();
      final connection = PeerConnection(
        probe: (p) => p.id == 'pc' ? oldResult.future : Future.value(p),
      );
      addTearDown(connection.dispose);
      connection.watch(peer());
      final oldCheck = connection.check();
      connection.watch(peer(id: 'new', host: '192.168.1.3'));
      expect(await connection.check(), isTrue);
      oldResult.completeError(const SocketException('old device disconnected'));
      expect(await oldCheck, isFalse);
      expect(connection.state, PeerConnectionState.online);
    },
  );

  test('sending rechecks an online target and sends nothing if it has disconnected', () async {
    var reachable = true;
    final c = ReadyController(
      connection: PeerConnection(
        probe: (p) async {
          if (!reachable) throw const SocketException('offline');
          return p;
        },
      ),
    );
    addTearDown(c.dispose);
    c.select(peer());
    await c.connection.check();
    expect(c.canSendToSelected, isTrue);
    reachable = false;
    await c.sendText('must not be transmitted');
    expect(c.session, isNull);
    expect(c.history, isEmpty);
    expect(c.busy, isFalse);
    expect(c.canSendToSelected, isFalse);
  });

  test('a disposed monitor ignores a pending probe', () async {
    final pending = Completer<Peer>();
    final connection = PeerConnection(probe: (_) => pending.future);
    var notifications = 0;
    connection.addListener(() => notifications++);
    connection.watch(peer());
    final check = connection.check();
    connection.dispose();
    final before = notifications;
    pending.complete(peer());
    expect(await check, isFalse);
    expect(notifications, before);
  });
}
