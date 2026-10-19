"""Validate offline listing fields/assets, then package community/store drafts.

This never uploads anything or changes repository visibility. The app candidate
and materials revision are tracked separately because the app tag is immutable.
"""
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent.parent


def png_info(path):
    header = path.read_bytes()[:29]
    if header[:8] != b'\x89PNG\r\n\x1a\n' or header[12:16] != b'IHDR':
        raise ValueError('Invalid PNG: ' + str(path))
    width, height, depth, color = struct.unpack('>IIBB', header[16:26])
    return {'width': width, 'height': height, 'bitDepth': depth, 'colorType': color}


def main():
    listing = ROOT / 'distribution/google-play'
    config = json.loads((listing / 'listing.json').read_text())
    version = re.search(r'^version:\s*(\S+)', (ROOT / 'pubspec.yaml').read_text(), re.M)[1]
    if version != config['versionName'] + '+' + str(config['versionCode']):
        raise ValueError('Listing no longer matches the app candidate')
    tagged = subprocess.check_output(['git', 'rev-list', '-n', '1', config['candidateTag']], cwd=ROOT, text=True).strip()
    if tagged != config['candidateCommit']:
        raise ValueError('Candidate source tag mismatch')
    if not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', config['supportEmail'] or ''):
        raise ValueError('Missing approved support email')
    for locale in config['locales']:
        for name, limit in [('title', 30), ('short-description', 80), ('full-description', 4000), ('release-notes', 500)]:
            value = (listing / locale / (name + '.txt')).read_text().strip()
            if not 0 < len(value) <= limit:
                raise ValueError('Listing length outside limit: ' + locale + '/' + name)
        graphic = png_info(listing / 'graphics' / ('feature-' + locale + '.png'))
        if graphic != {'width': 1024, 'height': 500, 'bitDepth': 8, 'colorType': 2}:
            raise ValueError('Feature graphic must be RGB 1024x500 PNG')
    icon = listing / 'graphics/icon-512.png'
    icon_info = png_info(icon)
    if (icon_info['width'], icon_info['height'], icon_info['bitDepth'], icon_info['colorType']) != (512, 512, 8, 6) or icon.stat().st_size > 1024 * 1024:
        raise ValueError('Play icon must be RGBA 512x512 and no more than 1 MiB')
    screenshots = ROOT / 'distribution/community-zh/screenshots'
    provenance = json.loads((screenshots / 'provenance.json').read_text())
    for name, digest in provenance['files'].items():
        path = screenshots / name
        if path.name != name or hashlib.sha256(path.read_bytes()).hexdigest() != digest:
            raise ValueError('Screenshot provenance digest mismatch')
        if min(png_info(path)[key] for key in ('width', 'height')) < 320:
            raise ValueError('Community screenshot too small')
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    paths = sorted((ROOT / 'distribution').rglob('*'))
    # Legal material comes from the frozen candidate, not concurrent edits.
    legal_names = ['LICENSE', 'ACKNOWLEDGEMENTS.md', 'ACKNOWLEDGEMENTS.zh-CN.md', 'THIRD_PARTY_NOTICES.md', 'THIRD_PARTY_NOTICES.zh-CN.md']
    legal_names += subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', tagged, 'licenses'], cwd=ROOT, text=True).splitlines()
    legal = {name: subprocess.check_output(['git', 'show', tagged + ':' + name], cwd=ROOT) for name in legal_names}
    files = []
    for path in paths:
        if path.is_symlink():
            raise ValueError('Symlinks are not permitted in the material archive')
        if not path.is_file():
            continue
        if path.suffix.lower() in ('.p12', '.pfx', '.jks', '.keystore', '.key') or path.name == 'key.properties':
            raise ValueError('Private signing material must not be packaged')
        files.append(path)
    manifest = {
        'candidateTag': config['candidateTag'], 'candidateCommit': tagged,
        'version': version, 'materialsCommit': revision,
        'status': 'offline-drafts-not-posted-or-submitted',
        'repositoryVisibility': 'private',
        'pending': ['Public binary download destination', 'Public privacy-policy URL', 'Final Play SDK/form review', 'Play enrollment and signing-key import', 'Final-binary store-format screenshots'],
        'files': {**{str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in files}, **{name: hashlib.sha256(value).hexdigest() for name, value in legal.items()}},
    }
    out = ROOT / 'dist'
    out.mkdir(exist_ok=True)
    archive = out / ('Dukto2-' + version.replace('+', '-build.') + '-promotion.zip')
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as bundle:
        for path in files:
            bundle.write(path, path.relative_to(ROOT))
        for name, value in legal.items():
            bundle.writestr(name, value)
        bundle.writestr('MATERIALS-MANIFEST.json', json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    (out / (archive.name + '.sha256')).write_text(hashlib.sha256(archive.read_bytes()).hexdigest() + '  ' + archive.name + '\n')
    print('Validated listing lengths, RGB feature graphics, RGBA icon and authentic screenshot digests.')
    print('Packaged offline drafts:', archive)


if __name__ == '__main__':
    main()
