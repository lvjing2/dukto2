// Explicit opt-in integration validation. Generates real bytes (not sparse
// lengths), writes a real destination and independently hashes its disk contents.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dukto2_core/dukto2_core.dart';

Future<void> main(List<String> args) async {
  final size = args.isEmpty
      ? 4 * 1024 * 1024 * 1024 + 17
      : int.parse(args.first);
  final useDiskSource = args.contains('--disk-source');
  final textMode = args.contains('--text');
  final root = await Directory.systemTemp.createTemp(
    'dukto2-large-validation-',
  );
  final identity = await DeviceIdentity.loadOrCreate(
    Directory('${root.path}/identity'),
  );
  final received = Directory('${root.path}/received');
  final server = TransferServer(
    identity: identity,
    name: 'Loopback receiver',
    receiveDirectory: received,
    onOffer: (_) async => true,
    bindAddress: InternetAddress.loopbackIPv4,
  );
  await server.start();
  final client = TransferClient();
  final timer = Stopwatch()..start();
  final baselineRss = ProcessInfo.currentRss;
  var peakRss = baselineRss;
  var bytes = 0;
  final sample = Timer.periodic(const Duration(milliseconds: 100), (_) {
    if (ProcessInfo.currentRss > peakRss) peakRss = ProcessInfo.currentRss;
  });
  final log = Timer.periodic(const Duration(seconds: 5), (_) {
    stdout.writeln(
      jsonEncode({
        'progress': bytes,
        'total': size,
        'rss': ProcessInfo.currentRss,
      }),
    );
  });
  final progress = server.progress.listen((event) => bytes = event.bytes);
  try {
    // Fixed deterministic non-zero byte pattern. Each chunk is actually streamed
    // through TLS and written; no preallocation, holes, or filesystem cloning.
    final pattern = Uint8List.fromList(
      List.generate(
        65536,
        (i) => textMode ? 65 + i % 26 : (i * 131 + i ~/ 251) % 256,
      ),
    );
    Stream<List<int>> source() async* {
      var remaining = size;
      while (remaining > 0) {
        final count = remaining < pattern.length ? remaining : pattern.length;
        yield Uint8List.sublistView(pattern, 0, count);
        remaining -= count;
      }
    }

    File? sourceFile;
    String? sourceDiskHash;
    if (useDiskSource) {
      sourceFile = File('${root.path}/source.bin');
      final sink = sourceFile.openWrite();
      try {
        await sink.addStream(source());
      } finally {
        await sink.close();
      }
      sourceDiskHash = (await sha256.bind(sourceFile.openRead()).first)
          .toString();
    }
    final done = server.received.first;
    final sent = await client.sendStream(
      peer: server.localPeer,
      name: textMode ? 'sixteen-mib-text.txt' : 'over-4gb.bin',
      kind: textMode ? TransferKind.text : TransferKind.file,
      size: size,
      openRead: sourceFile == null ? source : sourceFile.openRead,
      sender: 'Generated streaming source',
    );
    final receipt = await done;
    final uploadMs = timer.elapsedMilliseconds;
    final diskHash = (await sha256.bind(receipt.file!.openRead()).first)
        .toString();
    final actualSize = await receipt.file!.length();
    if (diskHash != sent.sha256 ||
        diskHash != receipt.sha256 ||
        actualSize != size ||
        (sourceDiskHash != null && diskHash != sourceDiskHash)) {
      throw StateError('Independent disk verification failed');
    }
    stdout.writeln(
      jsonEncode({
        'result': 'passed',
        'bytes': size,
        if (textMode) 'textPreviewCharacters': receipt.text!.length,
        if (textMode) 'textPreviewTruncated': receipt.textTruncated,
        'sha256': diskHash,
        'uploadMs': uploadMs,
        'totalMs': timer.elapsedMilliseconds,
        'baselineRss': baselineRss,
        'peakRss': peakRss,
        'scope': useDiskSource
            ? 'same-process Mac TLS loopback, real source and destination files; not GUI/Android'
            : 'same-process Mac TLS loopback, generated source to real disk; not GUI/Android or source-disk benchmark',
      }),
    );
  } finally {
    log.cancel();
    sample.cancel();
    await progress.cancel();
    await client.close();
    await server.close();
    await root.delete(recursive: true);
  }
}
