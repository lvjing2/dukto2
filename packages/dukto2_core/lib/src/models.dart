import 'dart:io';
import 'dart:math';

String randomId([int length = 24]) {
  final random = Random.secure();
  return List.generate(
    length,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

String verificationCode(String fingerprint) => RegExp('.{4}')
    .allMatches(fingerprint.substring(0, 16).toUpperCase())
    .map((m) => m[0])
    .join(' ');

class Peer {
  final String id;
  final String name;
  final String host;
  final int port;
  final String fingerprint;
  final DateTime lastSeen;

  Peer({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.fingerprint,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  String get code => verificationCode(fingerprint);
  Map<String, Object> toJson() => {
    'v': 1,
    'id': id,
    'name': name,
    'port': port,
    'fingerprint': fingerprint,
  };

  factory Peer.fromJson(Map<String, dynamic> json, String host) {
    final id = json['id'];
    final name = json['name'];
    final port = json['port'];
    final fingerprint = json['fingerprint'];
    if (json['v'] != 1 ||
        id is! String ||
        id.length > 128 ||
        id.isEmpty ||
        name is! String ||
        name.isEmpty ||
        name.length > 128 ||
        port is! int ||
        port < 1 ||
        port > 65535 ||
        fingerprint is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(fingerprint)) {
      throw const FormatException('Invalid peer announcement');
    }
    return Peer(
      id: id,
      name: name,
      host: host,
      port: port,
      fingerprint: fingerprint,
    );
  }
}

class FileOffer {
  final String sender;
  final String name;
  final int size;
  final String remoteAddress;

  const FileOffer({
    required this.sender,
    required this.name,
    required this.size,
    this.remoteAddress = '',
  });

  Map<String, Object> toJson() => {
    'sender': sender,
    'name': name,
    'size': size,
  };

  factory FileOffer.fromJson(Map<String, dynamic> json, String address) {
    final sender = json['sender'];
    final name = json['name'];
    final size = json['size'];
    if (sender is! String ||
        sender.isEmpty ||
        sender.length > 128 ||
        name is! String ||
        !validFileName(name) ||
        size is! int ||
        size < 0 ||
        size > 1024 * 1024 * 1024 * 1024) {
      throw const FormatException('Invalid file offer');
    }
    return FileOffer(
      sender: sender,
      name: name,
      size: size,
      remoteAddress: address,
    );
  }
}

bool validFileName(String name) =>
    name.isNotEmpty &&
    name.length <= 240 &&
    name != '.' &&
    name != '..' &&
    name.toLowerCase() != '.partial' &&
    !name.endsWith('.') &&
    !name.endsWith(' ') &&
    !RegExp(r'[\x00-\x1f\x7f/\\:*?"<>|]').hasMatch(name) &&
    !RegExp(
      r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\.|$)',
      caseSensitive: false,
    ).hasMatch(name);

class TransferProgress {
  final String id;
  final String name;
  final int total;
  final int bytes;
  final bool incoming;
  const TransferProgress({
    required this.id,
    required this.name,
    required this.total,
    required this.bytes,
    required this.incoming,
  });
}

class TransferReceipt {
  final String name;
  final int size;
  final String sha256;
  final File? file;
  const TransferReceipt({
    required this.name,
    required this.size,
    required this.sha256,
    this.file,
  });
}

class TransferCancelled implements Exception {
  @override
  String toString() => 'Transfer cancelled';
}

class CancellationToken {
  bool _cancelled = false;
  final List<void Function()> _callbacks = [];
  bool get isCancelled => _cancelled;
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final callback in List.of(_callbacks)) {
      callback();
    }
    _callbacks.clear();
  }

  void onCancel(void Function() callback) {
    if (_cancelled) {
      callback();
    } else {
      _callbacks.add(callback);
    }
  }

  void remove(void Function() callback) => _callbacks.remove(callback);
  void check() {
    if (_cancelled) throw TransferCancelled();
  }
}
