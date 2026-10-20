import 'dart:io';

import 'package:dukto2/src/app_settings.dart';
import 'package:dukto2/src/controller.dart';
import 'package:dukto2/src/dashboard.dart';
import 'package:dukto2/src/localization.dart';
import 'package:dukto2/src/settings_page.dart';
import 'package:dukto2/src/theme.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class LocaleController extends Dukto2Controller {
  LocaleController({super.settingsStore})
    : super(filePicker: () async => throw FileSystemException('private path')) {
    starting = false;
    name = 'Mac – 保留名称';
  }
  @override
  bool get ready => true;
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  late Directory root;
  final calls = <MethodCall>[];
  setUp(() async {
    root = await Directory.systemTemp.createTemp('dukto2-locale-');
    calls.clear();
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, (call) async {
      calls.add(call);
      return switch (call.method) {
        'getDeviceName' => 'Mac – 保留名称',
        'notificationStatus' => 'granted',
        _ => null,
      };
    });
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, null);
    await root.delete(recursive: true);
  });
  Future<void> close(Dukto2Controller c) async {
    c.answerOffer(false);
    await c.client.close();
    c.dispose();
  }

  test(
    'system default, ten choices, regional matching and English fallback',
    () {
      expect(const AppSettings().language, AppLanguage.system);
      expect(AppLanguage.supportedLocales.length, 10);
      expect(
        AppLanguage.resolve([const Locale('it'), const Locale('de', 'AT')]),
        const Locale('de'),
      );
      expect(
        AppLanguage.resolve([const Locale('pt', 'PT')]),
        AppLanguage.ptBr.locale,
      );
      expect(
        AppLanguage.resolve([const Locale('zh', 'TW')]),
        AppLanguage.zhHans.locale,
      );
      expect(AppLanguage.resolve([const Locale('it')]), const Locale('en'));
      expect(
        AppSettings.fromJson({'language': 'unknown'}).language,
        AppLanguage.system,
      );
      expect(AppSettings.fromJson({}).language, AppLanguage.system);
      for (final language in AppLanguage.values) {
        expect(
          AppSettings.fromJson(AppSettings(language: language).toJson())
              .language,
          language,
        );
      }
    },
  );

  test(
    'language is remembered, failed saves retain the previous language',
    () async {
      final c = LocaleController(settingsStore: SettingsStore(root));
      await c.loadSettings();
      expect(await c.setLanguage(AppLanguage.ja), isTrue);
      expect((await SettingsStore(root).load()).language, AppLanguage.ja);
      expect(c.strings.settings, '設定');
      final settings = SettingsStore(root);
      await settings.file.delete();
      await Directory(settings.file.path).create();
      expect(await c.setLanguage(AppLanguage.ar), isFalse);
      expect(c.settings.language, AppLanguage.ja);
      expect(c.settingsError, c.strings.settingsSaveFailed);
      await Directory(settings.file.path).delete();
      expect(await c.setLanguage(AppLanguage.system), isTrue);
      expect((await settings.load()).language, AppLanguage.system);
      await close(c);
    },
  );

  test('live errors, consent and notifications translate without replacing the session', () async {
    final c = LocaleController(settingsStore: SettingsStore(root));
    await c.loadSettings();
    await c.setLanguage(AppLanguage.en);
    await c.pickFile();
    expect(c.error, c.strings.filePickerFailed);
    await c.setLanguage(AppLanguage.fr);
    expect(c.error, 'Sélection de fichiers impossible');
    expect(c.error, isNot(contains('private path')));
    final offer = const FileOffer(
      sender: 'Phone – اسم',
      name: '文件.bin',
      size: 4,
    );
    final decision = c.receiveOffer(offer);
    final session = c.session;
    final cancellation = session!.cancellation;
    final name = c.name;
    expect(c.status, c.strings.newRequest);
    await c.setLanguage(AppLanguage.ar);
    expect(c.session, same(session));
    expect(c.session!.cancellation, same(cancellation));
    expect(cancellation.isCancelled, isFalse);
    expect(c.pendingOffer, same(offer));
    expect(c.status, 'طلب استلام جديد');
    expect(c.name, name);
    c.answerOffer(false);
    expect(await decision, isFalse);
    await c.notifyCompletion(
      TransferReceipt(
        name: 'private',
        size: 1,
        sha256: 'a' * 64,
        text: 'secret',
      ),
      incoming: true,
    );
    final payload =
        calls.lastWhere((c) => c.method == 'notifyComplete').arguments as Map;
    expect(payload['title'], c.strings.receiveComplete);
    expect(payload['body'], c.strings.receivedVerified(c.strings.text));
    expect(payload.values.join(), isNot(contains('secret')));
    expect(
      calls.lastWhere((c) => c.method == 'configureLocalization').arguments,
      containsPair('cancel', 'إلغاء'),
    );
    await close(c);
  });

  test(
    'Arabic byte sizes keep the number before Latin units in RTL layout',
    () {
      for (final bytes in [16, 1536, 1572864, 1610612736]) {
        final text = formatBytes(bytes, locale: 'ar');
        final painter = TextPainter(
          text: TextSpan(text: text, style: const TextStyle(fontSize: 16)),
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: 200);
        final number = text.indexOf(RegExp(r'[0-9٠-٩]'));
        final unit = text.indexOf('B');
        final numberBox = painter
            .getBoxesForSelection(
              TextSelection(baseOffset: number, extentOffset: number + 1),
            )
            .single;
        final unitBox = painter
            .getBoxesForSelection(
              TextSelection(baseOffset: unit, extentOffset: unit + 1),
            )
            .single;
        expect(numberBox.left, lessThan(unitBox.left), reason: text);
        painter.dispose();
      }
    },
  );

  test('Russian and Arabic file-count plural rules', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    expect(ru.fileCount(1), contains('файл'));
    expect(ru.fileCount(2), contains('файла'));
    expect(ru.fileCount(5), contains('файлов'));
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(ar.fileCount(0), 'لا ملفات');
    expect(ar.fileCount(1), 'ملف واحد');
    expect(ar.fileCount(2), 'ملفان');
    expect(ar.fileCount(3), contains('ملفات'));
    expect(ar.fileCount(11), contains('ملفًا'));
  });

  testWidgets('live language change retains editor draft and history', (
    tester,
  ) async {
    final c = LocaleController(settingsStore: SettingsStore(root));
    c.settings = const AppSettings(language: AppLanguage.en);
    c.sendKind = TransferKind.text;
    c.selected = Peer(
      id: 'peer',
      name: 'Phone – هاتف',
      host: '192.168.1.2',
      port: 45879,
      fingerprint: 'a' * 64,
      supportsText: true,
    );
    c.history.add(
      HistoryEntry(
        TransferReceipt(name: 'unchanged.txt', size: 4, sha256: 'a' * 64),
        true,
      ),
    );
    await tester.pumpWidget(
      ListenableBuilder(
        listenable: c,
        builder: (context, _) => MaterialApp(
          locale: c.settings.language.locale,
          supportedLocales: AppLanguage.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: TransferDashboard(controller: c),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'draft – 草稿 – نص');
    await tester.runAsync(() => c.setLanguage(AppLanguage.ar));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'draft – 草稿 – نص',
    );
    expect(c.history.single.receipt.name, 'unchanged.txt');
    expect(
      Directionality.of(tester.element(find.byType(TransferDashboard))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => close(c));
  });

  for (final language in AppLanguage.values.where(
    (value) => value.locale != null,
  )) {
    testWidgets(
      '${language.tag}: narrow screen, large text, history and language picker',
      (tester) async {
        tester.view.physicalSize = const Size(375, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final c = LocaleController(settingsStore: SettingsStore(root));
        c.settings = AppSettings(language: language);
        c.history.add(
          HistoryEntry(
            TransferReceipt(
              name: '中文-file.txt',
              size: 1536,
              sha256: 'a' * 64,
              text: 'A draft – نص',
            ),
            true,
            peerName: 'Phone – هاتف',
            elapsed: const Duration(seconds: 3),
          ),
        );
        final strings = c.strings;
        Widget app(Widget home) => MaterialApp(
          locale: language.locale,
          supportedLocales: AppLanguage.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: dukto2Theme(Brightness.light)
              .copyWith(splashFactory: InkRipple.splashFactory),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: home,
        );
        await tester.pumpWidget(app(TransferDashboard(controller: c)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(TransferDashboard));
        expect(
          Directionality.of(context),
          language == AppLanguage.ar ? TextDirection.rtl : TextDirection.ltr,
        );
        await tester.pumpWidget(app(SettingsPage(controller: c)));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('settings-language')),
          200,
          scrollable: find
              .descendant(
                of: find.byType(SettingsPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await Scrollable.ensureVisible(
          tester.element(find.byKey(const ValueKey('settings-language'))),
          alignment: 0.5,
        );
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();
        final languageTile = find
            .byKey(const ValueKey('settings-language'))
            .hitTestable();
        expect(languageTile, findsOneWidget);
        await tester.tap(languageTile);
        await tester.pumpAndSettle();
        expect(find.text(strings.language), findsWidgets);
        expect(find.byKey(const ValueKey('language-system')), findsOneWidget);
        expect(find.byKey(const ValueKey('language-ar')), findsOneWidget);
        Rect languageGlyphBounds(String tag) {
          final text = find.descendant(
            of: find.byKey(ValueKey('language-$tag')),
            matching: find.byType(Text),
          );
          final paragraph = tester.renderObject<RenderParagraph>(text);
          final boxes = paragraph.getBoxesForSelection(
            TextSelection(
              baseOffset: 0,
              extentOffset: paragraph.text.toPlainText().length,
            ),
          );
          final bounds = boxes
              .map((b) => b.toRect())
              .reduce((a, b) => a.expandToInclude(b));
          return bounds.shift(paragraph.localToGlobal(Offset.zero));
        }

        final english = languageGlyphBounds('en');
        final arabic = languageGlyphBounds('ar');
        expect(
          language == AppLanguage.ar ? arabic.right : arabic.left,
          closeTo(language == AppLanguage.ar ? english.right : english.left, 1),
        );

        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() => close(c));
      },
    );
  }
}
