# Distribution before store enrollment

English | [Simplified Chinese](../direct-downloads.md)

As of 2026-10-22, [GitHub Releases](https://github.com/lvjing2/dukto2/releases) is the preview download channel. Store enrollment and production Apple signing proceed separately from Android and desktop previews. Source remains public under Apache-2.0. Packaging changes apply to the next build; existing published attachments are not changed.

## Platform scope

| Platform | Current download | Limits and next steps |
| --- | --- | --- |
| Android | Universal APK signed with the fixed project application key | Installed through the system installer without Play Store. Vendor policy may require per-source approval or block installation. A differently signed development build cannot update in place. Future Play enrollment must preserve the application-signing identity and use the separate upload key for AABs. |
| Windows x64 / ARM64 | Complete portable ZIP | No publisher code signing yet; SmartScreen or organization policy may block execution. Signing, an installer and store delivery are later steps. |
| Linux x64 / ARM64 | Complete TAR.GZ with a user installation entry | Ubuntu 24.04 is the current binary baseline. Other distributions still depend on compatible GTK/glibc. AppImage / Flatpak are not default mainline release assets; work on another branch is not a published capability. |
| macOS | Ad-hoc ZIP for preview users who understand the limits | No Developer ID signing or notarization yet. Gatekeeper may block opening; follow [Apple guidance](https://support.apple.com/en-us/102445), without disabling system protections. Broad distribution awaits developer enrollment, signing and notarization. |
| iPhone / iPad | No public installable download yet | Unsigned device builds stay in CI, and are not installable IPAs or TestFlight builds. Public distribution awaits Apple signing and distribution setup. Developer Xcode testing is covered in the [iOS guide](ios.md). |

See [Android signing](https://developer.android.com/studio/publish/app-signing) and [Apple developer accounts](https://developer.apple.com/help/account/basics/about-your-developer-account). Store enrollment, publisher certificates and OS approval to open an app are separate concerns.

## Downloads and verification

Future releases provide six application packages: Android APK, Windows x64 / ARM64 ZIPs, Linux x64 / ARM64 TAR.GZ bundles and macOS ZIP, plus `INSTALL.md` and `SHA256SUMS.txt`. The English [distribution notice](../releases/DISTRIBUTION.md) is shared by installation instructions and Release bodies. It includes naming permission, the open-source condition, independent maintenance and the support link. Unsigned iOS, Play AAB and detailed metadata stay in expiring CI artifacts rather than public installation downloads.

Download your package, `INSTALL.md` and `SHA256SUMS.txt` together. On macOS run `shasum -a 256 -c SHA256SUMS.txt`; on Linux run `sha256sum -c SHA256SUMS.txt`. If you downloaded only one platform, missing other packages is expected: ensure your selected package and instructions report OK. On Windows use `Get-FileHash .\<downloaded-package> -Algorithm SHA256` in PowerShell and compare its entry. A checksum detects damaged or changed content; it does not authenticate the publisher.

Exit desktop apps before replacing program files and retain settings and received files. Android updates keep the package/application key and increase versionCode, without requiring routine uninstall. There is no automatic updater.

## Release checklist

1. Keep the naming-permission summary, Apache-2.0 and third-party notices public. Keep full private emails and mail headers out of the repository. Route support to Dukto2 Issues.
2. Choose the source commit, update the project version/build number in `pubspec.yaml`, and run `python3 tool/sync_project_version.py`. Never reuse or move published tags or replace historical attachments.
3. Run `tool/check.sh` and CI formatting. Manual workflows build without publication; tag builds create drafts. English Release Notes must distinguish executed checks from untested scope.
4. Assemble all platform outputs from the same commit. Verify the fixed APK key, application ID, versionCode, all downloads and the checksum list. Exclude unsigned iOS and store-upload or promotional files from user downloads.
5. Test installation/update from final downloaded packages, launch, two-device transfers, cancellation and cleanup. Retain existing user data; record OS, signing, architecture and limitations. Unverified cross-channel updates remain explicitly unverified.
6. Review the draft's per-platform validation and signing/notarization status. Candidates remain prereleases. Publish after maintainer acceptance; store enrollment pending does not mean store availability.
7. Preserve tags, build metadata, checksums and validation evidence separately from expiring CI artifacts. Fix published issues in a new version rather than replacing old payloads.

Commands and signing details are in [Release CI](release-ci.md). This preparation does not create a new tag, publish a Release or submit a store application.
