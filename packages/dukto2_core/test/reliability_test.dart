import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:test/test.dart';

class RecordingDiscovery extends PeerDiscovery {
  int scans = 0;
  RecordingDiscovery(super.local)
    : super(port: 0, subnetFallback: false, useMulticast: false);

  @override
  Future<void> scan() async {
    scans++;
  }
}

void main() {
  late Directory root;
  late DeviceIdentity identity;
  late DeviceIdentity other;
  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('dukto2-reliability-');
    identity = await DeviceIdentity.loadOrCreate(Directory('${root.path}/one'));
    other = await DeviceIdentity.loadOrCreate(Directory('${root.path}/two'));
  });
  tearDownAll(() => root.delete(recursive: true));

  Future<TransferServer> start({
    ReceiveTargetFactory? target,
    Duration? idle,
  }) async {
    final server = TransferServer(
      identity: identity,
      name: 'Receiver',
      receiveDirectory: Directory('${root.path}/${randomId()}'),
      onOffer: (_) async => true,
      bindAddress: InternetAddress.loopbackIPv4,
      createTarget: target,
      idleTimeout: idle ?? const Duration(seconds: 30),
    );
    await server.start();
    addTearDown(server.close);
    return server;
  }

  HttpClient pinned() =>
      HttpClient(context: SecurityContext(withTrustedRoots: false))
        ..findProxy = ((_) => 'DIRECT')
        ..badCertificateCallback = (cert, _, _) =>
            sha256.convert(cert.der).toString() == identity.fingerprint;

  test(
    'active search scans with visible peers and coalesces repeats',
    () async {
      final server = await start();
      final discovery = RecordingDiscovery(
        Peer(
          id: other.id,
          name: 'Local',
          host: '127.0.0.1',
          port: 1,
          fingerprint: other.fingerprint,
        ),
      );
      addTearDown(discovery.close);
      await discovery.start();
      await discovery.confirmEndpoint('127.0.0.1', server.port);
      expect(discovery.peers.single.fingerprint, identity.fingerprint);
      final first = discovery.search();
      expect(identical(first, discovery.search()), isTrue);
      await first;
      expect(discovery.scans, 1);
      expect(discovery.peers.single.fingerprint, identity.fingerprint);
      await discovery.search();
      expect(discovery.scans, 2);
      await discovery.close();
      await discovery.search();
      expect(discovery.scans, 2);
    },
  );

  test(
    'listener health check completes TLS and emits no transfer error',
    () async {
      final server = await start();
      final errors = <TransferFailure>[];
      final subscription = server.errors.listen(errors.add);
      addTearDown(subscription.cancel);
      await server.ensureListening();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(errors, isEmpty);
    },
  );

  test(
    'sender cancellation before upload releases target and signals the UI',
    () async {
      final server = await start();
      final http = pinned();
      addTearDown(() => http.close(force: true));
      Uri url(String path) => Uri(
        scheme: 'https',
        host: '127.0.0.1',
        port: server.port,
        path: path,
      );
      final request = await http.postUrl(url('/v1/offer'));
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({'sender': 'Mac', 'name': 'not-started.bin', 'size': 99}),
      );
      final response = await request.close();
      final body = jsonDecode(await utf8.decoder.bind(response).join()) as Map;
      final stopped = server.errors.first;
      final cancel = await http.deleteUrl(url('/v1/file/${body['token']}'));
      await (await cancel.close()).drain<void>();
      expect((await stopped).kind, TransferFailureKind.cancelled);
      expect(await server.receiveDirectory.list().toList(), isEmpty);
    },
  );

  test(
    'unreachable or forged UDP candidates never become visible devices',
    () async {
      final server = await start();
      final reserve = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final port = reserve.port;
      reserve.close();
      final discovery = PeerDiscovery(
        Peer(
          id: other.id,
          name: 'Local',
          host: '127.0.0.1',
          port: 1,
          fingerprint: other.fingerprint,
        ),
        port: port,
        subnetFallback: false,
        probeTimeout: const Duration(milliseconds: 150),
      );
      await discovery.start();
      addTearDown(discovery.close);
      final udp = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(udp.close);
      final forged = Peer(
        id: identity.id,
        name: 'Spoof',
        host: '127.0.0.1',
        port: server.port,
        fingerprint: 'a' * 64,
      );
      udp.send(
        utf8.encode(jsonEncode({'app': 'dukto2', ...forged.toJson()})),
        InternetAddress.loopbackIPv4,
        port,
      );
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(discovery.peers, isEmpty);
    },
  );

  test(
    'Bonjour candidates are confirmed over HTTPS without multicast',
    () async {
      final server = await start();
      final reserve = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final port = reserve.port;
      reserve.close();
      final discovery = PeerDiscovery(
        Peer(
          id: other.id,
          name: 'iPhone',
          host: '127.0.0.1',
          port: 1,
          fingerprint: other.fingerprint,
        ),
        port: port,
        useMulticast: false,
        subnetFallback: false,
      );
      await discovery.start();
      addTearDown(discovery.close);
      await discovery.confirmEndpoint('untrusted.local', server.port);
      await discovery.confirmEndpoint('127.0.0.1', 65536);
      expect(discovery.peers, isEmpty);
      await discovery.confirmEndpoint('127.0.0.1', server.port);
      expect(discovery.peers.single.id, identity.id);
      expect(discovery.peers.single.fingerprint, identity.fingerprint);
      expect(discovery.peers.single.name, 'Receiver');
    },
  );

  test(
    'remembered endpoints reconnect after restart without subnet scanning',
    () async {
      final server = await start();
      final cache = File('${root.path}/${randomId()}/known-peers.json');
      final local = Peer(
        id: other.id,
        name: 'Local',
        host: '127.0.0.1',
        port: 1,
        fingerprint: other.fingerprint,
      );
      final first = PeerDiscovery(
        local,
        knownPeersFile: cache,
        useMulticast: false,
        subnetFallback: false,
      );
      await first.rememberPeer(
        await TransferClient.probe('127.0.0.1', server.port),
      );
      await first.close();
      final reserve = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final port = reserve.port;
      reserve.close();
      final next = PeerDiscovery(
        local,
        port: port,
        knownPeersFile: cache,
        useMulticast: false,
        subnetFallback: false,
      );
      addTearDown(next.close);
      final found = next.changes.firstWhere((peers) => peers.isNotEmpty);
      await next.start();
      final peers = await found.timeout(const Duration(seconds: 5));
      expect(peers.single.fingerprint, identity.fingerprint);
      expect(peers.single.host, '127.0.0.1');
    },
  );

  test(
    'confirmed endpoints receive online and graceful offline announcements',
    () async {
      final server = await start();
      final receiver = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
        reusePort: !Platform.isAndroid && !Platform.isWindows,
      );
      addTearDown(receiver.close);
      // This observer and discovery share one host and port. Unicast with
      // SO_REUSEPORT can reach either socket, unlike two separate LAN devices.
      // Join the announcement group so multicast loopback fans out to both.
      for (final interface in await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      )) {
        try {
          receiver.joinMulticast(PeerDiscovery.group, interface);
        } on SocketException {
          // Skip adapters which cannot join this multicast group.
        }
      }
      final received = Completer<Map<String, dynamic>>();
      final departed = Completer<Map<String, dynamic>>();
      final subscription = receiver.listen((event) {
        if (event != RawSocketEvent.read) return;
        Datagram? packet;
        while ((packet = receiver.receive()) != null) {
          final value =
              jsonDecode(utf8.decode(packet!.data)) as Map<String, dynamic>;
          if (value['event'] == 'offline') {
            if (!departed.isCompleted) departed.complete(value);
          } else if (!received.isCompleted) {
            received.complete(value);
          }
        }
      });
      addTearDown(subscription.cancel);
      final discovery = PeerDiscovery(
        Peer(
          id: other.id,
          name: 'Local',
          host: '127.0.0.1',
          port: 12345,
          fingerprint: other.fingerprint,
        ),
        port: receiver.port,
        subnetFallback: false,
      );
      addTearDown(discovery.close);
      await discovery.start();
      await discovery.confirmEndpoint('127.0.0.1', server.port);
      final message = await received.future.timeout(const Duration(seconds: 3));
      expect(message['app'], 'dukto2');
      expect(message['id'], other.id);
      expect(message['port'], 12345);
      expect(message['event'], 'online');
      await discovery.close();
      final offline = await departed.future.timeout(const Duration(seconds: 1));
      expect(offline['event'], 'offline');
      expect(offline['id'], other.id);
      expect(offline['fingerprint'], other.fingerprint);
    },
  );

  test(
    'remembered endpoint rejects an IP reused by a different identity',
    () async {
      final server = await start();
      final cache = File('${root.path}/${randomId()}.json');
      final candidate = await TransferClient.probe('127.0.0.1', server.port);
      await cache.writeAsString(
        jsonEncode([
          {
            ...candidate.toJson(),
            'host': candidate.host,
            'fingerprint': 'a' * 64,
          },
        ]),
      );
      final reserve = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final port = reserve.port;
      reserve.close();
      final discovery = PeerDiscovery(
        Peer(
          id: other.id,
          name: 'Local',
          host: '127.0.0.1',
          port: 1,
          fingerprint: other.fingerprint,
        ),
        port: port,
        knownPeersFile: cache,
        useMulticast: false,
        subnetFallback: false,
      );
      addTearDown(discovery.close);
      await discovery.start();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(discovery.peers, isEmpty);
    },
  );

  test(
    'write/commit failures discard an external destination and publish no receipt',
    () async {
      final target = _FailingTarget();
      final server = await start(target: (_, _) async => target);
      final receipts = <TransferReceipt>[];
      final subscription = server.received.listen(receipts.add);
      addTearDown(subscription.cancel);
      final client = TransferClient();
      addTearDown(client.close);
      await expectLater(
        client.sendStream(
          peer: server.localPeer,
          name: 'x.bin',
          size: 16,
          openRead: () => Stream.value(List.filled(16, 1)),
          sender: 'Sender',
        ),
        throwsA(
          isA<TransferFailure>().having(
            (f) => f.cause,
            'cause',
            isA<HttpException>(),
          ),
        ),
      );
      expect(target.discarded, isTrue);
      expect(receipts, isEmpty);
    },
  );

  test(
    'stalled upload is removed and the receiver can accept the next file',
    () async {
      final server = await start(idle: const Duration(milliseconds: 250));
      final http = pinned();
      addTearDown(() => http.close(force: true));
      Uri url(String path) => Uri(
        scheme: 'https',
        host: '127.0.0.1',
        port: server.port,
        path: path,
      );
      final offer = await http.postUrl(url('/v1/offer'));
      offer.headers.contentType = ContentType.json;
      offer.write(
        jsonEncode({
          'sender': 'Sender',
          'name': 'stalled.bin',
          'size': 1000000,
        }),
      );
      final response = await offer.close();
      final body = jsonDecode(await utf8.decoder.bind(response).join()) as Map;
      final upload = await http.putUrl(url('/v1/file/${body['token']}'));
      upload.contentLength = 1000000;
      final error = server.errors.first;
      upload.add(List.filled(1024, 1));
      await upload.flush();
      await error.timeout(const Duration(seconds: 3));
      http.close(force: true);
      expect(await server.receiveDirectory.list().toList(), isEmpty);
      final client = TransferClient();
      addTearDown(client.close);
      final done = server.received.first;
      await client.sendStream(
        peer: server.localPeer,
        name: 'retry.bin',
        size: 3,
        openRead: () => Stream.value([1, 2, 3]),
        sender: 'Sender',
      );
      expect(await (await done).file!.readAsBytes(), [1, 2, 3]);
    },
  );

  test(
    'receiver cancellation interrupts a stalled stream without waiting for idle timeout',
    () async {
      final server = await start();
      final client = TransferClient();
      addTearDown(client.close);
      final source = StreamController<List<int>>();
      final progress = server.progress.first;
      final sending = client.sendStream(
        peer: server.localPeer,
        name: 'cancel.bin',
        size: 10000000,
        openRead: () => source.stream,
        sender: 'Sender',
      );
      final failure = expectLater(sending, throwsA(anything));
      source.add(List.filled(65536, 7));
      await progress.timeout(const Duration(seconds: 3));
      final error = server.errors.first;
      server.cancelIncoming();
      await error.timeout(const Duration(seconds: 3));
      await source.close();
      await failure;
      expect(await server.receiveDirectory.list().toList(), isEmpty);
    },
  );
}

class _FailingTarget implements ReceiveTarget {
  bool discarded = false;
  @override
  Future<void> addStream(Stream<List<int>> bytes) async {
    await bytes.drain<void>();
  }

  @override
  Future<void> close() async {}
  @override
  Future<TransferReceipt> commit(FileOffer offer, String sha256) async =>
      throw const FileSystemException('No space at commit');
  @override
  Future<void> discard() async {
    discarded = true;
  }
}
