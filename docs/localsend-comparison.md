# dukto2 与 LocalSend：基线后的技术选择

后续决策：用户现已暂停新增功能，先验证独立项目的必要性。当前结论见 [LocalSend 社区需求与独立方向评估](localsend-community-research.md)。下文的“不整体迁移”是当时的工程接入判断，不能作为长期独立维护的产品依据。

研究日期：2026-10-18，本轮再次核对 GitHub `releases/latest` 仍指向 v1.18.2。本文只做源码、协议与正式安装包检查；未安装运行 LocalSend，未测量其速度、内存或后台稳定性。dukto2 的真机结果与未验证范围见 [验证记录](validation.md) 和 [基线](baseline.md)。暂停新增功能，未经后续决策不替换传输核心。

## 建议

**先保留 dukto2 当前 Flutter UI、平台工程和独立核心边界，选择性参考 LocalSend 的 Android 文件访问、前台服务与网络恢复设计；暂不整体迁移。** 这是基于以下证据作出的工程判断：

1. LocalSend 正式版已有 Flutter、Dart isolates、Rust 核心，平台集成更完整，但替换核心还要接入 Rust 构建、桥接、文件描述符、身份和会话模型，不是换一个 Dart 依赖。
2. 当前检查的 LocalSend v2 上传路径没有字节偏移续传；改用它不能直接得到断网或应用重启后的断点续传。
3. 正式 ARM32 APK 最低 Android API 24。支持 ARM32 不等于支持 Android 5 / 6；换核心也不会降低 Flutter 外壳的系统门槛。
4. dukto2 已跑通本轮 macOS / Android 双向小文件互传，但大文件、后台、老设备、自动发现可靠性都仍需专项验收。当前没有证据证明任一方案在目标旧设备上性能更好。

如果下一阶段明确优先与 LocalSend 生态互通，可再评估独立的协议适配器；原 Dukto 协议兼容仍是另一个适配目标。现在保留本地基线，等待用户确认下一阶段优先级。

### 按目标作决定

| 用户最看重的目标 | 更合适的选择 | 原因 |
| --- | --- | --- |
| 保留当前简洁 UI，先把 macOS / Android 做可靠 | 暂不整体迁移，选择性参考平台能力 | 近期缺口集中在发现、文件保存、后台与验收，不一定需要更换传输语言 |
| 尽快拥有现成的多平台功能，并与 LocalSend 客户端互通 | 认真考虑基于 LocalSend fork，再接入当前 UI | 可复用其已有平台与多文件流程；需要接受跟踪上游、构建和 UI 接入成本 |
| 主要为了支持旧系统或断点续传 | 不以迁移作为解决方案 | 当前正式包的系统下限和 v2 协议都没有直接满足这些目标 |

不整体迁移并不代表长期自研更便宜。继续自研需要自己维护协议、发现、存储、后台与异常恢复；选择性借鉴也不会自动继承上游修复。若跨平台覆盖和 LocalSend 互通成为首要目标，复用上游的长期收益可能超过一次性接入成本。此次建议依据当前只先跑通 macOS / Android 的范围，不依据已投入的代码量。

## 对比对象与证据等级

| 对象 | 固定版本 | 检查范围 |
| --- | --- | --- |
| dukto2（原 Lanbeam） | `2633a0d7a5cedda963c894501c567651117265f2`，标签 `baseline-2026-10-18` | 本机源代码、24 项通过的测试、Apple Silicon Mac 与 Android 16 真机双向传输 |
| LocalSend 正式版 | [v1.18.2](https://github.com/localsend/localsend/releases/tag/v1.18.2)，Git `af0416be50770a97760f7070684bc667b759a15c` | 标签源码、发布资产列表、正式 ARM32 APK 清单与原生库 |
| LocalSend 开发分支 | `d01fdb14c978fa8b2b13e29a50cc0feaefe5c1b9` | 只读参考，不将开发分支新增行为归入正式版 |

正式版发布时间由 GitHub Release API 确认为 2026-08-21。以下 LocalSend 代码链接固定到 v1.18.2，避免随 main 变化。其许可证为 **Apache-2.0**，不是 MIT；复用代码时应保留相应许可证、版权及所需声明。dukto2 目前没有复制 LocalSend 源码，其自身开源许可证尚待决定。[许可证](https://github.com/localsend/localsend/blob/v1.18.2/LICENSE)

## 系统与 CPU 范围

| 项目 | dukto2 当前状态 | LocalSend v1.18.2 |
| --- | --- | --- |
| Flutter / Dart | 3.47.7 / 3.13.5 | 标签 `.fvmrc` 固定 Flutter 3.41.9；app 声明 Dart ^3.11 |
| Android 下限 | min API 24，即 Android 7；只实测 Android 16 / arm64 | 正式 ARM32 APK 实际 `sdkVersion:24`；README 写 Android 5.0，与此包不一致，安装判断以 APK 为准 |
| Android CPU | 本次 APK 仅有 arm64 Flutter 引擎；未验证 ARM32、x64 | 发布资产分别提供 arm32v7、arm64v8、x64 APK；检查的 ARM32 包包含 armeabi-v7a 引擎，未在旧机运行 |
| macOS | 工程最低 12.0；仅实测并保存 arm64 包 | Runner 工程最低 11.0；本次未检查 DMG 内各架构，也未实际启动 |
| Windows | 尚未实现或验证 | 官方 README 标为 Windows 10；本次发布有 x86-64 与 arm64 资产，没有 Win32 资产 |

参考：[固定 Flutter 版本](https://github.com/localsend/localsend/blob/v1.18.2/.fvmrc)、[平台说明](https://github.com/localsend/localsend/blob/v1.18.2/README.md)、[Android 构建配置](https://github.com/localsend/localsend/blob/v1.18.2/app/android/app/build.gradle)、[Flutter 3.41.9 的 API 24 默认值](https://github.com/flutter/flutter/blob/3.41.9/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt)。正式包元数据和校验值保存在本项目 `artifacts/research/`。

如果目标包含 Android 5 / 6、Win7、32 位 Windows，需要先独立决定维护旧工具链还是另做客户端；不能从“Rust 核心”推导出这些平台自动获得支持。

## 传输、大文件与恢复

| 维度 | dukto2 基线 | LocalSend v1.18.2 源码结论 |
| --- | --- | --- |
| 数据路径 | Dart TLS / HTTP 流式上传、临时文件、接收端长度与 SHA-256 校验、提交后回执 | Flutter → Dart isolates → flutter_rust_bridge → Rust 核心；可从路径、Android FD 或流发送 |
| 内存与背压 | 没有整文件读入的正常传输路径；网络 I/O 异步，但当前哈希与服务运行于应用 isolate，未量测大文件 UI 卡顿与 RSS | Rust 接收端有容量 16 的有界队列、512 KiB BufWriter，发送和桥接存在 await 背压；桥接流队列容量 1。不能把 512 KiB 当作总内存上限，帧大小、TLS、并发、桥接也占内存 |
| 文件大小 | 协议上限 1 TiB，但客户端整次上传有 2 小时超时；只验收约 1 MB / 4 MB | Rust 长度类型使用 u64，不能据 CPU 32 位判断存在 4 GB 限制；仍需实测存储文件系统、插件与真实包 |
| 中断后重传 | 没有续传；重新发送从头开始 | 检查的 v2 `/upload` 参数是 sessionId / fileId / token，没有偏移；文件重新打开会截断。校验错误后的重试不等于从已传字节继续 |
| 应用重启恢复 | 没有持久化续传状态；启动清理临时接收数据 | v2 会话与文件状态在内存；没有看到偏移协商与持久化恢复索引，不能恢复既有部分文件继续接收 |
| 完整性 | 本实现必须核对 SHA-256；本轮两端实际文件独立复核一致 | 创建和验证 checksum 设置默认 true，但协议字段可选、设置可关闭，生成失败存在无 checksum 继续路径；不能断言所有兼容客户端每次都强制验 hash |
| 哈希开销 | 正常传输中增量计算 | 发送前可先读取一次文件生成 checksum，接收中增量验证；慢 SD 卡与大文件需要计入预读时间 |

关键源码：[v2 上传客户端](https://github.com/localsend/localsend/blob/v1.18.2/packages/core/src/http/client/v2.rs)、[v2 接收入口](https://github.com/localsend/localsend/blob/v1.18.2/packages/core/src/http/server/v2.rs)、[接收落盘与有界队列](https://github.com/localsend/localsend/blob/v1.18.2/packages/core/src/http/server/common/save.rs)、[内存会话](https://github.com/localsend/localsend/blob/v1.18.2/packages/core/src/http/server/common/session.rs)、[桥接背压](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/rust/src/api/stream.rs)、[上传数据源与 u64 长度](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/rust/src/api/http.rs)、[重开保存目标](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/lib/src/task/server/file_saver.dart)、[checksum 默认设置](https://github.com/localsend/localsend/blob/v1.18.2/app/lib/provider/persistence_provider.dart)、[发送端生成校验值](https://github.com/localsend/localsend/blob/v1.18.2/app/lib/provider/network/send_provider.dart)。

上述续传结论针对固定正式版的标准 v2 上传路径：其 app HTTP provider 和上传 isolate 的 HTTP provider 实际均选择 `LsHttpClientVersion.v2`；v3 模块的存在不代表客户端已获得新上传能力。[app provider](https://github.com/localsend/localsend/blob/v1.18.2/app/lib/provider/http_provider.dart)、[isolate provider](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/lib/src/isolate/child/http_provider.dart)

## Android 存储与后台、网络变化

dukto2 当前先接收到私有目录，再通过系统保存对话框导出；导出时可能同时占用两份大文件空间。LocalSend 已实现 SAF 目标选择和原生 FD 读写，可直接写入选定目标；相册等路径仍有缓存或额外处理，不能概括为所有场景都零拷贝。借鉴这层平台集成可以保留现有 UI 与传输协议。[Android 原生桥](https://github.com/localsend/localsend/blob/v1.18.2/app/android/app/src/main/kotlin/org/localsend/localsend_app/MainActivity.kt)、[保存目标处理](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/lib/src/task/server/file_saver.dart)

dukto2 只有前台运行与保持唤醒处理，尚未实现 Android 前台传输服务。LocalSend 使用 dataSync 前台服务及相应权限，减少退到后台时被中止的风险；这仍不保证厂商省电策略下永不中止，也不提供进程死亡续传。代码也处理 Android 12+ 后台启动前台服务失败的情况。[前台服务](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/lib/util/foreground_service.dart)

LocalSend 还有失效 HTTP 服务探测、服务重启与相关网络恢复处理；重启监听器和恢复进行中的文件是两件事。dukto2 本轮 VPN / Wi-Fi 环境下自动发现不稳定，正式验收使用手动 IPv4。两者在当前网络的可靠性差异还没有对照实测。[服务恢复](https://github.com/localsend/localsend/blob/v1.18.2/app/lib/provider/network/server/server_provider.dart)

## 三条路径的改造成本

| 路径 | 保留内容 | 主要投入与代价 | 判断 |
| --- | --- | --- | --- |
| 继续自研 | UI、平台工程、Dart 核心和已验证行为 | 自己完善发现、后台、SAF、大文件和续传；平台测试责任全部保留 | 立即改动最少，但不能低估可靠性工程 |
| 选择性复用或参考 | UI 与整体结构；按独立边界引入平台能力或协议适配 | 清晰划分原生存储 / 前台服务 / 协议适配边界，保留许可证与来源；增加互操作测试 | 当前优先，先决定目标能力再做小范围验证 |
| 用 LocalSend 核心替换 | 可以保留 UI 和大部分 Flutter 平台外壳 | 接入 Cargo / NDK / FRB 生成链；重做身份及证书校验、发现、offer / 接收授权、进度 / 取消、文件路径 / FD、历史状态和错误映射；再跑各平台包验证 | 中到高集成成本，且续传、旧系统问题依旧存在 |

当前 `Dukto2Controller` 直接使用 `TransferServer`、`TransferClient`、`PeerDiscovery`、`DeviceIdentity` 以及回执 / 授权事件，尚不是可无缝插拔的通用传输接口。若以后替换，应先围绕这些实际接点定义最小适配接口，而不是先把 UI 或整个项目迁到 LocalSend。完整 fork LocalSend 还涉及替换其 UI、品牌、配置与更新链路，成本比仅换核心更大。

LocalSend 的优势还包括已有多文件会话和各平台发布工程；dukto2 当前 UI 只选择一个文件、同一时间执行一次收发。它的 `localsend_isolates` 也不是已发布的通用 SDK：标签 `pubspec.yaml` 标记 `publish_to: none`、`resolution: workspace`，依赖 Refena、相邻 `typed_isolates` 和本地 Rust builder。直接接入这层需要维护源码依赖及其生成文件；直接接 Rust 核心则需要自行提供桥接和应用事件适配。[isolate 包依赖](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/pubspec.yaml)、[Rust 桥接依赖](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/rust/Cargo.toml)、[多文件与授权接口](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/lib/src/isolate/parent/actions.dart)

选择“兼容 LocalSend 协议”也不强制使用 Rust：可以让当前 Dart 核心另加协议适配，但这只获得互操作能力，仍须自己维护实现与兼容测试，不能声称已经复用了上游核心的性能和修复。

开发分支相对正式标签还有连接数限制、事件和服务器处理等变更；本次对比没有把这些未发布代码的能力计入 v1.18.2，也没有直接依赖 main。

## 建议的下一阶段顺序

1. 保留已验证基线和现有 UI，先确定最低系统 / CPU 与最大文件目标。
2. 若接受当前路线，优先补自动发现与切网恢复、Android 直接保存和传输前台服务，随后完成下列大文件 / 中断验收；先控制为 macOS / Android 两个平台。
3. 若决定优先多平台覆盖或 LocalSend 互通，再在隔离分支验证最小适配：发现、一个文件双向收发、拒绝 / 取消、证书校验与进度。用实际接入结果决定换核心或完整 fork。

以上是后续方案，没有在本轮创建迁移分支、接入依赖或改动 UI / 传输实现。

## 决策前需要的验收

- 明确最低 OS / CPU，以及必须支持的最大单文件大小；以实际目标旧机测试安装和运行。
- 用真实 >4 GB 文件及目标大文件（例如 20 GB）在低内存与慢存储下测峰值 RSS、UI 响应、吞吐、预哈希时间和可用空间；小文件 SHA 一致不能代替此项。
- 断 Wi-Fi、切网、杀进程、重启后分别验收；若要求续传，必须看到偏移协商、源文件版本检查、持久化状态和最终完整性校验，而不是整文件重传后显示成功。
- Android 息屏、退后台、省电模式、SAF 授权和低存储；单独确认接收目标、临时文件与导出空间占用。
- 校验不一致、取消、接收端拒绝、超时和自动发现失败均应有可恢复结果。不能用 LocalSend 的源码设计代替 dukto2 的实际平台验收。

以上为后续评估门槛，本轮没有执行新功能开发、迁移或大文件性能测试。Android 真机本轮工作已经结束，可以退出应用、断开 USB。


## 决策后进展

用户已确认不迁移，研究后继续在 dukto2 实施选择性借鉴；实现与证据见 [0.1.1 可靠性改进](reliability.md)。上面的暂停表述是当时决策前的状态。
