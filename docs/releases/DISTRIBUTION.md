## Downloads and installation

These are direct-download preview packages from the Dukto2 project. Store distribution is pending. Download the package matching your operating system and CPU architecture, plus `SHA256SUMS.txt`. The same instructions are included in `INSTALL.md`.

| System | Download | Installation and limits |
| --- | --- | --- |
| Android | `*-android.apk` | Install the APK through the system installer. It uses the project application-signing key; a developer/debug build with a different key cannot be updated in place. Keep required data before deciding how to handle a signing conflict. Do not install an AAB directly. |
| Windows x64 / ARM64 | Matching `*-windows*.zip` | Extract the complete archive and run `Dukto2.exe`, retaining DLLs and data. The publisher is not code-signed; Windows or organization policies may block it. ARM64 requires Windows 11. |
| Linux x64 / ARM64 | Matching `*-linux*.tar.gz` | Extract the full bundle and run its user installation script. Ubuntu 24.04 is the current build baseline; GTK/glibc compatibility on other distributions is not guaranteed. |
| macOS | `*-macos-adhoc.zip` | Extract the app and move it to Applications. It is ad-hoc signed and not notarized. Gatekeeper may block opening; follow [Apple's guidance](https://support.apple.com/en-us/102445) after checking the source. Do not disable system protections. |
| iPhone / iPad | No public installable package yet | Unsigned device builds remain developer CI artifacts. They are not installable IPAs or TestFlight builds. Public distribution awaits the Apple developer signing/distribution setup. |

Verify downloads before opening them. Keep the downloaded packages, `INSTALL.md` and `SHA256SUMS.txt` together. On macOS use `shasum -a 256 -c SHA256SUMS.txt`; on Linux use `sha256sum -c SHA256SUMS.txt`. Missing files are reported if you downloaded only one platform: check that the selected package and `INSTALL.md` each report OK. On Windows use `Get-FileHash .\<downloaded-package> -Algorithm SHA256` in PowerShell and compare with its entry in `SHA256SUMS.txt`. Checksums detect damaged or changed downloads; they do not establish publisher identity.

Updates are manual: exit Dukto2 before replacing desktop program files, retaining settings and received files; Android requires the same application identity/signing key and an increasing versionCode. There is no automatic updater. A build passing CI does not mean every platform, old device or background-transfer scenario has been tested. See [validation coverage](https://github.com/lvjing2/dukto2/blob/main/docs/en/validation.md).

## Name, license and support

Dukto creator Emanuele Colombo agreed to the Dukto2 name on the condition that its source remains open source, preferably under MIT or Apache-2.0. Dukto2 continues under Apache-2.0 and is independently maintained by lvjing2. Naming permission does not imply code review or release certification by the original author. Support and feature requests belong in [Dukto2 Issues](https://github.com/lvjing2/dukto2/issues), not with the original Dukto author.
