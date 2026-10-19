import 'dart:io';

import 'package:dukto2/src/app_settings.dart';
import 'package:dukto2/src/controller.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class ReadyController extends Dukto2Controller {
  ReadyController({super.settingsStore});
  @override
  bool get ready => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  var systemName = '系统设备 🌍';
  setUp(() async {
    root = await Directory.systemTemp.createTemp('dukto2-settings-');
    calls.clear();
    systemName = '系统设备 🌍';
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, (call) async {
      calls.add(call);
      return switch (call.method) {
        'getDeviceName' => systemName,
        'notificationStatus' => 'notDetermined',
        'requestNotifications' => 'denied',
        _ => null,
      };
    });
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, null);
    await root.delete(recursive: true);
  });

  Future<void> close(Dukto2Controller c) async {
    await c.client.close();
    c.dispose();
  }

  test(
    'native device type distinguishes phones and tablets with a safe fallback',
    () async {
      final c = ReadyController();
      for (final (value, expected) in [
        ('phone', DeviceType.phone),
        ('tablet', DeviceType.tablet),
        ('computer', DeviceType.computer),
        ('future-device', DeviceType.hostPlatform),
      ]) {
        messenger.setMockMethodCallHandler(
          Dukto2Controller.platform,
          (call) async => call.method == 'getDeviceType' ? value : null,
        );
        expect(await c.readDeviceType(), expected);
      }
      messenger.setMockMethodCallHandler(Dukto2Controller.platform, (_) async {
        throw MissingPluginException();
      });
      expect(await c.readDeviceType(), DeviceType.hostPlatform);
      messenger.setMockMethodCallHandler(Dukto2Controller.platform, (_) async {
        throw PlatformException(code: 'UNAVAILABLE');
      });
      expect(await c.readDeviceType(), DeviceType.hostPlatform);
      await close(c);
    },
  );

  test(
    'settings persist and legacy custom names never override system names',
    () async {
      final first = ReadyController(settingsStore: SettingsStore(root));
      await SettingsStore(root).file.writeAsString('{"deviceName":"旧的自定义名"}');
      await first.loadSettings();
      expect(first.name, '系统设备 🌍');
      expect(await first.setAppearance(AppAppearance.dark), isTrue);
      expect(await first.setCompletionNotifications(false), isTrue);
      await close(first);
      final second = ReadyController(settingsStore: SettingsStore(root));
      await second.loadSettings();
      expect(second.name, '系统设备 🌍');
      expect(second.settings.appearance, AppAppearance.dark);
      expect(second.settings.completionNotifications, isFalse);
      systemName = '系统设备已更新';
      await second.refreshSystemSettings();
      expect(second.name, systemName);
      expect(
        (await SettingsStore(root).load()).toJson().containsKey('deviceName'),
        isFalse,
      );
      await close(second);
    },
  );

  test('corrupt and unknown preferences recover safely', () async {
    final store = SettingsStore(root);
    await store.file.writeAsString('{bad json');
    expect((await store.load()).appearance, AppAppearance.system);
    await store.file.writeAsString(
      '{"deviceName":"x\\ny","appearance":"unknown","completionNotifications":"yes"}',
    );
    final loaded = await store.load();
    expect(loaded.appearance, AppAppearance.system);
    expect(loaded.completionNotifications, isTrue);
  });

  test(
    'failed preference write does not change UI state and can retry',
    () async {
      final blocked = File('${root.path}/blocked');
      await blocked.writeAsString('owned test fixture');
      final c = ReadyController(
        settingsStore: SettingsStore(Directory(blocked.path)),
      );
      await c.loadSettings();
      expect(await c.setAppearance(AppAppearance.dark), isFalse);
      expect(c.settings.appearance, AppAppearance.system);
      expect(c.settingsError, isNotNull);
      await blocked.delete();
      expect(await c.setAppearance(AppAppearance.dark), isTrue);
      expect(c.settings.appearance, AppAppearance.dark);
      await close(c);
    },
  );

  test('disabled completion alerts stay quiet and permission failure cannot fail receipt', () async {
    final c = ReadyController(settingsStore: SettingsStore(root));
    await c.loadSettings();
    const receipt = TransferReceipt(
      name: 'private-name.txt',
      size: 3,
      sha256: 'abc',
      text: 'secret text',
    );
    await c.setCompletionNotifications(false);
    await c.notifyCompletion(receipt, incoming: true);
    expect(calls.where((call) => call.method == 'notifyComplete'), isEmpty);
    await c.setCompletionNotifications(true);
    expect(c.notificationPermission, 'denied');
    await c.notifyCompletion(receipt, incoming: true);
    final payload = calls.last.arguments as Map;
    expect(payload['body'], c.strings.receivedVerified(c.strings.text));
    expect(payload.values.join(), isNot(contains('secret')));
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, (_) async {
      throw PlatformException(code: 'DENIED');
    });
    await c.notifyCompletion(receipt, incoming: false);
    expect(c.error, isNull);
    await close(c);
  });
}
