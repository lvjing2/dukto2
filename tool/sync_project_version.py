"""Generate the displayed project version from pubspec, before platform normalization."""
import argparse
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
ASSET = Path('assets/project-version.json')


def project_metadata(root):
    match = re.search(r'^version:\s*(\S+)\s*$', (root / 'pubspec.yaml').read_text(), re.M)
    if match is None or not re.fullmatch(r'\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?\+[1-9]\d*', match[1]):
        raise ValueError('Expected project version plus positive build number in pubspec.yaml')
    version, build = match[1].rsplit('+', 1)
    return {'version': version, 'buildNumber': build}


def sync(root, check=False):
    target = root / ASSET
    expected = json.dumps(project_metadata(root), indent=2) + '\n'
    if check:
        if not target.is_file() or target.read_text() != expected:
            raise ValueError('Project version asset is stale; run python3 tool/sync_project_version.py')
    else:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(expected)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    sync(ROOT, args.check)
