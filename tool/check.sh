#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root"
python3 -m unittest discover -s tool -p 'test_*.py'
python3 tool/sync_native_localizations.py --check
python3 tool/sync_project_version.py --check
./tool/flutterw pub get
# Resolve the nested package before the workspace analyzer reads its context.
(cd packages/dukto2_core && ../../tool/dartw pub get)
# Avoid Flutter 3.47.7 LSP initialization's Unicode-path issue.
./tool/dartw analyze
./tool/flutterw test
cd packages/dukto2_core
../../tool/dartw analyze
../../tool/dartw test
