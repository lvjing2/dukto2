import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;

import 'models.dart';

/// A newly created destination owned by one transfer. Implementations must stream
/// with backpressure, publish only on commit, and discard only their own data.
abstract class ReceiveTarget {
  Future<void> addStream(Stream<List<int>> bytes);
  Future<void> close();
  Future<TransferReceipt> commit(FileOffer offer, String sha256);
  Future<void> discard();
}

typedef ReceiveTargetFactory =
    Future<ReceiveTarget> Function(String transferId, FileOffer offer);

/// Large text is validated incrementally and stored through the platform writer.
/// Only the bounded preview is kept in memory or exposed before opening a file.
class _TextPreview implements Sink<String> {
  final buffer = StringBuffer();
  bool hasContent = false;
  @override
  void add(String value) {
    if (!hasContent && value.trim().isNotEmpty) hasContent = true;
    final remaining = maxTextPreviewCharacters - buffer.length;
    if (remaining > 0) {
      buffer.write(
        value.length <= remaining ? value : value.substring(0, remaining),
      );
    }
  }

  @override
  void close() {}
}

class TextReceiveTarget implements ReceiveTarget {
  final ReceiveTarget? storage;
  final _bytes = <int>[];
  final _preview = _TextPreview();
  int _length = 0;
  TextReceiveTarget({this.storage});
  @override
  Future<void> addStream(Stream<List<int>> bytes) async {
    final decoder = utf8.decoder.startChunkedConversion(_preview);
    final checked = bytes.map((chunk) {
      _length += chunk.length;
      if (_length > maxTextBytes ||
          (storage == null && _length > maxInlineTextBytes)) {
        throw const FormatException('Text exceeds agreed storage limit');
      }
      decoder.add(chunk);
      if (storage == null) _bytes.addAll(chunk);
      return chunk;
    });
    if (storage != null) {
      await storage!.addStream(checked);
    } else {
      await checked.drain<void>();
    }
    decoder.close(); // Reject incomplete UTF-8 before any successful receipt.
  }

  @override
  Future<void> close() async => storage?.close();
  @override
  Future<TransferReceipt> commit(FileOffer offer, String sha256) async {
    if (_length != offer.size || !_preview.hasContent) {
      throw const FormatException('Invalid text content');
    }
    final saved = await storage?.commit(offer, sha256);
    var preview = _preview.buffer.toString();
    if (preview.isNotEmpty &&
        preview.codeUnitAt(preview.length - 1) >= 0xd800 &&
        preview.codeUnitAt(preview.length - 1) <= 0xdbff) {
      preview = preview.substring(0, preview.length - 1);
    }
    final receipt = TransferReceipt(
      name: offer.name,
      size: offer.size,
      sha256: sha256,
      text: storage == null ? utf8.decode(_bytes) : preview,
      textTruncated: storage != null,
      file: saved?.file,
      contentUri: saved?.contentUri,
    );
    _bytes.clear();
    return receipt;
  }

  @override
  Future<void> discard() async {
    _bytes.clear();
    await storage?.discard();
  }
}

class FileReceiveTarget implements ReceiveTarget {
  static Future<void> recover(Directory parent) async {
    if (!await parent.exists()) return;
    await for (final entity in parent.list(followLinks: false)) {
      if (entity is Directory &&
          RegExp(r'^[a-f0-9]{48}$').hasMatch(p.basename(entity.path))) {
        if (await File(p.join(entity.path, '.partial')).exists() ||
            await entity.list().isEmpty) {
          await entity.delete(recursive: true);
        }
      }
    }
  }

  final Directory directory;
  IOSink? _sink;
  bool _committed = false;
  FileReceiveTarget._(this.directory);

  static Future<FileReceiveTarget> create(Directory parent, String id) async =>
      FileReceiveTarget._(await Directory(p.join(parent.path, id)).create());

  File get _temporary => File(p.join(directory.path, '.partial'));

  @override
  Future<void> addStream(Stream<List<int>> bytes) async {
    _sink = _temporary.openWrite();
    await _sink!.addStream(bytes);
    await _sink!.flush();
  }

  @override
  Future<void> close() async {
    final sink = _sink;
    _sink = null;
    await sink?.close();
  }

  @override
  Future<TransferReceipt> commit(FileOffer offer, String sha256) async {
    final file = await _temporary.rename(p.join(directory.path, offer.name));
    _committed = true;
    return TransferReceipt(
      name: offer.name,
      size: offer.size,
      sha256: sha256,
      file: file,
    );
  }

  @override
  Future<void> discard() async {
    await close();
    if (!_committed && await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
