# Reliability and transfer sessions

English | [简体中文](../reliability.md)

## Module boundaries

`packages/dukto2_core` is pure Dart and owns discovery, identity, TLS and transfer transactions. The Flutter controller coordinates the UI and native platforms; bounded streams and `ReceiveTarget` connect platform file access.

`TransferSession` owns direction, consent, progress, timing, file count and cancellation for one file or an explicitly approved batch. Phases cover approval, waiting, upload, verification, cleanup, cancellation and terminal states. Completion, failure, cancellation and shutdown share once-only cleanup. The session stays busy until cleanup settles, preventing a new session from racing old resource release.

Pending native startup settles before the corresponding stop request. After asynchronous receive-target preparation, session identity and cancellation are rechecked; invalid targets are discarded. History is saved per file while the remaining manifest uses the same explicit batch authorization.

## Failures and diagnostics

`TransferFailure` records stage, kind, direction and an independent diagnostic ID, preserving the original exception and stack trace. Platform failures retain an error code. A presentation mapping produces Chinese UI messages. Cleanup failures are logged separately without replacing the primary failure.

The server error stream is `Stream<TransferFailure>`; client transfer errors use that type. Explicit cancellation retains `TransferCancelled`, and preflight validation can still throw its original validation exceptions. Unrelated malformed HTTP requests are logged without terminating an authorized application session.

The in-memory journal retains 200 entries by default. JSON Lines are written under app support to `diagnostics/transfers.jsonl`, limited to 512 KiB per file with one `.1` rotation and at most 200 queued writes. Logging failure does not fail a transfer.

Serialized logs omit transfer filenames, storage paths, text bodies, raw exception messages and authorization tokens. Limited source stack locations, failure kinds and OS codes remain. Diagnostic IDs are independent of transfer tokens.

## Discovery and networking

UDP / Bonjour provide candidates, confirmed through HTTPS before appearing as peers. Certificate fingerprints deduplicate peers; stale peers expire. Interface changes and foreground resume rebuild subscriptions. Refreshing discovery does not deliberately interrupt file transfers.

Bounded probing of directly connected private IPv4 /24 networks and manual addresses remain available without multicast. This does not guarantee cross-subnet, AP-isolated or VPN reachability. See [protocol v1](protocol-v1.md) for ports, timing and consent.

## Storage and platform resources

- Desktop receivers write isolated temporary targets and publish only after correct size / digest and commit, without overwriting files.
- Android 10+ defaults to MediaStore pending entries; selected folders use SAF. MethodChannel writes at most 256 KiB per block and waits for native worker acknowledgement.
- iOS privately stages, coordinates copying into the selected folder and rechecks the result. Extra disk space is required; external providers may add delays.
- Android foreground service, CPU and Wi-Fi locks cover explicitly started transfers. Desktop platforms inhibit idle sleep; Apple mobile transfers mainly run in the foreground. Resources are released after completion, failure or cancellation.

Network loss or process termination requires sending from the start. Startup cleans only app-recorded uncommitted targets. If a commit acknowledgement is lost, the receiver may have saved the file while the sender reports failure; retraction and exactly-once delivery are not guaranteed.

## Design references

Staged discovery, per-interface multicast, foreground-transfer lifecycle and system storage designs reference [LocalSend v1.18.2](https://github.com/localsend/localsend/tree/v1.18.2). Dukto2 uses its own Dart core without integrating LocalSend's Rust core. See the [provenance review](source-provenance-audit.md) and [acknowledgements](../../ACKNOWLEDGEMENTS.md) for findings and unresolved origins.

Executed checks and platform limits are listed in [validation coverage](validation.md).
