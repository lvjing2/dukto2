# Security

English | [简体中文](SECURITY.zh-CN.md)

Dukto2 is a development preview and has not had an independent security audit. Maintenance targets current repository code; there is no security-support commitment for older release branches.

## Trust model

- Discovery provides candidate addresses. Compare the code on the other device's screen before pinning its TLS certificate fingerprint.
- Files and text require explicit receiving consent. Batch approval covers only the displayed manifest.
- Size and SHA-256 checks detect content mismatches; they do not establish sender trust or file safety. Users decide whether to open received files.
- Identity and history stay in local app data; files go to system or selected folders. History text and received bodies have no additional app-level encryption at rest. Permissions, backups, cloud synchronization and disk encryption depend on the OS and user configuration.
- There is no internet relay, account service or automatic clipboard synchronization. Continuous safe operation on hostile networks, against malicious peers, or after sleep / process termination is not guaranteed.

## Report a vulnerability

Do not disclose exploitable details, real files, passwords, identity private keys or full identity directories in public issues.

Use [GitHub Private Vulnerability Reporting](https://github.com/lvjing2/dukto2/security/advisories/new) through Security → Report a vulnerability. Reports may be written in English or Simplified Chinese.

Include affected versions and systems, impact, a minimal reproduction without sensitive content, and expected / actual behavior. There is no response-time or bounty commitment. See [Release CI](docs/en/release-ci.md) for distribution and signing limits.
