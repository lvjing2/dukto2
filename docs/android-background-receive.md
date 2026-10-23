# Android 后台等待接收：评估

[English](en/android-background-receive.md) | 简体中文

2026-10-23 的实现前评估，以下内容作为设计依据保留。功能现已获准纳入主线，默认关闭；实际实现和检查范围见 [功能与验证](android-background-receive-option.zh-CN.md)。耗电测试已按用户要求停止，厂商冻结限制保留。

**结论：用户主动开启、限时等待接收并显示通知，有条件可行；不承诺应用未启动、强行停止或深度休眠后的实时接收。**

## 推荐交互

- 默认关闭；用户在前台开启「后台等待接收」，首版建议每次 30 分钟，不持久化为自动重启任务。
- 显示低打扰状态通知，包含剩余时间和「停止等待」。后台收到请求时发独立提醒，点击直接回到原请求的文件清单，用户确认后才开始上传。
- 通知不提供直接接收按钮；锁屏隐藏文件名和文本。请求名称不是可信身份，需限流、合并提醒，避免陌生设备刷通知。
- 到期停止接受新请求；已明确同意的传输按现有会话完成或取消，不因等待计时结束中断。关闭等待不关闭前台正常接收功能。
- 通知权限或请求通知渠道关闭时，不开启后台等待；保留前台收发。通知点击不是接收授权。

## 技术与限制

| 项目 | 判断 |
| --- | --- |
| 服务类型 | `connectedDevice` 是网络设备交互的候选；现有组播权限满足其一项启动前提，但不等于所有空闲监听用途都已获认可。实现前须验证实际用途与前台服务声明，Play 审核另行完成。 |
| 现有 `dataSync` | 保留实际传输职责，不用于全天空等；target 35+ 的后台运行有每日累计时限。 |
| 生命周期 | 当前服务不是 Dart 服务器的所有者；`MainActivity.onDestroy` 会停止服务、释放发现和存储适配器。需让服务持有接收运行时/FlutterEngine，页面只附着 UI，并保证仅有一个服务器和会话。单改 Manifest 不够。 |
| 请求通知 | 新建接收请求渠道，使用指向 Activity 的不可变 PendingIntent；仅携带本机请求标识，不暴露授权 token。点击时核对请求仍有效，过期提醒不能重建授权。 |
| 协议 | 可复用现有五分钟确认预算和单文件/批次清单；提醒随拒绝、取消、超时、退出撤销，不持久化旧授权。暂不增加离线发送队列。 |
| 电量与网络 | 等待时不沿用传输期间的长时间 CPU/高性能 Wi-Fi 锁，不持续扫描网段。先测无长持锁方案的可达性与耗电；若只能靠高耗电保活才可靠，应放弃默认开放。 |

Android 12+ 限制后台启动前台服务，应从用户可见操作启动。Android 13+ 即使不授予通知权限也可能允许前台服务运行，但无法提供所需通知体验，因此上述权限门槛是产品选择。Doze 会限制网络和唤醒锁，前台服务不等于实时网络保证。

本项目已确认 HyperOS 智能省电可冻结进程；仅更改服务类型无效。[Issue #2](https://github.com/lvjing2/dukto2/issues/2) 维持不开发绕过方案。手动「无限制」仅作为该机型的使用建议，不自动修改设置。用户停止、强行停止或划掉任务后首版结束等待，不自动拉起。

当前工具链 target SDK 36；升级至 37 时另行接入局域网运行时权限，不提前为本功能添加该权限。

## 实现前的验收门槛

1. 原生服务/共享引擎生命周期验证：Home、Activity 重建、回到页面均不重复启动服务器，停止后端口和资源释放。
2. 通知开关、锁屏点击、过期通知、重复请求和取消均不误授权；前台收发及批量确认保持原行为。
3. 覆盖 Android 13、14、15+ 与现有 HyperOS 真机：屏幕亮/灭、自然及强制 Doze、等待到期、网络切换、系统停止；把暂停/不可达与可靠送达区分记录。
4. 对照普通空闲运行测 30 分钟耗电、CPU、网络及锁状态。深度休眠和厂商冻结若不可达，应如实提示，不新增保活绕过手段。

通知部分改动较小，运行时与服务生命周期调整是主要工作量。建议先完成隔离验证，再决定是否开放该选项；本评估不是实现或商店审核通过的证明。

官方依据：[服务类型](https://developer.android.com/develop/background-work/services/fgs/service-types)、[服务时限](https://developer.android.com/develop/background-work/services/fgs/timeout)、[后台启动限制](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start)、[通知权限](https://developer.android.com/develop/ui/compose/notifications/notification-permission)、[Doze](https://developer.android.com/training/monitoring-device-state/doze-standby)、[Play 声明](https://support.google.com/googleplay/android-developer/answer/13392821?hl=en)、[局域网权限](https://developer.android.com/privacy-and-security/local-network-permission)。
