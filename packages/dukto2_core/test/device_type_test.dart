import 'dart:convert';
import 'dart:io';

import 'package:dukto2_core/dukto2_core.dart';
import 'package:test/test.dart';

void main() {
  Peer peer(DeviceType type) => Peer(
    id: 'peer',
    name: '任意系统设备名称',
    host: '127.0.0.1',
    port: 45879,
    fingerprint: 'a' * 64,
    deviceType: type,
  );

  test('announcements preserve device types through JSON serialization', () {
    for (final type in DeviceType.values) {
      final json =
          jsonDecode(jsonEncode(peer(type).toJson())) as Map<String, dynamic>;
      expect(Peer.fromJson(json, '127.0.0.1').deviceType, type);
    }
  });

  test(
    'legacy and unknown device types remain usable without name guessing',
    () {
      final json = peer(DeviceType.unknown).toJson();
      expect(json.containsKey('deviceType'), isFalse);
      for (final value in [null, 'future-device', 1, <String, Object>{}]) {
        final parsed = Peer.fromJson({
          ...json,
          'name': 'iPad',
          'deviceType': value,
        }, '127.0.0.1');
        expect(parsed.deviceType, DeviceType.unknown);
        expect(parsed.fingerprint, 'a' * 64);
      }
    },
  );

  test(
    'HTTPS probing and endpoint discovery preserve the actual server type',
    () async {
      final root = await Directory.systemTemp.createTemp('dukto2-device-type-');
      final identity = await DeviceIdentity.loadOrCreate(
        Directory('${root.path}/identity'),
      );
      final server = TransferServer(
        identity: identity,
        name: '任意系统设备名称',
        deviceType: DeviceType.tablet,
        receiveDirectory: Directory('${root.path}/received'),
        onOffer: (_) async => false,
        bindAddress: InternetAddress.loopbackIPv4,
      );
      final discovery = PeerDiscovery(
        peer(DeviceType.computer),
        subnetFallback: false,
      );
      try {
        await server.start();
        final probed = await TransferClient.probe('127.0.0.1', server.port);
        expect(probed.deviceType, DeviceType.tablet);
        expect(probed.fingerprint, identity.fingerprint);
        final found = discovery.changes.first;
        await discovery.confirmEndpoint('127.0.0.1', server.port);
        final discovered = (await found.timeout(
          const Duration(seconds: 5),
        )).single;
        expect(discovered.deviceType, probed.deviceType);
        expect(discovered.fingerprint, probed.fingerprint);
      } finally {
        await discovery.close();
        await server.close();
        await root.delete(recursive: true);
      }
    },
  );
}
