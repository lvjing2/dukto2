import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dukto2/main.dart';
import 'package:dukto2/src/controller.dart';
import 'package:dukto2_core/dukto2_core.dart';

final class TestFile extends PlatformFile {
  @override
  String get name => '测试文件_名称很长也需要完整显示_0123456789.bin';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestController extends Dukto2Controller {
  int sends = 0;
  bool? answer;
  TestController() {
    starting = false;
    name = '测试 Mac';
    selected = Peer(
      id: 'phone',
      name: 'Android 测试设备',
      host: '192.168.1.2',
      port: 12345,
      fingerprint: 'a' * 64,
    );
  }
  @override
  bool get ready => true;
  @override
  Future<void> pickFile() async {
    chosenFile = TestFile();
    chosenSize = 1024;
    sendPhase = SendPhase.ready;
    notifyListeners();
  }

  @override
  Future<void> sendFile() async {
    sends++;
    sending = true;
    sendPhase = SendPhase.waiting;
    notifyListeners();
  }

  void offer() {
    pendingOffer = const FileOffer(
      sender: 'Android',
      name: '收到的测试.bin',
      size: 42,
    );
    notifyListeners();
  }

  void expire() {
    pendingOffer = null;
    notifyListeners();
  }

  @override
  void answerOffer(bool accept) {
    answer = accept;
    pendingOffer = null;
    notifyListeners();
  }
}

void main() {
  Future<void> show(
    WidgetTester tester,
    TestController c,
    Size size, {
    bool dark = false,
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp(
        theme: dukto2Theme(dark ? Brightness.dark : Brightness.light),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: TransferDashboard(controller: c),
      ),
    );
    await tester.pumpAndSettle();
  }

  void clean(WidgetTester tester, TestController c) {
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await c.client.close();
      c.dispose();
    });
  }

  testWidgets('choosing a file never sends until explicit send action', (
    tester,
  ) async {
    final c = TestController();
    clean(tester, c);
    await show(tester, c, const Size(390, 844));
    await tester.tap(find.text('选择文件'));
    await tester.pumpAndSettle();
    expect(c.sends, 0);
    expect(find.text('准备就绪'), findsOneWidget);
    await tester.ensureVisible(find.widgetWithText(FilledButton, '发送文件'));
    await tester.tap(find.widgetWithText(FilledButton, '发送文件'));
    await tester.pump();
    expect(c.sends, 1);
    expect(find.text('等待对方接收'), findsOneWidget);
    expect(find.text('取消传输'), findsOneWidget);
  });
  testWidgets(
    'phone, landscape, desktop and dark large text layouts fit long file names',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      await c.pickFile();
      for (final size in [
        const Size(320, 750),
        const Size(812, 375),
        const Size(1100, 850),
      ]) {
        await show(tester, c, size, dark: true, scale: 2);
        expect(find.text('dukto2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
  testWidgets(
    'incoming consent appears above scrolled content and rejects on back',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      await show(tester, c, const Size(390, 844));
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      c.offer();
      await tester.pumpAndSettle();
      expect(find.text('接收文件'), findsOneWidget);
      expect(c.answer, isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(c.answer, false);
      expect(find.text('接收文件'), findsNothing);
    },
  );
  testWidgets(
    'expired consent closes only its route and keeps local info open',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      await show(tester, c, const Size(1100, 850));
      await tester.tap(find.byTooltip('本机信息'));
      await tester.pumpAndSettle();
      c.offer();
      await tester.pumpAndSettle();
      expect(find.text('接收文件'), findsOneWidget);
      c.expire();
      await tester.pumpAndSettle();
      expect(find.text('接收文件'), findsNothing);
      expect(find.text('本机信息'), findsOneWidget);
      expect(find.text('完成'), findsOneWidget);
    },
  );
  testWidgets('desktop Escape rejects an incoming request', (tester) async {
    final c = TestController();
    clean(tester, c);
    await show(tester, c, const Size(800, 600));
    c.offer();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(c.answer, false);
  });
  testWidgets('receiving requires pressing accept', (tester) async {
    final c = TestController();
    clean(tester, c);
    await show(tester, c, const Size(1100, 850));
    c.offer();
    await tester.pumpAndSettle();
    expect(c.answer, isNull);
    await tester.tap(find.text('接收文件'));
    await tester.pumpAndSettle();
    expect(c.answer, true);
  });
  testWidgets('about credits Dukto and clearly discloses AI creation', (
    tester,
  ) async {
    final c = TestController();
    clean(tester, c);
    await show(tester, c, const Size(800, 600));
    await tester.tap(find.byTooltip('关于 dukto2'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Emanuele Colombo'), findsOneWidget);
    expect(find.textContaining('OpenAI Codex'), findsOneWidget);
  });
}
