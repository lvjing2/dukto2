# Contributing to Dukto2

English | [Simplified Chinese](CONTRIBUTING.zh-CN.md)

Read the platform coverage in the README before reporting a problem. A successful build, simulator test and physical LAN transfer are different results. Issues and pull requests are welcome in English or Simplified Chinese.

## Local development

Use Flutter 3.47.7 stable / Dart 3.13.5 and Python 3 for script tests. From the repository root:

```sh
./tool/flutterw pub get
./tool/check.sh
```

Use Flutter on PATH or set `FLUTTER_BIN`. Windows supports `./tool/windows.ps1` in PowerShell; Linux supports `./tool/linux.sh`. See [Windows](docs/en/windows.md), [Linux](docs/en/linux.md) and [iOS](docs/en/ios.md). SSH is optional for remote development and is not required to use the app.

Format changed Dart files with `./tool/dartw format <files>`. Avoid unrelated formatting, dependency changes and generated machine configuration. Report the actual OS, architecture and toolchain when native builds are relevant.

## Code boundaries

- Keep `packages/dukto2_core` pure Dart; access platform files through streams and receive-target interfaces.
- Use bounded streams. Publish only after size and SHA-256 checks; never overwrite existing files.
- Preserve TLS fingerprint verification. Names and discovery announcements do not prove identity.
- Consent covers one file or one explicitly displayed batch and its validity period. Cancellation and errors must not approve unrelated later requests.
- Validate native permissions, storage, notifications and sleep behavior on the relevant platform rather than generalizing another platform's result.

## Issues and pull requests

Include OS versions, CPU architecture, app versions, connection method, reproduction steps and expected behavior. Redact logs, names and screenshots; do not provide real file contents, private keys, identity files or passwords.

Explain the concrete problem, behavior changes, actual validation commands and results, and untested platforms. Transfer, cancellation, cleanup and consent changes need meaningful regression coverage. UI changes should include screenshots at the relevant sizes. Keep each contribution focused.

AI-assisted contributions are welcome. Explain the scope and how generated content, provenance and tests were checked; do not report unexecuted checks as passing.

Repository documentation supports English and Simplified Chinese. Root documents use `NAME.md` and `NAME.zh-CN.md`; topic guides use `docs/en/` and `docs/`. Maintain both versions and reciprocal language links when behavior changes. Code identifiers and protocol keys remain English. Keep original license texts unchanged.

See [SECURITY.md](SECURITY.md) for vulnerabilities and [Release CI](docs/en/release-ci.md) for packaging and signing. `python3 tool/prepare_source.py` creates a local source-review package in ignored `artifacts/community/`; it does not commit or publish.

## Contribution license

Unless explicitly agreed otherwise, contributions intentionally submitted for inclusion are provided under the project's [Apache License 2.0](LICENSE). Retain third-party copyright and license notices and record sources for introduced or adapted code.

Dukto2 is independently maintained. Please use this repository’s Issues for support and feature requests rather than contacting the original Dukto author.
