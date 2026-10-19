# Third-party sources and licenses

English | [简体中文](THIRD_PARTY_NOTICES.zh-CN.md)

Dukto2's own code uses [Apache License 2.0](LICENSE) (`Apache-2.0`). Upstream work retains its copyright and license; this project's statement does not replace them.

## Runtime and dependencies

- Flutter / Dart: platform projects were generated from Flutter 3.47.7 templates. Retain Flutter Authors' BSD notice, copied in [licenses/Flutter-BSD-3-Clause.txt](licenses/Flutter-BSD-3-Clause.txt). SDK and engine distributions include additional components; preserve generated notices with binaries.
- Direct app dependencies: `file_picker`, `path_provider`, `path`. Direct core dependencies: `basic_utils`, `crypto`, `path`. Both `pubspec.lock` files record exact and transitive versions.
- Settings → About → Third-party licenses displays Flutter-registered runtime notices. Preserve `flutter_assets/NOTICES.Z` and other resources when distributing full builds, rather than copying only the executable.
- This is a source index, not a complete legal audit of all dependencies. Recheck actual native components and notices when dependencies or distribution methods change.

## Design and implementation references

- **Dukto / Emanuele Colombo**: inspiration for the experience and project spirit. The author's page states GPL; original core source headers state GPL-2.0-or-later. Dukto2 aims at an independent rewrite with a new protocol. The [initial review](docs/en/source-provenance-audit.md) leaves historical and asset provenance questions open; it does not rule out copying, adaptation, translation or derivative-work status, or establish official succession. Sources: [original project](https://www.msec.it/blog/dukto/) and [community source headers](https://github.com/xuzhen/dukto/blob/master/duktoprotocol.cpp). The community root LICENSE.txt has a separate disclaimer that does not supersede source notices.
- **LocalSend**: reference for discovery, foreground-transfer lifecycle and system storage, including the choice of IPv4 multicast address. Upstream uses Apache-2.0. Its Rust core is not integrated. The initial review found no confirmed business-code copying, while old certificate-generation provenance remains unresolved; see the [review](docs/en/source-provenance-audit.md), [reliability guide](docs/en/reliability.md) and [acknowledgements](ACKNOWLEDGEMENTS.md). Record any subsequently confirmed reuse per file and retain required notices. [Upstream license](https://github.com/localsend/localsend/blob/main/LICENSE).
- **UI UX Pro Max**: development-time design guidance, not a runtime dependency; see [acknowledgements](ACKNOWLEDGEMENTS.md).

## Icons and screenshots

Vector masters and platform exports are in `design/app-icon/`; see the [asset guide](design/app-icon/README.en.md) for generation and source scope. Maintainers still need to confirm that assets can be distributed under the chosen license. The common paper-plane shape is not claimed as an exclusive mark.

`docs/screenshots/` contains actual device / simulator captures, not runtime assets. Its [index](docs/screenshots/README.en.md) records versions and surrounding desktop content. Review names, backgrounds, system prompts and other applications for suitability before publication.
