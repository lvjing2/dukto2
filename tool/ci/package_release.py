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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=['check', 'linux', 'windows', 'macos', 'android', 'ios'])
    args = parser.parse_args()
    os.chdir(ROOT)
    check_tag(os.environ.get('GITHUB_REF', ''))
    if args.target == 'check':
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
    if args.target in ('linux', 'windows'):
        source = ROOT / ('artifacts/linux/Dukto2-linux-x64.tar.gz' if args.target == 'linux' else 'artifacts/windows/Dukto2-windows-x64-release.zip')
        suffix = '.tar.gz' if args.target == 'linux' else '.zip'
        output = dest / (prefix + '-x64' + suffix)
        shutil.copy2(source, output)
    else:
        with tempfile.TemporaryDirectory(prefix='dukto2-package-') as temp:
            stage = Path(temp)
            legal(stage)
            if args.target == 'android':
                apks = sorted((ROOT / 'build/app/outputs/flutter-apk').glob('app-*-release.apk'))
                if len(apks) != 3:
                    raise ValueError('Expected the three split ABI release APKs')
                for apk in apks:
                    with zipfile.ZipFile(apk) as archive:
                        if 'AndroidManifest.xml' not in archive.namelist():
                            raise ValueError('Not an Android APK')
                    sdk = Path(os.environ.get('ANDROID_HOME') or os.environ['ANDROID_SDK_ROOT'])
                    signers = sorted((sdk / 'build-tools').glob('*/apksigner'))
                    if not signers:
                        raise ValueError('apksigner is required to verify unsigned status')
                    status = subprocess.run([str(signers[-1]), 'verify', str(apk)], capture_output=True)
                    if status.returncode == 0:
                        raise ValueError('Refusing to label a signed APK as unsigned')
                    shutil.copy2(apk, stage / apk.name.replace('-release.apk', '-release-unsigned.apk'))
                (stage / 'INSTALL.txt').write_text('Unsigned release APKs. Sign with your own Android release key before installation.\n')
                output = dest / (prefix + '-unsigned.zip')
            else:
                app = ROOT / ('build/macos/Build/Products/Release/Dukto2.app' if args.target == 'macos' else 'build/ios/iphoneos/Runner.app')
                if not (app / 'Info.plist').is_file():
                    raise ValueError('Missing built Apple app bundle')
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
                (stage / 'INSTALL.txt').write_text('macOS: ad-hoc signed, not notarized. iOS: unsigned device build, not an installable IPA or App Store package.\n')
            (stage / 'BUILD-INFO.json').write_text(json.dumps(metadata, indent=2) + '\n')
            if args.target in ('macos', 'ios'):
                subprocess.run(['ditto', '-c', '-k', '--sequesterRsrc', str(stage), str(output)], check=True)
            else:
                with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as bundle:
                    for path in sorted(stage.rglob('*')):
                        if path.is_file():
                            bundle.write(path, path.relative_to(stage))
    (dest / (output.name + '.sha256')).write_text(sha256(output) + '  ' + output.name + '\n')
    (dest / (prefix + '.json')).write_text(json.dumps(metadata, indent=2) + '\n')
    print('Packaged:', output.name)


if __name__ == '__main__':
    main()
