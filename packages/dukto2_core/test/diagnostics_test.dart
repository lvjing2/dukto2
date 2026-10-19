import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dukto2_core/dukto2_core.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:test/test.dart';

void main() {
  test(
    'diagnostics are bounded and never serialize payloads or capability URLs',
    () async {
      final logs = TransferDiagnostics(capacity: 3);
      final op = logs.begin(incoming: false);
      const secret = '/private/secret.txt?token=do-not-record-this';
      final cause = HttpException(secret);
      final stack = StackTrace.fromString('frame.dart:12');
      op.move(TransferStage.upload);
      final failure = op.fail(cause, stack);
      op.cleanupFailed(StateError(secret), stack);
      expect(logs.entries, hasLength(3));
      expect(identical(failure.cause, cause), isTrue);
      expect(identical(failure.stackTrace, stack), isTrue);
      expect(failure.stage, TransferStage.upload);
      expect(op.id, hasLength(16)); // distinct from 48-character upload grants
      final encoded = jsonEncode(logs.entries.map((e) => e.toJson()).toList());
      expect(encoded, isNot(contains(secret)));
      expect(encoded, contains('cleanupFailed'));
      expect(() => logs.entries.clear(), throwsUnsupportedError);
      await logs.close();
    },
  );

  test(
    'failure classification retains the original phase and reason',
    () async {
      final logs = TransferDiagnostics();
      for (final (error, kind) in <(Object, TransferFailureKind)>[
        (TimeoutException('private'), TransferFailureKind.timeout),
        (const SocketException('private'), TransferFailureKind.network),
        (const HandshakeException('private'), TransferFailureKind.certificate),
        (const FileSystemException('private'), TransferFailureKind.storage),
        (TransferCancelled(), TransferFailureKind.cancelled),
      ]) {
        final op = logs.begin(incoming: true)..move(TransferStage.upload);
        final failure = op.fail(error, StackTrace.current);
        expect(failure.kind, kind);
        expect(failure.stage, TransferStage.upload);
        expect(identical(failure.cause, error), isTrue);
      }
      await logs.close();
    },
  );

  test(
    'a cleanup error cannot replace the original receiver write failure',
    () async {
      final dir = await Directory.systemTemp.createTemp('dukto2-diagnostics-');
      final identity = await DeviceIdentity.loadOrCreate(
        Directory('${dir.path}/identity'),
      );
      final target = BrokenTarget();
      final server = TransferServer(
        identity: identity,
        name: 'Receiver',
        receiveDirectory: Directory('${dir.path}/received'),
        onOffer: (_) async => true,
        createTarget: (_, _) async => target,
        bindAddress: InternetAddress.loopbackIPv4,
      );
      final client = TransferClient();
      await server.start();
      try {
        final failed = server.errors.first;
        await expectLater(
          client.sendStream(
            peer: server.localPeer,
            name: 'private-name.bin',
            size: 3,
            openRead: () => Stream.value([1, 2, 3]),
            sender: 'Sender',
          ),
          throwsA(isA<TransferFailure>()),
        );
        final failure = await failed;
        expect(failure.kind, TransferFailureKind.storage);
        expect(failure.stage, TransferStage.storage);
        expect(identical(failure.cause, target.primary), isTrue);
        expect(target.discards, 1);
        expect(
          server.diagnostics.entries.where(
            (e) => e.event == TransferLogEvent.cleanupFailed,
          ),
          isNotEmpty,
        );
        final data = jsonEncode(
          server.diagnostics.entries.map((e) => e.toJson()).toList(),
        );
        expect(data, isNot(contains('private-name.bin')));
        expect(data, isNot(contains('secret-path')));
      } finally {
        await client.close();
        await server.close();
        await dir.delete(recursive: true);
      }
    },
  );

  test(
    'a malformed unrelated offer is logged without terminating an approved batch',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'dukto2-request-scope-',
      );
      final identity = await DeviceIdentity.loadOrCreate(
        Directory('${root.path}/identity'),
      );
      final server = TransferServer(
        identity: identity,
        name: 'Receiver',
        receiveDirectory: Directory('${root.path}/received'),
        onOffer: (_) async => true,
        bindAddress: InternetAddress.loopbackIPv4,
      );
      final client = TransferClient();
      await server.start();
      final errors = <TransferFailure>[];
      final subscription = server.errors.listen(errors.add);
      final http = HttpClient(context: SecurityContext(withTrustedRoots: false))
        ..findProxy = ((_) => 'DIRECT')
        ..badCertificateCallback = ((cert, _, _) =>
            crypto.sha256.convert(cert.der).toString() == identity.fingerprint);
      try {
        final token = await client.offerBatch(
          peer: server.localPeer,
          sender: 'Sender',
          files: [
            const FileOffer(sender: 'Sender', name: 'good.bin', size: 3),
            const FileOffer(sender: 'Sender', name: 'empty.bin', size: 0),
          ],
        );
        final request = await http.postUrl(
          Uri(
            scheme: 'https',
            host: '127.0.0.1',
            port: server.port,
            path: '/v1/offer',
          ),
        );
        request.headers.contentType = ContentType.json;
        request.write('{bad');
        final response = await request.close();
        expect(response.statusCode, 400);
        await response.drain<void>();
        await Future<void>.delayed(Duration.zero);
        expect(errors, isEmpty);
        expect(
          server.diagnostics.entries.any(
            (e) => e.failure?.kind == TransferFailureKind.invalidData,
          ),
          isTrue,
        );
        final received = server.received.first;
        await client.sendStream(
          peer: server.localPeer,
          name: 'good.bin',
          size: 3,
          openRead: () => Stream.value([1, 2, 3]),
          sender: 'Sender',
          batchToken: token,
          batchIndex: 0,
        );
        expect(await (await received).file!.readAsBytes(), [1, 2, 3]);
        expect(errors, isEmpty);
      } finally {
        http.close(force: true);
        await subscription.cancel();
        await client.close();
        await server.close();
        await root.delete(recursive: true);
      }
    },
  );
}

class BrokenTarget implements ReceiveTarget {
  final primary = const FileSystemException('write failed', '/secret-path');
  int discards = 0;
  @override
  Future<void> addStream(Stream<List<int>> source) async {
    await source.drain<void>();
    throw primary;
  }

  @override
  Future<void> close() async => throw StateError('secondary close failure');
  @override
  Future<void> discard() async {
    discards++;
    throw StateError('secondary discard failure');
  }

  @override
  Future<TransferReceipt> commit(FileOffer offer, String sha256) async =>
      throw StateError('must not commit');
}
