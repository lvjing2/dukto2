# Changelog

English | [简体中文](CHANGELOG.zh-CN.md)

Versions describe source evolution, not published installation packages. See [validation coverage](docs/en/validation.md) for actual platform builds and transfers.

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
