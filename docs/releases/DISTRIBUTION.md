## Downloads

Choose your system and architecture. Store distribution is pending.

| System | Package and installation |
| --- | --- |
| Android | `*-android.apk`: install through the system installer. Differently signed debug builds cannot update in place. |
| Windows x64 / ARM64 | Matching ZIP: extract fully and run `Dukto2.exe`. No publisher signing; Windows may block it. ARM64 requires Windows 11. |
| Linux x64 / ARM64 | Matching TAR.GZ: extract and run the user installation script. Ubuntu 24.04 baseline; other distributions need compatible libraries. |
| macOS | `*-macos-adhoc.zip`: extract and move the app to Applications. Not notarized; follow [Apple guidance](https://support.apple.com/en-us/102445) if blocked. |
| iPhone / iPad | No public installable package yet. Unsigned builds stay in CI. |

Verify your package against `SHA256SUMS.txt`: use `shasum -a 256 <file>` on macOS, `sha256sum <file>` on Linux, or `Get-FileHash .\<file> -Algorithm SHA256` in PowerShell. Checksums verify content, not publisher identity.

Updates are manual; exit the app before replacing desktop files and retain user data. See [tested coverage](https://github.com/lvjing2/dukto2/blob/main/docs/en/validation.md).

## Acknowledgement

The original author agreed to the Dukto2 name provided the source remains open. Dukto2 uses Apache-2.0 and is independently maintained by lvjing2. Support: [Dukto2 Issues](https://github.com/lvjing2/dukto2/issues).
