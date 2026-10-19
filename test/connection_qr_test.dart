import 'dart:convert';
import 'dart:io';

import 'package:dukto2/src/connection_qr.dart';
import 'package:dukto2/src/connection_qr_card.dart';
import 'package:dukto2/src/controller.dart';
import 'package:dukto2/src/app_language.dart';
import 'package:dukto2/src/localization.dart';
import 'package:dukto2/src/theme.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Peer peer({
  String? fingerprint,
  String host = '10.23.49.155',
  String id = 'mac',
}) => Peer(
  id: id,
  name: 'Mac',
  host: host,
  port: 45879,
  fingerprint: fingerprint ?? 'a' * 64,
);

void main() {
  test('QR round trip keeps identity and bounded local endpoints', () {
    final code = ConnectionQr.local(peer(), [
      '10.23.49.155:45879',
      '10.48.255.25:45879',
      '10.23.49.155:45879',
      '127.0.0.1:45879',
      '8.8.8.8:443',
      'https://example.com',
    ]);
    final parsed = ConnectionQr.parse(code.encode());
    expect(parsed.id, 'mac');
    expect(parsed.fingerprint, 'a' * 64);
    expect(parsed.addresses, ['10.23.49.155:45879', '10.48.255.25:45879']);
  });

  test('scanner input rejects unrelated, malformed and unbounded payloads', () {
    final data = <String, Object>{
      'v': 1,
      'id': 'mac',
      'fingerprint': 'a' * 64,
      'addresses': ['10.23.49.155:45879'],
    };
    for (final value in [
      'https://example.com',
      'dukto2:connect:{',
      'x' * 4097,
      for (final changes in [
        {'v': 2},
        {'id': ''},
        {'fingerprint': 'invalid'},
        {'addresses': []},
        {
          'addresses': ['8.8.8.8:443'],
        },
        {
          'addresses': ['10.0.0.1:65536'],
        },
        {'addresses': List.filled(9, '10.0.0.1:45879')},
      ])
        '${ConnectionQr.prefix}${jsonEncode({...data, ...changes})}',
    ]) {
      expect(() => ConnectionQr.parse(value), throwsFormatException);
    }
  });

  test('tries alternate subnet addresses and checks QR identity', () async {
    final code = ConnectionQr.local(peer(), [
      '10.48.255.25:45879',
      '10.23.49.155:45879',
    ]);
    final hosts = <String>[];
    final connected = await code.connect(
      probe: (host, port) async {
        hosts.add(host);
        expect(port, 45879);
        if (host == '10.48.255.25') throw const SocketException('unreachable');
        return peer(host: host);
      },
    );
    expect(hosts.length, 2);
    expect(connected.host, '10.23.49.155');
    await expectLater(
      code.connect(probe: (_, _) async => peer(fingerprint: 'b' * 64)),
      throwsA(isA<SocketException>()),
    );
    await expectLater(
      code.connect(probe: (_, _) async => peer(id: 'different')),
      throwsA(isA<SocketException>()),
    );
  });

  test(
    'QR selects the fingerprint-matched peer directly and rejects impostors',
    () async {
      final controller = Dukto2Controller();
      addTearDown(controller.dispose);
      final code = ConnectionQr.local(peer(), ['10.23.49.155:45879']);
      await controller.connectQr(code, probe: (_, _) async => peer());
      expect(controller.selected?.fingerprint, 'a' * 64);
      final selected = controller.selected;
      await expectLater(
        controller.connectQr(
          code,
          probe: (_, _) async => peer(fingerprint: 'b' * 64),
        ),
        throwsA(isA<SocketException>()),
      );
      expect(controller.selected, same(selected));
    },
  );

  for (final size in [const Size(375, 812), const Size(1100, 1000)]) {
    testWidgets('QR fits scrollable device information dialog at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    scrollable: true,
                    content: SizedBox(
                      width: 360,
                      child: ConnectionQrCard(
                        qr: ConnectionQr.local(peer(), ['10.23.49.155:45879']),
                      ),
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(ConnectionQrCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in AppLanguage.supportedLocales) {
    for (final brightness in Brightness.values) {
      testWidgets('localized QR dialog: $locale, $brightness, large text', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(375, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final strings = lookupAppLocalizations(locale);
        expect(strings.qrVerify, isNot(contains('Wi-Fi')));
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            supportedLocales: AppLanguage.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: dukto2Theme(brightness),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      scrollable: true,
                      content: SizedBox(
                        width: 360,
                        child: ConnectionQrCard(
                          qr: ConnectionQr.local(peer(), [
                            '10.23.49.155:45879',
                          ]),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text(strings.qrVerify), findsOneWidget);
        expect(find.text(strings.subnetHint), findsNothing);
        expect(
          Directionality.of(tester.element(find.byType(ConnectionQrCard))),
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final brightness in Brightness.values) {
    testWidgets(
      'QR and subnet guidance fit small screen with large text: $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(375, 500);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConnectionQrCard(
                    qr: ConnectionQr.local(peer(), ['10.23.49.155:45879']),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.bySemanticsLabel('Dukto2 设备连接二维码'), findsOneWidget);
        expect(
          find.text("同一网络下，即使处于不同子网，只要设备能够互通，点击「扫码连接」扫描此二维码即可连接。"),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
