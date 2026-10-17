import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory root;
  late DeviceIdentity alice;
  late DeviceIdentity bob;
  late TransferServer server;
  late TransferClient client;
  late Directory received;

  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('dukto2-tests-');
    alice = await DeviceIdentity.loadOrCreate(
      Directory(p.join(root.path, 'alice')),
    );
    bob = await DeviceIdentity.loadOrCreate(
      Directory(p.join(root.path, 'bob')),
    );
  });
  tearDownAll(() async => root.delete(recursive: true));
  setUp(() async {
    received = await Directory(p.join(root.path, randomId(4))).create();
    server = TransferServer(
      identity: bob,
      name: 'Bob Android',
      receiveDirectory: received,
      onOffer: (_) async => true,
      bindAddress: InternetAddress.loopbackIPv4,
    );
    await server.start();
    client = TransferClient();
  });
  tearDown(() async {
    await client.close();
    await server.close();
  });

  Future<File> fixture(String name, List<int> bytes) async =>
      File(p.join(root.path, name)).writeAsBytes(bytes, flush: true);

  HttpClient pinnedClient() =>
      HttpClient(context: SecurityContext(withTrustedRoots: false))
        ..findProxy = ((_) => 'DIRECT')
        ..badCertificateCallback = (certificate, _, _) =>
            sha256.convert(certificate.der).toString() == bob.fingerprint;

  Uri url(String path) =>
      Uri(scheme: 'https', host: '127.0.0.1', port: server.port, path: path);

  Future<(int, Map<String, dynamic>)> post(
    HttpClient http,
    String path,
    Map<String, Object> body,
  ) async {
    final request = await http.postUrl(url(path));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    return (
      response.statusCode,
      jsonDecode(await utf8.decoder.bind(response).join())
          as Map<String, dynamic>,
    );
  }

  test('identity persists and exposes only public fingerprint', () async {
    final loaded = await DeviceIdentity.loadOrCreate(
      Directory(p.join(root.path, 'alice')),
    );
    expect(loaded.fingerprint, alice.fingerprint);
    expect(loaded.id, alice.id);
    expect(alice.fingerprint, isNot(bob.fingerprint));
    expect(alice.code.length, 19);
  });

  test(
    'manual probe binds advertised identity to observed TLS certificate',
    () async {
      final peer = await TransferClient.probe('127.0.0.1', server.port);
      expect(peer.id, bob.id);
      expect(peer.fingerprint, bob.fingerprint);
    },
  );

  for (final size in [0, 31, 3 * 1024 * 1024 + 17]) {
    test(
      'TLS upload and checked commit preserve $size bytes and Unicode name',
      () async {
        final bytes = List<int>.generate(size, (index) => (index * 17) % 256);
        final file = await fixture('测试 $size.bin', bytes);
        final completed = server.received.first;
        final sent = await client.sendFile(
          peer: server.localPeer,
          file: file,
          sender: 'Alice macOS',
        );
        final receipt = await completed;
        expect(receipt.file, isNotNull);
        expect(await receipt.file!.readAsBytes(), bytes);
        expect(receipt.sha256, sha256.convert(bytes).toString());
        expect(sent.sha256, receipt.sha256);
        expect(receipt.file!.path, startsWith(received.path));
        expect(
          await File(p.join(receipt.file!.parent.path, '.partial')).exists(),
          isFalse,
        );
      },
    );
  }

  test('platform file streams work without any local file path', () async {
    final bytes = List<int>.generate(65537, (index) => index % 256);
    final completed = server.received.first;
    final sent = await client.sendStream(
      peer: server.localPeer,
      sender: 'Android SAF',
      name: 'stream.dat',
      size: bytes.length,
      openRead: () =>
          Stream.fromIterable([bytes.sublist(0, 99), bytes.sublist(99)]),
    );
    final receipt = await completed;
    expect(await receipt.file!.readAsBytes(), bytes);
    expect(sent.sha256, sha256.convert(bytes).toString());
  });

  test(
    'restart removes abandoned staging data and preserves committed files',
    () async {
      await server.close();
      final abandoned = await Directory(
        p.join(received.path, randomId()),
      ).create();
      await File(
        p.join(abandoned.path, '.partial'),
      ).writeAsString('unfinished');
      final finished = await Directory(
        p.join(received.path, randomId()),
      ).create();
      await File(p.join(finished.path, 'kept.txt')).writeAsString('complete');
      server = TransferServer(
        identity: bob,
        name: 'Bob',
        receiveDirectory: received,
        onOffer: (_) async => true,
        bindAddress: InternetAddress.loopbackIPv4,
      );
      await server.start();
      expect(await abandoned.exists(), isFalse);
      expect(
        await File(p.join(finished.path, 'kept.txt')).readAsString(),
        'complete',
      );
    },
  );

  test('same filenames never overwrite previous transfers', () async {
    final file = await fixture('same.txt', [1]);
    final paths = <String>[];
    final subscription = server.received.listen(
      (receipt) => paths.add(receipt.file!.path),
    );
    for (var i = 0; i < 2; i++) {
      await client.sendFile(
        peer: server.localPeer,
        file: file,
        sender: 'Alice',
      );
    }
    expect(paths.length, 2);
    expect(paths[0], isNot(paths[1]));
    await subscription.cancel();
  });

  test('TLS rejects a changed fingerprint before sending an offer', () async {
    final wrong = Peer(
      id: bob.id,
      name: 'Bob',
      host: '127.0.0.1',
      port: server.port,
      fingerprint: alice.fingerprint,
    );
    final file = await fixture('pin.txt', [1, 2, 3]);
    await expectLater(
      client.sendFile(peer: wrong, file: file, sender: 'Alice'),
      throwsA(isA<HandshakeException>()),
    );
    expect(await received.list().toList(), isEmpty);
  });

  test('receiver refusal transfers no bytes', () async {
    await server.close();
    server = TransferServer(
      identity: bob,
      name: 'Bob',
      receiveDirectory: received,
      onOffer: (_) async => false,
      bindAddress: InternetAddress.loopbackIPv4,
    );
    await server.start();
    final file = await fixture('rejected.txt', [7]);
    await expectLater(
      client.sendFile(peer: server.localPeer, file: file, sender: 'Alice'),
      throwsA(isA<HttpException>()),
    );
    expect(await received.list().toList(), isEmpty);
  });

  test(
    'malicious paths, reserved names and invalid sizes are rejected',
    () async {
      final http = pinnedClient();
      addTearDown(() => http.close(force: true));
      for (final name in [
        '../escape',
        '/absolute',
        r'C:\escape',
        '.',
        '..',
        'NUL.txt',
        'CON',
        'a\u0000.txt',
        'x/../y',
      ]) {
        final (status, _) = await post(http, '/v1/offer', {
          'sender': 'Mallory',
          'name': name,
          'size': 1,
        });
        expect(status, 400, reason: name);
      }
      final (status, _) = await post(http, '/v1/offer', {
        'sender': 'Mallory',
        'name': 'valid',
        'size': -1,
      });
      expect(status, 400);
      expect(await received.list().toList(), isEmpty);
    },
  );

  test('incorrect checksum discards the staged file', () async {
    final http = pinnedClient();
    addTearDown(() => http.close(force: true));
    final (_, offer) = await post(http, '/v1/offer', {
      'sender': 'Alice',
      'name': 'file.bin',
      'size': 3,
    });
    final id = offer['token'];
    final request = await http.putUrl(url('/v1/file/$id'));
    request.contentLength = 3;
    request.add([1, 2, 3]);
    final response = await request.close();
    expect(response.statusCode, 200);
    await response.drain<void>();
    expect(
      await received.list(recursive: true).length,
      2,
    ); // directory + staged file
    final (status, _) = await post(http, '/v1/commit/$id', {
      'sha256': 'incorrect',
    });
    expect(status, 422);
    expect(await received.list().toList(), isEmpty);
  });

  test('concurrent offers cannot hijack an approved transfer', () async {
    final http = pinnedClient();
    addTearDown(() => http.close(force: true));
    final (first, offer) = await post(http, '/v1/offer', {
      'sender': 'Alice',
      'name': 'a.txt',
      'size': 0,
    });
    expect(first, 200);
    final (second, _) = await post(http, '/v1/offer', {
      'sender': 'Mallory',
      'name': 'b.txt',
      'size': 0,
    });
    expect(second, 409);
    final request = await http.deleteUrl(url('/v1/file/${offer['token']}'));
    await (await request.close()).drain<void>();
    expect(await received.list().toList(), isEmpty);
  });

  test('mid-stream cancellation never publishes a partial file', () async {
    final file = await fixture(
      'cancel.bin',
      List<int>.generate(16 * 1024 * 1024, (index) => index % 256),
    );
    final cancellation = CancellationToken();
    var receiptCount = 0;
    final receivedSubscription = server.received.listen((_) => receiptCount++);
    final progressSubscription = client.progress.listen((event) {
      if (event.bytes > 65536) cancellation.cancel();
    });
    await expectLater(
      client.sendFile(
        peer: server.localPeer,
        file: file,
        sender: 'Alice',
        cancellation: cancellation,
      ),
      throwsA(isA<TransferCancelled>()),
    );
    // Allow the disconnected server handler to unwind and delete its temporary file.
    for (var i = 0; i < 50 && await received.list().isEmpty == false; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    expect(receiptCount, 0);
    expect(await received.list().toList(), isEmpty);
    await progressSubscription.cancel();
    await receivedSubscription.cancel();
  });

  test(
    'UDP discovery accepts a real announcement and ignores malformed packets',
    () async {
      final reserve = await RawDatagramSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final port = reserve.port;
      reserve.close();
      final remote = TransferServer(
        identity: alice,
        name: 'Alice',
        receiveDirectory: Directory(p.join(root.path, randomId())),
        onOffer: (_) async => false,
        bindAddress: InternetAddress.loopbackIPv4,
      );
      await remote.start();
      final discovery = PeerDiscovery(
        server.localPeer,
        port: port,
        subnetFallback: false,
      );
      await discovery.start();
      final udp = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
      try {
        final found = discovery.changes.first;
        udp.send([0xff], InternetAddress.loopbackIPv4, port);
        udp.send(
          utf8.encode(
            jsonEncode({
              'app': 'dukto2',
              ...Peer(
                id: alice.id,
                name: 'Alice',
                host: '127.0.0.1',
                port: remote.port,
                fingerprint: alice.fingerprint,
              ).toJson(),
            }),
          ),
          InternetAddress.loopbackIPv4,
          port,
        );
        final peers = await found.timeout(const Duration(seconds: 3));
        expect(peers.single.id, alice.id);
        expect(peers.single.host, '127.0.0.1');
        expect(peers.single.fingerprint, alice.fingerprint);
        // Rebinding after resume preserves the stream and can discover again.
        await discovery.refresh(force: true);
        final refreshed = discovery.changes.first;
        udp.send(
          utf8.encode(
            jsonEncode({'app': 'dukto2', ...remote.localPeer.toJson()}),
          ),
          InternetAddress.loopbackIPv4,
          port,
        );
        expect(
          (await refreshed.timeout(const Duration(seconds: 3))).single.id,
          alice.id,
        );
      } finally {
        udp.close();
        await discovery.close();
        await remote.close();
      }
    },
  );
}
