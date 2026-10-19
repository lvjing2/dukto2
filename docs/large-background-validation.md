# 大文件、后台与中断验收

日期：2026-10-18（Asia/Shanghai）。应用版本 0.1.3+4，Apple Silicon Mac 与 Android 16 / REDMI K90，通过同一 Wi-Fi 的 TLS 传输。USB 只用于控制设备、采样和独立读取结果，不做网络转发。

本记录区分图形版互传与 Mac 验收命令行；每个成功结果均在协议校验后独立读取接收文件复核。测试产物保存在被 Git 忽略的 `artifacts/large-background/`。

## 测试数据与方法

- 大文件为实际写入的 1,073,741,841 字节（1 GiB + 17），不是稀疏文件或伪造长度。SHA-256：`a12dd83f95fc70d2b8e49eb61cdad50fad2f2e14fbfaa4fdfa189950f4530fed`。
- 锁屏及中断对照使用上述文件前 134,217,728 字节（128 MiB），SHA-256：`4a584c6fa6b3483390ec80a04a825d5fe67d5fc68826773e475ce5a9aca73347`。
- 通过本应用的通知、服务、进程及内存记录采样，不收集其他应用通知内容。成功后确认后台服务及唤醒锁释放。
- 锁屏测试期间 USB 供电。采样中的 `wakefulness=Dozing` 是系统屏幕电源状态，不代表已经进入 Android device-idle 的深度 Doze；不将短期息屏结果当作长时间省电模式保证。

## 已完成结果

| 场景 | 结果 | 证据 |
| --- | --- | --- |
| Mac 图形版 → Android 图形版，1 GiB + 17，仅 Home 退后台 | 完成；手机 MediaStore 已公开，独立磁盘摘要与长度一致。私有接收目录约 4 MiB，未增加一份完整大文件副本。 | `gui-mac-to-android-home.json`、`gui-mac-to-android-home-samples.jsonl` |
| Mac 限速验收 CLI → Android 图形版，128 MiB，直接锁屏 | 完成；约一分钟持续锁屏接收，真实落盘 SHA-256 一致，结束后服务和唤醒锁释放。 | `lock-probe-send.jsonl`、`lock-probe-receipt.json`、`lock-probe-samples.jsonl` |
| Android 图形版 → Mac 图形版，1 GiB + 17，发送时锁屏 | 完成；手机系统选择器选择原文件，Mac 明确确认接收，实际磁盘大小和摘要一致。采样记录覆盖约 34 秒的锁屏持续发送。 | `gui-android-to-mac-locked.json`、`gui-android-to-mac-send-samples.jsonl` |
| 发送进程被 SIGKILL 终止 | 已有数据上传后终止专用 Mac 发送进程；Android 未提交条目消失、无成功历史，后台服务停止；随后新 offer 从头发送 1 MiB 成功并独立校验。 | `sender-kill-result.json`、`sender-kill-retry-result.json` |
| Android 接收应用 force-stop | 中断时 pending 日志存在；重启清理未完成条目，发送方报失败；从头重新发送 1 MiB 成功并独立校验。 | `receiver-force-stop-result.json`、`receiver-force-stop-retry-result.json` |
| Android Wi-Fi 关闭约 40 秒再恢复 | 发送方明确报超时，未提交条目被删除，成功历史未增加，服务停止；Wi-Fi 恢复后从头重发 1 MiB 成功并独立校验。 | `wifi-drop-result.json`、`wifi-drop-retry-result.json` |
| 通知按钮取消（修复展开样式后） | 用户在真实通知里看到并点击「取消」；发送进程自行报连接重置并以 1 退出，手机删除 pending 条目、无成功历史、服务停止；随后从头重发 1 MiB 并独立校验成功。 | `notification-cancel-result.json`、`notification-cancel-retry-result.json`、`notification-style-own-record.txt` |

重发使用与中断测试相同的名称，但发送新的 1 MiB 完整内容；其大小有意小于原 128 MiB，用于验证忙状态释放、协议重新握手和安全提交，不冒充 128 MiB 的断点续传。

Android 大文件收发期间的采样峰值分别约为 329 MiB / 317 MiB PSS，Mac 分别约为 249 MiB / 244 MiB RSS；两者是不同指标，不直接相加或比较。统计已按各自完成回执时间截断，避免把下一项测试混入本次结果，见 `telemetry-summary.json`。这些是调试应用的有限频率采样，不等于精确分配峰值或发布版内存保证。

### 首轮失败与对照

第一轮 Mac 图形版 → Android 图形版大文件在 Home 后继续传输，随后锁屏时连接被重置。Mac 报 `Connection reset by peer`，手机报 `Connection closed while receiving data`。手机进程未退出，Wi-Fi 随后查询仍连接；本次暂存日志清空且无成功历史，未把半成品发布为已完成文件。

只退后台的大文件重发成功；随后直接锁屏的限速 128 MiB 接收也成功。因此目前只能确认发生过连接重置，尚无足够证据归因于某个生命周期或省电实现，不以一次对照通过宣称已修复首轮问题。原始记录见 `gui-mac-to-android-samples.jsonl`、`first-lock-failure-app.log`、`first-lock-storage.xml` 和 `events.jsonl`。

### 通知取消的显示问题

真机系统通知记录确认传输通知含有一个「取消」action，但折叠样式没有展示清楚的展开入口。自动化未能稳定展开；用户实际反馈也没有看到按钮。因此早期 `notification-cancel-*-automation-attempt*.json` 及 `notification-cancel-manual-unavailable.json` 仅是未完成的 UI 验收记录，不算通知取消通过。最后一次由验收工具停止发送进程，不能归因于用户点击通知取消。

为此在 `TransferService.notification()` 明确设置系统 `Notification.BigTextStyle`，其余通知权限和取消处理保持不变。[Android 官方说明](https://developer.android.com/develop/ui/compose/notifications)将操作按钮归入通知展开视图。更新后，用户确认能够看到并点击通知中的「取消」；独立验收确认发送端自行失败、未完成数据删除、无成功历史、前台服务停止。这一结果限于本次真机，不推断其他厂商的通知布局。

修复包 `Dukto2-0.1.3-android-notification-style-debug.apk` 已构建，签名与现有基线一致、权限未增加。用户明确确认后完成更新安装，独立读取设备上 APK 的 SHA-256 与候选一致；清单见 `notification-style-candidate.json`。版本标识仍为 0.1.3+4，必须用该清单的 APK 摘要区分原调试包与本次通知样式修复包。

## 可复用的显式验收工具

`packages/dukto2_core/bin/validate_lan_transfer.dart` 使用正式 TLS 传输核心，仅在测试源流上限速；不会改动协议、跳过指纹校验或给图形应用增加测试开关。

```sh
# 在实际接收端屏幕确认 code 后发送真实源文件；可选 --size 只取源文件前缀。
./tool/dartw run packages/dukto2_core/bin/validate_lan_transfer.dart send \
  --host RECEIVER_IPV4 --port RECEIVER_PORT --code 'SCREEN_CODE' \
  --file /absolute/source.bin --mib-per-second 2
```

工具输出 JSON 进度、大小、耗时和本进程 RSS；发送前独立计算真实源文件摘要，与接收回执比较。真机接收后另用独立命令读取文件摘要。CLI 数值不代表 Flutter 图形应用的内存或未经限速的 Wi-Fi 吞吐。

## 自动检查与边界

`tool/check.sh` 通过：25 项 Flutter / 平台测试、30 项真实 TLS / UDP 核心测试，两个分析器无问题。首轮日志：`artifacts/large-background/checks.log`；最终复核日志：`final-checks.log`。通知样式修复的 Android 原生构建日志为 `android-notification-style-build.log`。

最终复核：手机 Wi-Fi 已恢复，暂存条目为零，传输前台服务和 CPU 唤醒锁均已释放；设置保留。已提交的 1 GiB 文件在强行停止与断网测试后仍完整。见 `post-interruption-audit.json`、`final-cleanup-audit.json`。本轮结果索引为 `summary.json`。

尚无断点续传。进程终止或连接失败后，需重新发起并从头发送；暂存回收不等于恢复进度。接收方提交后回执丢失仍可能出现“文件已保存、发送方未确认”，重发不覆盖旧文件，可能新增副本。

本轮不涵盖旧版 Android、其他厂商、Intel Mac、USB 断开后的长时间锁屏或强制深度 Doze。大于 4 GiB 的结果仍限于此前 Mac 核心回环，见 [可靠性改进](reliability.md)，不能替代 Android 真机验证。
