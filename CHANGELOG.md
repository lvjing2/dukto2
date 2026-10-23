# Changelog

English | [Simplified Chinese](CHANGELOG.zh-CN.md)

Versions describe source evolution, not published installation packages. See [validation coverage](docs/en/validation.md) for actual platform builds and transfers.

## 0.1.6-rc.11+18 — Release candidate

- Add optional Android background reception, off by default, with a 30-minute waiting window and notifications that open the existing receive confirmation.
- Preserve the receive runtime across Activity recreation; stop waiting on opt-out or expiry without granting automatic file consent.

- Abort stalled uploads without publishing partial files.

## 0.1.6-rc.10+17 — Release candidate

- Distinguish confirmed peer cancellation from network failures, stop uploads, and clean up temporary resources.
- Tolerate transient or slow peer identity probes without bypassing identity checks before sending.
- Simplify selected-device rows and combine repeated encrypted LAN transfer descriptions across all supported languages.
- Keep nearby-device counts visible during active discovery.
- Increase Android versionCode to 17, retaining the existing application and upload signing keys.

## 0.1.6-rc.8+15 — Release candidate

- Isolate outgoing discovery announcements from the receive socket, so unavailable multicast or broadcast routes cannot disable reception or the next departure announcement.
- Use separate receive ports in the same-host departure regression test.
- Increase Android versionCode to 15, retaining the existing application and upload signing keys.

## 0.1.6-rc.7+14 — Release candidate

- Show the same project version in the app and release metadata, keeping the platform build number separate.
- Simplify empty-device and empty-history states across desktop and mobile layouts.
- Correct the multicast observer in the macOS departure-broadcast regression test; preserve the three-second expiry behavior.
- Use project-version release tags and increase Android versionCode to 14.

## 0.1.6-rc.6+13 — Release candidate

- Unify refresh-button and touch pull-to-refresh actions into active discovery, with a searching indicator and coalesced repeated requests.
- Check discovered peers independently every second and expire them after three seconds without HTTPS confirmation. Graceful exit broadcasts a departure hint; a failed HTTPS check permits earlier removal.
- Give presence checks separate bounded capacity so candidate scans cannot delay liveness checks.
- Simplify selected-device details and the QR scanner; show author links and the installed version in About.
- Deploy the same discovery logic to Android and Windows x64 for manual acceptance; this does not establish hardware coverage on every platform.

## 0.1.6-rc.5+12 — Release candidate

- Add native Windows ARM64 and Linux ARM64 builds and separate downloads.
- Verify architecture across the app, engine, plugins and runtime libraries; ARM64 hardware acceptance remains pending.

## 0.1.6-rc.3+10 — Release candidate

- Add Windows camera and image QR connections with touch and orientation support.
- Show online/offline state, disable unavailable sends, and recheck endpoint identity before sending.
- Place the device name first in Settings and align all language names with the dialog direction.
- Bundle the Windows VC++ runtime and add a user-level Linux desktop installer.
- Increase Android versionCode to 10 while retaining the application and upload signing identities.

## 0.1.6-rc.2+9 — Release candidate

- Freeze the first release candidate; align Android APK and Play AAB at versionCode 9, using separate application and upload signing keys.
- Add ten UI languages and localized native notifications, plus QR device connections that verify the complete device fingerprint before connecting.
- Include known-peer discovery, batch approval, file/text transfers, remembered receiving folders and transfer-history actions.
- Produce five-platform CI packages as a private GitHub prerelease draft. iOS remains an unsigned device build; macOS is ad-hoc signed and not notarized.
- Google Play enrollment, production approval and real cross-channel upgrades remain pending; see the release notes for validation limits.

## 0.1.6+7 — Unreleased

- Add structured transfer failures, bounded diagnostic logs and unified transfer-session cleanup.
- Provide English / Simplified Chinese repository documentation and bilingual issue / pull-request templates; consolidate development records and update simulator screenshots.
- Add five-platform native Release CI, versioned artifacts and digests, and tag-triggered draft releases; Android uses separate application and upload signing keys.
- Integrate Linux receiving-folder settings, opening folders, sleep inhibition, notification capability detection and user-level desktop registration. Revalidation coverage is documented separately.
- Select Apache-2.0; add licenses, third-party notices, contribution and security guides, provenance review and community checks.

## 0.1.5+6 — Development preview

- Unify launcher and in-app branding and update macOS hardware screenshots.

## 0.1.4+5 — Development preview

- Approve batches once; failure or cancellation stops remaining files, and continuing requests consent for the unfinished manifest.
- Extend receiving approval to five minutes, independently of inter-file idle expiry.
- Add device filtering, completion time and duration to recent transfers and improve narrow layouts.
- Add iPhone / iPad, Windows and Linux integration, with different platform validation levels.

## 0.1.1–0.1.3 — Development preview

- Improve discovery, Android foreground transfer service and system-folder storage.
- Add remembered receiving folders, 16 MiB text transfers, settings and completion notifications.
- Validate selected large-file, background, screen-off, cancellation and interruption scenarios, with known failures and limits retained.

## 0.1.0 — Initial baseline

- Flutter UI and independent Dart HTTPS core, identity comparison, streaming, size and digest checks.
- Bidirectional file transfers between macOS and Android GUI applications.
