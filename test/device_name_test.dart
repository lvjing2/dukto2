import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dukto2/src/controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(
    () => messenger.setMockMethodCallHandler(Dukto2Controller.platform, null),
  );
  test(
    'uses the platform configured Unicode name rather than an identity suffix',
    () async {
      messenger.setMockMethodCallHandler(Dukto2Controller.platform, (
        call,
      ) async {
        expect(call.method, 'getDeviceName');
        return '  我的工作电脑 🖥️  ';
      });
      final controller = Dukto2Controller();
      expect(await controller.readDeviceName(), '我的工作电脑 🖥️');
      await controller.client.close();
      controller.dispose();
    },
  );
  test('unavailable name bridge does not block app startup', () async {
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, (call) async {
      throw PlatformException(code: 'UNAVAILABLE');
    });
    final controller = Dukto2Controller();
    expect(await controller.readDeviceName(), isNotEmpty);
    await controller.client.close();
    controller.dispose();
  });
}
