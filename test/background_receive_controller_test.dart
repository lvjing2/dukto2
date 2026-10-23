import 'package:dukto2/src/controller.dart';
import 'package:dukto2/src/settings_page.dart';
import 'package:dukto2/src/localization.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class AndroidController extends Dukto2Controller {
  @override
  String get operatingSystem => 'android';
  @override
  bool get ready => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  var permission = true;
  var requestShown = true;
  final calls = <MethodCall>[];
  const offer = FileOffer(
    sender: 'Untrusted device name',
    name: 'test.bin',
    size: 3,
  );
  setUp(() {
    permission = true;
    requestShown = true;
    calls.clear();
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, (call) async {
      calls.add(call);
      return switch (call.method) {
        'backgroundReceiveStatus' => permission,
        'showReceiveRequest' => requestShown,
        _ => null,
      };
    });
  });
  tearDown(
    () => messenger.setMockMethodCallHandler(Dukto2Controller.platform, null),
  );
  Future<void> close(AndroidController c) async {
    await c.shutdown();
    c.dispose();
  }

  test('background opt-out rejects new offer but foreground still asks for consent', () async {
    final c = AndroidController();
    await c.setAppVisible(false);
    expect(await c.receiveOffer(offer), false);
    expect(c.pendingOffer, isNull);
    await c.setAppVisible(true);
    final pending = c.receiveOffer(offer);
    await Future<void>.delayed(Duration.zero);
    expect(c.pendingOffer, same(offer));
    c.answerOffer(false);
    expect(await pending, false);
    await close(c);
  });
  test('background notification never approves; switching off declines current offer', () async {
    final c = AndroidController();
    await c.setBackgroundReceiving(true);
    await c.setAppVisible(false);
    var settled = false;
    final pending = c.receiveOffer(offer).then((v) {
      settled = true;
      return v;
    });
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(settled, false);
    expect(c.pendingOffer, same(offer));
    expect(calls.any((c) => c.method == 'showReceiveRequest'), true);
    await c.setBackgroundReceiving(false);
    expect(await pending, false);
    expect(c.pendingOffer, isNull);
    await close(c);
  });
  test('request-channel denial rejects offer and stops waiting', () async {
    final c = AndroidController();
    await c.setBackgroundReceiving(true);
    await c.setAppVisible(false);
    requestShown = false;
    expect(await c.receiveOffer(offer), false);
    expect(c.backgroundReceive.enabled, false);
    expect(c.pendingOffer, isNull);
    await close(c);
  });
  test('permission revocation on resume declines background request without auto approval', () async {
    final c = AndroidController();
    await c.setBackgroundReceiving(true);
    await c.setAppVisible(false);
    final pending = c.receiveOffer(offer);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    permission = false;
    await c.backgroundReceive.refreshPermission();
    expect(await pending, false);
    expect(c.backgroundReceive.enabled, false);
    await close(c);
  });
  testWidgets(
    'Android settings switch defaults off and permission denial explains failure',
    (tester) async {
      final c = (await tester.runAsync(() async => AndroidController()))!;
      permission = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: SettingsPage(controller: c),
        ),
      );
      final toggle = find.byKey(const ValueKey('background-receive-switch'));
      await tester.scrollUntilVisible(
        toggle,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<SwitchListTile>(toggle).value, false);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(toggle).value, false);
      expect(
        find.text(
          'Allow notifications and both background reception channels in system settings.',
        ),
        findsOneWidget,
      );
      expect(find.text('System notification settings'), findsOneWidget);
      expect(calls.any((c) => c.method == 'startBackgroundReceive'), false);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() => close(c));
    },
  );
}
