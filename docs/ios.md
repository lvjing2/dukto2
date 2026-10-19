# iPhone 与 iPad

2026-10-18 接入独立 iOS 工程，沿用 Flutter 界面与 Dart TLS 核心。最低 iOS / iPadOS 15，目标设备族包括 iPhone 和 iPad。当前验证环境为 Apple Silicon Mac、Xcode 27.1，以及 iOS 27.0 模拟器；旧系统和真机仍待验证。

## 接入内容

- Apple 端通过系统 Bonjour 发布和浏览 `_dukto2._tcp`。发现结果只是地址候选，仍由核心发起 HTTPS 探测并核对证书身份，发送前保留屏幕核对码确认。
- iOS 不发送自定义 IP 组播或广播，不申请受限 multicast entitlement。保留限流的私有 IPv4 /24 探测和手动连接；确认 Android 端点后向它发送 UDP 单播公告。Android 互通尚需 Apple 真机实测。
- 默认接收位置为「文件 → 我的 iPhone / iPad → Dukto2 → 接收文件」。设置中可通过系统目录选择器更改，使用安全书签记住授权；恢复默认不删除原文件。
- 系统文件选择器选择发送源；已接收文件通过系统分享面板打开或导出。iPad 分享面板设置了 popover 锚点。
- 复用文本输入、显式粘贴、查看与复制、16 MiB 上限。小文本保存在应用私有历史，大文本正文使用所选接收目录。
- 完成通知使用系统授权与本地通知；传输时临时阻止自动锁屏。
- 设备名称读取系统允许返回的名称。iOS 16 起，未经 Apple 特殊授权时，真机通常只返回 iPhone / iPad；模拟器名称不能证明真机可读取用户自定义名称。

## 保存与中断

每次原生写入最多 256 KiB，Dart 等待写入完成再继续，避免全文件驻留内存。接收期间写入应用私有暂存；完成时通过文件协调器复制到所选目录的独立传输子目录，重新流式读取并核对大小和 SHA-256，再改为最终文件名。此流程需要额外磁盘空间，不是零副本写入。外部文件提供方的空间、可用性与上传行为仍由该提供方决定。

原生待完成日志用于应用重启后的暂存清理；暂时不可用的提供方保留清理记录，已发布文件不因清理被删除。历史使用应用生成的不透明文件标识，按相对路径解析，避免把旧容器绝对路径当作永久授权。

传输主要在前台使用。切后台时只申请系统有限宽限时间；到期中止并提示重新发送，不宣称锁屏或后台可无限传输。没有自动接受后台请求、进程死亡续传或断点续传。

## 构建

```sh
./tool/flutterw pub get
./tool/flutterw build ios --simulator --debug
# 仅检查真机架构，不产生可直接安装的签名 IPA：
./tool/flutterw build ios --no-codesign --release
```

真机调试需配置自己的 Apple 开发团队与签名，并在设备上信任电脑、开启开发者模式。本机团队设置放在未纳入 Git 的 `ios/Flutter/LocalSigning.xcconfig` 中（`DEVELOPMENT_TEAM = 自己的团队 ID`），Debug / Release 可选包含此文件，也可以通过 `xcodebuild DEVELOPMENT_TEAM=...` 传入。项目不提交个人团队 ID，未发布 TestFlight / App Store。

2026-10-18 已通过 USB 配对 iPad Pro 11 英寸（第 3 代），iPadOS 26.6，开启开发者模式。用户授权后完成 Personal Team 自动签名，Release 真机构建、严格签名校验和安装通过；用户已信任开发者并启动应用、允许本地网络。签名、安装日志位于 `artifacts/ios/physical-ipad/`。实际互传验收结果在完成后单独记录，安装成功不代表局域网传输已通过。

首轮启动时，两端 Wi-Fi 地址位于不同子网，Mac 到 iPad 的路由被 VPN 接管；待用户将设备接入同一 Wi-Fi 后继续核对码与互传。当前 Device Hub 对这台 iPadOS 26.6 提示屏幕共享需要 27.0，因此真机界面点击由用户配合；这项工具限制不改变应用的最低系统版本。

## 自动验证

- `tool/check.sh`：Flutter / 平台 29 项、Dart 核心 31 项通过，分析器无问题。
- iOS XCTest 5 项通过：有界写入与重复准备保护；错误哈希不发布及重启清理；已有文件不覆盖且取消保留；自选目录记忆和恢复默认保留文件；正确提交、重启与导出定位。
- macOS Debug、iOS Simulator Debug、iOS Device Release（无签名）构建通过。
- 历史操作布局增加 800 / 1200 宽同排检查，并保留窄屏两倍字号回归。

## 模拟器操作验收

| 范围 | 结果 |
| --- | --- |
| Mac CLI → iPhone GUI → Mac GUI 文本 | 69 字节中文、emoji、多行及两侧空格，通过 iPhone 查看、复制、粘贴后回传；两端历史正文逐字节相同 |
| Mac CLI → iPhone GUI → Mac GUI 文件 | 1 MiB + 17 字节；通过系统文件选择器选取接收文件回传；两端实际文件逐字节相同 |
| Mac CLI → iPad GUI 文件 | 同一 1 MiB + 17 字节文件，独立读盘校验一致 |
| iPad GUI → Mac GUI 文件 | 系统文件选择器选取 1 MiB + 17 字节文件，Mac 实际保存内容与原件逐字节相同 |
| iPad GUI → iPhone GUI → iPad GUI 文件 | 两端自动发现，实际查看本机核对码后连接，系统选择器选文件，每次由接收界面确认；双向独立读盘、大小及 SHA-256 一致 |
| iPad GUI → iPhone GUI → iPad GUI 文本 | 69 字节中文、emoji、多行和两侧空格，查看、复制、粘贴后回传；两端新收发历史正文逐字节相同 |
| Mac CLI → iPad GUI → Mac GUI 文本 | 同一 69 字节文本，显式复制粘贴回传，独立读取历史一致 |
| 原生目录选择 | iPhone 系统选择「Dukto2」文档目录，更新安装并重启后仍可访问，再从设置恢复默认成功 |
| iPad 原生导出 | 横屏系统分享 popover 正常打开，未崩溃；未向外部应用发送文件 |
| 自动发现和布局 | iPhone、iPad、Mac 显示彼此；iPad 横竖屏保持双栏，历史查看 / 复制与记录并排 |

文本 SHA-256：`cde315d9700f2dfe39590cedd4eedc8ec0b895799ce64aa6f17aa4514d48fe74`。

文件 SHA-256：`f4bf9b8dec6e3e28b2ec33266145d244fe97a6bce1ec054ace053bab67d2ef9a`。

本轮未验证 16 MiB iOS 文本、iOS 系统完成通知实际出现、外部文件提供方、Apple 真机与 Android 互传。新增 iPad → Mac 和 iPhone ↔ iPad 验收全程使用真实 Flutter 图形界面，未通过 CLI 代替手机或平板发送。前轮标为 CLI 的传输仍按原范围记录；所有模拟器结果均不能当作真实跨设备 Wi-Fi 吞吐验证。

补测中发现切换目标会保留上一目标的“已发送”卡片状态，已修复：更换设备身份后保留已选文件并重置为准备就绪，等待用户显式发送；新增回归测试，并在 iPad 上实际切换目标确认发送按钮恢复。

“关于 Dukto2”入口已从主界面右上角移至设置底部，致敬、AI 创作说明与第三方许可保留。最终构建已更新到 iPhone / iPad 模拟器，并检查了设置入口和 iPad 关于弹窗；手机两倍字号深色、桌面浅色的导航回归通过。

iPad 首次从历史行复制后，紧接着粘贴曾提示空剪贴板；从查看文本窗口再次复制后成功，最终双向正文核对一致。尚未定位是否由模拟器剪贴板同步时序引起，后续真机复验。

本机证据保存在未纳入 Git 的 `artifacts/ios/`；本轮五个方向的独立校验、历史基线、清理检查及构建日志位于 `artifacts/ios/peer-validation/`。模拟器与宿主机共享网络环境，不能替代真实 Wi-Fi、锁屏、省电、外部云盘及旧 iOS 验收。

## 平台依据

- [Flutter 支持平台](https://docs.flutter.dev/reference/supported-platforms)
- [Flutter UIScene 与原生通道](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate)
- [Apple：目录访问](https://developer.apple.com/documentation/uikit/providing-access-to-directories)
- [Apple：本地网络隐私](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy)
- [Apple：multicast entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.networking.multicast)
- [Apple：设备名称限制](https://developer.apple.com/documentation/uikit/uidevice/name)
