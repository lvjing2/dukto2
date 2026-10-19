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

enum DeviceType {
  unknown,
  phone,
  tablet,
  computer;

  static DeviceType parse(Object? value) => switch (value) {
    'phone' => phone,
    'tablet' => tablet,
    'computer' => computer,
    _ => unknown,
  };

  // iOS needs the native interface idiom to distinguish iPhone from iPad.
  static DeviceType get hostPlatform => switch (Platform.operatingSystem) {
    'macos' || 'windows' || 'linux' => computer,
    'android' => phone,
    _ => unknown,
  };
}

class Peer {
  final String id;
  final String name;
  final String host;
  final int port;
  final String fingerprint;
  final DateTime lastSeen;
  final bool supportsText;
  final bool supportsBatch;
  final DeviceType deviceType;

  Peer({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.fingerprint,
    this.supportsText = false,
    this.supportsBatch = false,
    this.deviceType = DeviceType.unknown,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  String get code => verificationCode(fingerprint);
  Map<String, Object> toJson() => {
    'v': 1,
    'id': id,
    'name': name,
    'port': port,
    'fingerprint': fingerprint,
    if (deviceType != DeviceType.unknown) 'deviceType': deviceType.name,
    if (supportsText || supportsBatch)
      'capabilities': [if (supportsText) 'text', if (supportsBatch) 'batch'],
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
      deviceType: DeviceType.parse(json['deviceType']),
      supportsText:
          json['capabilities'] is List &&
          (json['capabilities'] as List).contains('text'),
      supportsBatch:
          json['capabilities'] is List &&
          (json['capabilities'] as List).contains('batch'),
    );
  }
}

const maxTextBytes = 16 * 1024 * 1024;
const maxInlineTextBytes = 1024 * 1024;
const maxTextPreviewCharacters = 16384;
String textPreview(String text) {
  if (text.length <= maxTextPreviewCharacters) return text;
  var end = maxTextPreviewCharacters;
  if (text.codeUnitAt(end - 1) >= 0xd800 &&
      text.codeUnitAt(end - 1) <= 0xdbff) {
    end--;
  }
  return text.substring(0, end);
}

enum TransferKind { file, text }

class FileOffer {
  final String sender;
  final String name;
  final int size;
  final String remoteAddress;
  final TransferKind kind;
  final List<FileOffer> files;
  bool get isText => kind == TransferKind.text;
  bool get isBatch => files.isNotEmpty;

  const FileOffer({
    required this.sender,
    required this.name,
    required this.size,
    this.remoteAddress = '',
    this.kind = TransferKind.file,
    this.files = const [],
  });

  Map<String, Object> toJson() => {
    'sender': sender,
    'name': name,
    'size': size,
    if (isText) 'kind': 'text',
  };

  factory FileOffer.fromJson(Map<String, dynamic> json, String address) {
    final sender = json['sender'];
    final name = json['name'];
    final size = json['size'];
    final kind = json['kind'];
    if (sender is! String ||
        sender.isEmpty ||
        sender.length > 128 ||
        name is! String ||
        !validFileName(name) ||
        size is! int ||
        size < 0 ||
        size > 1024 * 1024 * 1024 * 1024 ||
        (kind != null && kind != 'file' && kind != 'text') ||
        (kind == 'text' && (size == 0 || size > maxTextBytes))) {
      throw const FormatException('Invalid file offer');
    }
    return FileOffer(
      sender: sender,
      name: name,
      size: size,
      remoteAddress: address,
      kind: kind == 'text' ? TransferKind.text : TransferKind.file,
    );
  }
}

FileOffer batchOfferFromJson(Map<String, dynamic> json, String address) {
  final raw = json['files'];
  if (raw is! List || raw.length < 2 || raw.length > 1000) {
    throw const FormatException('A batch must contain 2 to 1000 files');
  }
  final files = raw.map((item) {
    if (item is! Map<String, dynamic> || item['kind'] != null) {
      throw const FormatException('Invalid batch manifest');
    }
    return FileOffer.fromJson({
      'sender': json['sender'],
      'name': item['name'],
      'size': item['size'],
    }, address);
  }).toList();
  final total = files.fold(0, (sum, file) => sum + file.size);
  if (total > 1024 * 1024 * 1024 * 1024) {
    throw const FormatException('Batch is too large');
  }
  return FileOffer(
    sender: files.first.sender,
    name: '${files.length} 个文件',
    size: total,
    remoteAddress: address,
    files: List.unmodifiable(files),
  );
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
  final String? contentUri;
  final String? text;
  final bool textTruncated;
  const TransferReceipt({
    required this.name,
    required this.size,
    required this.sha256,
    this.file,
    this.contentUri,
    this.text,
    this.textTruncated = false,
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
