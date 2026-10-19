import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dukto2_core/dukto2_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory root;
  late DeviceIdentity identity;
  late TransferServer server;
  late TransferClient client;
  late Peer peer;
  late List<FileOffer> consents;
  late List<TransferReceipt> received;
  late OfferHandler onConsent;
  late StreamSubscription<TransferReceipt> subscription;
  var accept = true;
  const sender = 'Batch sender';
  const files = [
    FileOffer(sender: sender, name: '中文.bin', size: 3),
    FileOffer(sender: sender, name: 'empty.bin', size: 0),
  ];
  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('dukto2-batch-core-');
    identity = await DeviceIdentity.loadOrCreate(
      Directory(p.join(root.path, 'identity')),
    );
  });
  tearDownAll(() => root.delete(recursive: true));
  setUp(() async {
    accept = true;
    consents = [];
    received = [];
    onConsent = (offer) async {
      consents.add(offer);
      return accept;
    };
    server = TransferServer(
      identity: identity,
      name: 'Receiver',
      receiveDirectory: Directory(p.join(root.path, randomId(4))),
      bindAddress: InternetAddress.loopbackIPv4,
      batchIdleTimeout: const Duration(milliseconds: 800),
      onOffer: (offer) => onConsent(offer),
    );
    await server.start();
    peer = server.localPeer;
    client = TransferClient();
    subscription = server.received.listen(received.add);
  });
  tearDown(() async {
    await client.close();
    await subscription.cancel();
    await server.close();
  });
  Future<String> approveBatch() =>
      client.offerBatch(peer: peer, sender: sender, files: files);
  Future<TransferReceipt> send(
    String batch,
    int index, {
    String? name,
    int? size,
    TransferKind kind = TransferKind.file,
    String from = sender,
    void Function()? opened,
  }) => client.sendStream(
    peer: peer,
    sender: from,
    name: name ?? files[index].name,
    size: size ?? files[index].size,
    kind: kind,
    batchToken: batch,
    batchIndex: index,
    openRead: () {
      opened?.call();
      return Stream.value(index == 0 ? [1, 2, 3] : <int>[]);
    },
  );

  test(
    'one consent displays exact manifest, then receives two checked files',
    () async {
      final batch = await approveBatch();
      expect(consents, hasLength(1));
      expect(consents.single.isBatch, isTrue);
      expect(consents.single.files.map((f) => f.name), ['中文.bin', 'empty.bin']);
      expect(consents.single.size, 3);
      expect(consents.single.remoteAddress, '127.0.0.1');
      await send(batch, 0);
      await send(batch, 1);
      expect(consents, hasLength(1));
      expect(received, hasLength(2));
      expect(await received.first.file!.readAsBytes(), [1, 2, 3]);
      expect(await received.last.file!.length(), 0);
      await expectLater(
        send(batch, 0),
        throwsA(
          isA<TransferFailure>().having(
            (f) => f.cause,
            'cause',
            isA<HttpException>(),
          ),
        ),
      );
      expect(consents, hasLength(1));
    },
  );

  test(
    'cancel while waiting revokes the pending batch request before approval',
    () async {
      final shown = Completer<void>();
      final approval = Completer<bool>();
      onConsent = (offer) {
        shown.complete();
        return approval.future;
      };
      final cancellation = CancellationToken();
      final future = client.offerBatch(
        peer: peer,
        sender: sender,
        files: files,
        cancellation: cancellation,
      );
      final check = expectLater(future, throwsA(isA<TransferCancelled>()));
      await shown.future;
      cancellation.cancel();
      await check;
      approval.complete(true); // a late UI response cannot create a grant
      onConsent = (offer) async {
        consents.add(offer);
        return true;
      };
      final fresh = await approveBatch();
      await send(fresh, 0);
      await send(fresh, 1);
      expect(received, hasLength(2));
    },
  );

  test('rejecting a batch never offers files or opens their streams', () async {
    accept = false;
    await expectLater(
      approveBatch(),
      throwsA(
        isA<TransferFailure>().having(
          (f) => f.cause,
          'cause',
          isA<HttpException>(),
        ),
      ),
    );
    expect(consents, hasLength(1));
    expect(received, isEmpty);
    expect(await server.receiveDirectory.list().toList(), isEmpty);
  });

  test(
    'authorization rejects changed names, sizes, sender, kind, wrong token, order and replay',
    () async {
      final batch = await approveBatch();
      var opened = false;
      for (final attempt in <Future<TransferReceipt> Function()>[
        () => send(batch, 0, name: 'extra.bin', opened: () => opened = true),
        () => send(batch, 0, size: 2, opened: () => opened = true),
        () => send(batch, 0, from: 'Other sender', opened: () => opened = true),
        () => send(
          batch,
          0,
          kind: TransferKind.text,
          opened: () => opened = true,
        ),
        () => send('0' * 48, 0, opened: () => opened = true),
        () => send(batch, 1, opened: () => opened = true),
      ]) {
        await expectLater(
          attempt(),
          throwsA(
            isA<TransferFailure>().having(
              (f) => f.cause,
              'cause',
              isA<HttpException>(),
            ),
          ),
        );
      }
      expect(opened, isFalse);
      await send(batch, 0);
      await expectLater(
        send(batch, 0),
        throwsA(
          isA<TransferFailure>().having(
            (f) => f.cause,
            'cause',
            isA<HttpException>(),
          ),
        ),
      );
      await send(batch, 1);
      expect(received, hasLength(2));
      expect(consents, hasLength(1));
    },
  );

  test(
    'sender and receiver cancellation both invalidate the remaining grant',
    () async {
      var batch = await approveBatch();
      await send(batch, 0);
      await client.cancelBatch(peer, batch);
      await expectLater(
        send(batch, 1),
        throwsA(
          isA<TransferFailure>().having(
            (f) => f.cause,
            'cause',
            isA<HttpException>(),
          ),
        ),
      );
      expect(received, hasLength(1));
      batch = await approveBatch();
      server.cancelIncoming();
      await expectLater(
        send(batch, 0),
        throwsA(
          isA<TransferFailure>().having(
            (f) => f.cause,
            'cause',
            isA<HttpException>(),
          ),
        ),
      );
      expect(consents, hasLength(2));
    },
  );

  test(
    'unused batch approval expires instead of accepting later files',
    () async {
      final batch = await approveBatch();
      await Future<void>.delayed(const Duration(milliseconds: 850));
      await expectLater(
        send(batch, 0),
        throwsA(
          isA<TransferFailure>().having(
            (f) => f.cause,
            'cause',
            isA<HttpException>(),
          ),
        ),
      );
      expect(received, isEmpty);
    },
  );

  test(
    'legacy peers get an explicit update error without a network offer',
    () async {
      final old = Peer(
        id: peer.id,
        name: peer.name,
        host: peer.host,
        port: peer.port,
        fingerprint: peer.fingerprint,
      );
      await expectLater(
        client.offerBatch(peer: old, sender: sender, files: files),
        throwsA(isA<FormatException>()),
      );
      expect(consents, isEmpty);
      expect(Peer.fromJson(peer.toJson(), peer.host).supportsBatch, isTrue);
    },
  );

  test(
    'manifest parser is bounded, file-only and uses the socket source address',
    () {
      Map<String, dynamic> body(List<Object?> items) => {
        'sender': sender,
        'files': items,
      };
      for (final items in <List<Object?>>[
        [],
        [files.first.toJson()],
        List.filled(1001, files.first.toJson()),
        [
          {'name': '../escape', 'size': 3},
          files.last.toJson(),
        ],
        [
          {'name': 'text', 'size': 3, 'kind': 'text'},
          files.last.toJson(),
        ],
      ]) {
        expect(
          () => batchOfferFromJson(body(items), '127.0.0.1'),
          throwsFormatException,
        );
      }
      final encoded =
          jsonDecode(jsonEncode(body(files.map((f) => f.toJson()).toList())))
              as Map<String, dynamic>;
      final offer = batchOfferFromJson({
        ...encoded,
        'remoteAddress': 'elsewhere',
      }, '127.0.0.1');
      expect(offer.files.every((f) => f.remoteAddress == '127.0.0.1'), isTrue);
    },
  );
}
