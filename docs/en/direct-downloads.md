# Direct-download releases

English | [Simplified Chinese](../direct-downloads.md)

Use [GitHub Releases](https://github.com/lvjing2/dukto2/releases) for previews while store enrollment is pending.

| Platform | Download and limits |
| --- | --- |
| Android | Signed APK; differently signed development builds cannot update in place. |
| Windows x64 / ARM64 | Complete ZIP; no publisher signing, so Windows may block it. ARM64 requires Windows 11. |
| Linux x64 / ARM64 | TAR.GZ; Ubuntu 24.04 baseline, with dependencies to verify on other distributions. |
| macOS | Ad-hoc ZIP, not notarized; Gatekeeper may block opening. |
| iPhone / iPad | No public installable package yet; unsigned builds stay in CI pending Apple distribution setup. |

Future releases include six application packages, `INSTALL.md` and `SHA256SUMS.txt`; Play AAB stays in CI. See the [distribution notice](../releases/DISTRIBUTION.md) for installation and verification. Updates are manual; retain user data and the Android application-signing identity.

Before publishing, update the version/build number, run checks, build one source commit, and verify installation, upgrades, transfers and cancellation from the final packages. Publish the accepted draft, marking candidates as prereleases. Never overwrite published tags or attachments. Commands and signing details are in [Release CI](release-ci.md).
