# dukto2

一个希望延续 Dukto 简单、直接体验的跨平台局域网文件传输项目。使用 Flutter / Dart 独立重写，当前先支持 macOS 与 Android。

## 致敬 Dukto

感谢 **Emanuele Colombo** 创作了 [Dukto](https://www.msec.it/blog/dukto/)，让不同系统之间的局域网传输变得简单。也感谢 [xuzhen/dukto](https://github.com/xuzhen/dukto) 及社区贡献者持续维护和移植这个项目。

dukto2 的目标是延续原作的实用精神，用现代框架继续探索跨系统文件互传。目前是独立重写项目；名称表达致敬与延续意愿，尚不代表原作者授予的官方继任身份或背书。项目发起人计划与原作者沟通，相关关系将以实际沟通结果更新。

当前实现没有复制 Dukto 源码、美术素材或品牌图标，使用独立传输核心与新协议。旧 Dukto 协议兼容留待后续单独实现。

详细来源与说明见 [致敬与创作说明](ACKNOWLEDGEMENTS.md)。

## AI 创作声明

本项目主要由 **OpenAI Codex** 在人的指导下创作：代码、UI 提案、测试与文档由 AI 生成并迭代；发起人提出目标、选择方案并审阅结果。开发过程中使用了 GPT-6.1 Sol，以及 UI UX Pro Max 等设计辅助工具。我们选择公开说明这一创作方式，而非将 AI 生成的工作表述为纯人工编写。

本仓库记录了已执行的自动检查与真机验证；结果和未覆盖范围见 [验证记录](docs/validation.md)。

项目计划开源。正式发布前将确定本项目的开源许可证，并整理依赖许可与发布信息；当前尚未发布公共仓库，也未将原作的许可条款自动套用到独立重写代码。

## 环境

- Flutter **3.47.7 stable** / Dart **3.13.5**，具体依赖版本见两个 `pubspec.lock`。
- macOS：最低 macOS 12；当前已验证 Apple Silicon，Intel 尚未实测。需要完整 Xcode，按 Flutter doctor 提示完成首次初始化；插件需要的 CocoaPods / Swift 工具链以 doctor 和实际构建结果为准。
- Android：Java 17+，Android SDK 36 / Build Tools 36，adb；最低 Android 7（API 24）。NDK 由 Flutter/Gradle 按需安装。
- 手机与电脑连接同一局域网，路由器允许设备间通信。

当前工作区的工具链位于项目相邻的 `../.toolchains/`；这些是本机依赖，不属于本仓库。其他电脑可直接使用 PATH 中的 Flutter，或设置 `FLUTTER_BIN`。

## 启动

```sh
./tool/flutterw pub get
./tool/flutterw doctor -v
./tool/flutterw run -d macos
# 查看 Android 真机 ID 后运行：
./tool/flutterw devices
./tool/flutterw run -d <android-device-id>
```

生成 Android 测试安装包：

```sh
./tool/flutterw build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

调试包使用开发签名，不代表正式商店发行版本。发布签名与自动更新尚未配置。

## 使用

1. 两台设备打开应用，在前台选择设备与确认收发。允许 macOS 的本地网络访问/防火墙接入。Android 新版已接入传输前台服务，真机后台验收状态见下文。
2. 在「附近设备」选择目标。如果未发现，可输入对方「本机信息」中显示的 IPv4 地址与端口。
3. **实际查看接收设备上的本机核对码**，与连接对话框中的 16 位十六进制码核对一致后确认。名称和自动发现信息不是可信身份凭据。
4. 点击「选择文件」，核对文件名与大小后点击「发送文件」。接收方确认后传输，双方 SHA-256 一致且接收方确认落盘后显示完成。
5. Android 10+ 默认直接保存到「下载 / dukto2」，可通过「更改接收文件夹」改用系统授权文件夹。Android 7–9 授权文件夹后可直接接收；未授权时保留应用内接收与「保存到…」。macOS 用 Finder 显示接收文件。

应用内及 SAF 文件夹接收使用独立子目录；Android 系统下载目录由 MediaStore 创建新条目处理重名，不覆盖旧文件。未完成的文件不显示为成功，重启时会清理上次遗留的临时文件。接收记录保存于本机，保留最近 100 条。

## 当前范围

- UDP 候选经 HTTPS 确认后展示；按接口公告、启动重发、切网重新订阅、证书去重和过期移除。组播不可用时限流探测直接连接的私有 IPv4 /24 网段，保留手动 IPv4 连接。
- 每个安装生成独立 TLS 身份；核对码确认后固定目标证书指纹。
- 每次单文件流式上传，独立选择与发送步骤；双向收发、进度、平均速度和取消。
- 蓝色极简界面、macOS 双栏 / Android 单列，跟随系统深浅色并支持手动切换。
- 接收请求前台弹层，返回键 / Esc 拒收，请求过期只关闭对应弹层。
- 接收确认、大小验证、SHA-256、临时文件提交、跨目录/非法文件名防护。
- macOS 沙箱网络权限与文件选择权限；Android 多播锁、dataSync 前台服务、进度 / 取消通知、直接接收至系统下载目录或已授权文件夹，保留历史文件导出。

0.1.0 基线已实机验证 macOS 图形版 ↔ Android 16 双向收发与 SHA-256 一致。0.1.1 新发现机制、Android 后台与直接保存已实现并构建，但当前手机未连接，尚待真机复验；不能将旧版双向验收当作新版后台能力的证据。本机已完成超过 4 GiB 的 TLS 流式落盘和独立 SHA-256 检查，范围详见 [可靠性改进与验证](docs/reliability.md)。

尚未实现：文件夹/文本/剪贴板传输、断点续传、IPv6、多任务队列、旧 Dukto 兼容。后台继续传输与进程死亡后继续传输不同：强行停止应用或网络中断后仍需从头重试。Android 后台服务受系统时间及厂商省电限制，未承诺永久驻留或后台自动接受新请求。取消不是撤回：已完成并提交的文件会保留。

## 测试

```sh
./tool/check.sh
```

包含核心的真实 TLS/UDP 测试及手机/桌面布局测试。实际跨系统验收应包含 Mac → Android 和 Android → Mac，检查接收端落盘文件的大小与 SHA-256。

macOS 图形工具链尚未齐全时，可运行**同一核心**的 CLI 与 Android App 互传：

```sh
cd packages/dukto2_core
# dart 可以使用 Flutter SDK bin/cache/dart-sdk/bin/dart。
dart pub get
dart run bin/dukto2.dart receive --dir ./received --name Mac
# probe 只读取身份，发送前仍必须核对接收设备上的码：
dart run bin/dukto2.dart probe --host 192.168.1.20 --port 54321
dart run bin/dukto2.dart send --host 192.168.1.20 --port 54321 \
  --code 'AAAA BBBB CCCC DDDD' --file ./example.bin
```

`receive --auto-accept` 仅供受控本地测试，图形应用始终要求接收确认。

## 目录

- `lib/`：Flutter 界面、状态和平台集成。
- `packages/dukto2_core/`：不依赖 Flutter 的发现、身份、收发与 CLI。
- `android/`、`macos/`：官方 Flutter 平台工程及必要适配。
- `docs/protocol-v1.md`：协议和信任边界。
- `docs/validation.md`：基线实际验证结果及未完成项。
- `docs/reliability.md`：0.1.1 对 LocalSend 的借鉴、实现与分层验收状态。

Flutter 的生成模板在中文目录中读取 SDK 路径时存在编码问题，`android/settings.gradle.kts` 已显式按 UTF-8 读取并传递路径。静态检查使用 `dart analyze`，避开当前 Flutter LSP 初始化在中文路径下的异常。
