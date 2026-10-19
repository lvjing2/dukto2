import 'dart:convert';
import 'dart:io';

import 'package:dukto2_core/dukto2_core.dart';

const subnetConnectionHint = '同一网络下，即使处于不同子网，也可以扫码连接；设备之间需要能够直接通信。';

/// Addresses plus the full device fingerprint, read from the other screen.
/// Identity is accepted only after HTTPS matches; this never authorizes files.
class ConnectionQr {
  static const prefix = 'dukto2:connect:';
  final String id;
  final String fingerprint;
  final List<String> addresses;

  ConnectionQr._(this.id, this.fingerprint, this.addresses);

  static bool _validAddress(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return false;
    final ip = InternetAddress.tryParse(parts[0]);
    final port = int.tryParse(parts[1]);
    if (ip?.type != InternetAddressType.IPv4 ||
        port == null ||
        port < 1 ||
        port > 65535) {
      return false;
    }
    final bytes = ip!.rawAddress;
    // Limit camera-supplied endpoints to local/private unicast addresses.
    return bytes[0] == 10 ||
        (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
        (bytes[0] == 192 && bytes[1] == 168) ||
        (bytes[0] == 169 && bytes[1] == 254);
  }

  factory ConnectionQr.local(Peer peer, Iterable<String> addresses) =>
      ConnectionQr._(
        peer.id,
        peer.fingerprint,
        List.unmodifiable(addresses.where(_validAddress).toSet().take(8)),
      );

  String encode() =>
      '$prefix${jsonEncode({'v': 1, 'id': id, 'fingerprint': fingerprint, 'addresses': addresses})}';

  factory ConnectionQr.parse(String value) {
    if (value.length > 4096 || !value.startsWith(prefix)) {
      throw const FormatException('请扫描 Dukto2 的连接二维码');
    }
    try {
      final data =
          jsonDecode(value.substring(prefix.length)) as Map<String, dynamic>;
      final id = data['id'] as String;
      final fingerprint = data['fingerprint'] as String;
      final addresses = (data['addresses'] as List).cast<String>();
      if (data['v'] != 1 ||
          id.isEmpty ||
          id.length > 128 ||
          !RegExp(r'^[a-f0-9]{64}$').hasMatch(fingerprint) ||
          addresses.isEmpty ||
          addresses.length > 8 ||
          !addresses.every(_validAddress)) {
        throw const FormatException();
      }
      return ConnectionQr._(
        id,
        fingerprint,
        List.unmodifiable(addresses.toSet()),
      );
    } on Object {
      throw const FormatException('连接二维码无效，请在对方设备重新打开本机信息');
    }
  }

  Future<Peer> connect({Future<Peer> Function(String, int)? probe}) async {
    probe ??= (host, port) =>
        TransferClient.probe(host, port, timeout: const Duration(seconds: 2));
    final results = await Future.wait(
      addresses.map((address) async {
        final parts = address.split(':');
        try {
          final peer = await probe!(parts[0], int.parse(parts[1]));
          return peer.id == id && peer.fingerprint == fingerprint ? peer : null;
        } on Object {
          return null;
        }
      }),
    );
    for (final peer in results) {
      if (peer != null) return peer;
    }
    throw const SocketException(
      '无法连接二维码中的设备，或设备身份不一致。请确认对方应用已打开、网络允许设备互通，再重新扫码。',
    );
  }
}
