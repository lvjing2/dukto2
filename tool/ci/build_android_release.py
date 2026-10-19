"""Build app-key APK and upload-key AAB; verify their cross-channel contract.

Private material is read only from environment secrets, restored to a temporary
directory, and removed on exit. Reports contain public certificate hashes only.
Play must still import the app key before real Play-distributed updates work.
"""

import base64
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def run(args, **kwargs):
    return subprocess.run([str(a) for a in args], check=True, **kwargs)


def sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def certificate_sha256(pem):
    cert = re.search(r'-----BEGIN CERTIFICATE-----\s*(.*?)\s*-----END CERTIFICATE-----', pem, re.S)
    if not cert:
        raise ValueError('No public signing certificate')
    return hashlib.sha256(base64.b64decode(re.sub(r'\s+', '', cert[1]), validate=True)).hexdigest()


def apk_identity(apk, aapt, signer):
    info = run([aapt, 'dump', 'badging', apk], capture_output=True, text=True).stdout
    header = re.search(r"^package: name='([^']+)' versionCode='(\d+)' versionName='([^']*)'", info, re.M)
    if not header:
        raise ValueError('Cannot read APK package/version')
    verification = run([signer, 'verify', '--verbose', '--print-certs', apk], capture_output=True, text=True).stdout
    fingerprint = verified_apk_certificate(verification)
    return {'applicationId': header[1], 'versionCode': int(header[2]), 'versionName': header[3], 'certificateSha256': fingerprint}


def verified_apk_certificate(verification):
    # Older tools number signers or use SDK ranges; newer tools prefix the
    # signature scheme (for example, `V2 Signer:`). All must pin one identity.
    labels = r'(?:Signer (?:#\d+|\(minSdkVersion=\d+(?: \(dev release=true\))?, maxSdkVersion=\d+\))|V[1-4](?:\.\d+)? Signer[^:\r\n]*:)'
    hashes = {value.lower() for value in re.findall(
        r'^' + labels + r' certificate SHA-256 digest:\s*([0-9a-fA-F]{64})\s*$', verification, re.M)}
    signer_counts = re.findall(r'^Number of signers:\s*(\d+)\s*$', verification, re.M)
    if signer_counts != ['1'] or len(hashes) != 1:
        # apksigner output contains public certificates only; retain diagnostics.
        raise ValueError('Expected one verified APK signing identity. apksigner output:\n' + verification)
    return hashes.pop()



def validate_contract(apk, bundle, equivalent, config, expected_code, expected_name):
    for value in (apk, bundle, equivalent):
        if (value['applicationId'], value['versionCode'], value['versionName']) != (config['applicationId'], expected_code, expected_name):
            raise ValueError('APK/AAB package or version mismatch; cross-channel update would be unsafe')
    if apk['certificateSha256'] != config['appCertificateSha256'] or equivalent['certificateSha256'] != config['appCertificateSha256']:
        raise ValueError('APK app signing certificate mismatch')
    if bundle['certificateSha256'] != config['uploadCertificateSha256']:
        raise ValueError('AAB upload certificate mismatch')
    if config['appCertificateSha256'] == config['uploadCertificateSha256']:
        raise ValueError('Application signing and upload keys must be separate')


def main():
    os.chdir(ROOT)
    os.umask(0o077)
    config = json.loads(Path(__file__).with_name('android-signing.json').read_text())
    sdk = Path(os.environ.get('ANDROID_HOME') or os.environ['ANDROID_SDK_ROOT'])
    version = re.search(r'^version:\s*(\S+)', (ROOT / 'pubspec.yaml').read_text(), re.M)[1]
    name, code = version.rsplit('+', 1)
    code = int(code)
    if not 0 < code <= 2100000000:
        raise ValueError('Android versionCode out of range')
    with tempfile.TemporaryDirectory(prefix='dukto2-signing-', dir=os.environ.get('RUNNER_TEMP')) as temp:
        temp = Path(temp)
        roles = {}
        for role in ('app', 'upload'):
            prefix = 'ANDROID_' + role.upper() + '_'
            values = {key: os.environ.get(prefix + key, '') for key in ('KEYSTORE_BASE64', 'STORE_PASSWORD', 'KEY_ALIAS', 'KEY_PASSWORD')}
            if not all(values.values()):
                raise ValueError('Missing GitHub signing secrets for role: ' + role)
            store = temp / (role + '.p12')
            store.write_bytes(base64.b64decode(values.pop('KEYSTORE_BASE64'), validate=True))
            env = dict(os.environ)
            # Do not forward the base64 stores or the other role's secrets to Gradle.
            for key in list(env):
                if key.startswith(('ANDROID_APP_', 'ANDROID_UPLOAD_')):
                    del env[key]
            env.pop('DUKTO2_ANDROID_UNSIGNED', None)
            env.update({
                'DUKTO2_ANDROID_SIGNED': 'true', 'DUKTO2_ANDROID_STORE_FILE': str(store),
                'DUKTO2_ANDROID_STORE_PASSWORD': values['STORE_PASSWORD'],
                'DUKTO2_ANDROID_KEY_ALIAS': values['KEY_ALIAS'],
                'DUKTO2_ANDROID_KEY_PASSWORD': values['KEY_PASSWORD'],
            })
            roles[role] = (store, values, env)
        for key in list(os.environ):
            if key.startswith(('ANDROID_APP_', 'ANDROID_UPLOAD_')):
                del os.environ[key]
        flutter = os.environ.get('FLUTTER_BIN', 'flutter')
        apk = ROOT / 'build/app/outputs/flutter-apk/app-release.apk'
        run([flutter, 'build', 'apk', '--release', '--target-platform', 'android-arm,android-arm64,android-x64'], env=roles['app'][2])
        saved_apk = temp / 'github.apk'
        shutil.copy2(apk, saved_apk)
        run([flutter, 'build', 'appbundle', '--release', '--target-platform', 'android-arm,android-arm64,android-x64'], env=roles['upload'][2])
        shutil.copy2(saved_apk, apk)
        aab = ROOT / 'build/app/outputs/bundle/release/app-release.aab'
        tools = sorted((sdk / 'build-tools').glob('*/apksigner'))
        if not tools:
            raise ValueError('Android build-tools missing')
        signer, aapt = tools[-1], tools[-1].with_name('aapt2')
        apk_info = apk_identity(apk, aapt, signer)
        run(['jarsigner', '-verify', aab], capture_output=True, text=True)
        pem = run(['keytool', '-printcert', '-jarfile', aab, '-rfc'], capture_output=True, text=True).stdout
        jar = temp / 'bundletool.jar'
        run(['curl', '--fail', '--location', '--retry', '3', '--connect-timeout', '30', '--max-time', '600', '--output', jar, config['bundletool']['url']])
        if sha256(jar) != config['bundletool']['sha256']:
            raise ValueError('Google bundletool checksum mismatch')
        run(['java', '-jar', jar, 'validate', '--bundle=' + str(aab)])
        manifest = run(['java', '-jar', jar, 'dump', 'manifest', '--bundle=' + str(aab), '--module=base'], capture_output=True, text=True).stdout
        xml = ET.fromstring(manifest)
        bundle_info = {
            'applicationId': xml.attrib['package'],
            'versionCode': int(xml.attrib['{http://schemas.android.com/apk/res/android}versionCode']),
            'versionName': xml.attrib['{http://schemas.android.com/apk/res/android}versionName'],
            'certificateSha256': certificate_sha256(pem),
        }
        # Reproduce Play's app-key signing locally from the upload-key signed AAB.
        store, values, _ = roles['app']
        store_pass, key_pass = temp / 'store-password', temp / 'key-password'
        store_pass.write_text(values['STORE_PASSWORD'])
        key_pass.write_text(values['KEY_PASSWORD'])
        apks = temp / 'play-equivalent.apks'
        run(['java', '-jar', jar, 'build-apks', '--bundle=' + str(aab), '--output=' + str(apks), '--mode=universal', '--ks=' + str(store), '--ks-key-alias=' + values['KEY_ALIAS'], '--ks-pass=file:' + str(store_pass), '--key-pass=file:' + str(key_pass)])
        equivalent_apk = temp / 'universal.apk'
        with zipfile.ZipFile(apks) as archive:
            equivalent_apk.write_bytes(archive.read('universal.apk'))
        equivalent = apk_identity(equivalent_apk, aapt, signer)
        validate_contract(apk_info, bundle_info, equivalent, config, code, name)
        report = {
            'applicationId': config['applicationId'], 'versionName': name, 'versionCode': code,
            'appCertificateSha256': apk_info['certificateSha256'],
            'uploadCertificateSha256': bundle_info['certificateSha256'],
            'playEquivalentApkVerified': True,
            'playAppSigningKeyImportRequired': config['playAppSigningKeyImportRequired'],
            'artifacts': {'apk': sha256(apk), 'aab': sha256(aab)},
        }
        (ROOT / 'build/android-signing-report.json').write_text(json.dumps(report, indent=2) + '\n')
        print('Verified Android signing roles, universal APK, AAB and Play-equivalent APK package/version contract.')


if __name__ == '__main__':
    main()
