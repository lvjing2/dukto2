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

Run `build/windows/x64/runner/Release/Dukto2.exe`. Distribute the entire Release directory, including DLLs, data and license files. The script outputs `artifacts/windows/Dukto2-windows-x64-release.zip` and SHA-256, without a signed installer. Targets need the corresponding Visual C++ x64 Runtime; see [distribution](release-ci.md).

## System behavior

- Uses the computer's system name; defaults to the system Downloads folder / Dukto2, including redirected Downloads. Supports selected folders, persistence and restore default.
- Opens / selects files in Explorer. An unavailable folder produces an error rather than silently changing destinations.
- Completion reminders use Windows notification-area APIs; actual display depends on system settings.
- Transfers inhibit idle sleep, not deliberate sleep or lid closure. There is no persistent tray process or resumption after process death.
- TCP defaults to 45879; UDP discovery uses 45878. Allow the trusted LAN when prompted by the firewall. Manual connections still require identity comparison.

References: [Flutter Windows setup](https://docs.flutter.dev/platform-integration/windows/setup), [distribution](https://docs.flutter.dev/platform-integration/windows/building).
