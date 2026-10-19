// Explicit opt-in physical-device validation. Uses the production TLS core;
// Pacing changes only the test source stream, never the protocol.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dukto2_core/dukto2_core.dart';

String? option(List<String> args, String key) {
  final index = args.indexOf(key);
  return index >= 0 && index + 1 < args.length ? args[index + 1] : null;
}

void log(Map<String, Object?> data) => stdout.writeln(jsonEncode(data));

Stream<List<int>> paced(Stream<List<int>> source, int bytesPerSecond) async* {
  final clock = Stopwatch()..start();
  var total = 0;
  await for (final bytes in source) {
    for (var offset = 0; offset < bytes.length; offset += 65536) {
      final end = (offset + 65536).clamp(0, bytes.length);
      final chunk = Uint8List.fromList(bytes.sublist(offset, end));
      total += chunk.length;
      if (bytesPerSecond > 0) {
        final delay =
            total * 1000000 ~/ bytesPerSecond - clock.elapsedMicroseconds;
        if (delay > 0) {
          await Future<void>.delayed(Duration(microseconds: delay));
        }
      }
      yield chunk;
    }
  }
}

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first != 'send') {
    stderr.writeln('''Controlled LAN validation (not a GUI benchmark):
  send --host IPV4 --port PORT --code CODE --file PATH [--size BYTES] [--name NAME] [--mib-per-second RATE]
Compare the receiving device's actual code before using --code.''');
    exitCode = 64;
    return;
  }
  final rate =
      ((double.tryParse(option(args, '--mib-per-second') ?? '0') ?? -1) *
              1024 *
              1024)
          .round();
  if (rate < 0) throw ArgumentError('Rate must be non-negative');
  final clock = Stopwatch()..start();
  var bytes = 0;
  var total = 0;
  var peakRss = ProcessInfo.currentRss;
  final sample = Timer.periodic(const Duration(seconds: 2), (_) {
    if (ProcessInfo.currentRss > peakRss) peakRss = ProcessInfo.currentRss;
    log({
      'event': 'progress',
      'bytes': bytes,
      'total': total,
      'elapsedMs': clock.elapsedMilliseconds,
      'rss': ProcessInfo.currentRss,
    });
  });
  TransferClient? client;
  final subscriptions = <StreamSubscription<dynamic>>[];
  try {
    final file = File(option(args, '--file')!);
    total = int.parse(option(args, '--size') ?? '${await file.length()}');
    if (total < 0 || total > await file.length()) {
      throw ArgumentError('Size must fit the real source file');
    }
    final expected = (await sha256.bind(file.openRead(0, total)).first)
        .toString();
    final peer = await TransferClient.probe(
      option(args, '--host')!,
      int.parse(option(args, '--port')!),
    );
    if (option(args, '--code')?.replaceAll(' ', '').toUpperCase() !=
        peer.code.replaceAll(' ', '')) {
      throw const FormatException('Receiver code mismatch');
    }
    log({
      'event': 'ready',
      'scope': 'validation CLI -> receiver at ${peer.host}',
      'expectedSha256': expected,
      'total': total,
      'rate': rate,
      'pid': pid,
    });
    client = TransferClient();
    subscriptions.add(client.progress.listen((event) => bytes = event.bytes));
    final sent = await client.sendStream(
      peer: peer,
      name: option(args, '--name') ?? file.uri.pathSegments.last,
      size: total,
      openRead: () => paced(file.openRead(0, total), rate),
      sender: 'Dukto2 controlled LAN validation',
    );
    if (sent.sha256 != expected || sent.size != total) {
      throw StateError('Source and receipt differ');
    }
    log({
      'event': 'passed',
      'bytes': total,
      'sha256': sent.sha256,
      'elapsedMs': clock.elapsedMilliseconds,
      'peakRss': peakRss,
    });
  } on Object catch (error) {
    log({
      'event': 'failed',
      'error': error.toString(),
      'bytes': bytes,
      'elapsedMs': clock.elapsedMilliseconds,
      'peakRss': peakRss,
    });
    exitCode = 1;
  } finally {
    sample.cancel();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await client?.close();
  }
}
