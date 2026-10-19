import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dukto2/src/controller.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

final class DiskFile extends PlatformFile {
  final File file;
  DiskFile(this.file);
  @override
  String get name => p.basename(file.path);
  @override
  Uri get uri => file.uri;
  @override
  Future<int?> length() => file.length();
  @override
  Stream<Uint8List> readAsByteStream() =>
      file.openRead().map(Uint8List.fromList);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class BatchController extends Dukto2Controller {
  BatchController({required super.filePicker});
  @override
  bool get ready => true;
}

class NetworkTestBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

class SlowCleanupReceiver extends BatchController {
  SlowCleanupReceiver() : super(filePicker: () async => []);
  @override
  Future<void> endTransferSession() =>
      Future<void>.delayed(const Duration(milliseconds: 100));
}

void main() {
  NetworkTestBinding();
  late Directory root;
  late DeviceIdentity identity;
  late TransferServer receiver;
  late BatchController sender;
  late List<PlatformFile> selection;
  late List<TransferReceipt> receipts;
  late StreamSubscription<TransferReceipt> subscription;
  late Future<bool> Function(FileOffer) approve;
  late Future<bool> Function(FileOffer) batchApproval;
  var batchPrompts = 0;
  final offers = <String>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('dukto2-batch-');
    identity = await DeviceIdentity.loadOrCreate(
      Directory(p.join(root.path, 'identity')),
    );
  });
  tearDownAll(() => root.delete(recursive: true));
  setUp(() async {
    offers.clear();
    batchPrompts = 0;
    receipts = [];
    selection = [];
    approve = (_) async => true;
    batchApproval = (_) async => true;
    receiver = TransferServer(
      identity: identity,
      name: 'Loopback receiver',
      receiveDirectory: Directory(p.join(root.path, randomId(4))),
      bindAddress: InternetAddress.loopbackIPv4,
      onOffer: (offer) async {
        if (offer.isBatch) {
          batchPrompts++;
          return batchApproval(offer);
        }
        offers.add(offer.name);
        return approve(offer);
      },
      onApprovedBatchFile: (offer) async {
        offers.add(offer.name);
        return approve(offer);
      },
    );
    await receiver.start();
    subscription = receiver.received.listen(receipts.add);
    sender = BatchController(filePicker: () async => selection)
      ..name = 'Loopback sender'
      ..selected = receiver.localPeer;
    messenger.setMockMethodCallHandler(
      Dukto2Controller.platform,
      (_) async => null,
    );
    for (final (name, bytes) in [
      ('一号.bin', [1, 2, 3]),
      ('empty.bin', <int>[]),
      ('third.bin', [9, 8, 7, 6]),
    ]) {
      selection.add(
        DiskFile(await File(p.join(root.path, name)).writeAsBytes(bytes)),
      );
    }
    await sender.pickFile();
  });
  tearDown(() async {
    await sender.shutdown();
    sender.dispose();
    await subscription.cancel();
    await receiver.close();
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, null);
  });

  test('multiple files stream in order with individual consent, receipts and timings', () async {
    final wall = Stopwatch()..start();
    var waitMicros = 0;
    approve = (_) async {
      expect(sender.busy, isTrue);
      final wait = Stopwatch()..start();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      waitMicros += wait.elapsedMicroseconds;
      return true;
    };
    await sender.sendFile();
    wall.stop();
    expect(sender.sendPhase, SendPhase.sent, reason: sender.error);
    expect(offers, selection.map((file) => file.name));
    expect(receipts, hasLength(3));
    expect(sender.history, hasLength(3));
    expect(sender.completedFiles, 3);
    expect(batchPrompts, 1);
    expect(sender.totalFileBytes, 7);
    var durationMicros = 0;
    for (final receipt in receipts) {
      final original =
          selection.firstWhere((file) => file.name == receipt.name) as DiskFile;
      expect(
        await receipt.file!.readAsBytes(),
        await original.file.readAsBytes(),
      );
      final entry = sender.history.firstWhere(
        (entry) => entry.receipt.name == receipt.name,
      );
      expect(entry.receipt.sha256, receipt.sha256);
      expect(entry.elapsed, isNotNull); // includes empty files
      durationMicros += entry.elapsed!.inMicroseconds;
    }
    expect(durationMicros, lessThan(wall.elapsedMicroseconds - waitMicros));
    await sender.sendFile();
    expect(
      offers,
      hasLength(3),
    ); // a completed batch is not accidentally resent
  });

  test(
    'consecutive files wait for receiver cleanup before asking consent again',
    () async {
      final controller = SlowCleanupReceiver();
      final finishes = <Future<void>>[];
      final received = receiver.received.listen((receipt) {
        finishes.add(controller.completeReceive(receipt));
      });
      controller.addListener(() {
        if (controller.pendingOffer != null) controller.answerOffer(true);
      });
      batchApproval = controller.receiveOffer;
      approve = controller.receiveApprovedBatchFile;
      try {
        await sender.sendFile();
        await Future.wait(finishes);
        expect(sender.sendPhase, SendPhase.sent, reason: sender.error);
        expect(controller.history, hasLength(3));
        expect(batchPrompts, 1);
      } finally {
        await received.cancel();
        await controller.shutdown();
        controller.dispose();
      }
    },
  );

  test('refusal stops the queue; retry sends only unfinished files', () async {
    approve = (offer) async => offer.name != 'empty.bin';
    await sender.sendFile();
    expect(sender.sendPhase, SendPhase.failed);
    expect(offers, ['一号.bin', 'empty.bin']);
    expect(sender.completedFiles, 1);
    expect(sender.history, hasLength(1));
    approve = (_) async => true;
    await sender.sendFile();
    expect(offers, ['一号.bin', 'empty.bin', 'empty.bin', 'third.bin']);
    expect(sender.completedFiles, 3);
    expect(receipts, hasLength(3));
  });

  test('cancel while waiting stops the remaining queue and preserves completed files', () async {
    approve = (offer) async {
      if (offer.name == 'empty.bin') {
        sender.cancelTransfer();
        return false;
      }
      return true;
    };
    await sender.sendFile();
    expect(sender.sendPhase, SendPhase.cancelled);
    expect(sender.busy, isFalse);
    expect(offers, ['一号.bin', 'empty.bin']);
    expect(sender.completedFiles, 1);
    expect(receipts, hasLength(1));
    approve = (_) async => true;
    await sender.sendFile();
    expect(receipts, hasLength(3));
  });

  test('cancelled selection retains queue; removing files and changing recipient reset correctly', () async {
    selection = [];
    await sender.pickFile();
    expect(sender.files, hasLength(3));
    sender.removeFile(1);
    expect(sender.files.map((item) => item.file.name), ['一号.bin', 'third.bin']);
    await sender.sendFile();
    expect(sender.completedFiles, 2);
    sender.select(
      Peer(
        id: 'new',
        name: 'New receiver',
        host: '127.0.0.1',
        port: receiver.port,
        fingerprint: identity.fingerprint,
      ),
    );
    expect(sender.completedFiles, 0);
    expect(sender.sendPhase, SendPhase.ready);
    expect(sender.fileIndex, 0);
  });
}
