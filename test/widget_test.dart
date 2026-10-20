import 'package:dukto2/src/localization.dart';
import 'package:dukto2/src/app_settings.dart';

import 'dart:io';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dukto2/main.dart';
import 'package:dukto2/src/controller.dart';
import 'package:dukto2_core/dukto2_core.dart';

final class TestFile extends PlatformFile {
  final String fileName;
  TestFile([this.fileName = '测试文件_名称很长也需要完整显示_0123456789.bin']);
  @override
  String get name => fileName;
  @override
  Future<int?> length() async => 1024;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// General UI fixtures use fixed state; connection lifecycle has its own tests.
class WidgetPeerConnection extends PeerConnection {
  @override
  void watch(Peer peer) {}
}

class TestController extends Dukto2Controller {
  int sends = 0;
  bool? answer;
  String? sentText;
  HistoryEntry? directoryOpened;
  @override
  Future<void> openHistoryDirectory(HistoryEntry entry) async {
    directoryOpened = entry;
  }

  TestController({Future<List<PlatformFile>> Function()? filePicker})
    : super(
        connection: WidgetPeerConnection(),
        filePicker: filePicker ?? (() async => [TestFile()]),
      ) {
    settings = const AppSettings(language: AppLanguage.zhHans);
    starting = false;
    name = '测试 Mac';
    selected = Peer(
      id: 'phone',
      name: 'Android 测试设备',
      host: '192.168.1.2',
      port: 12345,
      fingerprint: 'a' * 64,
      supportsText: true,
    );
  }
  @override
  bool get canSendToSelected => true;
  @override
  PeerConnectionState get connectionState => PeerConnectionState.online;
  @override
  bool get ready => true;
  @override
  Future<void> sendFile() async {
    sends++;
    beginOutgoingSession();
    sendPhase = SendPhase.waiting;
    notifyListeners();
  }

  @override
  Future<void> sendText(String text) async {
    sentText = text;
    beginOutgoingSession();
    sendPhase = SendPhase.waiting;
    notifyListeners();
  }

  @override
  Future<void> pickTextFile() async {
    chosenTextFile = TestFile();
    chosenTextSize = 2 * 1024 * 1024;
    chosenTextPreview = 'UTF-8 preview\n' * 2000;
    notifyListeners();
  }

  void offer() {
    unawaited(
      receiveOffer(
        const FileOffer(sender: 'Android', name: '收到的测试.bin', size: 42),
      ),
    );
    notifyListeners();
  }

  void expire() {
    super.answerOffer(false);
    notifyListeners();
  }

  @override
  void answerOffer(bool accept) {
    answer = accept;
    super.answerOffer(accept);
    notifyListeners();
  }
}

class AvailabilityController extends TestController {
  PeerConnectionState state = PeerConnectionState.offline;
  @override
  PeerConnectionState get connectionState => state;
  @override
  bool get canSendToSelected => state == PeerConnectionState.online;
}

class StorageTestController extends TestController {
  int folderChoices = 0;
  @override
  bool get canEditSettings => true;
  @override
  Future<void> refreshSystemSettings() async {}
  @override
  bool get canChooseReceiveFolder => true;
  @override
  Future<void> chooseReceiveFolder() async {
    folderChoices++;
  }
}

class PhoneConnectionController extends TestController {
  @override
  bool get canScanQr => true;
}

class SearchTestController extends TestController {
  int searches = 0;
  Completer<void> searchFinished = Completer<void>();

  @override
  Future<void> refreshAddresses({bool activeSearch = false}) async {
    if (activeSearch) {
      searches++;
      await searchFinished.future;
    }
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
        locale: AppLanguage.zhHans.locale,
        supportedLocales: AppLanguage.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        // Flutter 3.47's InkSparkle shader has no SkSL stage for the software
        // test renderer. Keep tap feedback while testing layout and actions.
        theme: dukto2Theme(dark ? Brightness.dark : Brightness.light)
            .copyWith(splashFactory: InkRipple.splashFactory),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: TransferDashboard(controller: c),
      ),
    );
    await tester.pumpAndSettle();
  }

  void clean(WidgetTester tester, TestController c) {
    // Widget tests have no native keep-awake plugin. Complete its calls rather
    // than leaving the acquisition timeout pending after accepting a transfer.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      Dukto2Controller.platform,
      (_) async => null,
    );
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await c.client.close();
      c.dispose();
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        Dukto2Controller.platform,
        null,
      );
    });
  }

  for (final size in [const Size(375, 812), const Size(1100, 800)]) {
    testWidgets('button and pull share one active search at $size', (
      tester,
    ) async {
      final c = SearchTestController()..selected = null;
      clean(tester, c);
      await show(tester, c, size);
      await tester.tap(find.byTooltip('刷新设备'));
      await tester.pump();
      expect(c.searches, 1);
      expect(find.text('正在搜索…'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.ancestor(
                of: find.byTooltip('刷新设备'),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );
      // Pulling while the button's search is active joins the same operation.
      final scroll = find
          .descendant(
            of: find.byType(RefreshIndicator),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.drag(scroll, const Offset(0, 360));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(c.searches, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      c.searchFinished.complete();
      await tester.pumpAndSettle();
      expect(c.searchingDevices, isFalse);
      expect(find.text('正在搜索…'), findsNothing);
      expect(find.byType(RefreshProgressIndicator), findsNothing);

      // A fresh pull must work even with an empty, shorter-than-viewport list.
      c.searchFinished = Completer<void>();
      await tester.drag(scroll, const Offset(0, 360));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(c.searches, 2);
      expect(c.searchingDevices, isTrue);
      expect(find.text('正在搜索…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(RefreshProgressIndicator), findsNothing);
      c.searchFinished.complete();
      await tester.pumpAndSettle();
      expect(c.searchingDevices, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'phone has one connection row and no show-QR action: dark=$dark scale=$scale',
        (tester) async {
          final c = PhoneConnectionController()..selected = null;
          clean(tester, c);
          await show(tester, c, const Size(375, 812), dark: dark, scale: scale);
          expect(find.text('显示二维码'), findsNothing);
          expect(find.text('扫码连接'), findsOneWidget);
          expect(find.text('手动连接'), findsOneWidget);
          final scan = tester.getRect(
            find
                .ancestor(
                  of: find.text('扫码连接'),
                  matching: find.byWidgetPredicate(
                    (widget) => widget is ButtonStyleButton,
                  ),
                )
                .first,
          );
          final manual = tester.getRect(
            find
                .ancestor(
                  of: find.text('手动连接'),
                  matching: find.byWidgetPredicate(
                    (widget) => widget is ButtonStyleButton,
                  ),
                )
                .first,
          );
          expect(scan.top, closeTo(manual.top, 0.1));
          expect(scan.bottom, closeTo(manual.bottom, 0.1));
          expect(scan.right, lessThan(manual.left));
          expect(tester.takeException(), isNull);
          await tester.tap(find.byTooltip('本机信息'));
          await tester.pumpAndSettle();
          expect(find.text('本机信息'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'nearby devices use their advertised type icons without a duplicate target',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      final devices = [
        (DeviceType.phone, '办公室设备', Icons.smartphone_outlined),
        (DeviceType.tablet, '会议室设备', Icons.tablet_mac_outlined),
        (DeviceType.computer, '工作设备', Icons.computer_outlined),
        (DeviceType.unknown, 'iPhone 名称的旧版设备', Icons.devices_outlined),
      ];
      c.peers = [
        for (var i = 0; i < devices.length; i++)
          Peer(
            id: 'peer-$i',
            name: devices[i].$2,
            host: '192.168.1.${i + 2}',
            port: 45879,
            fingerprint: '${i + 1}' * 64,
            deviceType: devices[i].$1,
          ),
      ];
      c.selected = null;
      for (final size in [const Size(375, 812), const Size(1200, 900)]) {
        await show(tester, c, size, dark: true);
        for (final (_, name, icon) in devices) {
          final card = find
              .ancestor(
                of: find.text(name).first,
                matching: find.byType(InkWell),
              )
              .first;
          expect(
            find.descendant(of: card, matching: find.byIcon(icon)),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      }
      c.select(c.peers[1]);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.tablet_mac_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'an old selection is not counted as a currently discovered device',
    (tester) async {
      final controller = TestController();
      await show(tester, controller, const Size(1024, 768));
      expect(find.text('附近设备 0'), findsOneWidget);
      expect(find.text('已核对 · 未发现'), findsNothing);
      expect(find.text('还没有发现设备'), findsOneWidget);
      controller.peers = [controller.selected!];
      controller.notifyListeners();
      await tester.pump();
      expect(find.text('附近设备 1'), findsOneWidget);
      expect(find.text('已核对 · 已选择'), findsOneWidget);
      controller.dispose();
    },
  );

  testWidgets(
    'offline, checking and changed identity disable both send buttons',
    (tester) async {
      final c = AvailabilityController();
      c.peers = [c.selected!];
      clean(tester, c);
      await c.pickFile();
      await show(tester, c, const Size(1024, 768));
      for (final state in PeerConnectionState.values) {
        c.state = state;
        c.sendKind = TransferKind.file;
        c.notifyListeners();
        await tester.pump();
        final fileButton = tester.widget<FilledButton>(
          find
              .ancestor(
                of: find.text('发送文件'),
                matching: find.byWidgetPredicate((w) => w is FilledButton),
              )
              .first,
        );
        expect(
          fileButton.onPressed != null,
          state == PeerConnectionState.online,
        );
        if (state == PeerConnectionState.offline) {
          expect(find.text('离线'), findsOneWidget);
        }
        c.sendKind = TransferKind.text;
        c.notifyListeners();
        await tester.pump();
        await tester.enterText(find.byType(TextField).first, 'hello');
        final textButton = tester.widget<FilledButton>(
          find.byKey(const ValueKey('send-text')),
        );
        expect(
          textButton.onPressed != null,
          state == PeerConnectionState.online,
        );
      }
      expect(c.sends, 0);
      expect(c.sentText, isNull);
    },
  );

  testWidgets(
    'changing recipient makes an already sent file ready for explicit send',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      await c.pickFile();
      c.sendPhase = SendPhase.sent;
      c.status = '已发送，对方校验通过';
      await show(tester, c, const Size(1024, 768));
      expect(find.text('已发送，校验通过'), findsOneWidget);
      c.select(
        Peer(
          id: 'ipad',
          name: 'iPad',
          host: '192.168.1.3',
          port: 12345,
          fingerprint: 'b' * 64,
          supportsText: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('已发送，校验通过'), findsNothing);
      expect(find.text('发送文件'), findsOneWidget);
      expect(c.chosenFile, isNotNull);
      expect(c.sends, 0);
      await tester.tap(find.text('发送文件'));
      await tester.pump();
      expect(c.sends, 1);
    },
  );

  testWidgets(
    'receive location remains usable on a small phone with large text',
    (tester) async {
      final controller = StorageTestController()
        ..receiveLocation = '本地接收目录_名字很长也需要换行显示_0123456789';
      await show(
        tester,
        controller,
        const Size(375, 812),
        dark: true,
        scale: 2,
      );
      expect(find.text('接收位置'), findsNothing);
      expect(find.text('更改目录'), findsNothing);
      await tester.tap(find.byTooltip('设置'));
      await tester.pumpAndSettle();
      expect(find.text('接收位置'), findsOneWidget);
      final button = find.widgetWithText(TextButton, '更改目录');
      await tester.scrollUntilVisible(
        button,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(button);
      await tester.pump();
      expect(controller.folderChoices, 1);
      expect(tester.takeException(), isNull);
      controller.dispose();
    },
  );

  testWidgets(
    'batch selection lists files, supports removal and fits phone and landscape',
    (tester) async {
      final c = TestController(
        filePicker: () async => [
          TestFile('first.bin'),
          TestFile('second.bin'),
          TestFile('third.bin'),
        ],
      );
      clean(tester, c);
      await c.pickFile();
      for (final size in [const Size(375, 812), const Size(812, 375)]) {
        await show(tester, c, size, dark: true, scale: 2);
        await tester.ensureVisible(find.text('3 个文件'));
        await tester.pumpAndSettle();
        expect(find.textContaining('first.bin'), findsOneWidget);
        expect(find.text('3.0 KB'), findsOneWidget);
        expect(c.sends, 0);
        expect(tester.takeException(), isNull);
      }
      await tester.ensureVisible(find.byTooltip('移除 second.bin'));
      await tester.tap(find.byTooltip('移除 second.bin'));
      await tester.pumpAndSettle();
      expect(c.files, hasLength(2));
      expect(find.textContaining('second.bin'), findsNothing);
    },
  );

  testWidgets(
    'history shows time and known duration while keeping the action at the right',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      final now = DateTime.now();
      c.history.add(
        HistoryEntry(
          const TransferReceipt(
            name: 'text',
            size: 3,
            sha256: 'abc',
            text: 'hi',
          ),
          true,
          peerName: 'iPad',
          time: DateTime(now.year, now.month, now.day, 12, 34),
          elapsed: const Duration(milliseconds: 2345),
        ),
      );
      await show(tester, c, const Size(375, 812), dark: true, scale: 2);
      await tester.scrollUntilVisible(
        find.text('查看文本'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('今天 12:34'), findsOneWidget);
      expect(find.text('耗时 2.3 秒'), findsOneWidget);
      expect(
        tester.getRect(find.text('今天 12:34')).right,
        lessThan(tester.getRect(find.text('查看文本')).left),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'batch consent shows the manifest and accepts the whole batch once',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      await show(tester, c, const Size(375, 812), dark: true, scale: 2);
      unawaited(
        c.receiveOffer(
          batchOfferFromJson({
            'sender': 'iPad',
            'files': [
              {'name': 'first.bin', 'size': 1024},
              {'name': '第二份.txt', 'size': 3},
              {'name': 'empty.bin', 'size': 0},
            ],
          }, '192.168.31.99'),
        ),
      );
      c.notifyListeners();
      await tester.pumpAndSettle();
      expect(find.text('iPad 想发送 3 个文件'), findsOneWidget);
      expect(find.text('确认一次，接收这批文件'), findsOneWidget);
      expect(find.textContaining('第二份.txt'), findsOneWidget);
      expect(find.text('接收文件'), findsNothing);
      await tester.ensureVisible(find.text('接收全部'));
      await tester.tap(find.text('接收全部'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.answer, isTrue);
      expect(c.pendingOffer, isNull);
      expect(c.receiving, isTrue);
      expect(find.text('接收全部'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

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
        expect(find.text('Dukto2'), findsOneWidget);
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
      expect(find.text('传输时请保持应用运行，避免设备休眠。'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('Android'),
        ),
        findsNothing,
      );
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
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.answer, true);
  });
  testWidgets('text needs explicit send and draft survives switching tabs', (
    tester,
  ) async {
    final c = TestController();
    clean(tester, c);
    await show(tester, c, const Size(390, 844));
    await tester.tap(find.text('文本'));
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('text-composer'));
    await tester.enterText(field, '你好\n  keep spaces  ');
    await tester.pumpAndSettle();
    expect(c.sentText, isNull);
    await tester.ensureVisible(find.text('文件').first);
    await tester.tap(find.text('文件').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('文本'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(field).controller!.text,
      '你好\n  keep spaces  ',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('send-text')));
    await tester.tap(find.byKey(const ValueKey('send-text')));
    await tester.pump();
    expect(c.sentText, '你好\n  keep spaces  ');
    expect(find.text('取消传输'), findsOneWidget);
  });

  testWidgets(
    'paste is explicit and whitespace or excessive UTF-8 cannot send',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      var reads = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.getData') {
            reads++;
            return {'text': '粘贴的链接 https://example.org'};
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await show(tester, c, const Size(1024, 768));
      await tester.tap(find.text('文本'));
      await tester.pumpAndSettle();
      expect(reads, 0);
      final send = find.byKey(const ValueKey('send-text'));
      expect(tester.widget<FilledButton>(send).onPressed, isNull);
      await tester.ensureVisible(find.byTooltip('粘贴文本'));
      await tester.tap(find.byTooltip('粘贴文本'));
      await tester.pumpAndSettle();
      expect(reads, 1);
      final field = find.byKey(const ValueKey('text-composer'));
      expect(
        tester.widget<TextField>(field).controller!.text,
        '粘贴的链接 https://example.org',
      );
      await tester.enterText(field, '中' * (maxInlineTextBytes ~/ 3 + 1));
      await tester.pumpAndSettle();
      expect(find.text('编辑区最多 1 MiB，大文本请从文件载入（上限 16 MiB）'), findsOneWidget);
      expect(tester.widget<FilledButton>(send).onPressed, isNull);
    },
  );

  testWidgets('received text is selectable and copied only by user action', (
    tester,
  ) async {
    final c = TestController();
    clean(tester, c);
    const text = '第一行\nhttps://example.org/第二行';
    c.history.add(
      HistoryEntry(
        const TransferReceipt(
          name: '文本消息',
          size: 44,
          sha256: 'abc',
          text: text,
        ),
        true,
      ),
    );
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await show(tester, c, const Size(375, 812), dark: true, scale: 2);
    expect(clipboard, isNull);
    await tester.scrollUntilVisible(
      find.text('查看文本'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('查看文本'));
    await tester.pumpAndSettle();
    final actions = find.byKey(const ValueKey('history-text-actions'));
    expect(tester.getSize(actions).height, lessThanOrEqualTo(64));
    expect(find.byTooltip('复制文本'), findsNothing);
    expect(find.byTooltip('复制 SHA-256 校验值'), findsNothing);
    await tester.tap(find.text('查看文本'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is SelectableText && w.data == text),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, '复制文本'));
    await tester.pumpAndSettle();
    expect(clipboard, text);
    expect(find.text('已复制文本'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'text input fits dark landscape with large text and reduced motion',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      c.sendKind = TransferKind.text;
      for (final (size, scale) in [
        (const Size(320, 750), 1.0),
        (const Size(375, 812), 1.0),
        (const Size(320, 750), 2.0),
        (const Size(375, 812), 2.0),
        (const Size(812, 375), 2.0),
        (const Size(1100, 850), 2.0),
      ]) {
        await show(tester, c, size, dark: true, scale: scale);
        await tester.enterText(
          find.byKey(const ValueKey('text-composer')),
          'long link https://example.org/' * 4,
        );
        await tester.pumpAndSettle();
        final toolbar = find.byKey(const ValueKey('text-actions'));
        final paste = find.byTooltip('粘贴文本');
        final more = find.byTooltip('更多文本操作');
        final send = find.byKey(const ValueKey('send-text'));
        await tester.ensureVisible(toolbar);
        await tester.pumpAndSettle();
        expect(tester.getSize(toolbar).height, lessThanOrEqualTo(64));
        for (final target in [paste, more, send]) {
          expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
          expect(tester.getSize(target).width, greaterThanOrEqualTo(48));
          expect(tester.getCenter(target).dy, tester.getCenter(toolbar).dy);
        }
        expect(find.text('载入文本文件'), findsNothing);
        expect(find.text('清空内容'), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'history filters offline devices before applying the twenty entry limit',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      for (var i = 0; i < 24; i++) {
        c.history.add(
          HistoryEntry(
            TransferReceipt(
              name: 'mac-$i.txt',
              size: 1,
              sha256: 'a',
              text: 'mac-$i',
            ),
            true,
            peerName: 'Mac',
          ),
        );
      }
      c.history.add(
        HistoryEntry(
          const TransferReceipt(
            name: 'ipad.txt',
            size: 1,
            sha256: 'b',
            text: 'iPad text',
          ),
          true,
          peerName: '离线 iPad',
        ),
      );
      await show(tester, c, const Size(375, 812));
      final filter = find.byKey(const ValueKey('history-device-filter'));
      await tester.ensureVisible(filter);
      await tester.pumpAndSettle();
      expect(find.textContaining('已接收 · 离线 iPad'), findsNothing);
      await tester.tap(filter);
      await tester.pumpAndSettle();
      await tester.tap(find.text('离线 iPad').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('已接收 · 离线 iPad'), findsOneWidget);
      expect(find.textContaining('已接收 · Mac'), findsNothing);
      c.history.insert(
        0,
        HistoryEntry(
          const TransferReceipt(
            name: 'reply.txt',
            size: 2,
            sha256: 'c',
            text: 'reply',
          ),
          false,
          peerName: '离线 iPad',
        ),
      );
      c.notifyListeners();
      await tester.pumpAndSettle();
      expect(find.textContaining('已发送 · 离线 iPad'), findsOneWidget);
      await tester.tap(filter);
      await tester.pumpAndSettle();
      await tester.tap(find.text('全部设备').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('已接收 · Mac'), findsNWidgets(19));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'file rows have one directory action and keep status on the left',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      final received = HistoryEntry(
        TransferReceipt(
          name: 'received.bin',
          size: 1024,
          sha256: 'abc',
          file: File('/tmp/received.bin'),
        ),
        true,
        peerName: 'iPad',
      );
      final sent = HistoryEntry(
        const TransferReceipt(name: 'sent.bin', size: 1024, sha256: 'def'),
        false,
        peerName: 'Mac',
        sourceUri: 'file:///tmp/sent.bin',
      );
      final legacy = HistoryEntry(
        const TransferReceipt(name: 'legacy.bin', size: 1, sha256: 'ghi'),
        false,
        peerName: 'Mac',
      );
      c.history.addAll([received, sent, legacy]);
      await show(tester, c, const Size(375, 812), dark: true, scale: 2);
      await tester.scrollUntilVisible(
        find.text('最近传输'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final buttons = find.widgetWithText(TextButton, '打开目录');
      expect(buttons, findsNWidgets(3));
      expect(find.byTooltip('复制 SHA-256 校验值'), findsNothing);
      await tester.ensureVisible(buttons.first);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.text('已接收 · iPad')).right,
        lessThan(tester.getRect(buttons.first).left),
      );
      await tester.tap(buttons.first);
      expect(c.directoryOpened, same(received));
      expect(tester.widget<TextButton>(buttons.last).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'history adapts name, timing and action regions without repeating direction',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      const fileName = '项目资料_这是一个很长的文件名称_20261019-final.zip';
      const peer = '这是一台名称很长的 Android 设备';
      c.history.add(
        HistoryEntry(
          const TransferReceipt(name: fileName, size: 16777216, sha256: 'abc'),
          false,
          peerName: peer,
          time: DateTime(2025, 1, 2, 12, 34),
          elapsed: const Duration(hours: 1, minutes: 2, seconds: 3),
        ),
      );
      for (final (size, scale, dark) in [
        (const Size(320, 812), 1.0, false),
        (const Size(375, 812), 1.0, true),
        (const Size(375, 812), 2.0, true),
        (const Size(812, 375), 1.0, false),
        (const Size(1024, 768), 1.0, true),
        (const Size(1200, 900), 1.0, false),
        (const Size(1200, 900), 2.0, false),
      ]) {
        await show(tester, c, size, dark: dark, scale: scale);
        final button = find.widgetWithText(TextButton, '打开目录');
        await tester.scrollUntilVisible(
          button,
          220,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        final name = tester.getRect(find.text(fileName));
        final bytes = tester.getRect(find.text('16.0 MB'));
        final info = tester.getRect(
          find.byKey(const ValueKey('history-entry-info')),
        );
        final timing = tester.getRect(
          find.byKey(const ValueKey('history-entry-timing')),
        );
        final action = tester.getRect(button);
        expect(find.text('已发送 · $peer'), findsOneWidget);
        expect(find.textContaining('发往'), findsNothing);
        expect(find.text('2025/1/2 12:34'), findsOneWidget);
        expect(find.text('耗时 1 小时 2 分 3 秒'), findsOneWidget);
        expect(bytes.left, greaterThan(name.right));
        expect(bytes.top, closeTo(name.top, 1));
        expect(action.height, greaterThanOrEqualTo(48));
        expect(action.right, lessThanOrEqualTo(size.width));
        if ((size.width >= 1024 || size == const Size(812, 375)) &&
            scale == 1) {
          expect(timing.left, greaterThan(info.right));
          expect(action.left, greaterThan(timing.right));
        } else {
          // The name keeps the full row; only supporting details share space
          // with the action, even with a long device name or large text.
          expect(name.bottom, lessThan(info.top));
          expect(bytes.right, greaterThan(action.left));
          expect(timing.right, lessThan(action.left));
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('wide history entries keep actions beside their metadata', (
    tester,
  ) async {
    final c = TestController();
    clean(tester, c);
    c.history.add(
      HistoryEntry(
        const TransferReceipt(
          name: '文本消息',
          size: 16777216,
          sha256: 'abc',
          text: '大文本预览',
          textTruncated: true,
        ),
        false,
        peerName: 'REDMI K90',
      ),
    );
    for (final size in [const Size(800, 632), const Size(1200, 900)]) {
      await show(tester, c, size);
      await tester.ensureVisible(find.text('查看文本'));
      await tester.pumpAndSettle();
      final info = tester.getRect(
        find.byKey(const ValueKey('history-entry-info')),
      );
      final actions = tester.getRect(
        find.byKey(const ValueKey('history-text-actions')),
      );
      expect(actions.center.dy, closeTo(info.center.dy, 1));
      expect(actions.left, greaterThan(info.right));
      expect(find.byTooltip('复制预览'), findsNothing);
      expect(
        tester.getRect(find.text('已发送 · REDMI K90')).right,
        lessThan(actions.left),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'phone keyboard keeps editor and send toolbar visible without the device list',
    (tester) async {
      final c = TestController()..sendKind = TransferKind.text;
      clean(tester, c);
      addTearDown(tester.view.resetViewInsets);
      for (final (size, keyboard, scale) in [
        (const Size(375, 812), 300.0, 1.0),
        (const Size(375, 812), 300.0, 2.0),
        (const Size(812, 375), 160.0, 1.0),
      ]) {
        await show(tester, c, size, dark: true, scale: scale);
        final field = find.byKey(const ValueKey('text-composer'));
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.tap(field);
        await tester.enterText(field, '你好\n保留草稿');
        await tester.pumpAndSettle();
        final focused = tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode;
        final oldOffset = tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels;
        tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
        await tester.pumpAndSettle();
        expect(focused.hasFocus, isTrue);
        expect(
          tester.widget<EditableText>(find.byType(EditableText)).focusNode,
          same(focused),
        );
        final toolbar = tester.getRect(
          find.byKey(const ValueKey('text-actions')),
        );
        final editor = tester.getRect(field);
        expect(toolbar.bottom, lessThanOrEqualTo(size.height - keyboard));
        expect(editor.top, greaterThanOrEqualTo(56));
        expect(
          editor.height,
          greaterThanOrEqualTo(size.height > 500 ? 120 : 48),
        );
        expect(editor.bottom, lessThanOrEqualTo(toolbar.top));
        expect(find.byTooltip('刷新设备'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('更多文本操作'));
        await tester.pumpAndSettle();
        expect(focused.hasFocus, isTrue);
        expect(
          tester.getRect(find.text('清空内容')).bottom,
          lessThanOrEqualTo(size.height - keyboard),
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(focused.hasFocus, isTrue);
        focused.unfocus();
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        expect(
          find.byKey(const PageStorageKey('transfer-content')),
          findsOneWidget,
        );
        expect(tester.widget<TextField>(field).controller!.text, '你好\n保留草稿');
        expect(
          tester
              .state<ScrollableState>(find.byType(Scrollable).first)
              .position
              .pixels,
          closeTo(oldOffset, 1),
        );
      }
    },
  );

  testWidgets(
    'large text file can send without an inline draft and can be cleared',
    (tester) async {
      final c = TestController();
      clean(tester, c);
      c.sendKind = TransferKind.text;
      await show(tester, c, const Size(1100, 850));
      await tester.ensureVisible(find.byTooltip('更多文本操作'));
      await tester.tap(find.byTooltip('更多文本操作'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('载入文本文件'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('text-composer')), findsNothing);
      expect(
        tester
            .widget<SelectableText>(find.byType(SelectableText).first)
            .maxLines,
        8,
      );
      final send = find.byKey(const ValueKey('send-text'));
      expect(tester.widget<FilledButton>(send).onPressed, isNotNull);
      await tester.ensureVisible(find.byTooltip('更多文本操作'));
      await tester.tap(find.byTooltip('更多文本操作'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('清空内容'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('text-composer')), findsOneWidget);
      expect(c.chosenTextFile, isNull);
    },
  );

  for (final (size, scale, dark) in [
    (const Size(375, 812), 2.0, true),
    (const Size(800, 600), 1.0, false),
  ]) {
    testWidgets(
      'about shows installed version and preserves credits at $size',
      (tester) async {
        PackageInfo.setMockInitialValues(
          appName: 'Dukto2',
          packageName: 'dev.dukto2.dukto2',
          version: '9.8.7-test',
          buildNumber: '4321',
          buildSignature: '',
        );
        final c = StorageTestController();
        clean(tester, c);
        await show(tester, c, size, scale: scale, dark: dark);
        expect(find.byTooltip('关于 Dukto2'), findsNothing);
        expect(find.text('关于 Dukto2'), findsNothing);
        await tester.tap(find.byTooltip('设置'));
        await tester.pumpAndSettle();
        final about = find.byKey(const ValueKey('settings-about'));
        await tester.scrollUntilVisible(
          about,
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(about);
        await tester.pumpAndSettle();
        expect(find.text('Dukto2 · 9.8.7-test (4321)'), findsOneWidget);
        expect(find.text('作者：lvjing2'), findsOneWidget);
        expect(find.text('GitHub · lvjing2/dukto2'), findsOneWidget);
        expect(find.textContaining('Emanuele Colombo'), findsOneWidget);
        expect(find.textContaining('OpenAI Codex'), findsNothing);
        expect(find.text('第三方许可'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
