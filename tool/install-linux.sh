#!/usr/bin/env bash
# Register this extracted bundle. Keep it in its final location first.
set -euo pipefail
bundle="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(uname -s)" != Linux ]]; then
  echo 'Run this from the extracted Linux package on Linux.' >&2
  exit 1
fi
if ! command -v python3 >/dev/null; then
  echo 'Python 3 is required. On Ubuntu: sudo apt install python3' >&2
  exit 1
fi
if [[ ! -x "$bundle/dukto2" ]]; then
  echo 'Incomplete package: keep dukto2, lib and data beside install.sh.' >&2
  exit 1
fi
if ! command -v ldd >/dev/null; then
  echo 'ldd is required to check runtime dependencies.' >&2
  exit 1
fi
while IFS= read -r -d '' binary; do
  dependencies="$(ldd "$binary")"
  if [[ "$dependencies" == *'not found'* ]]; then
    printf 'Missing runtime dependencies for %s:\n%s\n' "$binary" "$dependencies" >&2
    echo 'On Ubuntu 24.04: sudo apt install libgtk-3-0t64 libstdc++6' >&2
    exit 1
  fi
done < <(find "$bundle" -type f \( -name '*.so' -o -name dukto2 \) -print0)
python3 "$bundle/install_linux_user.py" "$bundle"
echo 'Dukto2 is now in your application menu. Keep this folder in place.'
