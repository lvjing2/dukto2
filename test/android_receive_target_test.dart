import 'dart:async';
import 'dart:typed_data';

import 'package:dukto2/src/android_receive_target.dart';
import 'package:dukto2/src/platform_receive_target.dart';
import 'package:dukto2_core/dukto2_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dukto2/storage-test');
  const offer = FileOffer(sender: 'Mac', name: 'large.bin', size: 800001);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'iOS commit supplies the digest and accepts only its owned receipt scheme',
    () async {
      var uri = 'dukto2-received://owned-document';
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'commitReceive') {
          expect((call.arguments as Map)['sha256'], 'checked-digest');
          return {'uri': uri};
        }
        return null;
      });
      final target = await PlatformReceiveTarget.create(
        channel,
        'id',
        offer,
        uriScheme: 'dukto2-received',
      );
      final receipt = await target.commit(offer, 'checked-digest');
      expect(receipt.contentUri, uri);
      uri = 'file:///unrelated/document';
      await expectLater(
        target.commit(offer, 'checked-digest'),
        throwsFormatException,
      );
    },
  );

  test(
    'platform writes are bounded and await the native writer before advancing',
    () async {
      final firstWrite = Completer<void>();
      final release = Completer<void>();
      final written = BytesBuilder(copy: false);
      final sizes = <int>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'writeReceive') {
          final bytes = (call.arguments as Map)['bytes'] as Uint8List;
          sizes.add(bytes.length);
          if (sizes.length == 1) {
            firstWrite.complete();
            await release.future;
          }
          written.add(Uint8List.fromList(bytes));
        }
        if (call.method == 'commitReceive') {
          return {'uri': 'content://media/external/downloads/42'};
        }
        return null;
      });
      final target = await AndroidReceiveTarget.create(channel, 'id', offer);
      final bytes = Uint8List.fromList(
        List.generate(offer.size, (i) => i % 251),
      );
      final writing = target.addStream(Stream.value(bytes));
      await firstWrite.future;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(sizes, [AndroidReceiveTarget.bufferSize]);
      release.complete();
      await writing;
      expect(sizes.reduce((a, b) => a + b), offer.size);
      expect(
        sizes.every((size) => size <= AndroidReceiveTarget.bufferSize),
        isTrue,
      );
      expect(written.takeBytes(), bytes);
      await target.close();
      final receipt = await target.commit(offer, 'checked-digest');
      expect(receipt.file, isNull);
      expect(receipt.contentUri, 'content://media/external/downloads/42');
    },
  );

  test(
    'native write failure propagates and destination can be discarded',
    () async {
      var discarded = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'writeReceive') {
          throw PlatformException(code: 'DISK_FULL');
        }
        if (call.method == 'discardReceive') discarded = true;
        return null;
      });
      final target = await AndroidReceiveTarget.create(channel, 'id', offer);
      await expectLater(
        target.addStream(Stream.value(Uint8List(10))),
        throwsA(isA<PlatformException>()),
      );
      await target.close();
      await target.discard();
      expect(discarded, isTrue);
    },
  );
}
