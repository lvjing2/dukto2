// Render documentation previews from the actual Flutter widgets.
// Run: ./tool/flutterw test tool/render_english_previews.dart
// These use sample device identities, not recorded transfer results.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dukto2/src/app_settings.dart';
import 'package:dukto2/src/controller.dart';
import 'package:dukto2/src/dashboard.dart';
import 'package:dukto2/src/localization.dart';
import 'package:dukto2/src/theme.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class PreviewController extends Dukto2Controller {
  @override
  bool get ready => true;
  @override
  bool get canScanQr => true;
}

void main() {
  testWidgets('render English documentation previews', (tester) async {
    var sdkPart = File(Platform.resolvedExecutable).parent;
    while (!Directory('${sdkPart.path}/material_fonts').existsSync()) {
      if (sdkPart.parent.path == sdkPart.path) {
        throw StateError('Flutter material_fonts directory not found');
      }
      sdkPart = sdkPart.parent;
    }
    final fonts = Directory('${sdkPart.path}/material_fonts');
    for (final entry in {
      'Roboto': 'Roboto-Regular.ttf',
      'MaterialIcons': 'MaterialIcons-Regular.otf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('${fonts.path}/${entry.value}').readAsBytesSync(),
            ),
          ),
        );
      await tester.runAsync(loader.load);
    }
    final directory = Directory.systemTemp.createTempSync(
      'dukto2-doc-preview-',
    );
    final identity = (await tester.runAsync(
      () =>
          DeviceIdentity.loadOrCreate(Directory('${directory.path}/identity')),
    ))!;
    final c = PreviewController()
      ..settings = const AppSettings(language: AppLanguage.en)
      ..starting = false
      ..status = 'Ready for local transfers'
      ..identity = identity
      ..name = 'This device'
      ..selected = Peer(
        id: 'documentation-sample',
        name: 'Nearby tablet',
        host: '192.168.1.20',
        port: 45879,
        fingerprint: 'a' * 64,
        supportsText: true,
        deviceType: DeviceType.tablet,
      );
    c.peers = [c.selected!];
    for (final entry in {
      'desktop-main-en': const Size(1180, 780),
      'phone-main-en': const Size(390, 844),
      'tablet-main-en': const Size(1024, 768),
    }.entries) {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: AppLanguage.en.locale,
            supportedLocales: AppLanguage.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: dukto2Theme(Brightness.light)
                .copyWith(splashFactory: InkRipple.splashFactory),
            home: TransferDashboard(controller: c),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/branding/dukto2.png'),
          tester.element(find.byType(TransferDashboard)),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final text in tester.widgetList<Text>(find.byType(Text))) {
        expect(
          text.data ?? text.textSpan?.toPlainText() ?? '',
          isNot(matches(RegExp(r'[\u3400-\u9fff]'))),
        );
      }
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final pixels = await boundary.toImage(pixelRatio: 1.5);
        final bytes = await pixels.toByteData(format: ui.ImageByteFormat.png);
        await File('docs/screenshots/${entry.key}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        pixels.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox());
    await c.client.close();
    c.dispose();
    directory.deleteSync(recursive: true);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
