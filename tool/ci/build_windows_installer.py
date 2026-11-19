"""Build and smoke-test the x64 per-user installer on a Windows CI runner."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    if os.name != 'nt':
        raise SystemExit('Windows host required for installer build and smoke test')
    version = re.search(r'^version:\s*(\d+\.\d+\.\d+)\+([1-9]\d*)$',
                        (ROOT / 'pubspec.yaml').read_text(), re.M)
    if not version:
        raise ValueError('Installer requires a numbered release and build number')
    name, code = version.groups()
    bundle = ROOT / 'build/windows/x64/runner/Release'
    subprocess.run(['python', str(ROOT / 'tool/ci/verify_native.py'),
                    'windows', 'x64', str(bundle)], check=True)
    for required in ('Dukto2.exe', 'flutter_windows.dll', 'data/icudtl.dat',
                     'data/flutter_assets', 'msvcp140.dll', 'vcruntime140.dll',
                     'vcruntime140_1.dll', 'LICENSE', 'THIRD_PARTY_NOTICES.md'):
        if not (bundle / required).exists():
            raise ValueError('Installer bundle missing ' + required)
    compiler = shutil.which('iscc') or str(Path(os.environ['ProgramFiles(x86)']) /
                                          'Inno Setup 6/ISCC.exe')
    if not Path(compiler).is_file():
        raise ValueError('Inno Setup compiler is not installed on the runner')
    output = ROOT / 'build/windows/installer'
    output.mkdir(parents=True, exist_ok=True)
    subprocess.run([compiler, '/DAppVersion=' + name, '/DBuildNumber=' + code,
                    '/DBundleDir=' + str(bundle), '/DOutputDirectory=' + str(output),
                    str(ROOT / 'tool/windows-installer.iss')], check=True)
    installer = output / f'Dukto2-{name}-build.{code}-windows-x64-setup.exe'
    report = output / 'smoke.json'
    subprocess.run(['pwsh', '-NoProfile', '-File', str(ROOT / 'tool/ci/test_windows_installer.ps1'),
                    '-Installer', str(installer), '-Bundle', str(bundle),
                    '-Report', str(report)], check=True)
    result = json.loads(report.read_text(encoding='utf-8-sig'))
    if result['status'] != 'passed':
        raise ValueError('Installer smoke test failed')
    result.update(file=installer.name, sha256=digest(installer),
                  signing='unsigned; no publisher certificate',
                  installScope='current user', version=name + '+' + code)
    report.write_text(json.dumps(result, indent=2) + '\n')
    print('Verified Windows installer:', installer.name)


if __name__ == '__main__':
    main()
