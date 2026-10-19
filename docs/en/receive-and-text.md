# Receiving folders and text

English | [Simplified Chinese](../receive-and-text.md)

## Receiving folders

Change the destination or restore its default in Settings → Receiving location. This does not move or delete existing files; history retains the original location. An inaccessible selected folder requires selecting it again.

| Platform | Default destination | Access |
| --- | --- | --- |
| macOS | Downloads / Dukto2 | System folder picker and security-scoped bookmarks |
| Windows / Linux | Downloads / Dukto2 | System folder picker and local path |
| Android 10+ | Downloads / Dukto2 | MediaStore by default, persistent SAF grants for selected folders |
| Android 7–9 | App storage | Direct receiving after an SAF folder grant |
| iPhone / iPad | Files → On My iPhone / iPad → Dukto2 → the default receiving folder shown in Settings | System folder picker and security-scoped bookmarks |

Separate targets handle duplicate names without overwriting existing files. Success is recorded only after length / SHA-256 validation and commit. Incomplete targets are discarded; cancellation never deletes committed files. See [storage lifecycle](reliability.md).

## Text

Select and verify a device, choose text, type or explicitly paste, then send. After approval, received text is available for viewing and copying in recent transfers. Clipboard contents are not read or synchronized automatically.

- Maximum payload: 16 MiB of UTF-8 bytes; the editor supports up to 1 MiB.
- Larger text is loaded from a file through the additional text actions and streamed.
- Received bodies over 1 MiB go to the destination folder with a bounded history preview, copy-preview action and access to the full text.
- Mobile editing uses a compact keyboard layout; dismissing the keyboard preserves the draft and page position.
- Clipboard capacity is determined by the operating system.

Manual connections accept IPv4 and a port. Full-width digits, colons and periods are normalized before strict validation. Device-code comparison remains required.
