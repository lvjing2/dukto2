# Dukto2 source provenance review

English | [Simplified Chinese](../source-provenance-audit.md)

Date: 2026-10-19. Scope: static source / asset comparisons, shared-template attribution, key implementation flows and available development history. The review itself did not change runtime code, select a license, push or publish.

## Findings

**The review found no clear evidence confirming that Dukto2 copied, adapted section by section, or translated Dukto / LocalSend business implementations. Exact matching files were traced to Flutter templates or generators. LocalSend discovery, storage and background designs are explicitly recorded references.**

This supports describing an intended independent implementation with acknowledged design references. It does not prove all code independently original or legally exclude derivative-work status. Certificate generation and the earliest development stage have provenance gaps, described below.

## Pinned versions and scope

The snapshot copied 262 non-ignored candidate files from the then-current worktree, recording SHA-256 for each; 76 files entered lexical code scanning. HEAD was `1660c0d4aa86e0826897e1cec9e194dfbdad696d`, but uncommitted changes were included, so HEAD alone cannot reproduce it. The digest of path-sorted `path SHA256` manifest entries was:

`aacac54b0e2b803a7ecb4f054abf64a8ae3a79e7961b62d0d6a7cfc3cd5b8b34`

| Reference | Pinned commit | Code files scanned |
| --- | --- | ---: |
| [Dukto R6 / v6](https://github.com/xuzhen/dukto/tree/1306c45b227c122ce153cefadfde7bd9a2ebc894) | `1306c45b227c122ce153cefadfde7bd9a2ebc894` | 63 |
| [xuzhen/dukto local HEAD](https://github.com/xuzhen/dukto/tree/5d86428fb4884505abc2b59e357fbd195ad01dbd) | `5d86428fb4884505abc2b59e357fbd195ad01dbd` | 108 |
| [LocalSend v1.17.0](https://github.com/localsend/localsend/tree/7f21d1f9082a43803e05c37f021912e012145aa5) | `7f21d1f9082a43803e05c37f021912e012145aa5` | 372 |
| [LocalSend v1.18.2](https://github.com/localsend/localsend/tree/af0416be50770a97760f7070684bc667b759a15c) | `af0416be50770a97760f7070684bc667b759a15c` | 540 |
| [LocalSend local main snapshot](https://github.com/localsend/localsend/tree/d01fdb14c978fa8b2b13e29a50cc0feaefe5c1b9) | `d01fdb14c978fa8b2b13e29a50cc0feaefe5c1b9` | 555 |

Local HEAD does not mean the latest remote commit. The development documents specifically referenced v1.18.2; v1.17.0 also covers the earlier Dart implementation. Fixed versions were exported using `git archive` without executing upstream code. Submodules and dependencies outside those archives were excluded.

## Method and automated results

1. Exact SHA-256 matching of nonempty code, configuration, icons and other resources.
2. Compare consecutive 20 / 40 lexical tokens after removing comments, retaining identifiers and strings.
3. Normalize non-keyword identifiers and literals, comparing consecutive 100 structural tokens to help detect renamed long fragments.
4. Manually review short hits, state flows, protocol representation and platform integration. This was not a line-by-line legal audit of every file.
5. Generate fresh five-platform templates using Flutter 3.47.7 and inspect plugin generator text to identify common upstream sources.

| Reference | Exact nonempty files | 20-token file pairs | 40-token pairs | Normalized 100-token pairs |
| --- | ---: | ---: | ---: | ---: |
| Dukto R6 | 0 | 0 | 0 | 0 |
| xuzhen/dukto | 0 | 0 | 0 | 0 |
| LocalSend v1.17.0 | 32 | 57 | 22 | 15 |
| LocalSend v1.18.2 | 32 | 59 | 23 | 15 |
| LocalSend main snapshot | 32 | 59 | 23 | 15 |

These are matching file-pair counts, not percentages copied. Punctuation counts as tokens, so nested UI closing brackets produce short matches. The scanner is not an AST, semantic or translation detector. No hit does not exclude short fragments, reordering, extensive adaptation or cross-language translation.

### Confirmed shared Flutter templates

Of 32 nonempty files matching LocalSend, 30 also exactly matched a freshly generated Flutter project. The other two, Windows / Linux `generated_plugin_registrant.h`, matched Flutter's generator text exactly.

Examples include `win32_window.cpp/.h`, `resource.h`, Flutter CMake, Linux `main.cc`, Apple workspace settings and default launch images. The longest match was Windows `win32_window.cpp`, 1,253 tokens / 288 lines; the whole file also matched Flutter's template, so it cannot establish copying from LocalSend.

All 40-token and normalized 100-token matches were platform templates, modified runner shells or plugin-generation configuration. Preserve Flutter's license in `licenses/Flutter-BSD-3-Clause.txt`.

Generators at SDK revision `abaf9c523780a608bd46686fd5e53740a07077f8`: `_cppPluginRegistryHeaderTemplate`, `_linuxPluginRegistryHeaderTemplate` and `_pluginCmakefileTemplate` in [flutter_plugins.dart](https://github.com/flutter/flutter/blob/abaf9c523780a608bd46686fd5e53740a07077f8/packages/flutter_tools/lib/src/flutter_plugins.dart).

### Reviewed short fragments and API idioms

- A 36-token match at `MainActivity.kt:209` covers the `onRequestPermissionsResult` signature, `super` call and start of an `if`. One handles notification permission and the other local-network permission; bodies differ. See the [Android API](https://developer.android.com/reference/android/app/Activity#onRequestPermissionsResult(int,java.lang.String[],int[])).
- Another v1.17.0 hit covers 30 tokens of `onActivityResult` signature and `super` call.
- Other short business-file hits mainly involve Android imports, `WidgetsBindingObserver`, common Column / dialog / Navigator combinations and `Future.delayed(Duration(milliseconds: 20))` in tests.

These lack distinctive continuous upstream business logic sufficient to confirm copying or adaptation. Short similarities also do not prove complete independence.

## Manual comparison of key implementations

| Area | Comparison | Finding |
| --- | --- | --- |
| File / text protocol | Dukto `network/sender.cpp` / `receiver.cpp` use staged TCP binary messages, NUL-terminated names, special text names and directory-size markers. Dukto2 uses HTTPS `/v1/offer`, `PUT /v1/file/:token` and separate digest commit. LocalSend uses `/api/localsend/v2/prepare-upload` and session / file / token, with Rust in v1.18.2 and Dart providers in v1.17.0. | No section-by-section translated state-machine evidence found. A different protocol alone does not prove every implementation independent. |
| Discovery | Dukto `buddymessage.cpp` parses byte types, ports and signatures with Messenger broadcast. Dukto2 uses JSON candidates, HTTPS confirmation and fingerprint deduplication. LocalSend staged discovery / per-interface multicast is an explicit reference. Dukto2's conservative probes use eight concurrent requests / 800 ms versus the inspected Rust defaults of 50 / 500 ms. | Confirmed design reference, not confirmed copied or translated implementation. |
| Multicast address | Dukto2 started at `239.255.77.77` and adopted LocalSend's `224.0.0.167` after reference. Ports remain 45878 / 45879 and messages differ. | Confirmed configuration reference; retain acknowledgement. |
| Android storage | LocalSend v1.18.2 `file_saver.dart` / MainActivity returns a path or detached FD for Rust. Dukto2 acknowledges chunks over MethodChannel, writes on Kotlin workers, commits MediaStore pending / SAF temporary targets and journals recovery. | Referenced access design; no confirmed copied business fragment or simple translation. |
| Background | LocalSend Dart `TransferNotification` combines tasks / reference counts and drives `flutter_foreground_task` through a queue. Dukto2's Kotlin `TransferService` handles one transfer with native notification, CPU / Wi-Fi locks and stop callbacks. | Similar goals with different implementation boundaries; reference documented. |
| TLS identity | Newer LocalSend uses Rust. Dukto2 uses Dart `basic_utils`, as did v1.17.0, with a similar call sequence. | Direct copying not confirmed; referenced adaptation cannot be excluded. See P1. |
| Flutter UI | Dukto uses Qt/QML; LocalSend uses Refena providers, pages and Slang; Dukto2 uses ChangeNotifier, dashboard and settings. No long business-UI hits, with short generic layout matches. | No confirmed page-by-page translation / continuous business-code copying. Not a full visual-provenance assessment. |
| Native bridges | Bonjour, folder and notification bridges had no business-code long hits at the tested thresholds; shared runners were classified as Flutter templates. | No clear copying evidence; no inference about unchecked external examples. |
| Icons / resources | Exact hashes of candidate files did not match either project's branding; shared images were default Flutter launch assets. | Excludes byte equality only, not visual derivation or every external SVG source. |

Results refer to pinned snapshots; line numbers may change. LocalSend focus: `packages/core/src/{discovery,multicast,http,crypto}`, `packages/localsend_isolates/lib/{util,src/task/server}` and Android MainActivity. Dukto2 focus: its core, `lib/src/`, Android and native bridges.

## What development history establishes

- Earliest commit `2633a0d` was already a functioning baseline: 84 files and 6,904 added lines. It does not reconstruct the initial AI prompts, examples read or generation steps.
- `7c97fd9` / `5459e01` record comparisons; `1660c0d` adds discovery, direct Android storage and foreground service, with reference history in documents / diffs.
- The earlier reliability document asserted independent design-based implementation without copying. That was a development statement, not independent provenance evidence.
- No whole-repository LocalSend import or Rust / Cargo integration appears in Git. That describes integration, not the origins of individual functions.

## Unresolved provenance and distribution limits

**P1: Certificate generation.** Dukto2 `identity.dart:46` and LocalSend v1.17.0 `app/lib/util/security_helper.dart:8` both use `basic_utils` for keys, CSR, self-signing, digest and roughly ten-year validity. API constraints influence order. Dukto2 separately implements random identity, serial number, isolate execution, fingerprint parsing, atomic persistence and permissions. No sufficient copying fragment was found, but incomplete initial records cannot distinguish library-example adoption from upstream-informed adaptation. A token threshold is not proof of originality.

**P2: Initial generation history.** Step-by-step pre-baseline records and full AI context are unavailable. They cannot be reconstructed or invented from current code differences.

**P3: External assets and other sources.** Flutter templates were traced. Icon authorship / distribution authorization, other examples, transitive dependencies, all historical versions and submodules were not exhausted by comparing two projects.

The technical review found no clear basis requiring distribution as a Dukto GPL derivative; it is not a legal determination. The review itself neither selected Apache-2.0 nor automatically changed the project to GPL. Retain acknowledgements, common-template licenses and unresolved provenance. Any later confirmed reuse must record original sources, copyright and licensing per file; choosing a license does not resolve third-party origins.

## Review material

Original manifests, scan results, template comparisons, fragments and logs stay in local development archives, not the distributed source. Pinned versions, findings and open items remain here for review.

The [scanner](../../tool/source_provenance_scan.py) accepts a reviewed snapshot via `--manifest` and a result path via `--output`. Rechecking needs the matching snapshot, not the changing worktree.

## Subsequent license decision

On 2026-10-19 the maintainer selected Apache-2.0 after reading the initial findings. Root and core LICENSE files were added. This does not change the historical findings or relicense third-party code, templates or assets.

## Email replacement before first publication

The maintainer requested keeping past commits while changing emails. Only author / committer emails in four commits were replaced; source trees, messages, dates and parent order stayed unchanged. Old snapshot IDs map to published history as follows:

| Review ID | Published history ID |
| --- | --- |
| `2633a0d7a5cedda963c894501c567651117265f2` | `7f4b125427de321ba96a25fb8bbf6ff21bcda4a9` |
| `7c97fd9beb23762af60e3a743c4cc4183154e1ce` | `5d71e9a42024c600b0b50f36cd06dc154545aa40` |
| `5459e013f65952830cf4230251c45e79137455e3` | `cf4c819a6ea16d3d511171b41c112559c54028a9` |
| `1660c0d4aa86e0826897e1cec9e194dfbdad696d` | `1c804161368a98951eddf457c94781fddd533aab` |
