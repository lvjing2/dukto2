import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dukto2_core/dukto2_core.dart';

String? option(List<String> args, String name) {
  final index = args.indexOf(name);
  return index >= 0 && index + 1 < args.length ? args[index + 1] : null;
}

Future<void> main(List<String> args) async {
  if (args.isEmpty || !['receive', 'probe', 'send'].contains(args.first)) {
    stderr.writeln('''Dukto2 CLI (same core as the Flutter app)
  receive --dir PATH [--identity PATH] [--port PORT] [--name NAME] [--auto-accept]
  probe --host IPV4 --port PORT
  send --host IPV4 --port PORT --code CODE --file PATH [--name NAME]
Compare --code with the code displayed on the receiving device.
--auto-accept is only intended for controlled local testing.''');
    exitCode = 64;
    return;
  }
  try {
    if (args.first == 'receive') {
      final directory = Directory(option(args, '--dir') ?? './received');
      final identity = await DeviceIdentity.loadOrCreate(
        Directory(option(args, '--identity') ?? './.dukto2-identity'),
      );
      final server = TransferServer(
        identity: identity,
        name: option(args, '--name') ?? Platform.localHostname,
        receiveDirectory: directory,
        onOffer: (offer) async {
          stdout.writeln(
            'OFFER ${jsonEncode(offer.toJson())} from ${offer.remoteAddress}',
          );
          if (args.contains('--auto-accept')) return true;
          stdout.write('Accept? [y/N] ');
          // Use auto-accept for automated tests; interactive mode is for manual use.
          return stdin.readLineSync()?.toLowerCase() == 'y';
        },
      );
      await server.start(port: int.parse(option(args, '--port') ?? '0'));
      final discovery = PeerDiscovery(server.localPeer);
      try {
        await discovery.start();
      } on Object catch (error) {
        stderr.writeln('Discovery unavailable: $error');
      }
      server.received.listen(
        (receipt) => stdout.writeln(
          'RECEIVED ${jsonEncode({'name': receipt.name, 'size': receipt.size, 'sha256': receipt.sha256, 'path': receipt.file!.absolute.path})}',
        ),
      );
      server.errors.listen((error) => stderr.writeln('ERROR $error'));
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      stdout.writeln(
        'READY ${jsonEncode({...server.localPeer.toJson(), 'code': identity.code, 'addresses': interfaces.expand((i) => i.addresses).map((a) => '${a.address}:${server.port}').toList()})}',
      );
      final done = Completer<void>();
      final signals = <StreamSubscription<ProcessSignal>>[];
      for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
        signals.add(
          signal.watch().listen((_) {
            if (!done.isCompleted) done.complete();
          }),
        );
      }
      await done.future;
      for (final subscription in signals) {
        await subscription.cancel();
      }
      await discovery.close();
      await server.close();
    } else {
      final peer = await TransferClient.probe(
        option(args, '--host')!,
        int.parse(option(args, '--port')!),
      );
      if (args.first == 'probe') {
        stdout.writeln(
          jsonEncode({...peer.toJson(), 'code': peer.code, 'host': peer.host}),
        );
        return;
      }
      final expected = option(
        args,
        '--code',
      )?.replaceAll(' ', '').toUpperCase();
      if (expected != peer.code.replaceAll(' ', '')) {
        throw const FormatException('Verification code differs from receiver');
      }
      final client = TransferClient();
      try {
        final receipt = await client.sendFile(
          peer: peer,
          file: File(option(args, '--file')!),
          sender: option(args, '--name') ?? 'Dukto2 CLI',
        );
        stdout.writeln(
          'SENT ${jsonEncode({'name': receipt.name, 'size': receipt.size, 'sha256': receipt.sha256})}',
        );
      } finally {
        await client.close();
      }
    }
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
