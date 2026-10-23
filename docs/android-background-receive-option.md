# Optional Android background reception

Approved for integration into main on 2026-10-23. Android background reception remains off by default; published packages require a separate release.

- Off by default. Enable it from Settings → Notifications while the app is visible.
- Each session lasts up to 30 minutes. It is not saved across process restarts and does not start at boot.
- Requires notification permission and both waiting/request channels. If unavailable, the switch stays off and offers system settings.
- A foreground service keeps the existing Flutter engine and LAN listener alive when the Activity leaves the foreground. Activity recreation reuses the runtime rather than creating another server.
- An incoming request creates a private notification. Opening it only shows the existing confirmation screen; it never grants consent. Existing TLS pinning, file/batch approval, streaming, hash checks, and receive storage remain in use.
- Switching off, expiry, or notification revocation rejects unconfirmed background requests and clears the request notification. A transfer already explicitly approved may finish under the existing transfer service.
- Removing the app task stops the runtime. Force-stop and manufacturer process freezing are not bypassed. HyperOS smart background limits can still prevent requests from arriving.
- No idle wake lock, battery exemption, cloud push, or automatic background restart is added. Battery consumption has not been assessed.

## Preview build

Set `DUKTO2_BACKGROUND_PREVIEW=true` when building Android. The preview uses application ID `dev.dukto2.bgvalidation` and label `Dukto2 后台预览`, independently of the official app. A release-mode preview uses the development signing key unless explicit release signing is configured; it is not an official distribution artifact.

## Checks

Automated checks cover default-off behavior, explicit consent, channel denial/revocation, expiry including delayed timers, stale notification IDs, rapid disable/start races, deferred cleanup during approved transfers, and switch feedback. Full-app physical checks and their results are recorded separately; prototype results must not be described as full-app acceptance.

The project owner approved integration after reviewing these checks.

## Validation (2026-10-23)

`tool/check.sh` passed: 23 tooling tests, 165 application tests, 71 core tests, and both analyzers. The notification UI correction subsequently passed all five controller/widget tests and analysis. The final Android preview built successfully.

Physical scope: Mac CLI → REDMI K90 / Android 17, full Flutter preview, original smart background policy. This is not macOS GUI acceptance or a multi-vendor reliability result.

| Check | Result |
| --- | --- |
| Initial state | Off; no waiting service |
| Explicit enable | On; connected-device foreground service appears |
| Background request | Request notification appears after Home |
| Notification tap | Opens exact file confirmation; no automatic approval |
| Confirmed file reception | 1,048,593 bytes; native on-device SHA-256 equals Mac original |
| Activity task clear/recreation | Same process and opt-in retained; another request can be declined |
| Switch off | Service exits; next background request is declined |
| Process restart after opt-in | Off again |
| Notification permission denied | Stays off and shows settings guidance; original permission restored |
| Notification “Stop waiting” | Pending request declined; service exits |
| Expiry, stale IDs, rapid toggles, busy cleanup | Automated checks; full 30-minute native expiry not physically timed |

File SHA-256: `c02555cac794d692704a1d1e5f3809874f8e98f1197f972f4af84e43e9a18bce`.

Known limit: earlier isolated pilot tests reproduced HyperOS freezing under the original smart policy even with a foreground service. This preview does not solve or bypass that policy. Long locked-screen availability is not guaranteed. Battery testing was stopped at the user's request. No battery policy was changed in this round.

Integration into main is approved. This record does not indicate a newly published installation package.
