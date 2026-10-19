# Dukto2 protocol v1

English | [简体中文](../protocol-v1.md)

Protocol and UI are separate. Any future legacy Dukto adapter should be independent; v1 must not introduce an unencrypted fallback.

## Discovery and trust

IPv4 UDP uses port 45878, multicast `224.0.0.167` and broadcast `255.255.255.255`. `IP_MULTICAST_IF` sends per IPv4 interface to reduce default-VPN-route effects; broadcast supplements it. Startup announcements repeat at 100 / 600 / 2600 ms, then every three seconds. Candidates enter the peer list only after HTTPS `/v1/info` and certificate confirmation; peers expire after 18 seconds without confirmation. JSON includes `app: dukto2`, `v: 1`, a random device ID, name, actual HTTPS port and full certificate DER SHA-256. Packets are limited to 4096 bytes, confirmed peers to 128 and concurrent probes to eight. Fingerprints deduplicate peers; an offline previous selection does not count as nearby.

Announcements and `/v1/info` may include `deviceType: "phone" | "tablet" | "computer"` for UI icons only. Missing / unknown / invalid values use a generic icon; old clients can ignore the field. Names and types establish neither identity nor consent. iPhone / iPad use system interface idiom, Android uses a 600dp smallest-width threshold, and desktops report computer.

The GUI defaults to HTTPS 45879 and falls back to a temporary port if occupied. Without discovery results, bounded HTTPS metadata probes target directly connected private IPv4 /24 networks; manual addresses remain available. Interface changes and foreground resume rebuild multicast subscriptions. An idle HTTPS self-check can rebind an unhealthy listener. This confirms announcement / certificate consistency, not the user's identity comparison.

Discovery and `/v1/info` provide unauthenticated candidates. Manual probing compares the response fingerprint with the actual TLS certificate. The UI requires comparing the first 16 hexadecimal SHA-256 characters (64 bits) on the receiving device's local screen. After confirmation, the sender pins the full fingerprint. Trusting an unverified advertised fingerprint alone does not resist a man-in-the-middle attack.

TLS minimum is 1.2. Each installation generates RSA 2048 / SHA-256 self-signed identity and a random device ID in private storage. Certificates last ten years; desktop private files use mode 0600, and Android uses private app storage. Hardware-backed keys, rotation and persistent trusted-peer lists are not implemented. Private keys are not sent over the network.

The receiver does not authenticate sender names. A file, text payload or explicitly shown batch requires human consent, with source IP binding the transaction. Unanswered offers are rejected after five minutes; busy receivers return 409. Senders wait up to five minutes 35 seconds, allowing response delivery. Payload idle timeouts are separate.

## File transaction

1. `GET /v1/info`: protocol version and public identity only.
2. `POST /v1/offer`: `{sender, name, size}`; JSON up to 8 KiB, file up to 1 TiB. Approval returns a random 192-bit `token`.
3. `PUT /v1/file/:token`: `Content-Length` must match the offered size. The receiver writes `.partial` in an isolated random directory or a platform uncommitted target. Both sides stream SHA-256. The receiver returns `{sha256, size}`.
4. After matching size / digest, the sender calls `POST /v1/commit/:token` with `{sha256}`. The receiver rechecks and publishes the target (file / SAF rename or clearing MediaStore IS_PENDING), returning `{committed: true, sha256}`. Only then is receiving successful.
5. `DELETE /v1/file/:token`: cancel / discard an uncommitted transaction. Cancellation closes the cancellable upload stream; writing must settle or fail before cleanup completes. Committed files are unaffected.

Tokens bind to source IP, are single-use and expire after two idle minutes; active uploads refresh expiry. Read inactivity on a connection times out after 30 seconds. Cancellation, I/O failure and digest mismatch do not publish files. Restart cleans app-owned random temporary directories / files and Android journaled pending documents, preserving public / completed files. The receiving directory must be exclusive to its server instance.

Filenames reject path separators, NUL, control characters, `.` / `..`, `.partial`, Windows reserved names and trailing periods / spaces. Targets are constructed only inside receiver-controlled random subdirectories. Directory trees, symbolic links and remote path writes are not supported.

## Batch authorization (0.1.4)

The `batch` capability enables certificate-pinned HTTPS `POST /v1/batch` with `{token, sender, files: [{name, size}, ...]}`. Clients generate the random 192-bit request token. Manifests contain 2–1000 regular files, at most 1 TiB total and 1 MiB of JSON. The dialog displays sender, count, total and files; one confirmation enables this grant. Peers without capability are asked to update rather than silently falling back to repeated approvals.

Subsequent `/v1/offer` calls include `batchToken` and zero-based `batchIndex`. The server matches actual source address, sender name, order, filename, size and type against the approved manifest before issuing a per-file token without another dialog. Every item still uploads, validates and commits independently. Commit advances the index; committed items cannot replay. Completion destroys authorization. The grant covers no text, extra files or future sessions.

`DELETE /v1/batch/:token` withdraws a pending offer or revokes remaining authorization. Receiver cancellation, item failure and process exit also revoke it. A two-minute inter-file idle gap expires the batch; active files still use their individual timeouts rather than that gap. Grants exist only in memory. Continuing unfinished files requires displaying and approving a fresh manifest.

## Limits

Data travels directly on the LAN, without discovery servers or cloud relays. Identity depends on actual code comparison. Approval requests do not prevent LAN denial of service; this implementation is not independently security-audited. Losing connectivity between commit and acknowledgement can leave a saved receiver file while the sender reports failure. A retry creates another file rather than overwriting the first.

Android targets and foreground services do not change the wire protocol; see [reliability](reliability.md).

## Text transaction

Announcements and `/v1/info` advertise `capabilities: ["text"]`; absence means unsupported. Text is not silently downgraded to a file. `/v1/offer` accepts `kind: "text"`; absent / `file` means a file, and unknown types are rejected. The inclusive limit is 16 MiB of UTF-8 bytes. Approval, upload length / SHA-256 and commit acknowledgement follow the file transaction.

Up to 1 MiB uses a bounded memory target. Larger text uses existing file / MediaStore / SAF targets, strictly validates UTF-8 incrementally and retains up to 16384 UTF-16 code units of preview without isolated surrogate truncation. Invalid encoding, length / digest mismatch or cancellation prevents publication. Only committed text enters history; receipts distinguish full content from previews.

macOS uses system Downloads authorization and persistent security-scoped bookmarks for selected folders. Changing folders does not move old files; old grants remain for history, and restoring default affects only new destinations. Package and protocol identifiers stay lowercase `dukto2`; the displayed product name is Dukto2.
