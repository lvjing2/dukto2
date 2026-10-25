"""Build offline Flatpak and AppImage candidates from a verified native bundle.

No release uploads, remote registration or host application installation.
AppImage tools are downloaded only from SHA-256-pinned official artifacts.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import struct
import subprocess
import tempfile
import urllib.request

from verify_native import architecture, verify_bundle

ROOT = Path(__file__).resolve().parents[2]
CONFIG = json.loads((ROOT / 'linux/packaging/portable/toolchain.json').read_text())
APP_ID = 'dev.dukto2.dukto2'
ARCHES = {'x64': 'x86_64', 'arm64': 'aarch64'}
PERMISSIONS = [
    '--share=network', '--share=ipc', '--socket=wayland',
    '--socket=fallback-x11', '--device=dri',
    '--filesystem=xdg-download/Dukto2:create', '--env=GTK_USE_PORTAL=1',
]
REQUIRED = ['dukto2', 'lib/libflutter_linux_gtk.so', 'lib/libapp.so',
            'data/icudtl.dat', 'data/flutter_assets/AssetManifest.bin']


def run(args, **kwargs):
    return subprocess.run([str(a) for a in args], check=True, **kwargs)


def digest(path):
    result = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            result.update(block)
    return result.hexdigest()


def version():
    return re.search(r'^version:\s*(\S+)', (ROOT / 'pubspec.yaml').read_text(), re.M)[1]


def elf_files(bundle):
    for path in sorted(bundle.rglob('*')):
        if path.is_file() and not path.is_symlink():
            with path.open('rb') as stream:
                if stream.read(4) == b'\x7fELF':
                    yield path


def glibc_versions(readelf):
    # readelf --version-info lists both definitions and requirements. Taking
    # the maximum conservatively rejects any unexpectedly newer bundled ELF.
    return {tuple(map(int, s.split('.'))) for s in
            re.findall(r'\bGLIBC_(\d+(?:\.\d+)+)\b', readelf)}


def audit(bundle, arch, readelf='readelf'):
    for name in REQUIRED:
        if not (bundle / name).is_file():
            raise ValueError('Incomplete Flutter bundle: ' + name)
    verify_bundle('linux', arch, bundle)
    limit = tuple(map(int, CONFIG['maximumGlibc'].split('.')))
    entries = []
    for path in elf_files(bundle):
        if architecture(path) != arch:
            raise ValueError('Wrong ELF architecture: ' + str(path))
        result = subprocess.check_output([readelf, '--version-info', str(path)], text=True)
        versions = glibc_versions(result)
        maximum = max(versions, default=(0, 0))
        if maximum > limit:
            raise ValueError(f'{path}: GLIBC {maximum} exceeds baseline {limit}')
        entries.append({'file': str(path.relative_to(bundle)),
                        'maximumGlibc': '.'.join(map(str, maximum)),
                        'sha256': digest(path)})
    return entries


def checked_copy(source, destination):
    # The Flutter bundle should be relocatable. Reject links escaping it instead
    # of accidentally exporting files outside the application build directory.
    for path in source.rglob('*'):
        if path.is_symlink() and not path.resolve().is_relative_to(source.resolve()):
            raise ValueError('Bundle symlink escapes source: ' + str(path))
    shutil.copytree(source, destination, symlinks=True)


def populate(prefix, bundle):
    app = prefix / 'lib/dukto2'
    app.parent.mkdir(parents=True, exist_ok=True)
    checked_copy(bundle, app)
    (prefix / 'bin').mkdir(parents=True)
    launcher = prefix / 'bin/dukto2'
    launcher.write_text('''#!/bin/sh
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
exec "$HERE/lib/dukto2/dukto2" "$@"
''')
    launcher.chmod(0o755)
    applications = prefix / 'share/applications'
    applications.mkdir(parents=True)
    shutil.copy2(ROOT / f'linux/packaging/{APP_ID}.desktop', applications)
    icon = ROOT / 'assets/branding/dukto2.png'
    width, height = struct.unpack('>II', icon.read_bytes()[16:24])
    icons = prefix / f'share/icons/hicolor/{width}x{height}/apps'
    icons.mkdir(parents=True)
    shutil.copy2(icon, icons / (APP_ID + '.png'))
    metainfo = prefix / 'share/metainfo'
    metainfo.mkdir(parents=True)
    epoch = int(subprocess.check_output(['git', '-C', str(ROOT), 'show', '-s', '--format=%ct', 'HEAD'], text=True))
    source = (ROOT / f'linux/packaging/portable/{APP_ID}.metainfo.xml').read_text()
    source = source.replace('@VERSION@', version()).replace('@DATE@', datetime.fromtimestamp(epoch, timezone.utc).date().isoformat())
    (metainfo / (APP_ID + '.metainfo.xml')).write_text(source)
    notices = prefix / 'share/licenses' / APP_ID
    notices.mkdir(parents=True)
    for name in ['LICENSE', 'ACKNOWLEDGEMENTS.md', 'THIRD_PARTY_NOTICES.md']:
        shutil.copy2(ROOT / name, notices)
    shutil.copytree(ROOT / 'licenses', notices / 'licenses')
    shutil.copy2(ROOT / 'docs/install.md', notices / 'INSTALL.zh-CN.md')
    run(['desktop-file-validate', applications / (APP_ID + '.desktop')])
    run(['appstreamcli', 'validate', '--no-net', metainfo / (APP_ID + '.metainfo.xml')])
    return app


def tool(name, arch, cache):
    entry = CONFIG['tools'][name][arch]
    path = cache / (name + '-' + entry['sha256'])
    if path.exists() and digest(path) != entry['sha256']:
        raise ValueError('Cached tool checksum mismatch: ' + name)
    if not path.exists():
        temporary = path.with_suffix('.download')
        try:
            with urllib.request.urlopen(entry['url'], timeout=120) as source, temporary.open('wb') as dest:
                shutil.copyfileobj(source, dest)
            if digest(temporary) != entry['sha256']:
                raise ValueError('Tool checksum mismatch: ' + name)
            temporary.replace(path)
        finally:
            temporary.unlink(missing_ok=True)
    path.chmod(0o755)
    return path


def unpack_tool(path, dest):
    dest.mkdir()
    run([path, '--appimage-extract'], cwd=dest, stdout=subprocess.DEVNULL)
    return dest / 'squashfs-root/AppRun'


def appimage(bundle, arch, output, cache, work):
    appdir = work / 'Dukto2.AppDir'
    prefix = appdir / 'usr'
    populate(prefix, bundle)
    apprun = work / 'AppRun'
    apprun.write_text('''#!/bin/sh
set -eu
APPDIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$APPDIR/usr/lib/dukto2/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="$APPDIR/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
exec "$APPDIR/usr/bin/dukto2" "$@"
''')
    apprun.chmod(0o755)
    deploy = unpack_tool(tool('linuxdeploy', arch, cache), work / 'linuxdeploy')
    icon = next((prefix / 'share/icons/hicolor').rglob(APP_ID + '.png'))
    run([deploy, '--appdir', appdir, '--deploy-deps-only', prefix / 'lib/dukto2',
         '--desktop-file', prefix / 'share/applications' / (APP_ID + '.desktop'),
         '--icon-file', icon, '--custom-apprun', apprun])
    # Check newly bundled system libraries as well as Flutter and plugins.
    audit(prefix / 'lib/dukto2', arch)
    for path in elf_files(appdir):
        if architecture(path) != arch:
            raise ValueError('Wrong AppImage dependency architecture: ' + str(path))
        requirements = glibc_versions(subprocess.check_output(['readelf', '--version-info', path], text=True))
        if max(requirements, default=(0, 0)) > tuple(map(int, CONFIG['maximumGlibc'].split('.'))):
            raise ValueError('Newer GLIBC bundled into AppImage: ' + str(path))
    pack = unpack_tool(tool('appimagetool', arch, cache), work / 'appimagetool')
    runtime = tool('runtime', arch, cache)
    env = dict(os.environ, ARCH=ARCHES[arch], VERSION=version(), SOURCE_DATE_EPOCH=subprocess.check_output(
        ['git', '-C', str(ROOT), 'show', '-s', '--format=%ct', 'HEAD'], text=True).strip())
    run([pack, '--no-appstream', '--runtime-file', runtime, appdir, output], env=env)
    output.chmod(0o755)


def flatpak(bundle, arch, output, work):
    # Prebuilt applications can be exported without compiling inside a sandbox.
    # Only Flatpak metadata and /app payload are assembled here; final execution
    # still uses Flatpak's normal sandbox and declared permissions.
    build = work / 'flatpak-build'
    populate(build / 'files', bundle)
    (build / 'metadata').write_text(
        f'[Application]\nname={APP_ID}\nruntime={CONFIG["flatpakRuntime"]}/{ARCHES[arch]}/{CONFIG["flatpakRuntimeVersion"]}\n')
    run(['flatpak', 'build-finish', '--command=dukto2', *PERMISSIONS, build])
    repo = work / 'flatpak-repo'
    run(['flatpak', 'build-export', '--arch=' + ARCHES[arch], repo, build, 'stable'])
    run(['flatpak', 'build-bundle', '--arch=' + ARCHES[arch],
         '--runtime-repo=https://flathub.org/repo/flathub.flatpakrepo', repo, output, APP_ID, 'stable'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('format', choices=['appimage', 'flatpak'])
    parser.add_argument('--arch', required=True, choices=ARCHES)
    parser.add_argument('--bundle', required=True, type=Path)
    parser.add_argument('--output', type=Path, default=ROOT / 'dist')
    parser.add_argument('--cache', type=Path, default=ROOT / 'artifacts/linux-portable-tools')
    args = parser.parse_args()
    if platform.system() != 'Linux' or platform.machine().lower() not in (
            ('x86_64',) if args.arch == 'x64' else ('aarch64', 'arm64')):
        parser.error('Build on native Linux of the requested architecture')
    bundle = args.bundle.resolve()
    entries = audit(bundle, args.arch)
    args.output.mkdir(parents=True, exist_ok=True)
    args.cache.mkdir(parents=True, exist_ok=True)
    stem = 'Dukto2-' + version().replace('+', '-build.') + '-linux-' + args.arch
    output = (args.output / (stem + ('.AppImage' if args.format == 'appimage' else '.flatpak'))).resolve()
    if output.exists():
        parser.error('Output exists; use a fresh output directory')
    with tempfile.TemporaryDirectory(prefix='dukto2-portable-') as temporary:
        work = Path(temporary)
        if args.format == 'appimage':
            appimage(bundle, args.arch, output, args.cache.resolve(), work)
        else:
            flatpak(bundle, args.arch, output, work)
    (output.parent / (output.name + '.sha256')).write_text(digest(output) + '  ' + output.name + '\n')
    info = {'version': version(), 'commit': subprocess.check_output(['git', '-C', str(ROOT), 'rev-parse', 'HEAD'], text=True).strip(),
            'format': args.format, 'architecture': args.arch, 'baseline': CONFIG['baseline'],
            'maximumGlibc': CONFIG['maximumGlibc'], 'sha256': digest(output), 'nativeFiles': entries,
            'validation': 'Packaging checks only; desktop and physical LAN tests are separate.'}
    if args.format == 'flatpak':
        info.update(runtime=CONFIG['flatpakRuntime'] + '/' + ARCHES[args.arch] + '/' + CONFIG['flatpakRuntimeVersion'],
                    permissions=PERMISSIONS)
    (output.parent / (output.name + '.json')).write_text(json.dumps(info, indent=2) + '\n')
    print(output)


if __name__ == '__main__':
    main()
