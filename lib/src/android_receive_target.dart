import 'package:flutter/services.dart';
import 'package:dukto2_core/dukto2_core.dart';

/// The native writer owns a pending MediaStore/SAF document. One bounded chunk
/// is acknowledged after the worker writes it, retaining network backpressure.
class AndroidReceiveTarget implements ReceiveTarget {
  static const bufferSize = 256 * 1024;
  final MethodChannel channel;
  final String id;
  bool _closed = false;
  AndroidReceiveTarget._(this.channel, this.id);

  static Future<AndroidReceiveTarget> create(
    MethodChannel channel,
    String id,
    FileOffer offer,
  ) async {
    await channel.invokeMethod<void>('prepareReceive', {
      'id': id,
      'name': offer.name,
      'size': offer.size,
    });
    return AndroidReceiveTarget._(channel, id);
  }

  @override
  Future<void> addStream(Stream<List<int>> bytes) async {
    final buffer = Uint8List(bufferSize);
    var used = 0;
    Future<void> write() async {
      if (used == 0) return;
      await channel.invokeMethod<void>('writeReceive', {
        'id': id,
        'bytes': Uint8List.sublistView(buffer, 0, used),
      });
      used = 0;
    }

    await for (final chunk in bytes) {
      var offset = 0;
      while (offset < chunk.length) {
        final count = (bufferSize - used).clamp(0, chunk.length - offset);
        buffer.setRange(used, used + count, chunk, offset);
        used += count;
        offset += count;
        if (used == bufferSize) await write();
      }
    }
    await write();
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await channel.invokeMethod<void>('closeReceive', {'id': id});
  }

  @override
  Future<TransferReceipt> commit(FileOffer offer, String sha256) async {
    final result = await channel.invokeMapMethod<String, dynamic>(
      'commitReceive',
      {'id': id},
    );
    final uri = result?['uri'] as String?;
    if (uri == null || Uri.tryParse(uri)?.scheme != 'content') {
      throw const FormatException('Missing committed document URI');
    }
    return TransferReceipt(
      name: offer.name,
      size: offer.size,
      sha256: sha256,
      contentUri: uri,
    );
  }

  @override
  Future<void> discard() async {
    await channel.invokeMethod<void>('discardReceive', {'id': id});
  }
}
