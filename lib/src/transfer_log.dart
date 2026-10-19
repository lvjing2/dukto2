import 'dart:convert';
import 'dart:io';

import 'package:dukto2_core/dukto2_core.dart';

/// A bounded, best-effort local journal. Disk failures never fail a transfer.
/// Only two log files and a bounded number of queued entries are retained.
class TransferLogWriter {
  final File file;
  final int maxBytes;
  final int maxPending;
  int _pending = 0;
  int droppedEntries = 0;
  bool _closed = false;
  Object? lastWriteError;
  Future<void> _writes = Future.value();
  TransferLogWriter(
    Directory support, {
    this.maxBytes = 512 * 1024,
    this.maxPending = 200,
  }) : file = File(
         '${support.path}${Platform.pathSeparator}diagnostics${Platform.pathSeparator}transfers.jsonl',
       );

  void add(TransferLogEntry entry) {
    if (_closed || _pending >= maxPending) {
      droppedEntries++;
      return;
    }
    final line = '${jsonEncode(entry.toJson())}\n';
    if (utf8.encode(line).length > maxBytes) {
      droppedEntries++;
      return;
    }
    _pending++;
    _writes = _writes
        .then((_) async {
          await file.parent.create(recursive: true);
          if (await file.exists() &&
              await file.length() + utf8.encode(line).length > maxBytes) {
            final old = File('${file.path}.1');
            if (await old.exists()) await old.delete();
            await file.rename(old.path);
          }
          await file.writeAsString(line, mode: FileMode.append);
        })
        .catchError((Object error) {
          lastWriteError = error;
        })
        .whenComplete(() => _pending--);
  }

  Future<void> close() async {
    _closed = true;
    await _writes;
  }
}
