# Dukto2 代码来源核查

日期：2026-10-19。范围：源码与资源的静态对照、共同模板追溯、关键实现流程复核及现有开发记录。没有修改运行时实现，没有选择项目许可证，也没有推送或发布。

## 结论

**本轮没有找到可以确认 Dukto2 复制、逐段改写或跨语言翻译 Dukto / LocalSend 业务实现的明确证据。发现的完整文件重合可以追溯到 Flutter 官方模板或生成器；参考 LocalSend 的发现、存储与后台设计有明确开发记录。**

这支持把项目描述为“以独立实现为目标，并明确参考其他开源项目设计”。它不构成“所有代码均独立原创”或“法律上已排除衍生作品”的证明。证书生成流程及最早实现阶段仍有来源记录缺口，见下面的待追溯项。

## 固定版本与范围

Dukto2 从当前 Git 工作区复制 262 个非忽略候选文件，记录每个文件 SHA-256，其中 76 个文件进入代码词法扫描。HEAD 为 `1660c0d4aa86e0826897e1cec9e194dfbdad696d`，但核查包含当时未提交的修改，不能仅凭 HEAD 复原。按文件路径排序拼接 `路径 SHA256` 得到的清单摘要为：

`aacac54b0e2b803a7ecb4f054abf64a8ae3a79e7961b62d0d6a7cfc3cd5b8b34`

| 对照对象 | 固定提交 | 扫描代码文件 |
| --- | --- | ---: |
| [Dukto 原 R6 / v6](https://github.com/xuzhen/dukto/tree/1306c45b227c122ce153cefadfde7bd9a2ebc894) | `1306c45b227c122ce153cefadfde7bd9a2ebc894` | 63 |
| [xuzhen/dukto 本地 HEAD](https://github.com/xuzhen/dukto/tree/5d86428fb4884505abc2b59e357fbd195ad01dbd) | `5d86428fb4884505abc2b59e357fbd195ad01dbd` | 108 |
| [LocalSend v1.17.0](https://github.com/localsend/localsend/tree/7f21d1f9082a43803e05c37f021912e012145aa5) | `7f21d1f9082a43803e05c37f021912e012145aa5` | 372 |
| [LocalSend v1.18.2](https://github.com/localsend/localsend/tree/af0416be50770a97760f7070684bc667b759a15c) | `af0416be50770a97760f7070684bc667b759a15c` | 540 |
| [LocalSend 本地 main 快照](https://github.com/localsend/localsend/tree/d01fdb14c978fa8b2b13e29a50cc0feaefe5c1b9) | `d01fdb14c978fa8b2b13e29a50cc0feaefe5c1b9` | 555 |

“本地 HEAD”不代表核查时远端最新提交。原开发文档明确写参考 v1.18.2，因此不只比较较新的 main；另补 v1.17.0，检查此前的 Dart 实现。参考仓库通过 `git archive` 导出固定版本，没有执行上游代码；Git 子模块内容和仓库外依赖不在这些归档的对照范围。

## 方法与自动结果

1. 对非空文件做 SHA-256 精确匹配，包含源码、配置、图标和其他资源。
2. 去除注释，比较连续 20 / 40 个词法 token，保留具体标识符与字符串。
3. 将非关键字标识符和字面量归一化，比较连续 100 个结构 token，辅助发现改名后的长片段。
4. 人工复核短片段、关键状态流、协议数据表示和平台集成方式。人工复核不是对所有文件逐行进行法律审查。
5. 使用项目对应的 Flutter 3.47.7 SDK 重新生成五平台纯模板，并核对 SDK 中插件注册文件的生成模板，排除共同上游。

| 对照 | 非空文件完全相同 | 20-token 文件对 | 40-token 文件对 | 100-token 归一化文件对 |
| --- | ---: | ---: | ---: | ---: |
| Dukto R6 | 0 | 0 | 0 | 0 |
| xuzhen/dukto | 0 | 0 | 0 | 0 |
| LocalSend v1.17.0 | 32 | 57 | 22 | 15 |
| LocalSend v1.18.2 | 32 | 59 | 23 | 15 |
| LocalSend main 快照 | 32 | 59 | 23 | 15 |

数字是命中的文件对数量，不是复制百分比。标点也计 token，嵌套 UI 的闭合括号会形成短命中。词法工具不是 AST、语义或机器翻译检测器；未命中不能排除短段、重排、深度改写或跨语言翻译。

### 已确认：共同 Flutter 模板

与 LocalSend 相同的 32 个非空文件中，30 个在本机新生成的 Flutter 官方工程中也完全相同；剩余两个是 Windows / Linux 的 `generated_plugin_registrant.h`，与 Flutter SDK 生成器中的对应文本完全相同。

包括 Windows `win32_window.cpp/.h`、`resource.h`、Flutter CMake 文件、Linux `main.cc`、Apple 工作区设置和默认启动图片等。最长连续命中是 Windows `win32_window.cpp` 的 1,253 个 token / 288 行，整个文件也与官方 Flutter 模板相同，不能据此归因为复制 LocalSend。

40-token 及 100-token 的命中均位于平台模板、其修改后的启动壳或插件生成配置中。需要保留共同上游 Flutter 的许可，见 `licenses/Flutter-BSD-3-Clause.txt`。

生成器定位（SDK revision `abaf9c523780a608bd46686fd5e53740a07077f8`）：[`flutter_plugins.dart`](https://github.com/flutter/flutter/blob/abaf9c523780a608bd46686fd5e53740a07077f8/packages/flutter_tools/lib/src/flutter_plugins.dart) 中的 `_cppPluginRegistryHeaderTemplate`、`_linuxPluginRegistryHeaderTemplate`、`_pluginCmakefileTemplate`。

### 已复核：短片段和 API 惯用写法

- `MainActivity.kt:209` 与 LocalSend 的 36-token 相同片段是 `onRequestPermissionsResult` 方法签名、`super` 调用及后续 `if` 的开头；两边分别处理通知权限与本地网络权限，处理体不同。[Android 官方 API](https://developer.android.com/reference/android/app/Activity#onRequestPermissionsResult(int,java.lang.String[],int[]))。
- v1.17.0 的另一处 30-token 命中是 `onActivityResult` 回调签名和 `super` 调用。
- 其余业务文件的短命中主要是 Android import、`WidgetsBindingObserver` 生命周期、Flutter Column / 对话框 / Navigator 的通用组合，以及测试中的 `Future.delayed(Duration(milliseconds: 20))`。

这些命中缺乏可归属于上游业务实现的独特连续逻辑，不能单独确认复制或改写，也不把短片段相似性当作完全独立的证明。

## 关键实现人工对照

| 模块 | 对照与差异 | 判定 |
| --- | --- | --- |
| 文件 / 文本协议 | Dukto `network/sender.cpp`、`receiver.cpp` 使用 TCP 二进制分阶段报文、NUL 结尾名称、特殊文本名称和目录大小标记；Dukto2 `transfer.dart` 使用 HTTPS 的 `/v1/offer`、`PUT /v1/file/:token`、独立摘要提交 `/v1/commit/:token`。LocalSend 是 `/api/localsend/v2/prepare-upload`、session/file/token 模型；v1.18.2 用 Rust server / client，v1.17.0 是 Dart provider。Dukto2 并非两者的同线协议实现。 | 没有找到状态机逐段对应的翻译证据；协议不同本身不证明全部代码独立。 |
| 设备发现 | Dukto `buddymessage.cpp` 解析字节类型、端口和签名，Messenger 广播发现；Dukto2 是 JSON 候选、HTTPS 身份确认、指纹去重。LocalSend 的分阶段发现 / 逐接口组播为明确参考对象。Dukto2 使用 8 并发 / 800 ms 的保守探测，而当前 LocalSend Rust 默认 50 并发 / 500 ms。 | 明确设计参考，没有确认复制实现或逐段翻译。 |
| 组播参数 | Dukto2 初始提交为 `239.255.77.77`，参考 LocalSend 后改为同一个 `224.0.0.167`；开发文档明确记载。端口仍是本项目的 45878 / 45879，报文和协议不同。 | 确认借鉴配置选择，应保留来源说明。 |
| Android 存储 | LocalSend v1.18.2 `file_saver.dart` / MainActivity 返回路径或 detach 后的 FD，Rust 写入；Dukto2 `PlatformReceiveTarget` 逐块经 MethodChannel 确认，Kotlin 工作线程写入，MediaStore pending 或 SAF 暂存改名提交，并记录恢复日志。 | 参考系统文件访问设计；未找到可确认复制的业务片段，结构并非简单翻译。 |
| 后台传输 | LocalSend 的 Dart `TransferNotification` 合并多任务、引用计数，经队列驱动 `flutter_foreground_task`；Dukto2 是自有 Kotlin `TransferService` 管理单任务、原生通知、唤醒锁 / Wi-Fi 锁、停止回调。 | 能力目标相似，具体实现边界不同；参考关系已记录。 |
| TLS 身份 | 新版 LocalSend 由 Rust 生成，Dukto2 使用 Dart `basic_utils`；旧 LocalSend v1.17.0 也用同一库，调用链相近，详见待追溯项 P1。 | 不能确认直接复制；生成流程的来源不能排除参考改写。 |
| Flutter 界面 | Dukto 是 Qt/QML，LocalSend 是 Refena provider、分页面与 Slang 文案；Dukto2 使用 ChangeNotifier 控制器与自身 dashboard / settings 组件。长片段扫描未命中业务 UI，短命中为通用布局。 | 没有找到逐页翻译或连续业务代码复制的明确证据；没有完成所有视觉元素的独立设计鉴定。 |
| Apple / Windows / Linux 桥接 | 新增 Bonjour、目录、通知等桥接未出现本次阈值下的业务长片段命中；共同启动壳另按 Flutter 模板分类。 | 未发现明确复制证据，不推断未检查的外部示例来源。 |
| 图标和资源 | 对所有候选非空文件做精确哈希比较，没有匹配两个项目的应用品牌图标；相同图片为默认 Flutter 启动资源。 | 排除的是字节相同；没有做视觉衍生鉴定，也没有完整追溯外部 SVG 资源包。 |

上述对应以固定快照为准，行号可能随后续编辑变化。LocalSend 对照重点位于 `packages/core/src/{discovery,multicast,http,crypto}`、`packages/localsend_isolates/lib/{util,src/task/server}` 与 `app/android/.../MainActivity.kt`；Dukto2 对应位于 `packages/dukto2_core/lib/src/`、`lib/src/`、Android 原生目录及各平台桥接。

## 开发记录能证明什么

- 最早 Git 提交 `2633a0d` 已是能收发的基线：84 个文件、6,904 行新增，不是从空工程开始的连续开发记录。它无法完整重建最初 AI 提示、读取的示例和生成过程。
- `7c97fd9` / `5459e01` 记录 LocalSend 比较；`1660c0d` 引入发现、Android 直接保存和前台服务，参考关系可追溯至文档与差异。
- `docs/reliability.md` 当时写“按设计借鉴自行实现，没有复制源码”。这是当时的开发自述，本次不把它当成独立的来源证明。
- Git 没有整库导入 LocalSend 的提交，本项目也未接入其 Cargo / Rust 核心。这只能证明当前集成方式，不能证明没有重写过单独函数。

## 待追溯项与发布边界

**P1：证书生成流程。** Dukto2 `identity.dart:46` 与 LocalSend v1.17.0 `app/lib/util/security_helper.dart:8` 均为 `basic_utils` 生成密钥、CSR、自签证书、计算证书摘要，并使用约十年有效期。库本身就提供这些 API，调用顺序受到 API 约束；Dukto2 在随机身份、序列号、隔离执行、指纹解析、原子保存与权限处理上另有实现。没有找到足以确认复制的片段，但也没有完整的初始生成记录来区分“独立采用库示例”和“参考上游后改写”。应保留此项，不因未达到 token 阈值就判定原创。

**P2：最初生成历史。** 缺失基线提交以前的逐步记录和完整 AI 上下文。本轮无法补造它们。现有代码的差异只能支持技术判断，不能证明所有表达的独立起源。

**P3：外部素材与其他来源。** Flutter 模板已定位；图标包的创作和公开授权、其他第三方示例、传递依赖、所有历史版本和子模块内容均未被这两项目对照穷尽。

技术结论没有给出“必须按 Dukto GPL 衍生作品分发”的明确证据，也不替代适用版权法下的判断。**本轮不据此直接写入 Apache-2.0，也不为了消除疑问自动改成 GPL。** 先保留致谢、共同模板许可和待追溯记录；若后续确认复用了具体代码，再按文件记录原始来源、版权和许可。选择许可证不能代替解决第三方来源问题。

## 复核资料

本机完整证据在忽略目录 `artifacts/provenance/`：`snapshot.json`（版本与逐文件摘要）、`scan-results.json`、`template-matches.json`、`generated-header-proof.json`、短片段摘录及运行日志。临时上游源码不加入本项目提交。

扫描工具为 [tool/source_provenance_scan.py](../tool/source_provenance_scan.py)，复跑命令：

```sh
python3 tool/source_provenance_scan.py \
  --manifest artifacts/provenance/snapshot.json \
  --output artifacts/provenance/repro-results.json
```

复跑需要原清单指向的本地快照；临时目录丢失后，应按上表固定提交重新导出，并用原 Dukto2 逐文件清单核对。不能用持续变化的工作区代替受审快照。

## 核查后的许可证决定

2026-10-19，维护者在阅读首轮核查结论后明确选择 Apache-2.0。根目录及核心包已添加 LICENSE。此决定不改变本报告的历史结论和待追溯项，也不对第三方代码、模板或素材重新授权。

## 首次公开时的历史邮箱替换

维护者要求保留过去提交并修改邮箱。首次公开前仅替换四条提交的作者及提交者邮箱，源码树、说明、日期和父子顺序保持不变。上文与本机快照中的旧 ID 对应如下；它们不是缺失源码或重新生成实现的记录。

| 核查时旧 ID | 公开历史 ID |
| --- | --- |
| `2633a0d7a5cedda963c894501c567651117265f2` | `7f4b125427de321ba96a25fb8bbf6ff21bcda4a9` |
| `7c97fd9beb23762af60e3a743c4cc4183154e1ce` | `5d71e9a42024c600b0b50f36cd06dc154545aa40` |
| `5459e013f65952830cf4230251c45e79137455e3` | `cf4c819a6ea16d3d511171b41c112559c54028a9` |
| `1660c0d4aa86e0826897e1cec9e194dfbdad696d` | `1c804161368a98951eddf457c94781fddd533aab` |
