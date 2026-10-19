# Windows 接入（开发中）

2026-10-19 已在 Windows 11 x64 完成 Release 构建、桌面启动及与 Mac 图形应用的双向文件、文本互传。实际文件落盘后独立计算 SHA-256；文本通过查看、复制、粘贴后回传，内容逐字节一致。Windows 10 属于后续兼容目标，尚未实测；ARM64 与 32 位 Windows 不在当前产物验证范围内。

本轮使用 Flutter 3.47.7 / Dart 3.13.5、Visual Studio 2022 17.9.3 和 Windows SDK 10.0.22621.0，产物版本 0.1.4+5。核心 39 项测试通过；首次 Windows 应用测试 42 项通过、3 项历史列表 widget 用例失败，Release 在保留失败证据后以 `-SkipTests` 构建。后续其他平台测试通过不等于这一 Windows 包已重新完整回归。此后的共享代码和图标调整尚需重建验证。

文件样本 1,048,609 字节，SHA-256 `7c8f84980bc99ebc8eecbc553773a0e8d6dac5d9394ad8b6c16fc9640305af82`；文本 98 字节，SHA-256 `3e1f4e396108ddaeed930850c31bf9b8b981935d7e9d42cbde8f8a5e36085c1a`。实际截图见 [Windows 桌面](screenshots/windows-main.png)。该包左下角曾错误显示“这台 Mac”，后续统一平台文案的验收应使用新包，不能据此认定旧包已修复。

2026-10-18 本机检查：应用 / 平台测试 34 项、核心测试 31 项通过，两个分析器无问题；macOS 调试构建通过。日志保存在 `artifacts/windows/checks.log` 与 `macos-regression-build.log`。这是早期记录；后续 Windows 原生构建和互传已在上文记录。当前新增许可打包步骤尚需在 Windows 重跑。

## 构建

在 Windows 安装与当前项目匹配的 Flutter 3.47.7 stable（Dart 3.13.5）、Git，以及 Visual Studio 的「使用 C++ 的桌面开发」工作负载和 Windows SDK。Visual Studio Code 本身不提供此编译工具链。先运行 `flutter doctor -v` 检查 Windows 工具链。

在工程根目录的 PowerShell 中执行：

```powershell
./tool/windows.ps1
# 或仅编译调试版：
./tool/windows.ps1 -Mode debug -SkipTests
```

脚本不修改系统执行策略。如果本机策略阻止脚本执行，可直接运行下列 Flutter / Dart 命令：

```powershell
flutter pub get
dart analyze
flutter test
cd packages/dukto2_core
dart pub get
dart analyze
dart test
cd ../..
flutter build windows --release
```

运行 `build/windows/x64/runner/Release/Dukto2.exe`。需要整个 Release 文件夹（包括 DLL、data 和原生资源），不能仅复制 exe。脚本将完整目录压缩到 `artifacts/windows/Dukto2-windows-x64-release.zip` 并输出 SHA-256；当前没有签名安装器或商店包。Windows ARM64 尚未建立构建与验收基线。

## 平台行为

- 使用 Windows 系统计算机名称，复用设备身份与 TLS 指纹核对；名称和发现消息不证明身份。
- 使用 Dart 的 UDP 多播 / 子网探测与手动 IP 连接，不需要另装 Bonjour。TCP 默认 45879，UDP 发现 45878；同机端口被占用时可使用随机 TCP 端口。
- 默认保存到系统「下载 / Dukto2」，支持重定向后的下载文件夹。设置中可以选择其他文件夹、记忆并恢复默认，切换不移动或删除已有文件。
- 用户目录和接收目录记忆保存在 path_provider 返回的应用支持目录；根目录不可用时拒绝文件接收，不能静默改存其他位置。历史仍保留旧目录引用。
- 最近传输复用设备筛选与单操作布局；文件在资源管理器中选中，文本在详情中查看、显式复制。发送源位置与接收位置独立记录。
- 完成提醒使用经典 Win32 通知区域 API；系统允许打扰时请求显示，临时通知图标会清理。设置明确显示由 Windows 管理，不能据此保证横幅或通知中心投递，需实机确认。
- 正在收发时请求阻止系统自动空闲休眠，不要求屏幕常亮，也不阻止用户主动睡眠或合盖。关闭应用即退出；未实现托盘常驻或跨进程续传。

首次运行可能出现 Windows 防火墙接入提示。只为测试使用的可信局域网允许 Dukto2；保持防火墙开启。自动发现失败时先用手动连接区分 TCP 与 UDP 问题，不能通过忽略证书或关闭防火墙绕过。

## SSH 与验收

同一局域网可使用 Windows OpenSSH Server 传送源码、编译、查看日志、运行核心测试并核对文件。采用公钥登录，不通过聊天发送密码。图形应用需在已登录的交互桌面启动；SSH 会话不能替代真实桌面验收。

后续补测（不重复声称已覆盖）：

1. Windows x64 编译与首次启动，确认名称、身份码、中文路径与系统目录。
2. Windows ↔ macOS、Android 文件与文本互传，逐字节 / SHA-256 核对；身份码在接收端实际查看。
3. 自动发现、手动连接、接收目录记忆、资源管理器定位及完成提醒。
4. 大文件、取消、中断与休眠请求释放；重启后临时文件清理。

参考：[Flutter Windows 构建环境](https://docs.flutter.dev/platform-integration/windows/setup)、[Flutter Windows 打包](https://docs.flutter.dev/platform-integration/windows/building)、[Microsoft OpenSSH Server](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)、[资源管理器定位](https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shopenfolderandselectitems)、[系统休眠请求](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setthreadexecutionstate)。
