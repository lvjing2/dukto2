# iPhone 与 iPad

[English](en/ios.md) | 简体中文

工程最低 iOS / iPadOS 15，同一应用覆盖 iPhone 和 iPad。已使用 iOS 27.0 模拟器及 iPadOS 26.6 真机验证部分场景；iPhone 真机、最低系统版本和后台仍需独立测试，见 [验证范围](validation.md)。

## 构建与签名

需要 macOS、完整 Xcode 及 Flutter 3.47.7 stable。

```sh
./tool/flutterw pub get
./tool/flutterw build ios --simulator --debug
# 仅检查设备架构，不产生可直接安装的 IPA：
./tool/flutterw build ios --no-codesign --release
```

真机调试配置自己的 Apple 团队与签名，在设备上信任电脑并开启开发者模式。团队配置可放在被忽略的 `ios/Flutter/LocalSigning.xcconfig`：

```xcconfig
DEVELOPMENT_TEAM = 你的团队ID
```

项目不提交个人签名资料。无签名 CI device app 不能直接安装，详见 [Release CI](release-ci.md)。

## 发现与名称

Apple 平台通过 Bonjour 发布与浏览 `_dukto2._tcp`，候选仍需 HTTPS 身份确认。iOS 不申请受限自定义 multicast entitlement；保留私有 IPv4 探测、UDP 单播和手动连接。网络隔离或 VPN 可能影响发现与连接。

iOS 16 起，未经 Apple 特殊授权时，真机通常只返回 iPhone / iPad；模拟器名称不证明可以读取用户自定义名称。设备类型取自系统 interface idiom，分别显示手机和平板图标。

## 文件与后台

默认保存到「文件 → 我的 iPhone / iPad → Dukto2 → 接收文件」，可在设置中选择其他文件夹并通过安全书签记住授权。系统文件选择器选择发送源；接收文件可通过系统分享面板打开或导出，iPad 使用 popover 锚点。

每次原生写入最多 256 KiB，等待写入确认后继续。先写应用私有暂存，提交时通过文件协调器复制到目标独立目录，流式复核长度及 SHA-256 后发布，因此需要额外磁盘空间。外部提供方的可用性由其自身决定。

启动清理未提交目标，保留已发布文件。历史通过应用生成的不透明标识定位，避免依赖旧沙盒的绝对路径。

主要在前台收发；后台只申请系统有限宽限时间，到期中止并提示重发。完成通知需要系统授权，不承诺锁屏持续传输、后台自动接受或进程死亡续传。
