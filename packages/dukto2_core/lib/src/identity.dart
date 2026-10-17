import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'models.dart';

/// Private keys stay in app support storage; discovery only exposes the public fingerprint.
class DeviceIdentity {
  final String id;
  final String certificatePem;
  final String privateKeyPem;
  final String fingerprint;

  DeviceIdentity._(this.id, this.certificatePem, this.privateKeyPem)
    : fingerprint = sha256
          .convert(
            base64Decode(
              certificatePem
                  .replaceAll(RegExp(r'-----[^-]+-----'), '')
                  .replaceAll(RegExp(r'\s'), ''),
            ),
          )
          .toString();

  String get code => verificationCode(fingerprint);

  static Future<DeviceIdentity> loadOrCreate(Directory directory) async {
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, 'identity.json'));
    if (await file.exists()) {
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final identity = DeviceIdentity._(
        data['id'] as String,
        data['certificate'] as String,
        data['key'] as String,
      );
      // Validate both key and certificate before starting a listener.
      identity.securityContext();
      return identity;
    }
    final data = await Isolate.run(() {
      final keys = CryptoUtils.generateRSAKeyPair(keySize: 2048);
      final private = keys.privateKey as RSAPrivateKey;
      final public = keys.publicKey as RSAPublicKey;
      final id = randomId(16);
      final csr = X509Utils.generateRsaCsrPem(
        {'CN': 'Dukto2-$id'},
        private,
        public,
      );
      return {
        'id': id,
        'certificate': X509Utils.generateSelfSignedCertificate(
          private,
          csr,
          3650,
          serialNumber: BigInt.parse(randomId(12), radix: 16).toString(),
        ),
        'key': CryptoUtils.encodeRSAPrivateKeyToPem(private),
      };
    });
    // Create atomically so interruption cannot leave half a private key on disk.
    final temporary = File('${file.path}.${randomId(4)}.tmp');
    await temporary.writeAsString(jsonEncode(data), flush: true);
    if (Platform.isMacOS || Platform.isLinux) {
      final result = await Process.run('chmod', ['600', temporary.path]);
      if (result.exitCode != 0) {
        await temporary.delete();
        throw FileSystemException(
          'Cannot secure identity file',
          temporary.path,
        );
      }
    }
    await temporary.rename(file.path);
    return DeviceIdentity._(data['id']!, data['certificate']!, data['key']!);
  }

  SecurityContext securityContext() => SecurityContext(withTrustedRoots: false)
    ..useCertificateChainBytes(utf8.encode(certificatePem))
    ..usePrivateKeyBytes(utf8.encode(privateKeyPem))
    ..minimumTlsProtocolVersion = TlsProtocolVersion.tls1_2;
}
