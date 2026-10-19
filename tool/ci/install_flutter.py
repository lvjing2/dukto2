"""Install a checksum-pinned official Flutter SDK on a hosted Actions runner."""

import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import zipfile


def main():
    lock = json.loads(Path(__file__).with_name('flutter-sdk.json').read_text())
    system = {'Darwin': 'macos', 'Windows': 'windows', 'Linux': 'linux'}[platform.system()]
    arch = 'arm64' if platform.machine().lower() in ('arm64', 'aarch64') else 'x64'
    entry = lock[system + '-' + arch]
    temp = Path(os.environ['RUNNER_TEMP']) / 'dukto2-flutter'
    temp.mkdir(exist_ok=True)
    archive = temp / Path(entry['archive']).name
    subprocess.run([
        'curl', '--fail', '--location', '--retry', '3', '--connect-timeout', '30',
        '--max-time', '1200', '--output', str(archive),
        'https://storage.googleapis.com/flutter_infra_release/releases/' + entry['archive'],
    ], check=True)
    digest = hashlib.sha256()
    with archive.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    if digest.hexdigest() != entry['sha256']:
        raise SystemExit('Flutter archive checksum mismatch; not extracting.')
    if system == 'windows':
        with zipfile.ZipFile(archive) as bundle:
            bundle.extractall(temp)
    elif system == 'macos':
        # ditto preserves executable modes and symlinks in the official ZIP.
        subprocess.run(['ditto', '-x', '-k', str(archive), str(temp)], check=True)
    else:
        subprocess.run(['tar', '-xJf', str(archive), '-C', str(temp)], check=True)
    archive.unlink()
    sdk = temp / 'flutter' / 'bin'
    with open(os.environ['GITHUB_PATH'], 'a', encoding='utf-8') as stream:
        stream.write(str(sdk) + '\n')
    with open(os.environ['GITHUB_ENV'], 'a', encoding='utf-8') as stream:
        stream.write('FLUTTER_BIN=' + str(sdk / ('flutter.bat' if system == 'windows' else 'flutter')) + '\n')
    print('Installed Flutter', lock['version'], 'for', system, arch)


if __name__ == '__main__':
    main()
