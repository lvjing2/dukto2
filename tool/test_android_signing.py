import importlib.util
import json
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location(
    'android_signing', Path(__file__).parent / 'ci/build_android_release.py'
)
android = importlib.util.module_from_spec(spec)
spec.loader.exec_module(android)


class AndroidSigningTest(unittest.TestCase):
    def setUp(self):
        self.config = {'applicationId': 'dev.dukto2.dukto2', 'appCertificateSha256': 'a' * 64, 'uploadCertificateSha256': 'b' * 64}
        self.apk = {'applicationId': self.config['applicationId'], 'versionName': '0.1.6', 'versionCode': 7, 'certificateSha256': 'a' * 64}
        self.bundle = dict(self.apk, certificateSha256='b' * 64)

    def check(self, apk=None, bundle=None, equivalent=None):
        android.validate_contract(apk or self.apk, bundle or self.bundle, equivalent or self.apk, self.config, 7, '0.1.6')

    def test_separate_upload_key_preserves_app_identity(self):
        self.check()

    def test_wrong_role_or_debug_certificate_is_rejected(self):
        for key in ('b' * 64, 'c' * 64):
            with self.assertRaises(ValueError):
                self.check(apk=dict(self.apk, certificateSha256=key))
        with self.assertRaises(ValueError):
            self.check(bundle=dict(self.bundle, certificateSha256='a' * 64))
        with self.assertRaises(ValueError):
            self.check(equivalent=dict(self.apk, certificateSha256='c' * 64))

    def test_abi_version_offset_or_different_package_cannot_pass(self):
        for field, value in [('versionCode', 2007), ('applicationId', 'example.other'), ('versionName', '0.1.7')]:
            with self.assertRaises(ValueError):
                self.check(bundle=dict(self.bundle, **{field: value}))
            with self.assertRaises(ValueError):
                self.check(apk=dict(self.apk, **{field: value}))

    def test_apksigner_numbered_and_sdk_range_output(self):
        digest = 'a' * 64
        for labels in [('Signer #1',), ('V2 Signer:',),
                       ('V2 Signer:', 'V3 Signer:'), (
            'Signer (minSdkVersion=33, maxSdkVersion=2147483647)',
            'Signer (minSdkVersion=24, maxSdkVersion=32)',
        )]:
            output = 'Number of signers: 1\n' + ''.join(
                label + ' certificate SHA-256 digest: ' + digest + '\n' for label in labels)
            self.assertEqual(android.verified_apk_certificate(output), digest)

    def test_multiple_signing_identities_or_missing_output_is_rejected(self):
        for output in ['', 'Number of signers: 1\n',
                       'Number of signers: 2\nSigner #1 certificate SHA-256 digest: ' + 'a' * 64,
                       'Number of signers: 1\nSigner (minSdkVersion=33, maxSdkVersion=2147483647) certificate SHA-256 digest: ' + 'a' * 64 +
                       '\nSigner (minSdkVersion=24, maxSdkVersion=32) certificate SHA-256 digest: ' + 'b' * 64]:
            with self.assertRaises(ValueError):
                android.verified_apk_certificate(output)

    def test_committed_public_certificates_match_pins(self):
        root = Path(__file__).resolve().parent.parent
        config = json.loads((root / 'tool/ci/android-signing.json').read_text())
        for role, field in [('app', 'appCertificateSha256'), ('upload', 'uploadCertificateSha256')]:
            self.assertEqual(android.certificate_sha256((root / 'certificates/android' / (role + '-signing.pem')).read_text()), config[field])


if __name__ == '__main__':
    unittest.main()
