# Dukto2 privacy policy draft

Prepared: 2026-10-20. Candidate: 0.1.6-rc.3+10. Maintainer: lvjing2. Contact: leojames.googol@gmail.com.

This is an offline release-preparation draft, not a published policy. Review the final binary and SDK behavior, establish a stable public URL and set the effective date before submitting a store listing.

## Files and text between devices

Dukto2 does not require an app account. Files you select and text you enter or paste are sent to the device you choose, after its receiving consent. The maintainer operates no file-relay, account or content-storage server. Transfers use HTTPS pinned to the verified device certificate, with size and SHA-256 checks. The recipient controls its copy; senders cannot remotely delete it.

Local discovery announces device names, types, app/protocol information, listening ports and public identity information. Other devices on the network may observe this discovery metadata; discovery messages are separate from encrypted file content. Connection records include device IDs, certificate fingerprints and local addresses. Connection QR codes contain local addresses and public device identities.

## Local storage and deletion

The app stores its device identity and keys, folder grants, language/theme/notification preferences, up to 100 history records, and up to 32 known devices. History can include peer and file names, sizes, locations, timestamps, durations and received text. It is not automatically uploaded to the maintainer.

Local diagnostics record stages, timestamps, random operation IDs, error types and limited source stack frames, without deliberately logging file content, file names or transfer addresses. Two rotating files are retained, each capped at 512 KiB by default, with a bounded write queue. There is no automatic log-upload feature. If you voluntarily email feedback, screenshots or logs, the maintainer receives that submission to address the issue.

Clearing app data or uninstalling normally deletes private app settings, records and identity; changed identities require verification again. Files saved to Downloads, an external folder or another device remain under your or the recipient's control. OS backup, restore and cloud storage are controlled by the operating system and your chosen storage provider; Dukto2 implements no separate backup service.

## Camera, clipboard and permissions

Camera access scans Dukto2 connection QR codes on the device. Camera images are not uploaded. Windows scanning briefly stores captured frames for local recognition and deletes them after processing; abrupt termination may leave a temporary file. Image recognition reads the selected image without deleting the original. Discovery and manual connection remain available without camera permission. The app reads the clipboard when you choose paste, and writes text when you choose copy; it implements no background clipboard monitoring.

Network and Wi-Fi permissions support discovery and communication. System file pickers and folder grants provide access to selected files. Notifications show progress and completion; foreground data-sync and wake-lock capabilities support active transfers. Permissions can be managed in system settings.

## Android barcode SDK

mobile_scanner 7.4.2 uses Google's bundled ML Kit barcode scanner com.google.mlkit:barcode-scanning:17.3.0. Google discloses diagnostic and usage-data collection, including device/app information, per-installation identifiers, performance, API configuration, input/output sizes, feature versions, events and error codes, transmitted over HTTPS. Bundling the model avoids its initial download; it does not imply an absence of SDK diagnostic traffic.

Dukto2 has no maintainer-operated analytics backend or advertising SDK. This is not a claim that all dependencies collect no data. Avoiding the scan screen is not a verified guarantee that every SDK remains uninitialized or sends nothing. Google's own policies govern its processing, retention and applicable requests:

- https://developers.google.com/ml-kit/android-data-disclosure
- https://policies.google.com/privacy

## Contact and changes

Contact leojames.googol@gmail.com for privacy questions or deletion of feedback you sent. The maintainer cannot access unsent local histories or delete copies on other devices. The policy will be updated when data practices or dependencies change, and a publicly accessible version must be hosted before store submission.
