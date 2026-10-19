# Multi-platform Release CI

English | [Simplified Chinese](../release-ci.md)

Workflow: [Release builds](https://github.com/lvjing2/dukto2/actions/workflows/release.yml), configured in [release.yml](../../.github/workflows/release.yml). Downloads follow repository access permissions.

## Trigger and download

- Actions → Release builds → Run workflow selects all or one platform and uploads artifacts without creating a tag or release. Android signing requires main or a release tag.
- A `v*` tag matching `pubspec.yaml` creates a **draft release** only after all builds succeed. It is not automatically published and does not overwrite a published release.
- Tags must match the source version, such as `v0.1.6` or `v0.1.6+7`; mismatches fail before building.

Each platform uploads an artifact, retained for seven days by default. It contains versioned archives or APK / AAB files, SHA-256 sidecars and JSON metadata. Draft-release attachments are stored separately from expiring Actions artifacts. Store submissions, installers and automatic updates are not configured. Android signing and initial Play enrollment are described in [two-channel signing](android-signing.md).

```sh
gh workflow run release.yml --repo lvjing2/dukto2 --ref main
gh run list --repo lvjing2/dukto2 --workflow release.yml
gh run download <run-id> --repo lvjing2/dukto2 --dir ./release-downloads
# In the extracted output directory:
sha256sum --check *.sha256
```

## Platforms and signing

| Platform | Runner | Output | Signing and use |
| --- | --- | --- | --- |
| Linux | Ubuntu 24.04 x64 | Full bundle tar.gz | Unsigned, with library checks; other distributions need testing |
| Windows | Windows 2025 x64 | Full Release zip | Unsigned; retain DLLs and data, not only the exe |
| macOS | macOS 26 arm64 | App zip | Ad-hoc, not notarized; actual architecture recorded in JSON, not proof of Intel validation |
| Android | Ubuntu + Java 21 | Signed universal APK, Play AAB and notices zip | Application key for APK, upload key for AAB; Play must first import the application key |
| iPhone / iPad | macOS 26 | Unsigned device app zip | One app covers both families; not an installable IPA or TestFlight package |

Windows packages contain the app, Flutter DLL and data but not Visual C++ Runtime. Install the matching x64 runtime from [Microsoft](https://aka.ms/vc14/vc_redist.x64.exe) if `MSVCP140.dll` / `VCRUNTIME140.dll` is missing. See [Flutter Windows distribution](https://docs.flutter.dev/platform-integration/windows/building) and [Microsoft runtime guidance](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist). Linux requires compatible GTK3 / glibc; `ldd` records native dependencies.

Android CI uses two GitHub Secrets groups and checks APK / AAB signatures, matching package / version, and an application-key-signed APK derived from the AAB. See [two-channel signing](android-signing.md). Local builds without signing parameters retain development debug-key behavior. Apple outputs still check ad-hoc / unsigned state, with production Apple signing configured separately. Private keys are never committed.

## Checks and traceability

Linux preflight runs analysis, Dart / Flutter / Python tests and formatting before parallel native builds. Windows and macOS also run host checks. One platform failing does not suppress other build results but blocks draft-release assembly. Compilation does not validate device UI, permissions, background behavior or LAN transfers.

Flutter 3.47.7 archives and official SHA-256 are pinned in [flutter-sdk.json](../../tool/ci/flutter-sdk.json); verification precedes extraction. Actions use pinned commits. Packages retain LICENSE, third-party notices and Flutter resources. Metadata records version, Git commit, platform, runner architecture, Flutter version and signing. Digests verify download integrity, not a security audit or reproducible-build proof.

Only draft assembly has `contents: write`; build jobs are read-only. Android steps restore their signing material from Secrets into temporary storage and clean it afterward, without changing repository visibility. Maintainers control tagging and publication. Manual / tag triggers, timeouts and retention limits avoid rebuilding five platforms on each code push.
