#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./tool/linux.sh [--doctor-only] [--skip-tests] [--skip-doctor]
Build a native Linux release and package the complete Flutter bundle.
Requires Linux x86_64 or aarch64, Flutter 3.47.7, and GTK3 build tooling.
FLUTTER_BIN / DART_BIN can select an existing SDK. No sudo or package installs.
EOF
}
doctor_only=false
skip_tests=false
skip_doctor=false
for arg in "$@"; do
  case "$arg" in
    --doctor-only) doctor_only=true ;;
    --skip-tests) skip_tests=true ;;
    --skip-doctor) skip_doctor=true ;;
    --help|-h) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done
if "$doctor_only" && "$skip_doctor"; then
  echo '--doctor-only cannot be combined with --skip-doctor.' >&2
  exit 2
fi
if [[ "$(uname -s)" != Linux ]]; then
  echo 'Linux builds require a Linux host. macOS cannot build this target.' >&2
  exit 1
fi
case "$(uname -m)" in
  x86_64) arch=x64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) echo 'Unsupported Linux architecture; use x86_64 or aarch64.' >&2; exit 1 ;;
esac
project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root"
mkdir -p artifacts/linux/runs
run_dir="$(mktemp -d "$project_root/artifacts/linux/runs/.new.XXXXXXXX")"
run_name="$(date -u +%Y%m%dT%H%M%SZ)-${run_dir##*.}"
mv "$run_dir" "artifacts/linux/runs/$run_name"
run_dir="$project_root/artifacts/linux/runs/$run_name"
exec > >(tee "$run_dir/build.log") 2>&1
phase=preflight
trap 'status=$?; printf "exit_code=%s\nlast_phase=%s\ntests_skipped=%s\ndoctor_skipped=%s\n" "$status" "$phase" "$skip_tests" "$skip_doctor" > "$run_dir/result.txt"; exit "$status"' EXIT
printf 'Evidence: %s\n' "$run_dir"
uname -a
for executable in git clang++ cmake ninja pkg-config tar sha256sum ldd; do
  command -v "$executable" >/dev/null || {
    printf 'Missing build dependency: %s\n' "$executable" >&2; exit 1;
  }
done
pkg-config --modversion gtk+-3.0 gio-2.0
phase=doctor
./tool/flutterw --version
if ! "$skip_doctor"; then ./tool/flutterw doctor -v; fi
if "$doctor_only"; then exit 0; fi
phase=dependencies
./tool/flutterw pub get
(cd packages/dukto2_core && ../../tool/dartw pub get)
if ! "$skip_tests"; then
  phase=checks
  ./tool/check.sh
fi
phase=build
./tool/flutterw build linux --release
bundle="build/linux/$arch/release/bundle"
for file in dukto2 lib/libflutter_linux_gtk.so lib/libapp.so data/icudtl.dat data/flutter_assets/AssetManifest.bin; do
  [[ -f "$bundle/$file" ]] || { printf 'Missing bundle file: %s\n' "$file" >&2; exit 1; }
done
phase=runtime-dependencies
while IFS= read -r -d '' binary; do
  ldd "$binary" > "$run_dir/ldd-current.txt"
  cat "$run_dir/ldd-current.txt" >> "$run_dir/ldd.txt"
  if grep -q 'not found' "$run_dir/ldd-current.txt"; then
    printf 'Missing runtime dependency for %s\n' "$binary" >&2; exit 1
  fi
done < <(find "$bundle" -type f \( -name '*.so' -o -name dukto2 \) -print0)
phase=package
stage="$run_dir/Dukto2-linux-$arch"
mkdir -p "$stage"
cp -a "$bundle/." "$stage/"
cp LICENSE ACKNOWLEDGEMENTS.md THIRD_PARTY_NOTICES.md "$stage/"
cp -a licenses "$stage/"
cp docs/linux.md "$stage/LINUX.md"
cp docs/install.md "$stage/INSTALL.zh-CN.md"
cp linux/packaging/dev.dukto2.dukto2.desktop "$stage/"
cp tool/install_linux_user.py "$stage/"
cp tool/install-linux.sh "$stage/install.sh"
chmod 755 "$stage/install.sh"
archive="$run_dir/Dukto2-linux-$arch.tar.gz"
tar -czf "$archive" -C "$run_dir" "Dukto2-linux-$arch"
sha256sum "$archive" > "$archive.sha256"
tar -tzf "$archive" > "$run_dir/package-files.txt"
cp "$archive" "artifacts/linux/Dukto2-linux-$arch.tar.gz"
sha256sum "artifacts/linux/Dukto2-linux-$arch.tar.gz" > "artifacts/linux/Dukto2-linux-$arch.tar.gz.sha256"
phase=complete
printf 'Release package: artifacts/linux/Dukto2-linux-%s.tar.gz\n' "$arch"
echo 'Compilation does not verify desktop GUI, discovery, or physical LAN transfers.'
