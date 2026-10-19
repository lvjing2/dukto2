import 'dart:async';
import 'dart:io';

import 'package:dukto2/src/controller.dart';
import 'package:dukto2/src/desktop_receive_folders.dart';
import 'package:dukto2/src/settings_page.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class DesktopController extends Dukto2Controller {
  final String target;
  DesktopController(
    this.target, {
    super.desktopFolders,
    super.directoryPicker,
    super.filePicker,
  });
  @override
  String get operatingSystem => target;
  @override
  bool get ready => true;
}

final class DiskSelection extends PlatformFile {
  final File file;
  DiskSelection(this.file);
  @override
  String get name => p.basename(file.path);
  @override
  Uri get uri => file.uri;
  @override
  Future<int?> length() => file.length();
  @override
  Stream<Uint8List> readAsByteStream() =>
      file.openRead().map(Uint8List.fromList);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class DesktopNetworkBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() {
  DesktopNetworkBinding();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory root;
  final calls = <MethodCall>[];
  var panelAvailable = false;
  var panelFails = false;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('dukto2-desktop-');
    calls.clear();
    panelAvailable = false;
    panelFails = false;
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, (call) async {
      calls.add(call);
      return switch (call.method) {
        'getDeviceName' => 'Desktop test',
        'notificationStatus' => 'managed',
        'canOpenNotificationSettings' => panelAvailable,
        'openNotificationSettings' when panelFails => throw PlatformException(
          code: 'NOTIFICATIONS',
        ),
        _ => null,
      };
    });
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, null);
    await root.delete(recursive: true);
  });

  for (final target in ['linux', 'windows']) {
    test(
      '$target directory selection is wired, remembered and reset safely',
      () async {
        final support = Directory(p.join(root.path, 'support'));
        final downloads = Directory(p.join(root.path, '下载', 'Dukto2'));
        final custom = await Directory(p.join(root.path, '自选 接收')).create();
        final existing = await File(p.join(custom.path, '已有.txt'))
            .writeAsString('keep');
        DesktopReceiveFolders folders() =>
            DesktopReceiveFolders(support, downloads);
        final first = DesktopController(
          target,
          desktopFolders: folders(),
          directoryPicker: () async => custom.path,
        );
        final second = DesktopController(target, desktopFolders: folders());
        try {
          await first.loadReceiveLocation();
          expect(first.canChooseReceiveFolder, isTrue);
          expect(first.receiveLocation, downloads.path);
          await first.chooseReceiveFolder();
          expect(first.receiveLocation, custom.path);
          expect(first.customReceiveFolder, isTrue);
          await second.loadReceiveLocation();
          expect(second.receiveLocation, custom.path);
          await second.resetReceiveFolder();
          expect(second.receiveLocation, downloads.path);
          expect(second.customReceiveFolder, isFalse);
          expect(await existing.readAsString(), 'keep');
        } finally {
          await first.shutdown();
          first.dispose();
          await second.shutdown();
          second.dispose();
        }
      },
    );

    test('$target history action calls the native directory opener', () async {
      final file = await File(p.join(root.path, '中文.txt'))
          .writeAsString('data');
      final c = DesktopController(target);
      try {
        await c.openHistoryDirectory(
          HistoryEntry(
            TransferReceipt(
              name: '中文.txt',
              size: 4,
              sha256: 'a' * 64,
              file: file,
            ),
            true,
          ),
        );
        final open = calls.where(
          (call) => call.method == 'openHistoryDirectory',
        );
        expect(open, hasLength(1));
        expect((open.single.arguments as Map)['path'], file.path);
      } finally {
        await c.shutdown();
        c.dispose();
      }
    });

    test(
      '$target sleep inhibition spans sending and is released on refusal',
      () async {
        final identity = await DeviceIdentity.loadOrCreate(
          Directory(p.join(root.path, 'identity')),
        );
        var allow = true;
        final receiver = TransferServer(
          identity: identity,
          name: 'Loopback receiver',
          receiveDirectory: Directory(p.join(root.path, 'received')),
          bindAddress: InternetAddress.loopbackIPv4,
          onOffer: (_) async => allow,
        );
        await receiver.start();
        final file = await File(p.join(root.path, 'source.txt'))
            .writeAsString('desktop');
        final c =
            DesktopController(
                target,
                filePicker: () async => [DiskSelection(file)],
              )
              ..name = 'Desktop sender'
              ..selected = receiver.localPeer;
        try {
          await c.pickFile();
          await c.sendFile();
          expect(c.sendPhase, SendPhase.sent, reason: c.error);
          expect(
            calls
                .where((call) => call.method == 'keepAwake')
                .map((call) => call.arguments),
            [true, false],
          );
          calls.clear();
          allow = false;
          await c.pickFile();
          await c.sendFile();
          expect(c.sendPhase, SendPhase.failed);
          expect(
            calls
                .where((call) => call.method == 'keepAwake')
                .map((call) => call.arguments),
            [true, false],
          );
          expect(calls.any((call) => call.method == 'startTransfer'), isFalse);
        } finally {
          await c.shutdown();
          c.dispose();
          await receiver.close();
        }
      },
    );

    test('$target receiving cancellation releases sleep inhibition', () async {
      final c = DesktopController(target);
      try {
        final approval = c.receiveOffer(
          const FileOffer(sender: 'Test', name: 'one.bin', size: 1),
        );
        c.answerOffer(true);
        expect(await approval, isTrue);
        c.cancelTransfer();
        await Future<void>.delayed(Duration.zero);
        expect(c.receiving, isFalse);
        expect(
          calls
              .where((call) => call.method == 'keepAwake')
              .map((call) => call.arguments),
          [true, false],
        );
      } finally {
        await c.shutdown();
        c.dispose();
      }
    });
  }

  test('foreground failure retains its cause when cleanup also fails and releases once', () async {
    final primary = PlatformException(
      code: 'FOREGROUND_DENIED',
      message: 'private details',
    );
    messenger.setMockMethodCallHandler(Dukto2Controller.platform, (call) async {
      calls.add(call);
      if (call.method == 'startTransfer') throw primary;
      if (call.method == 'stopTransfer') {
        throw PlatformException(code: 'STOP_FAILED');
      }
      return null;
    });
    final file = await File(p.join(root.path, 'source.bin'))
        .writeAsBytes([1, 2, 3]);
    final c =
        DesktopController(
            'android',
            filePicker: () async => [DiskSelection(file)],
          )
          ..selected = Peer(
            id: 'peer',
            name: 'Peer',
            host: '127.0.0.1',
            port: 1,
            fingerprint: 'a' * 64,
          );
    try {
      await c.pickFile();
      await c.sendFile();
      expect(c.sendPhase, SendPhase.failed);
      expect(c.busy, isFalse);
      expect(c.lastTransferFailure!.kind, TransferFailureKind.platform);
      expect(c.lastTransferFailure!.stage, TransferStage.platform);
      expect(c.lastTransferFailure!.platformCode, 'FOREGROUND_DENIED');
      expect(
        (c.lastTransferFailure!.cause as PlatformException).code,
        'FOREGROUND_DENIED',
      );
      expect(c.error, isNot(contains('private details')));
      expect(
        c.diagnostics.entries.any((e) => e.event == TransferLogEvent.failed),
        isTrue,
      );
      expect(
        c.diagnostics.entries.any(
          (e) => e.event == TransferLogEvent.cleanupFailed,
        ),
        isTrue,
      );
      await c.shutdown();
      expect(
        calls.where((call) => call.method == 'stopTransfer'),
        hasLength(1),
      );
      expect(
        calls
            .where((call) => call.method == 'keepAwake')
            .map((call) => call.arguments),
        [true, false],
      );
    } finally {
      await c.shutdown();
      c.dispose();
    }
  });

  test(
    'Linux notification settings only open when the desktop supports them',
    () async {
      final c = DesktopController('linux');
      try {
        await c.refreshSystemSettings();
        expect(c.notificationPermission, 'managed');
        expect(c.canOpenNotificationSettings, isFalse);
        await c.openNotificationSettings();
        expect(
          calls.any((call) => call.method == 'openNotificationSettings'),
          isFalse,
        );
        panelAvailable = true;
        await c.refreshSystemSettings();
        expect(c.canOpenNotificationSettings, isTrue);
        await c.openNotificationSettings();
        expect(
          calls.where((call) => call.method == 'openNotificationSettings'),
          hasLength(1),
        );
        panelFails = true;
        await c.openNotificationSettings();
        expect(c.settingsError, contains('无法打开系统设置'));
      } finally {
        await c.shutdown();
        c.dispose();
      }
    },
  );

  testWidgets('Linux hides unavailable notification panels in settings', (
    tester,
  ) async {
    final c = (await tester.runAsync(() async => DesktopController('linux')))!;
    addTearDown(() async {
      await c.shutdown();
      c.dispose();
    });
    await tester.pumpWidget(MaterialApp(home: SettingsPage(controller: c)));
    await tester.pumpAndSettle();
    expect(find.text('系统通知设置'), findsNothing);
    panelAvailable = true;
    await tester.runAsync(c.refreshSystemSettings);
    await tester.pumpAndSettle();
    expect(find.text('系统通知设置'), findsOneWidget);
  });
}
