# Validation coverage

English | [Simplified Chinese](../validation.md)

As of 2026-10-19. Current-workspace checks and prior device tests are separate; an older package passing does not validate every current change on that platform.

## Device connection status (2026-10-20)

The selected endpoint is checked every five seconds, with full certificate-fingerprint and device-ID matching, and checked again before sending. Green means online; gray means offline or checking. Changed identities are reported separately. File and text sends are disabled while unreachable, checking or mismatched. Old selections are no longer inserted into the nearby list; a directly reachable selected endpoint remains usable without discovery.

134 application tests, 49 core tests and 18 script tests passed. macOS Debug / Release builds passed. The actual Mac GUI connected to a controlled loopback TLS endpoint: sending was enabled online, disabled with a gray dot after shutdown, and restored after restarting the same identity and port. Captures are saved locally under `artifacts/peer-availability/`. This is a single-host check, not cross-device or Windows-tablet acceptance.

## Windows QR increment (2026-10-20)

Camera scanning and local image recognition retain full certificate fingerprint and device-ID matching. Both analyzers, 18 script tests and 49 core tests passed. After the application suite passed, additional orientation/theme combinations brought the new QR tests to 10 passing tests. Layouts cover 375×500, 900×500, 500×900, large text and reduced motion. Camera doubles cover unavailable/denied cameras, switching, background release and temporary-photo cleanup.

[Windows CI 39361156061](https://github.com/lvjing2/dukto2/actions/runs/39361156061) passed native host tests, Release compilation and packaging at source `0f39205`. The archive SHA-256 is `d333b74184c77320a02d49272788f31f34dcc8fefec068f6f1f76faa327b0fda`. Its camera plugin, Flutter DLL, three CRT DLLs and runtime license resources were checked independently. This private CI validation build does not replace an existing tag or Release asset.

These are automated checks. With no Windows device environment available, the maintainer deferred camera recognition, transfers after image connection, tablet hardware and device screenshots. Earlier Windows file-transfer results do not substitute for them.

## Current source

- `tool/check.sh`: 116 application tests, 49 core tests and 14 script tests passed; both analyzers reported no issues.
- Current macOS, Android and iOS simulator multilingual debug builds passed. UI acceptance and previous simulator transfer checks are distinguished below.
- QR dialogs cover ten languages, light/dark themes, large text and Arabic RTL layout. QR connection tests cover full fingerprint and device ID matching, rejection of mismatched identities, and direct peer selection without a second code comparison. File reception still requires separate consent.
- REDMI K90 physically scanned the Mac screen and directly selected the verified Mac without a second code comparison. Actual GUI file selection, sending and receiver consent then transferred 1 MiB + 17 bytes in each direction. Independent receiver-side sizes and SHA-256 hashes matched both sources across routable private subnets. Large files and background operation were not repeated in this round.
- Final compact connection actions and the Manual connection label were installed on Mac and Android. The Mac scanner page opens and returns; the iOS simulator build passed. Actual camera decoding on Mac and physical iPhone / iPad scanning remain unverified.
- UI acceptance: all ten languages were selected on iPhone. Arabic survived a force-close and relaunch on iPhone; English survived an update and cold launch on iPad. German and Arabic landscape layouts and English portrait layout were checked on iPad. Language changes and rotation retained a numeric text draft and the selected peer. Both devices were restored to system language.
- Fixed reversed Latin byte units found in Arabic simulator layouts by isolating each number/unit pair as LTR. A text-layout regression covers B, KB, MB and GB; the rebuilt app was visually rechecked on both simulators. Manual addresses and device codes remain LTR. Current Chinese and Arabic captures are indexed under [screenshots](../screenshots/README.en.md). This round did not add cross-device transfer tests.
- iPhone 18 Pro and iPad Pro 13-inch (M5), iOS 27.0 simulators: each approved one batch containing a UTF-8 file, empty file and 4 MiB binary. Including retries and pacing controls, all nine saved files independently matched source size and SHA-256.
- Cancelling an iPhone receive produced no success entry or temporary / pending residue. Resending succeeded, and diagnostics retained a structured upload-stage cancellation.
- Both simulators sent text through the Flutter UI; viewing, copying and pasting preserved exact content and hashes in both directions. New history entries contained time and duration.

Simulators share the host network; this does not validate physical Wi-Fi, background / screen-off operation or OS process termination.

## Prior hardware and desktop results

| Environment | Verified | Outstanding |
| --- | --- | --- |
| Apple Silicon macOS | Files / text with Android and iPad, folder memory, notifications and batch approval | Intel, minimum OS, full hardware regression after session refactoring |
| Android 16 / REDMI K90 | Bidirectional 1 GiB + 17 bytes with Mac; Home-background receive, screen-off send and paced 128 MiB screen-off receive; network loss, process termination, notification cancellation and cleanup / retry | Other vendors, older systems, prolonged deep Doze; some later Android → Mac large-file batches still timed out connecting |
| iPadOS 26.6 hardware | Files, text and three-file batches with Mac; approval after more than two minutes | Hardware regression after refactoring, Android exchange and background |
| Windows 11 x64 | Earlier native launch and files / text with Mac; 0.1.6 native build and host tests | Full 0.1.6 GUI destination / notification / transfer revalidation, Windows 10 / ARM64 |
| Ubuntu 24.04.3 x64 | Bidirectional GUI files; 0.1.6 default / selected destinations, restart persistence, opening folders, completion notifications, sleep inhibition and release | Full current GUI sending / text revalidation, other distributions / ARM64 |

An initial Android screen-off test reset the connection; later successful controls did not reproduce it and do not prove its root cause fixed. Screen-off tests used USB power, not deep Doze. Committed files survive cancellation; process death does not support resumption.

## Core and CI

The pure Dart core previously streamed and saved 4 GiB + 17 bytes in same-host TLS tests, plus a real 1 GiB + 17-byte source file, with independently matching disk hashes. These are not Flutter GUI memory or LAN throughput measurements.

Native Release CI built and packaged five platforms. See [Release CI](release-ci.md) for signature and usage limits; successful compilation does not prove device permissions or transfers. Presentation images are indexed under [screenshots](../screenshots/README.en.md).

## Revalidation

Run `./tool/check.sh` for shared code. For device tests, verify identity through the actual screen QR code or compare the receiver's code manually, select and approve in the UI, and independently read the saved length and SHA-256. Large-file / background changes should also cover cancellation, network loss, process termination, resource release and a fresh send. Report OS, architecture and the actual tested version.
