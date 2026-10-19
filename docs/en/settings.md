# Settings

English | [简体中文](../settings.md)

Open Settings using the gear on the main screen. About Dukto2 is at the bottom; receiving-folder controls are not duplicated on the main screen.

| Setting | Behavior |
| --- | --- |
| Receiving location | Select / remember a folder or restore default; existing files stay in place |
| Device name | Read-only name returned by the system, refreshed on startup and foreground resume; no in-app renaming |
| Completion notifications | Enable successful-send / receive reminders and inspect or request system permission |
| Appearance | System, light or dark, remembered after restart |
| About | Version, Dukto tribute, AI disclosure and third-party licenses |

Changing a system name does not change device identity or its certificate. iOS restricts access to custom names; see [Apple platforms](ios.md).

Completion messages omit filenames and text bodies. System permission, do-not-disturb and desktop notification services control actual display. Notification failure does not invalidate a completed transfer. Android's ongoing foreground-service notification, including progress and cancellation, is separate from completion reminders.

Linux exposes system notification settings only when supported by the desktop; Windows manages notification delivery. See [files and text](receive-and-text.md) for destinations and [batches and history](batch-and-history.md) for recent transfers.
