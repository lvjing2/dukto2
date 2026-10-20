# Windows

English | [Simplified Chinese](../windows.md)

Windows 11 x64 is tested; Windows 10, ARM64 and 32-bit Windows are not. See [validation coverage](validation.md) for builds and transfers actually performed.

## Build

Install Flutter 3.47.7 stable / Dart 3.13.5, Git, Visual Studio's Desktop development with C++ workload and Windows SDK. Visual Studio Code does not provide that toolchain. Check `flutter doctor -v` first.

From the repository root in PowerShell:

```powershell
./tool/windows.ps1
# Debug build only, without tests:
./tool/windows.ps1 -Mode debug -SkipTests
```

The script does not change execution policy. Alternatively:

```powershell
flutter pub get
dart analyze
flutter test
cd packages/dukto2_core
dart pub get
dart analyze
dart test
cd ../..
flutter build windows --release
```

Run `build/windows/x64/runner/Release/Dukto2.exe`. Distribute the entire Release directory, including DLLs, data and license files. The script outputs `artifacts/windows/Dukto2-windows-x64-release.zip` and SHA-256, without a signed installer. New builds include the toolchain-provided release CRT DLLs for app-local deployment; packaging fails if required DLLs are absent. Existing rc.2 downloads may still need the official Visual C++ x64 Redistributable. See [installation](../install.md) and [distribution](release-ci.md).

## System behavior

- Uses the computer's system name; defaults to the system Downloads folder / Dukto2, including redirected Downloads. Supports selected folders, persistence and restore default.
- Opens / selects files in Explorer. An unavailable folder produces an error rather than silently changing destinations.
- Completion reminders use Windows notification-area APIs; actual display depends on system settings.
- Transfers inhibit idle sleep, not deliberate sleep or lid closure. There is no persistent tray process or resumption after process death.
- TCP defaults to 45879; UDP discovery uses 45878. Allow the trusted LAN when prompted by the firewall. Manual connections still require identity comparison.

References: [Flutter Windows setup](https://docs.flutter.dev/platform-integration/windows/setup), [distribution](https://docs.flutter.dev/platform-integration/windows/building).

## QR connection

Open **Scan QR** to use a camera or **Choose image**. PNG, JPEG and BMP images are supported, with limits of 20 MiB encoded and 16 megapixels decoded. Recognition stays on this device.

Use the camera selector on devices with multiple cameras. The current Windows camera backend reports all lenses as front-facing, so some tablets need manual selection of the rear camera. Controls support touch, portrait/landscape and large text. Native Windows ARM64 tablet builds remain unverified.

If camera access fails, check Windows Settings → Privacy & security → Camera, including desktop-app access. Image recognition and manual connection remain available. Switching cameras, backgrounding or leaving the scanner releases the camera. Temporary capture photos are deleted after processing and never added to transfer history; selected images are left unchanged. Abrupt process termination can leave an unprocessed photo in the system temporary directory.

QR connections still match the complete certificate fingerprint and device ID. Transfer consent remains separate.

Native ARM64 hosts use `arm64` build directories and package names; x64 hosts continue to use `x64`. CI checks binary architecture. ARM64 desktop launch and LAN transfers still require physical-device validation.
