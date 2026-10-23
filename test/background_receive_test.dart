import 'dart:async';

import 'package:dukto2/src/background_receive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('background-receive-test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  var permission = true;
  var shown = true;
  var disabled = 0;
  setUp(() {
    calls.clear();
    permission = true;
    shown = true;
    disabled = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'backgroundReceiveStatus' => permission,
        'showReceiveRequest' => shown,
        _ => null,
      };
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  BackgroundReceive make({Duration duration = const Duration(minutes: 30)}) =>
      BackgroundReceive(
        channel: channel,
        onDisabled: () => disabled++,
        duration: duration,
      );

  test('default off, no implicit platform start, new runtime does not remember opt-in', () async {
    final first = make();
    expect(first.enabled, false);
    expect(calls, isEmpty);
    await first.setEnabled(true);
    await first.close();
    final next = make();
    expect(next.enabled, false);
    await next.close();
  });
  test(
    'notification permission or channel denied never starts service',
    () async {
      permission = false;
      final c = make();
      expect(await c.setEnabled(true), false);
      expect(c.unavailable, true);
      expect(calls.where((c) => c.method == 'startBackgroundReceive'), isEmpty);
      await c.close();
    },
  );
  test('revoked request notification disables reception without retaining stale ID', () async {
    final c = make();
    await c.setEnabled(true);
    shown = false;
    expect(await c.notifyRequest('0123456789abcdef'), false);
    expect(c.enabled, false);
    expect(c.matchesRequest('0123456789abcdef'), false);
    expect(calls.any((c) => c.method == 'stopBackgroundReceive'), true);
    await c.close();
  });
  test('old cleanup cannot clear newer pending request', () async {
    final c = make();
    await c.setEnabled(true);
    await c.notifyRequest('0123456789abcdef');
    await c.notifyRequest('fedcba9876543210');
    final before = calls.length;
    await c.clearRequest('0123456789abcdef');
    expect(calls.length, before);
    expect(c.matchesRequest('fedcba9876543210'), true);
    await c.clearRequest('fedcba9876543210');
    expect(c.matchesRequest('fedcba9876543210'), false);
    await c.close();
  });
  test('expiry rejects stale notification and retains approved transfer until done', () async {
    final c = make(duration: const Duration(milliseconds: 40));
    await c.setEnabled(true);
    await c.notifyRequest('0123456789abcdef');
    await c.setBusy(true);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(c.enabled, false);
    expect(c.matchesRequest('0123456789abcdef'), false);
    expect(calls.where((c) => c.method == 'stopBackgroundReceive'), isEmpty);
    await c.setBusy(false);
    expect(calls.where((c) => c.method == 'stopBackgroundReceive').length, 1);
    await c.close();
  });
  test(
    'expired clock rejects a notification even before delayed timer dispatch',
    () async {
      var now = DateTime(2026);
      final c = BackgroundReceive(
        channel: channel,
        onDisabled: () => disabled++,
        duration: const Duration(minutes: 30),
        clock: () => now,
      );
      await c.setEnabled(true);
      await c.notifyRequest('0123456789abcdef');
      now = now.add(const Duration(minutes: 31));
      expect(c.matchesRequest('0123456789abcdef'), false);
      expect(await c.notifyRequest('fedcba9876543210'), false);
      await c.refreshPermission();
      expect(calls.any((c) => c.method == 'stopBackgroundReceive'), true);
      await c.close();
    },
  );
  test('timer actually ends waiting and removes notification', () async {
    final c = make(duration: const Duration(milliseconds: 40));
    await c.setEnabled(true);
    await c.notifyRequest('0123456789abcdef');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(c.enabled, false);
    expect(c.matchesRequest('0123456789abcdef'), false);
    expect(calls.any((c) => c.method == 'clearReceiveRequest'), true);
    await c.close();
  });
  test(
    'switch off while native start is pending cannot resurrect wait',
    () async {
      final starting = Completer<void>();
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'backgroundReceiveStatus') return true;
        if (call.method == 'startBackgroundReceive') await starting.future;
        return null;
      });
      final c = make();
      final on = c.setEnabled(true);
      while (!calls.any((c) => c.method == 'startBackgroundReceive')) {
        await Future<void>.delayed(Duration.zero);
      }
      final off = c.setEnabled(false);
      starting.complete();
      await on;
      await off;
      expect(c.enabled, false);
      expect(c.changing, false);
      expect(calls.any((c) => c.method == 'stopBackgroundReceive'), true);
      await c.close();
    },
  );
  test(
    'native stop failure does not fail an approved transfer cleanup',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'backgroundReceiveStatus') return true;
        if (call.method == 'stopBackgroundReceive') {
          throw PlatformException(code: 'STOPPED');
        }
        return null;
      });
      final c = make();
      await c.setEnabled(true);
      await c.setBusy(true);
      await c.setEnabled(false);
      await c.setBusy(false);
      expect(c.enabled, false);
      expect(c.unavailable, true);
      await c.close();
    },
  );
  test('resume detects permission revocation and ends wait', () async {
    final c = make();
    await c.setEnabled(true);
    permission = false;
    await c.refreshPermission();
    expect(c.enabled, false);
    expect(disabled, greaterThan(0));
    await c.close();
  });
}
