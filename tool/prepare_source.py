#!/usr/bin/env python3
"""Freeze non-ignored Git source files for local review, without committing/publishing.

Rejects common credential paths, private-key/token markers, symlinks and missing
local Markdown links. This limited preflight is not a complete security audit.
"""

import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import tarfile
import tempfile
from urllib.parse import unquote


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path('artifacts/community'))
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    output = args.output if args.output.is_absolute() else root / args.output
    # Keep candidates inside the ignored artifacts tree, never the source list.
    output = output.resolve()
    if not output.is_relative_to(root / 'artifacts'):
        parser.error('--output must be inside the project artifacts directory')
    raw = subprocess.check_output(
        ['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard'], cwd=root
    )
    names = sorted({p.decode('utf-8') for p in raw.split(b'\0') if p})
    blocked = re.compile(
        r'(^|/)(\.git|artifacts|\.dart_tool|build|\.toolchains|Pods|ephemeral|xcuserdata)(/|$)'
        r'|(^|/)(\.env(?:\..*)?|LocalSigning\.xcconfig|local\.properties|Generated\.xcconfig|'
        r'id_(?:rsa|ed25519).*|key\.properties)$|\.(?:p12|pfx|key|mobileprovision|provisionprofile)$'
    )
    markers = {
        'private key': re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH |DSA |ENCRYPTED )?PRIVATE KEY-----'),
        'GitHub token': re.compile(r'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b'),
        'AWS access key': re.compile(r'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b'),
    }
    payload = {}
    errors = []
    for name in names:
        path = root / name
        if not path.exists() and not path.is_symlink():
            continue  # A tracked deletion is not part of this candidate.
        if blocked.search(name) or path.is_symlink() or not path.is_file():
            errors.append(f'{name}: excluded/generated/credential path or non-regular file')
            continue
        data = path.read_bytes()
        payload[name] = (data, 0o755 if path.stat().st_mode & 0o111 else 0o644)
        if b'\0' in data:
            continue
        text = data.decode('utf-8', errors='replace')
        for label, pattern in markers.items():
            if pattern.search(text):
                errors.append(f'{name}: possible {label}; inspect locally')
        if path.suffix == '.md':
            for match in re.finditer(r'!?\[[^\]\n]*\]\((<[^>]+>|[^\s)]+)(?:\s+"[^"]*")?\)', text):
                target = unquote(match[1].strip('<>').split('#', 1)[0])
                if not target or re.match(r'^[a-zA-Z][a-zA-Z0-9+.-]*:', target):
                    continue
                dest = root / target.lstrip('/') if target.startswith('/') else path.parent / target
                if not dest.exists():
                    errors.append(f'{name}: missing local Markdown target {target}')
    if errors:
        for error in errors:
            print(error)
        raise SystemExit('Preflight failed; no candidate created.')
    output.mkdir(parents=True, exist_ok=True)
    run = Path(tempfile.mkdtemp(prefix='candidate-', dir=output))
    source = run / 'source'
    entries = {}
    for name, (data, mode) in payload.items():
        dest = source / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
        dest.chmod(mode)
        entries[name] = hashlib.sha256(data).hexdigest()
    archive = run / 'Dukto2-source-review.tar.gz'
    with archive.open('wb') as stream, gzip.GzipFile(filename='', mode='wb', fileobj=stream, mtime=0) as zipped:
        with tarfile.open(fileobj=zipped, mode='w') as tar:
            for name, (data, mode) in payload.items():
                info = tarfile.TarInfo('dukto2/' + name)
                info.size, info.mode, info.mtime = len(data), mode, 0
                tar.addfile(info, io.BytesIO(data))
    revision = subprocess.run(
        ['git', 'rev-parse', '--verify', 'HEAD'], cwd=root, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, check=False,
    )
    manifest = {
        'status': 'local review candidate; not published or platform-validated',
        'head': revision.stdout.strip() if revision.returncode == 0 else None,
        'fileCount': len(entries),
        'files': entries,
        'archiveSha256': hashlib.sha256(archive.read_bytes()).hexdigest(),
        'scope': 'Common credential markers/paths and local Markdown links only; not legal or security clearance.',
    }
    (run / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
    print(f'Candidate: {run.relative_to(root)}')
    print(f'Files: {len(entries)}; archive SHA-256: {manifest["archiveSha256"]}')


if __name__ == '__main__':
    main()
