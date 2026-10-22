# Acknowledgements and AI creation

English | [Simplified Chinese](ACKNOWLEDGEMENTS.zh-CN.md)

## Dukto

Thank you to **Emanuele Colombo** for creating Dukto. Dukto2 aims to continue its simple, direct LAN transfer experience.

- Original project: [Dukto R6](https://www.msec.it/blog/dukto/).
- Community maintenance: [xuzhen/dukto](https://github.com/xuzhen/dukto).
- Thanks to the [community contributors](https://github.com/xuzhen/dukto/graphs/contributors) who maintain and port it.

The original author has agreed to the Dukto2 name, provided the source remains open. Dukto2 uses [Apache-2.0](LICENSE), is independently maintained by lvjing2, and handles support through [Issues](https://github.com/lvjing2/dukto2/issues).

Dukto2 is a Flutter / Dart rewrite without legacy protocol compatibility. See the [provenance review](docs/en/source-provenance-audit.md) for source comparisons and unresolved origins.

## LocalSend design references

Staged discovery, per-interface multicast, foreground-transfer lifecycle and Android system-file access were informed by [LocalSend v1.18.2](https://github.com/localsend/localsend/tree/v1.18.2). Thank you to its authors and contributors.

Dukto2 uses its own Dart protocol and transfer core, without integrating LocalSend's Rust core. See the [provenance review](docs/en/source-provenance-audit.md) for similarities and unresolved origins. Development statements about independent implementation are not complete provenance proof. Implementation choices are described in [reliability](docs/en/reliability.md).

## AI creation

OpenAI Codex primarily generated and iterated the code, UI, tests and documentation under human direction. The human initiator defines goals, chooses approaches and reviews results. Development used GPT-6.1 Sol and local design guidance from [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill).

Flutter, Dart and other dependencies are their authors' work, not original work by this project or AI. The app's third-party licenses page shows runtime notices. Dukto2's own code uses [Apache License 2.0](LICENSE).

See [third-party notices](THIRD_PARTY_NOTICES.md); a Flutter template license copy is in `licenses/`. AI disclosure does not replace third-party license obligations.
