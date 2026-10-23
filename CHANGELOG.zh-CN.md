# 变更记录

[English](CHANGELOG.md) | 简体中文

版本号描述源码演进，不表示已经发布对应安装包。各平台实际构建和互传范围以 [验证记录](docs/validation.md) 为准。

## Unreleased

- Add optional Android background reception, off by default, with a 30-minute waiting window and notifications that open the existing receive confirmation.
- Preserve the receive runtime across Activity recreation; stop waiting on opt-out or expiry without granting automatic file consent.

## 0.1.6-rc.10+17 — Release candidate

- Distinguish confirmed peer cancellation from network failures, stop uploads, and clean up temporary resources.
- Tolerate transient or slow peer identity probes without bypassing identity checks before sending.
- Simplify selected-device rows and combine repeated encrypted LAN transfer descriptions across all supported languages.
- Keep nearby-device counts visible during active discovery.
- Increase Android versionCode to 17, retaining the existing application and upload signing keys.

## 0.1.6-rc.8+15 — 发布候选

- 发现公告使用独立发送 socket，避免不支持组播或广播的路由错误关闭接收端，影响继续接收公告和下一次离线通知。
- 同机离线公告回归用例使用独立接收端口，避免数据包竞争。
- Android 安装版本号升至 15，继续沿用现有应用签名与上传签名。

## 0.1.6-rc.7+14 — 发布候选

- 应用与发布元数据统一显示项目版本号，单独保留各平台构建号。
- 精简电脑和移动端的无设备、无传输记录状态。
- 修正 macOS 离线广播回归用例的组播监听方式，保持 3 秒存活过期逻辑。
- 发布标签统一使用项目版本号，Android 安装版本号升至 14。

## 0.1.6-rc.6+13 — 发布候选

- 点击刷新与触屏下拉刷新统一触发主动扫描，显示「正在搜索」状态，重复操作共享同一轮搜索。
- 已发现设备每秒独立检查，连续 3 秒未获 HTTPS 确认即移除；正常退出发送离线广播，核实不可达后提前移除。
- 在线检查与候选扫描使用独立并发名额，避免大范围扫描拖慢离线状态更新。
- 精简已选设备信息和二维码扫描页面，在「关于」中增加作者链接及实际安装版本信息。
- Android 与 Windows x64 已部署同一发现逻辑用于手动验收；本轮不宣称完成所有平台真机上下线测试。

## 0.1.6-rc.5+12 — 发布候选

- 增加 Windows ARM64、Linux ARM64 原生构建和独立附件。
- 打包校验主程序、引擎、插件及运行库的处理器架构；ARM64 真机验收待完成。

## 0.1.6-rc.3+10 — 发布候选

- Windows 增加摄像头与图片扫码连接，适配触屏及横竖屏。
- 显示设备在线 / 离线状态；不可连接时禁用发送，发送前重新核对可达性和身份。
- 设备名称置于设置首项，修正语言列表中阿拉伯语名称的对齐。
- Windows 随包提供 VC++ 运行库，Linux 增加用户级桌面安装入口。
- Android 构建号升至 10，继续使用现有应用与上传签名密钥。

## 0.1.6-rc.2+9 — 发布候选

- 冻结首个发布候选；Android APK 与 Play AAB 统一使用 versionCode 9，应用签名和上传签名继续分离。
- 增加十种界面语言与原生通知本地化；二维码连接在建立连接前核对完整设备指纹。
- 包含已知设备发现、批量确认、文件与文本传输、可记忆接收目录及传输记录操作。
- 五平台 CI 产物汇总为私有 GitHub 预发布草稿；iOS 仍是未签名 device build，macOS 为 ad-hoc 签名且未经公证。
- Google Play 建档、生产访问审批及真实双渠道升级仍待完成；验证边界见发布说明。

## 0.1.6+7 — 未发布

- 增加结构化传输错误、有界诊断日志与统一的传输会话清理。
- 仓库文档提供中英文两版，Issue / PR 模板支持双语；整理开发过程资料并更新模拟器截图。
- 增加五平台原生 Release CI、版本化产物与摘要，以及标签触发的草稿 Release；Android 使用独立应用签名与上传密钥。

- Linux 接入共享桌面接收目录设置、打开目录和休眠抑制；完善通知设置能力探测及用户级桌面注册。新增行为仍需桌面复验。
- 选择 Apache-2.0，添加许可证、第三方声明、贡献和安全指南、来源核查与社区检查工作流。

## 0.1.5+6 — 开发预览

- 统一启动图标和应用内品牌图片，更新 macOS 实机截图。

## 0.1.4+5 — 开发预览

- 批量文件改为整批确认，失败或取消停止余下文件；继续发送时重新授权剩余清单。
- 接收确认窗口调整为五分钟，与批次内空闲超时分开计算。
- 最近传输增加设备筛选、完成时间和耗时，调整窄屏布局。
- 接入 iPhone / iPad、Windows 与 Linux；各平台验证程度不同。

## 0.1.1–0.1.3 — 开发预览

- 改善自动发现、Android 前台传输服务和系统目录接收。
- 增加可记忆的接收位置、16 MiB 文本收发、设置与完成提醒。
- 增加大文件、后台、锁屏、取消及中断验证，保留已知失败和边界。

## 0.1.0 — 初始基线

- Flutter 界面及独立 Dart HTTPS 传输核心，身份核对、流式收发、大小与摘要校验。
- macOS 与 Android 图形版双向文件互传。
