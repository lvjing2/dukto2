import 'dart:io';
import 'dart:typed_data';

import 'package:dukto2/src/connection_qr.dart';
import 'package:dukto2/src/qr_image_decoder.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';

final sampleQr = ConnectionQr.local(
  Peer(
    id: 'test-device',
    name: 'Test',
    host: '192.168.1.2',
    port: 45879,
    fingerprint: 'a' * 64,
  ),
  ['192.168.1.2:45879'],
);

img.Image qrImage(String value, {bool transparent = false}) {
  final matrix = QrImage(
    QrCode.fromData(data: value, errorCorrectLevel: QrErrorCorrectLevel.M),
  );
  const scale = 5, border = 4;
  final size = (matrix.moduleCount + border * 2) * scale;
  final image = img.Image(width: size, height: size, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(255, 255, 255, transparent ? 0 : 255));
  for (var y = 0; y < matrix.moduleCount; y++) {
    for (var x = 0; x < matrix.moduleCount; x++) {
      if (matrix.isDark(y, x)) {
        img.fillRect(
          image,
          x1: (x + border) * scale,
          y1: (y + border) * scale,
          x2: (x + border + 1) * scale - 1,
          y2: (y + border + 1) * scale - 1,
          color: img.ColorRgba8(0, 0, 0, 255),
        );
      }
    }
  }
  return image;
}

void main() {
  test('PNG JPEG BMP preserve the full connection identity and rotated QR', () {
    final image = qrImage(sampleQr.encode());
    final inputs = [
      img.encodePng(image),
      img.encodeJpg(image),
      img.encodeBmp(image),
      img.encodePng(img.copyRotate(image, angle: 90)),
      img.encodePng(qrImage(sampleQr.encode(), transparent: true)),
    ];
    for (final bytes in inputs) {
      final decoded = decodeConnectionQrImage(Uint8List.fromList(bytes))!;
      expect(decoded.fingerprint, sampleQr.fingerprint);
      expect(decoded.id, sampleQr.id);
      expect(decoded.addresses, sampleQr.addresses);
    }
  });

  test('blank images do not connect and unrelated/unsafe QR is rejected', () {
    final blank = img.Image(width: 100, height: 100);
    img.fill(blank, color: img.ColorRgb8(255, 255, 255));
    expect(decodeConnectionQrImage(img.encodePng(blank)), isNull);
    for (final value in [
      'https://example.com',
      sampleQr.encode().replaceAll('192.168.1.2', '8.8.8.8'),
    ]) {
      expect(
        () => decodeConnectionQrImage(img.encodePng(qrImage(value))),
        throwsA(
          isA<QrImageException>().having(
            (e) => e.reason,
            'reason',
            QrImageFailure.invalidQr,
          ),
        ),
      );
    }
  });

  test(
    'compressed bytes and decoded dimensions are bounded before allocation',
    () {
      expect(
        () => decodeConnectionQrImage(Uint8List(maxQrImageBytes + 1)),
        throwsA(
          isA<QrImageException>().having(
            (e) => e.reason,
            'reason',
            QrImageFailure.tooLarge,
          ),
        ),
      );
      final bmp = Uint8List.fromList(
        img.encodeBmp(img.Image(width: 1, height: 1)),
      );
      final header = ByteData.sublistView(bmp);
      header.setInt32(18, 1024 * 1024, Endian.little);
      header.setInt32(22, 1024, Endian.little);
      expect(
        () => decodeConnectionQrImage(bmp),
        throwsA(
          isA<QrImageException>().having(
            (e) => e.reason,
            'reason',
            QrImageFailure.tooLarge,
          ),
        ),
      );
      expect(
        () => decodeConnectionQrImage(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<QrImageException>()),
      );
    },
  );

  test('isolate file decoding leaves the selected image unchanged', () async {
    final folder = await Directory.systemTemp.createTemp('dukto2-qr-image-');
    try {
      final file = File('${folder.path}/qr.png');
      final bytes = img.encodePng(qrImage(sampleQr.encode()));
      await file.writeAsBytes(bytes);
      expect(
        (await readConnectionQrImage(file.path))!.fingerprint,
        sampleQr.fingerprint,
      );
      expect(await file.readAsBytes(), bytes);
    } finally {
      await folder.delete(recursive: true);
    }
  });
}
