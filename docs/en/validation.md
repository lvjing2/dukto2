# Validation coverage

English | [Simplified Chinese](../validation.md)

As of 2026-10-21. Current-workspace checks and prior device tests are separate; an older package passing does not validate every current change on that platform.

## Peer cancellation and compact device selection (2026-10-21)

- Before the fix, real loopback TLS receiver cancellation returned a network failure. Peer cancellation now requires explicit certificate-pinned HTTPS confirmation scoped to the current token and source IP. Ordinary disconnects, unknown/expired tokens and legacy v1 receivers without the extension are not interpreted as peer cancellation. Confirmations expire after two minutes, with a maximum cache of 128. Status queries confer no file permission and never own upload/commit cleanup.
- Cancellation stops the outgoing source subscription and upload connection, distinguishing local and peer cancellation. File and text panels provide the peer-cancelled message in every existing language. Online selected devices no longer repeat the verified/selected subtitle; selection tint, checkmark, accessibility selection and abnormal connection details remain.
- `tool/check.sh` passed all 150 application, 67 core and 22 script tests, with both analyzers clean. Coverage includes stalled sources, real disconnects, confirmation capacity/expiry, commit boundaries, legacy v1 responses and rendered panel messages. The full check passed again after the device-list simplification.
- The isolated Mac receiver cancelled after receiving 2 MiB. The REDMI K90 running Android 17 visibly reported peer cancellation, and no partial file remained on the Mac. In the reverse direction, cancelling a paced receive on the phone produced `Transfer cancelled by peer` on the Mac CLI; the Android temporary file and pending MediaStore row were removed and the foreground service stopped.
- After cancellation, the final phone build received a new 1 MiB + 17 bytes request with a fresh consent dialog. Committed-file size and independent SHA-256 matched, and the foreground service stopped normally afterward.
- Android was updated with a local Release validation build without clearing data; the Mac Release build passed. Compact selection was also checked on the actual phone. Evidence is local under `artifacts/peer-cancel-20261021/`. This validates Mac CLI ↔ physical Android, not macOS GUI ↔ Android or old hardware, and does not publish a new Release.

## Slow-network presence regression (2026-10-21)

- HTTPS probes for announcements, Bonjour, manual addresses and remembered endpoints now have a two-second default budget. Subnet scans retain an 800 ms maximum per candidate. Known-peer heartbeat probes allow two seconds, independently of the unchanged three-second expiry after the last successful confirmation.
- Selected peers are checked every second, sharing an unfinished probe. Three consecutive failures are required to turn a previously online selection offline. Initial failures never establish online status; changing selections resets the failure count, and device-ID or certificate-fingerprint changes block sending immediately. Display grace never substitutes for the pre-send check: a failed check creates no transfer and immediately marks the selection offline.
- Before the fix, regressions for one transient miss, a 1.2-second selected-peer response, and real loopback TLS announcements/heartbeats responding after 1.1 seconds failed. After the fix, `tool/check.sh` passed all 147 application, 63 core and 22 script tests, with both analyzers clean. Core checks also cover disconnection, hanging endpoints, forged broadcasts, stale results and recovery.
- The matching local Android Release validation build updated rc.5 to rc.8+15 without clearing history. Its signing certificate matches the previously installed local development build, not the official Release certificate. The macOS Release build also passed.
- A REDMI K90 running Android 17 connected through its real UI to an isolated Mac CLI endpoint. After identity verification, 128 MiB + 17 bytes transferred in both directions across routable subnets. Independently checked committed-file sizes and SHA-256 digests matched on both devices. Both directions included pressing Home, with the foreground transfer service observed running. The Mac CLI initiated the forward transfer; Android used its system picker and actual send button for the return transfer.
- Pausing only the controlled receiver disabled sending on Android. Resuming the same process restored sending without reselection, and the received test text matched exactly. Receiver-side cancellation of a separate paced transfer removed an observed approximately 28 MiB MediaStore temporary file and its pending row. A subsequent 1 MiB + 17 bytes request still required fresh consent, passed transfer and independent digest checks, and released its foreground service after completion.
- That round identified receiver-initiated cancellation being classified as a network failure; it has since been fixed and revalidated in the peer-cancellation round above. Original evidence is under `artifacts/connection-stability-20261021/`. Accessibility export could not reach idle during one animated progress screen; that snapshot is excluded from status evidence. Transfer conclusions rely on actual screenshots, receiver records and disk checks.
- This validates Mac CLI ↔ physical Android, not macOS GUI ↔ Android. It does not establish end-to-end 4 GiB, screen-off/deep-sleep or old-Android acceptance. Wireless ADB was used for debugging only; file payloads used real LAN TLS without ADB port forwarding.

## Windows active-search acceptance (2026-10-21)

Commit `7e6d7a4` was validated natively on Windows 11 x64, OS build 26200, with Flutter 3.47.7 / Dart 3.13.5. The uploaded source snapshot was independently SHA-256 checked and built in a separate directory, retaining the previous application and user data.

- All 139 application tests, 50 core tests and both analyzers passed on Windows. The Release build and complete DLL/data package succeeded. Archive SHA-256: `b5fc455e94cc10e84025db21e4b6bf8950c7092f298320a0d5b031b53bb6889e`. This local validation package does not replace a published Release asset.
- The real desktop process ran from the verified build path. Existing settings were not cleared, and prior history remained visible. Clicking refresh showed the searching label and spinner, then restored the refresh action. The live list discovered Mac and Android peers. A read-only UDP observer on the Mac received the active-discovery announcements.
- This PC has a mouse and no touchscreen. Mouse dragging does not trigger the touch pull gesture. Further pull validation was stopped at the maintainer's request. A prior [Windows SDK touch injection](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-injecttouchinput) reached the searching UI, but is not counted as manual physical-touchscreen acceptance. File transfers and cameras were not retested in this round.
- The existing `Dukto2.lnk` now targets this build, with its previous link backed up. The temporary desktop verification task and input tools were removed. Captures: [button-triggered search](../screenshots/windows-discovery-search.png) / [finished](../screenshots/windows-discovery-ready.png). History entries are from earlier transfers.

## Active device search (2026-10-21)

The refresh button and a pull at the top of the list share one active discovery operation: reannounce, reconnect verified endpoints, and run the bounded private IPv4 subnet scan even when peers are already visible. Apple also restarts Bonjour; Android ensures its multicast lock is held. Repeated gestures join the current task, and periodic network checks do not interrupt it. Existing peers stay visible. A single heading and spinner show searching; short lists also support the gesture.

- `tool/check.sh` passed 139 application tests, 50 core tests and 21 script tests; both analyzers were clean. The final indicator adjustment additionally passed all 32 widget tests and application analysis. The Android Release APK built successfully.
- REDMI K90 was updated over wireless adb without clearing data. Actual button and pull operations showed searching, finished, restored the refresh action, and kept the discovered Mac visible. A read-only UDP observer on the Mac received fresh discovery announcements after both actions. The final two rounds took approximately 28 seconds from input to observing completion, including the full scan and UI sampling; this is not time to first discovery.
- Core coverage includes scanning with existing peers, coalescing requests, and returning safely after close. UI coverage includes phone/desktop, short lists, state restoration, and a single progress indicator. Controller coverage includes scan failures and native-discovery failure fallback.
- Hardware captures: [searching](../screenshots/android-discovery-search.png) / [finished](../screenshots/android-discovery-ready.png). File transfers, real-network discovery on other platforms, and disconnect/reconnect were not revalidated in this round.

## Device connection status (2026-10-20)

The selected endpoint is checked every five seconds, with full certificate-fingerprint and device-ID matching, and checked again before sending. Green means online; gray means offline or checking. Changed identities are reported separately. File and text sends are disabled while unreachable, checking or mismatched. Old selections are no longer inserted into the nearby list; a directly reachable selected endpoint remains usable without discovery.

134 application tests, 49 core tests and 18 script tests passed. macOS Debug / Release builds passed. The actual Mac GUI connected to a controlled loopback TLS endpoint: sending was enabled online, disabled with a gray dot after shutdown, and restored after restarting the same identity and port. Captures are saved locally under `artifacts/peer-availability/`. This is a single-host check, not cross-device or Windows-tablet acceptance.

## Windows QR increment (2026-10-20)

Camera scanning and local image recognition retain full certificate fingerprint and device-ID matching. Both analyzers, 18 script tests and 49 core tests passed. After the application suite passed, additional orientation/theme combinations brought the new QR tests to 10 passing tests. Layouts cover 375×500, 900×500, 500×900, large text and reduced motion. Camera doubles cover unavailable/denied cameras, switching, background release and temporary-photo cleanup.

[Windows CI 39361156061](https://github.com/lvjing2/dukto2/actions/runs/39361156061) passed native host tests, Release compilation and packaging at source `0f39205`. The archive SHA-256 is `d333b74184c77320a02d49272788f31f34dcc8fefec068f6f1f76faa327b0fda`. Its camera plugin, Flutter DLL, three CRT DLLs and runtime license resources were checked independently. This private CI validation build does not replace an existing tag or Release asset.

Those were the automated checks on 2026-10-20. With no Windows device environment available then, the maintainer deferred camera recognition, transfers after image connection, tablet hardware and device screenshots. Earlier Windows file-transfer results do not substitute for them.

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
