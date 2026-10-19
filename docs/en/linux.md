# Linux

English | [简体中文](../linux.md)

Ubuntu 24.04.3 x64 / GTK3 is tested. Ubuntu 22.04, other distributions and ARM64 are not; binaries built on newer distributions need not run on older systems. See [validation coverage](validation.md).

## Build

Ubuntu build dependencies:

```sh
sudo apt-get update
sudo apt-get install -y git curl xz-utils unzip zip clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

Install Flutter 3.47.7 stable / Dart 3.13.5 on PATH or set `FLUTTER_BIN`. Android SDK, Xcode and Visual Studio are not required.

```sh
./tool/linux.sh --doctor-only
./tool/linux.sh
```

By default the script runs `tool/check.sh`, builds natively, checks dynamic libraries and packages the bundle. `--skip-tests` is for diagnosing build problems; `--skip-doctor` avoids a repeated toolchain check. Skipped checks are recorded and cannot be counted as passing.

Output: `artifacts/linux/Dukto2-linux-x64.tar.gz`; logs: `artifacts/linux/runs/`. Distribute the full bundle with lib, data, licenses and third-party notices, not just its executable. Targets need compatible GTK3 / glibc.

## Launch and desktop integration

In a logged-in graphical desktop:

```sh
./build/linux/x64/release/bundle/dukto2
# Register the source-build bundle for the current user:
python3 tool/install_linux_user.py build/linux/x64/release/bundle
# In an extracted distribution:
python3 install_linux_user.py .
```

Registration installs the current user's desktop entry and icon without sudo or moving the bundle. Re-register after moving or updating it. Completion notifications need a desktop service and the installed desktop file for the app ID. No deb, rpm or AppImage is provided.

## System behavior

- Defaults to Downloads / Dukto2, with selected folders, restart persistence and restore default. Inaccessible folders require reselection; old files and history remain.
- Opens parent folders through GIO and sends completion reminders through the desktop notification service.
- GNOME / Ubuntu can open system notification settings when `gnome-control-center` is installed; other desktops hide unavailable actions.
- Transfers inhibit idle sleep and release the request on completion, failure, cancellation or exit. Deliberate sleep, lid closure and locking remain possible.
- UDP discovery uses 45878; TCP defaults to 45879. VM NAT / WSL2 can affect inbound connections and does not replace normal desktop LAN validation.

References: [Flutter Linux setup](https://docs.flutter.dev/platform-integration/linux/setup), [distribution](https://docs.flutter.dev/platform-integration/linux/building).
