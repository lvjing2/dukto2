"""Prepare one user-facing asset per OS from verified native CI packages.

APK bytes remain unchanged. Archives gain build metadata and an internal
checksum list; their original files, signatures, modes and links are preserved.
Detailed CI artifacts (including Play AAB) are retained separately.
"""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import tarfile
import zipfile

TARGETS = {'android': '.apk', 'windows': '-x64.zip', 'linux': '-x64.tar.gz',
           'macos': '-adhoc.zip', 'ios': '-device-unsigned.zip'}
EXTRA = {'RELEASE-INFO.json', 'SHA256SUMS.txt'}


def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def safe_name(name):
    path = PurePosixPath(name)
    if path.is_absolute() or '..' in path.parts or '\n' in name or '\r' in name or '\\' in name:
        raise ValueError('Unsafe archive path: ' + name)


def checksum(data, name):
    safe_name(name)
    return hashlib.sha256(data).hexdigest() + '  ' + name + '\n'


def metadata_bytes(info, original):
    return (json.dumps({'build': info, 'originalCiArchiveSha256': digest(original),
                        'packaging': 'Original payload preserved; internal metadata and checksums added'},
                       ensure_ascii=False, indent=2) + '\n').encode()


def repack_zip(source, dest, info):
    payload = metadata_bytes(info, source)
    with zipfile.ZipFile(source) as before:
        sums = ''
        for entry in before.infolist():
            safe_name(entry.filename)
            if entry.filename in EXTRA:
                raise ValueError('Archive already has publication metadata')
            if entry.is_dir() or entry.filename.startswith('__MACOSX/'):
                continue
            # shasum follows extracted symlinks, so only list regular payloads.
            if stat.S_ISLNK(entry.external_attr >> 16):
                continue
            sums += checksum(before.read(entry), entry.filename)
    sums += checksum(payload, 'RELEASE-INFO.json')
    shutil.copy2(source, dest)
    # Append only: retain original compressed payloads and ZipInfo attributes.
    with zipfile.ZipFile(dest, 'a', zipfile.ZIP_DEFLATED) as archive:
        archive.writestr('RELEASE-INFO.json', payload)
        archive.writestr('SHA256SUMS.txt', sums)


def repack_tar(source, dest, info):
    payload = metadata_bytes(info, source)
    sums = ''
    with tarfile.open(source, 'r:gz') as before, tarfile.open(dest, 'w:gz', format=tarfile.PAX_FORMAT) as after:
        for entry in before:
            safe_name(entry.name)
            if entry.name in EXTRA:
                raise ValueError('Archive already has publication metadata')
            if entry.isfile():
                data = before.extractfile(entry).read()
                sums += checksum(data, entry.name)
                after.addfile(entry, io.BytesIO(data))
            else:
                after.addfile(entry)
        sums += checksum(payload, 'RELEASE-INFO.json')
        for name, data in [('RELEASE-INFO.json', payload), ('SHA256SUMS.txt', sums.encode())]:
            entry = tarfile.TarInfo(name)
            entry.size, entry.mode = len(data), 0o644
            after.addfile(entry, io.BytesIO(data))


def prepare(source, dest, version):
    if not re.fullmatch(r'\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?\+\d+', version):
        raise ValueError('Invalid release version')
    if dest.exists():
        raise ValueError('Output must be a new directory')
    prefix = 'Dukto2-' + version.replace('+', '-build.') + '-'
    inputs = []
    commits = set()
    for target, suffix in TARGETS.items():
        artifact = source / (prefix + target + suffix)
        info = json.loads((source / (prefix + target + '.json')).read_text())
        if info['target'] != target or info['version'] != version or not re.fullmatch(r'[0-9a-f]{40}', info['commit']):
            raise ValueError('Source/version metadata mismatch: ' + target)
        commits.add(info['commit'])
        expected = (source / (artifact.name + '.sha256')).read_text().strip()
        if expected != digest(artifact) + '  ' + artifact.name:
            raise ValueError('Original CI checksum mismatch: ' + artifact.name)
        if target == 'android':
            report = info['androidSigning']
            if not report['playEquivalentApkVerified'] or report['artifacts']['apk'] != digest(artifact):
                raise ValueError('Missing verified APK signature contract')
            with zipfile.ZipFile(artifact) as apk:
                notices = gzip.decompress(apk.read('assets/flutter_assets/NOTICES.Z')).decode()
                if '\ndukto2\n' not in notices or 'Apache License' not in notices:
                    raise ValueError('Application licenses missing from APK')
        inputs.append((target, artifact, info))
    if len(commits) != 1:
        raise ValueError('Cannot combine builds from different source commits')
    dest.mkdir(parents=True)
    for target, artifact, info in inputs:
        output = dest / artifact.name
        if target == 'android':
            shutil.copy2(artifact, output)
            if digest(output) != digest(artifact):
                raise ValueError('APK bytes changed')
        elif artifact.name.endswith('.tar.gz'):
            repack_tar(artifact, output, info)
        else:
            repack_zip(artifact, output, info)
    return sorted(dest.iterdir())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('destination', type=Path)
    parser.add_argument('--version', required=True)
    args = parser.parse_args()
    for path in prepare(args.source, args.destination, args.version):
        print(path.name)


if __name__ == '__main__':
    main()
