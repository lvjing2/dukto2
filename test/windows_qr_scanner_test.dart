import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:dukto2/src/connection_qr.dart';
import 'package:dukto2/src/windows_qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'qr_image_decoder_test.dart' show sampleQr;

class FakeCamera extends CameraPlatform {
  List<CameraDescription> cameras;
  bool denied;
  String? picture;
  int next = 0;
  final disposed = <int>[];
  final opened = <String>[];
  final initialized = StreamController<CameraInitializedEvent>.broadcast();
  final errors = StreamController<CameraErrorEvent>.broadcast();
  final closing = StreamController<CameraClosingEvent>.broadcast();
  FakeCamera({this.cameras = const [], this.denied = false, this.picture});
  @override
  Future<List<CameraDescription>> availableCameras() async {
    if (denied) throw CameraException('CameraAccessDenied', 'test');
    return cameras;
  }

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings mediaSettings,
  ) async {
    expectSync(mediaSettings.enableAudio, isFalse);
    opened.add(cameraDescription.name);
    return ++next;
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    initialized.add(
      CameraInitializedEvent(
        cameraId,
        1280,
        720,
        ExposureMode.auto,
        false,
        FocusMode.auto,
        false,
      ),
    );
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      initialized.stream.where((e) => e.cameraId == cameraId);
  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) => errors.stream;
  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) => closing.stream;
  @override
  Future<void> dispose(int cameraId) async {
    disposed.add(cameraId);
  }

  @override
  Future<XFile> takePicture(int cameraId) async {
    return XFile(picture ?? '/nonexistent-dukto2-test-capture.jpg');
  }

  @override
  Widget buildPreview(int cameraId) => const ColoredBox(color: Colors.black);
}

// Capture cleanup uses real filesystem IO; allow it to finish outside fake time.
Future<void> settleCamera(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  for (final scenario in [
    (false, const Size(375, 500), Brightness.light),
    (true, const Size(375, 500), Brightness.dark),
    (false, const Size(900, 500), Brightness.dark),
    (true, const Size(500, 900), Brightness.light),
  ]) {
    final denied = scenario.$1;
    testWidgets(
      'image connection works without camera (denied=$denied, size=${scenario.$2}), large text',
      (tester) async {
        tester.view.physicalSize = scenario.$2;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final camera = FakeCamera(denied: denied);
        ConnectionQr? result;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: scenario.$3),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await Navigator.push<ConnectionQr>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MediaQuery(
                          data: const MediaQueryData(
                            textScaler: TextScaler.linear(2),
                            disableAnimations: true,
                          ),
                          child: WindowsQrScannerPage(
                            camera: camera,
                            pickImage: () async => 'fixture.png',
                            decodeImage: (_) async => sampleQr,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('从图片识别'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('从图片识别'));
        await tester.tap(find.text('从图片识别'));
        await tester.pumpAndSettle();
        expect(result!.fingerprint, sampleQr.fingerprint);
        expect(camera.opened, isEmpty);
        await camera.initialized.close();
        await camera.errors.close();
        await camera.closing.close();
      },
    );
  }

  testWidgets(
    'camera result closes capture and deletes only its temporary photo',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync(
        'dukto2-camera-test-',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      final photo = File('${directory.path}/capture.jpg')
        ..writeAsBytesSync([0]);
      final camera = FakeCamera(
        picture: photo.path,
        cameras: const [
          CameraDescription(
            name: 'USB Camera',
            lensDirection: CameraLensDirection.external,
            sensorOrientation: 0,
          ),
        ],
      );
      ConnectionQr? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              child: const Text('open'),
              onPressed: () async {
                result = await Navigator.push<ConnectionQr>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WindowsQrScannerPage(
                      camera: camera,
                      decodeImage: (_) async => sampleQr,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 800));
      await settleCamera(tester);
      expect(result?.fingerprint, sampleQr.fingerprint);
      expect(photo.existsSync(), isFalse);
      expect(camera.disposed, [1]);
      await camera.initialized.close();
      await camera.errors.close();
      await camera.closing.close();
    },
  );

  testWidgets(
    'rear camera preferred; switching, background and close release camera',
    (tester) async {
      final camera = FakeCamera(
        cameras: const [
          CameraDescription(
            name: 'Front',
            lensDirection: CameraLensDirection.front,
            sensorOrientation: 0,
          ),
          CameraDescription(
            name: 'Rear',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          home: WindowsQrScannerPage(
            camera: camera,
            decodeImage: (_) async => null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(camera.opened, ['Rear']);
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Front').last);
      await settleCamera(tester);
      expect(camera.opened, ['Rear', 'Front']);
      expect(camera.disposed, [1]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await settleCamera(tester);
      expect(camera.disposed, [1, 2]);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settleCamera(tester);
      expect(camera.opened.length, 3);
      await tester.pumpWidget(const SizedBox());
      await settleCamera(tester);
      expect(camera.disposed, [1, 2, 3]);
      await camera.initialized.close();
      await camera.errors.close();
      await camera.closing.close();
    },
  );
}
