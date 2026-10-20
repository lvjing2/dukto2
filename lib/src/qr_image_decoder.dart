import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

import 'connection_qr.dart';

enum QrImageFailure { tooLarge, unreadable, invalidQr }

class QrImageException implements Exception {
  final QrImageFailure reason;
  const QrImageException(this.reason);
}

const maxQrImageBytes = 20 * 1024 * 1024;
const maxQrImagePixels = 16 * 1024 * 1024;

/// Read and decode off the UI isolate. The image never leaves this device.
Future<ConnectionQr?> readConnectionQrImage(String path) => Isolate.run(() {
  final file = File(path);
  if (file.lengthSync() > maxQrImageBytes) {
    throw const QrImageException(QrImageFailure.tooLarge);
  }
  // Bound the read even if the file grows after the length check.
  final input = file.openSync();
  try {
    return decodeConnectionQrImage(input.readSync(maxQrImageBytes + 1));
  } finally {
    input.closeSync();
  }
});

ConnectionQr? decodeConnectionQrImage(Uint8List bytes) {
  if (bytes.length > maxQrImageBytes) {
    throw const QrImageException(QrImageFailure.tooLarge);
  }
  try {
    final decoder = img.findDecoderForData(bytes);
    if (decoder is! img.PngDecoder &&
        decoder is! img.JpegDecoder &&
        decoder is! img.BmpDecoder) {
      throw const QrImageException(QrImageFailure.unreadable);
    }
    final info = decoder!.startDecode(bytes);
    if (info == null || info.width < 1 || info.height < 1) {
      throw const QrImageException(QrImageFailure.unreadable);
    }
    if (info.width * info.height > maxQrImagePixels) {
      throw const QrImageException(QrImageFailure.tooLarge);
    }
    var image = decoder.decodeFrame(0);
    if (image == null) {
      throw const QrImageException(QrImageFailure.unreadable);
    }
    image = img.bakeOrientation(image);
    if (image.width > 1800 || image.height > 1800) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? 1800 : null,
        height: image.height > image.width ? 1800 : null,
      );
    }
    image = image.convert(format: img.Format.uint8, numChannels: 4);
    // Explicit ARGB values avoid native byte-order and channel-order assumptions.
    final pixels = Int32List(image.width * image.height);
    for (final pixel in image) {
      final alpha = pixel.a.toInt();
      int blend(num value) =>
          (value.toInt() * alpha + 255 * (255 - alpha)) ~/ 255;
      pixels[pixel.y * image.width + pixel.x] =
          (blend(pixel.r) << 16) | (blend(pixel.g) << 8) | blend(pixel.b);
    }
    final source = RGBLuminanceSource(image.width, image.height, pixels);
    String? text;
    for (final luminance in [source, source.invert()]) {
      try {
        text = QRCodeReader()
            .decode(BinaryBitmap(HybridBinarizer(luminance)))
            .text;
        break;
      } on ReaderException {
        // A camera frame without a readable code is expected, not a failure.
      }
    }
    if (text == null) return null;
    try {
      return ConnectionQr.parse(text);
    } on FormatException {
      throw const QrImageException(QrImageFailure.invalidQr);
    }
  } on QrImageException {
    rethrow;
  } on Object {
    throw const QrImageException(QrImageFailure.unreadable);
  }
}
