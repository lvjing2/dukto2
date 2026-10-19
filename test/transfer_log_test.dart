import 'dart:convert';
import 'dart:io';

import 'package:dukto2/src/transfer_log.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('dukto2-log-');
  });
  tearDown(() => root.delete(recursive: true));
  TransferLogEntry entry() => TransferLogEntry(
    operationId: 'diagnostic-id',
    incoming: false,
    stage: TransferStage.upload,
    event: TransferLogEvent.stageChanged,
  );
  test('JSON lines rotate into exactly two bounded files', () async {
    final log = TransferLogWriter(root, maxBytes: 350);
    for (var i = 0; i < 8; i++) {
      log.add(entry());
    }
    await log.close();
    final files = await log.file.parent.list().where((f) => f is File).toList();
    expect(files, hasLength(2));
    for (final f in files.cast<File>()) {
      expect(await f.length(), lessThanOrEqualTo(350));
      for (final line in await f.readAsLines()) {
        expect((jsonDecode(line) as Map)['stage'], 'upload');
      }
    }
    expect(log.lastWriteError, isNull);
  });
  test(
    'a blocked log directory is best effort and does not throw to its caller',
    () async {
      await File('${root.path}/diagnostics').writeAsString('occupied');
      final log = TransferLogWriter(root);
      log.add(entry());
      await log.close();
      expect(log.lastWriteError, isA<FileSystemException>());
    },
  );
  test(
    'the pending queue is bounded and shutdown flushes accepted entries',
    () async {
      final log = TransferLogWriter(root, maxPending: 2);
      for (var i = 0; i < 20; i++) {
        log.add(entry());
      }
      await log.close();
      expect(await log.file.readAsLines(), hasLength(2));
      expect(log.droppedEntries, 18);
    },
  );
}
