import 'dart:io';

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

class FileReceiveTarget implements ReceiveTarget {
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
