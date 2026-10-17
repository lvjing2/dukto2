# dukto2 0.1.1：发现、后台与直接保存

日期：2026-10-18。用户决定不迁移，研究 LocalSend 后继续在 dukto2 实现。保留 Flutter UI 和纯 Dart 协议核心；基线标签 `baseline-2026-10-18` 及其安装包不覆盖。

## 借鉴来源与本项目取舍

参考固定正式版 [LocalSend v1.18.2](https://github.com/localsend/localsend/tree/v1.18.2)。本轮按设计借鉴自行实现，没有引入其 Rust 核心、Dart isolate 包或复制其源码。

| 能力 | LocalSend 参考 | dukto2 实现 |
| --- | --- | --- |
| 发现可靠性 | [分阶段发现](https://github.com/localsend/localsend/blob/v1.18.2/packages/core/src/discovery/mod.rs)、[逐接口组播](https://github.com/localsend/localsend/blob/v1.18.2/packages/core/src/multicast/socket.rs) | 启动重发；每个 IPv4 接口发送；UDP 候选经 HTTPS 证书与公告指纹 / id 一致检查后才显示；按指纹去重并优先本地地址 |
| 发现兜底 | 先公告 / 已知设备，再有限并发探测 | GUI 优先绑定固定 HTTPS 端口 45879，端口被占用则使用临时端口。无设备时探测最多两个直接连接的私有 /24 网段，最多 8 个并发、单探测 800 ms；不自动扫描 VPN 接口 |
| 切网恢复 | 生命周期恢复探测监听器，失效后重建 | Android 网络回调去抖；恢复前台或接口变化时重新加入组播；闲置时通过本机 HTTPS 身份探测检查监听器，必要时重绑；不因刷新发现而中止正在传输的文件 |
| 传输保活 | [按任务管理前台服务](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/lib/util/transfer_notification.dart) | 只在明确开始收发后启动原生 dataSync 服务；通知显示进度并可取消，完成 / 失败 / 取消后停止；持有有时限的 CPU 唤醒锁及 Wi-Fi 锁；不启动常驻监听服务 |
| 文件访问 | [SAF / 路径保存目标](https://github.com/localsend/localsend/blob/v1.18.2/packages/localsend_isolates/lib/src/task/server/file_saver.dart) | 纯 Dart 的 ReceiveTarget 接口，桌面文件与 Android 文档是两个实现。Android 通道逐块等待原生工作线程确认写入，每块最多 256 KiB，不跨通道传整文件 |
| 提交语义 | 借鉴系统文件访问，保留 dukto2 原有协议约束 | Android 10+ 用 MediaStore Downloads 的 IS_PENDING，摘要及长度一致且发送方提交后公开；SAF 用本次传输的独立目录及临时名，校验后改名；不支持安全改名 / 删除的提供程序明确报错 |

组播使用 `224.0.0.167:45878`，协议标识仍为 dukto2；与 LocalSend 共用组播地址不代表协议兼容，UDP 端口和报文均独立。无设备时的周期子网探测至少间隔两分钟，启动、接口变化与手动刷新可触发新的分阶段发现。/24 探测只是保守兜底，不保证覆盖更大子网、AP 隔离、全部 VPN 或非默认 HTTPS 端口；手动 IPv4 仍可用。

## 兼容与系统限制

- Android 最低 API 24 / Android 7；本轮产物是 arm64 调试 APK。Android 7–9 可以授权 SAF 文件夹；未授权前保留私有接收与导出，不额外索取全盘存储权限。
- Android 10+ 默认直接保存到「下载 / dukto2」，也可选择本地文件夹。SAF 暂存目录是随机标识子目录，最终文件在其中；不会为了整理目录而覆盖旧文件。
- macOS 工程最低 12.0；本轮 arm64，Intel 未验收；Windows / Linux 尚未适配。
- 第一次传输可能请求通知权限。拒绝权限后 Android 仍允许前台服务，但通知展示受系统控制。前台服务不等于永不被杀；[Android 后台时间限制](https://developer.android.com/develop/background-work/services/fgs/timeout)需要处理 onTimeout 并结束任务。
- 退出 / 强行停止、杀进程与断网不提供断点续传。部分文件使用专用暂存路径或 pending 条目，不显示为成功；中断清理失败时保留日志，下次启动只清理本项目记录的未提交条目。已提交的文件不会因取消或启动清理被删除。
- SAF 提供程序的能力、SD 卡文件系统和可用空间仍可能限制大文件。未承诺 FAT32 支持超过 4 GiB。
- 既有客户端整次上传 2 小时上限、30 秒输入空闲超时仍保留。大文件能力不等于任意时长传输能力。

## 已执行验证（分清层次）

### 自动化

仓库 `tool/check.sh` 已通过静态分析、13 项 Flutter / 平台桥测试和 21 项真实 TLS / UDP 核心测试，共 34 项。新增覆盖：

- UDP 公告必须通过实际 HTTPS 身份确认；伪造指纹不进入设备列表；发现重新绑定不终止 UI 事件流。
- Android 写入通道按最多 256 KiB 分块，并等待原生确认；工作线程写入失败向上传播。
- 外部接收目标提交失败：丢弃目标，不发布成功回执。
- 上传无数据进展：清理暂存，随后可正常接受新文件。
- 接收端取消正在等待数据的上传：不等 30 秒空闲超时即可退出。
- 发送方接受后、上传前取消：接收目标被释放，并通知 UI 退出接收状态。
- 监听器自检使用完整 HTTPS，避免裸 TCP 探测制造 TLS 错误。
- 小屏深色、200% 文字下可查看长接收位置并使用文件夹按钮。

### macOS 核心大文件

`packages/dukto2_core/bin/validate_large_transfer.dart` 是显式运行的集成验证工具，不进入每次快速测试。运行时创建自己的临时目录，结束后删除，只保留摘要、大小、耗时和内存日志。

| 场景 | 字节数 | 独立验证 | 结果 |
| --- | --- | --- | --- |
| 生成的实际数据流 → TLS → 真实接收文件 | 4,294,967,313（4 GiB + 17） | 接收文件实际长度与独立磁盘 SHA-256；非稀疏文件，不伪造长度 | 通过；SHA-256 `f513236715fb5587aec0c7c45bba5a7008ed80e172e29fbb963c90e66dbfa05b` |
| 真实源文件 → TLS → 真实接收文件 | 1,073,741,841（1 GiB + 17） | 独立读取源文件与接收文件摘要，加上协议两端校验 | 通过；SHA-256 `a12dd83f95fc70d2b8e49eb61cdad50fad2f2e14fbfaa4fdfa189950f4530fed` |

4 GiB 验证进程同时包含发送和接收核心，基线 RSS 22,953,984 字节，峰值 34,471,936 字节（约 32.9 MiB），到提交约 79.3 秒，含独立读取复核总计约 104.5 秒。1 GiB 真实磁盘源场景峰值 40,599,552 字节（约 38.7 MiB），总计约 34.5 秒；该次日志 uploadMs 包含源文件生成及预先读取摘要时间，不作为纯网络耗时。

**这些是同机、同进程、AOT 核心验证，不是 Flutter GUI 内存测量，也不是 Mac ↔ Android 吞吐测试。** 两次均以实际收到的数据进行落盘，再独立读取；4 GiB 的源为生成流，不能冒充从源盘读取 4 GiB 的验收。日志位于 `artifacts/dukto2-large-validation.log` 和 `artifacts/dukto2-disk-validation.log`。

### macOS GUI 与同机 CLI

新版 Mac GUI 已自动发现独立测试身份的 CLI，实际比较界面核对码与 CLI 控制台核对码后连接，使用系统文件选择器选择专用 172,032 字节文件并明确发送；反向 CLI → GUI 经过真实接收确认。两端落盘文件独立 SHA-256 均为 `3bedc7fc137ca17cf59d40a99cc25ea99a2621098b74e6b851f6b7513d3c473c`。退出 CLI 后，GUI 显示「附近设备 0」和「已核对 · 未发现」，未把旧选择继续计为在线。这是 Mac GUI ↔ 同机 CLI，不是 Mac ↔ Android。证据见 `artifacts/dukto2-0.1.1-gui-validation.json` 与截图。

### 构建与真机状态

macOS / Android 调试构建已通过一次；最终产物以当前检查日志与产物清单为准。0.1.0 的历史真机双向传输证据仍在 [基线验证](validation.md)，不混作 0.1.1 的验证结果。

**当前没有连接 Android 真机，新版的系统下载目录、SAF、通知、息屏 / Home 后台、切网恢复与跨系统大文件尚待真机验收。** 用户已收到连接设备的请求。本轮没有安装 / 操作未连接的手机，也没有把构建成功表述为平台行为已通过。

## 真机待执行清单

1. 更新同一包名应用，在原 Wi-Fi / VPN 条件下观察双向自动发现；切网 / 恢复前台后重新发现；保留手动连接对照。
2. 双向小文件，直接保存到下载目录后通过 adb 独立读取 SHA-256；确认私有接收目录未再产生完整副本。
3. 授权系统文件夹并重启，检查授权持久化、同名接收、不覆盖旧文件、历史打开与取消清理。
4. 真实大文件收发，记录文件系统、可用空间、两端摘要、RSS、耗时；分别 Home 退后台和息屏后确认通知与持续进度。
5. 通知取消、拔网 / 断 Wi-Fi、发送方进程中止、接收方强行停止，检查明确失败、无假成功、重启只清理临时数据，以及从头重发可成功。提交后丢失回执可能出现“接收端已保存，发送端未确认”，不能承诺撤回或恰好一次交付。
6. 旧系统 / ARM32 / Intel 需独立构建和真实设备测试；当前未纳入已验证范围。
