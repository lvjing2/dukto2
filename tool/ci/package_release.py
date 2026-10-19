"""Package known native outputs with license notices and provenance metadata."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def version():
    value = re.search(r'^version:\s*(\S+)', (ROOT / 'pubspec.yaml').read_text(), re.M)[1]
    if not re.fullmatch(r'\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+\d+)?', value):
        raise ValueError('Invalid pubspec version')
    return value


def check_tag(ref):
    if ref.startswith('refs/tags/'):
        value = version()
        if ref[10:] not in ('v' + value, 'v' + value.split('+')[0]):
            raise ValueError('Release tag must match pubspec.yaml version')


def sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def legal(stage):
    for name in ('LICENSE', 'ACKNOWLEDGEMENTS.md', 'THIRD_PARTY_NOTICES.md'):
        shutil.copy2(ROOT / name, stage / name)
    shutil.copytree(ROOT / 'licenses', stage / 'licenses')
    shutil.copy2(ROOT / 'docs/install.md', stage / 'INSTALL.zh-CN.md')


def validate_apple_bundle(app, target):
    plist = app / ('Contents/Info.plist' if target == 'macos' else 'Info.plist')
    if not plist.is_file():
        raise ValueError('Missing built Apple app bundle: ' + str(plist))


def release_matrix(ref, requested):
    runners = {'linux': 'ubuntu-24.04', 'windows': 'windows-2025', 'macos': 'macos-26', 'android': 'ubuntu-24.04', 'ios': 'macos-26'}
    if requested != 'all' and requested not in runners:
        raise ValueError('Unknown release platform')
    targets = list(runners) if ref.startswith('refs/tags/') or requested == 'all' else [requested]
    if 'android' in targets and ref and ref != 'refs/heads/main' and not ref.startswith('refs/tags/v'):
        raise ValueError('Android signing is restricted to main or release tags')
    return {'include': [{'target': t, 'runner': runners[t]} for t in targets]}


def package_android(dest, prefix, metadata):
    config = json.loads(Path(__file__).with_name('android-signing.json').read_text())
    report = json.loads((ROOT / 'build/android-signing-report.json').read_text())
    if (report['appCertificateSha256'] != config['appCertificateSha256'] or
            report['uploadCertificateSha256'] != config['uploadCertificateSha256'] or
            report['applicationId'] != config['applicationId'] or not report['playEquivalentApkVerified']):
        raise ValueError('Missing verified Android cross-channel signing contract')
    expected_name, expected_code = version().rsplit('+', 1)
    if report['versionName'] != expected_name or report['versionCode'] != int(expected_code):
        raise ValueError('Stale Android signing report')
    files = {'apk': ROOT / 'build/app/outputs/flutter-apk/app-release.apk', 'aab': ROOT / 'build/app/outputs/bundle/release/app-release.aab'}
    outputs = []
    for kind, source in files.items():
        if sha256(source) != report['artifacts'][kind]:
            raise ValueError('Android artifact changed after signature verification')
        output = dest / (prefix + ('.apk' if kind == 'apk' else '-play.aab'))
        shutil.copy2(source, output)
        outputs.append(output)
    metadata['signing'] = {'apk': 'application key', 'aab': 'upload key'}
    metadata['androidSigning'] = report
    with tempfile.TemporaryDirectory(prefix='dukto2-notices-') as temp:
        stage = Path(temp)
        legal(stage)
        (stage / 'certificates').mkdir()
        for name in ('app-signing.pem', 'upload-signing.pem'):
            shutil.copy2(ROOT / 'certificates/android' / name, stage / 'certificates' / name)
        (stage / 'BUILD-INFO.json').write_text(json.dumps(metadata, indent=2) + '\n')
        (stage / 'INSTALL.txt').write_text('GitHub APK: signed installable universal APK. Play AAB: upload-key signed, not directly installable. Play must import our existing app key via PEPK before cross-channel updates work. Use increasing versionCodes. See https://github.com/lvjing2/dukto2/blob/main/docs/android-signing.md\n')
        output = dest / (prefix + '-notices.zip')
        with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as bundle:
            for path in sorted(stage.rglob('*')):
                if path.is_file():
                    bundle.write(path, path.relative_to(stage))
        outputs.append(output)
    return outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=['check', 'linux', 'windows', 'macos', 'android', 'ios'])
    args = parser.parse_args()
    os.chdir(ROOT)
    check_tag(os.environ.get('GITHUB_REF', ''))
    if args.target == 'check':
        matrix = release_matrix(os.environ.get('GITHUB_REF', ''), os.environ.get('RELEASE_PLATFORM') or 'all')
        if os.environ.get('GITHUB_OUTPUT'):
            with open(os.environ['GITHUB_OUTPUT'], 'a') as stream:
                stream.write('matrix=' + json.dumps(matrix) + '\n')
        print('Version/tag valid:', version())
        return
    dest = ROOT / 'dist'
    dest.mkdir(exist_ok=True)
    prefix = 'Dukto2-' + version().replace('+', '-build.') + '-' + args.target
    commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
    metadata = {
        'version': version(), 'commit': commit, 'target': args.target,
        'runnerSystem': platform.system(), 'runnerArchitecture': platform.machine(),
        'flutter': json.loads(Path(__file__).with_name('flutter-sdk.json').read_text())['version'],
        'signing': {'android': 'unsigned', 'ios': 'unsigned', 'macos': 'ad-hoc, not notarized'}.get(args.target, 'unsigned'),
        'validation': 'Native CI build only; does not verify device UI or LAN transfer.',
    }
    outputs = []
    if args.target == 'android':
        outputs = package_android(dest, prefix, metadata)
    elif args.target in ('linux', 'windows'):
        source = ROOT / ('artifacts/linux/Dukto2-linux-x64.tar.gz' if args.target == 'linux' else 'artifacts/windows/Dukto2-windows-x64-release.zip')
        suffix = '.tar.gz' if args.target == 'linux' else '.zip'
        output = dest / (prefix + '-x64' + suffix)
        shutil.copy2(source, output)
    else:
        with tempfile.TemporaryDirectory(prefix='dukto2-package-') as temp:
            stage = Path(temp)
            legal(stage)
            if args.target in ('macos', 'ios'):
                app = ROOT / ('build/macos/Build/Products/Release/Dukto2.app' if args.target == 'macos' else 'build/ios/iphoneos/Runner.app')
                validate_apple_bundle(app, args.target)
                shutil.copytree(app, stage / app.name, symlinks=True)
                if args.target == 'macos':
                    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(stage / app.name)], check=True)
                    signing = subprocess.run(['codesign', '-dv', str(stage / app.name)], capture_output=True, text=True, check=True)
                    if 'Signature=adhoc' not in signing.stderr:
                        raise ValueError('Expected an ad-hoc macOS signature')
                    metadata['binaryArchitectures'] = subprocess.check_output(['lipo', '-archs', str(app / 'Contents/MacOS/Dukto2')], text=True).strip()
                elif subprocess.run(['codesign', '--verify', str(stage / app.name)], capture_output=True).returncode == 0:
                    raise ValueError('Expected an unsigned iOS device build')
                output = dest / (prefix + ('-adhoc.zip' if args.target == 'macos' else '-device-unsigned.zip'))
                instructions = ('Move Dukto2.app to Applications, then open it. This build is ad-hoc signed, not notarized. If blocked, review System Settings > Privacy & Security > Open Anyway after checking the source. Do not disable Gatekeeper.\n' if args.target == 'macos' else 'Unsigned iOS device build for developers only. Not directly installable; not an IPA, TestFlight or App Store release. Requires your own Xcode signing.\n')
                (stage / 'INSTALL.txt').write_text(instructions)
            (stage / 'BUILD-INFO.json').write_text(json.dumps(metadata, indent=2) + '\n')
            subprocess.run(['ditto', '-c', '-k', '--sequesterRsrc', str(stage), str(output)], check=True)
    if not outputs:
        outputs = [output]
    for output in outputs:
        (dest / (output.name + '.sha256')).write_text(sha256(output) + '  ' + output.name + '\n')
    (dest / (prefix + '.json')).write_text(json.dumps(metadata, indent=2) + '\n')
    print('Packaged:', ', '.join(p.name for p in outputs))


if __name__ == '__main__':
    main()
