import 'package:dukto2/src/controller.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const offer = FileOffer(sender: '测试设备', name: 'test.bin', size: 1);

  setUp(() {
    messenger.setMockMethodCallHandler(
      Dukto2Controller.platform,
      (_) async => null,
    );
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, null);
  });

  testWidgets('a request can still be accepted after four minutes', (
    tester,
  ) async {
    final controller = (await tester.runAsync(() async => Dukto2Controller()))!;
    addTearDown(() async {
      await controller.shutdown();
      controller.dispose();
    });
    bool? accepted;
    controller.receiveOffer(offer).then((value) => accepted = value);
    await tester.pump(const Duration(minutes: 4));
    expect(controller.pendingOffer, same(offer));
    controller.answerOffer(true);
    await tester.pump();
    expect(accepted, isTrue);
  });

  testWidgets('an unanswered request expires at five minutes', (tester) async {
    final controller = (await tester.runAsync(() async => Dukto2Controller()))!;
    addTearDown(() async {
      await controller.shutdown();
      controller.dispose();
    });
    bool? accepted;
    controller.receiveOffer(offer).then((value) => accepted = value);
    await tester.pump(const Duration(minutes: 4, seconds: 59));
    expect(controller.pendingOffer, same(offer));
    await tester.pump(const Duration(seconds: 1));
    expect(accepted, isFalse);
    expect(controller.pendingOffer, isNull);
    expect(controller.receiving, isFalse);
  });
}
