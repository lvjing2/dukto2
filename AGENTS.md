# Dukto2

- Keep `packages/dukto2_core` independent of Flutter. Platform file access is a stream boundary.
- Never silently downgrade TLS or accept an arbitrary certificate for file transmission. `probe` only reads public identity; sending pins the verified fingerprint.
- Receiver consent covers one file or one explicitly displayed batch manifest. Batch approval must be scoped to its exact files, source and short-lived token; never approve later unrelated offers. Device names and UDP discovery are untrusted.
- Stream file data with bounded buffers. Publish a final file only after size and digest checks, never overwrite an existing transfer.
- Keep any future Dukto compatibility adapter separate from protocol v1.
- Use `tool/check.sh` for verification. Current Flutter's LSP analyzer breaks with this workspace's Unicode path; `dart analyze` works.
- Distinguish core loopback tests, Mac CLI ↔ Android tests, and macOS GUI ↔ Android tests in reports.
