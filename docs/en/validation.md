# Validation coverage

English | [简体中文](../validation.md)

As of 2026-10-19. Current-workspace checks and prior device tests are separate; an older package passing does not validate every current change on that platform.

## Current source

- `tool/check.sh`: 69 application tests, 46 core tests and 4 script tests passed; both analyzers reported no issues.
- macOS debug and iOS simulator debug builds passed.
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

Run `./tool/check.sh` for shared code. For device tests, compare the receiver's actual code, select and approve in the UI, and independently read the saved length and SHA-256. Large-file / background changes should also cover cancellation, network loss, process termination, resource release and a fresh send. Report OS, architecture and the actual tested version.
