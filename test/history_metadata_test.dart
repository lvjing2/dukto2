import 'dart:convert';

import 'package:dukto2/src/controller.dart';
import 'package:dukto2/src/dashboard.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'history persists completion time and elapsed; legacy records stay unknown',
    () {
      final entry = HistoryEntry(
        const TransferReceipt(name: 'a.bin', size: 1, sha256: 'abc'),
        false,
        time: DateTime(2026, 10, 18, 16, 5),
        elapsed: const Duration(milliseconds: 1234),
      );
      final restored = HistoryEntry.fromJson(
        jsonDecode(jsonEncode(entry.toJson())) as Map<String, dynamic>,
      );
      expect(restored.time, entry.time);
      expect(restored.elapsed, entry.elapsed);
      final legacy = entry.toJson()..remove('elapsedMs');
      expect(HistoryEntry.fromJson(legacy).elapsed, isNull);
      expect(
        HistoryEntry.fromJson({...legacy, 'elapsedMs': -1}).elapsed,
        isNull,
      );
    },
  );

  test('local dates handle midnight, year boundaries and UTC timestamps', () {
    final today = DateTime(2026, 1, 1, 0, 1);
    expect(
      formatHistoryTime(DateTime(2026, 1, 1, 0, 0), now: today),
      '今天 00:00',
    );
    expect(
      formatHistoryTime(DateTime(2025, 12, 31, 23, 59), now: today),
      '昨天 23:59',
    );
    expect(
      formatHistoryTime(DateTime(2025, 12, 30, 12, 5), now: today),
      '2025/12/30 12:05',
    );
    final summer = DateTime(2026, 7, 5, 12);
    expect(
      formatHistoryTime(DateTime(2026, 6, 5, 9, 8).toUtc(), now: summer),
      '06/05 09:08',
    );
  });

  test('elapsed labels cover subsecond, minute and hour transfers', () {
    expect(formatElapsed(Duration.zero), '小于 1 秒');
    expect(formatElapsed(const Duration(milliseconds: 1250)), '1.3 秒');
    expect(formatElapsed(const Duration(seconds: 65)), '1 分 5 秒');
    expect(formatElapsed(const Duration(seconds: 3723)), '1 小时 2 分 3 秒');
  });
}
