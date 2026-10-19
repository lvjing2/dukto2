# Google Play 数据安全与应用内容核对表（离线草稿）

对应 0.1.6-rc.2+9，源码 c6ed3ca。未提交 Console；最终勾选应按届时的表单、最终依赖和网络行为复核。本表记录技术事实，不代替维护者对商店声明的审核。

| 项目 | 证据 / 草稿结论 |
| --- | --- |
| 应用 / 维护者 | Dukto2 / lvjing2；dev.dukto2.dukto2 |
| 支持与隐私联系 | leojames.googol@gmail.com（已由维护者指定可公开） |
| 账户、登录、付费功能、广告 | 当前无应用账户、登录、付费功能或广告；建议工具类别及免费发行，尚未提交定价 |
| 文件与文字 | 用户选择、端到端设备连接、接收确认、HTTPS 固定设备证书；不经维护者中继。逐项核对用户主动分享/端到端加密的表单规则，不能直接推断整个应用“无采集” |
| 本地信息 | 设备身份、设置、目录授权、100 条历史、32 个已知设备、两个有界诊断文件；OS 备份/文件提供方另行控制 |
| 第三方采集 | mobile_scanner 7.4.2 → bundled ML Kit barcode-scanning 17.3.0。必须计入 Google 披露的诊断、使用和每安装标识数据 |
| 建议复核的数据类别 | App info and performance / Diagnostics；Device or other IDs；事件是否属于 App activity / App interactions，按最终 SDK 行为及表单定义逐项确认 |
| 用途及是否可选 | SDK 披露为 diagnostics / usage analytics。应用没有独立的 SDK 数据开关，不能未经验证就宣称其采集可选 |
| 共享 | 文件发送给用户明确选择的接收方；用户主动分享的豁免应逐项核对。Google 说明 ML Kit 诊断数据不继续转给第三方，但服务商归类仍须维护者核对 |
| 传输保护 | 文件 HTTPS + 证书核对；Google 披露 SDK 诊断使用 HTTPS；局域网发现元数据不是加密文件数据 |
| 删除 | 本机数据由系统清除；外部保存文件需单独删除；反馈邮件可联系维护者处理。没有应用账户，所以不伪造账户删除链接 |
| 相机 | 扫描连接二维码，可拒绝；不用于拍照存档；不上传图像到维护者 |
| 数据同步前台服务 | 用户发起的文件/文本传输，进度及取消通知；正式上架时按 Console 要求准备说明和真实操作录屏 |
| 内容分级 / 目标年龄 | 尚未填写；按工具类实际行为回答问卷，不伪造评级或把项目定位为儿童产品 |
| 应用访问 | 当前无需登录，无测试账号；审阅 LAN 功能需要另一台运行 Dukto2 的可达设备 |
| 公开隐私网址 | 待托管；私有 GitHub raw/blob 链接不可作为公众无需登录访问的政策页 |
| 应用内隐私入口 | 上架前需接入最终政策网址并复核。此轮未修改候选应用的隐私入口 |

源码依据：android/app/src/main/AndroidManifest.xml、lib/src/controller.dart、lib/src/transfer_log.dart、packages/dukto2_core/lib/src/diagnostics.dart、discovery.dart，以及锁定的 mobile_scanner Android 依赖。

官方依据（2026-10-19 核对）：
- https://developers.google.com/ml-kit/android-data-disclosure
- https://support.google.com/googleplay/android-developer/answer/10787469
- https://support.google.com/googleplay/android-developer/answer/9866151

Play 仍等待开发者身份审核、手机号验证、创建应用、PEPK 导入应用签名密钥、指纹核对和真实双渠道升级验收。本次不执行这些动作。
