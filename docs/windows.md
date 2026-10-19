# Windows

[English](en/windows.md) | 简体中文

已验证 Windows 11 x64；Windows 10、ARM64 和 32 位 Windows 尚未实测。实际构建与互传范围见 [验证范围](validation.md)。

## 构建

安装 Flutter 3.47.7 stable / Dart 3.13.5、Git、Visual Studio「使用 C++ 的桌面开发」工作负载及 Windows SDK。Visual Studio Code 不提供此工具链，先运行 `flutter doctor -v` 检查。

在工程根目录的 PowerShell 执行：

```powershell
./tool/windows.ps1
# 仅调试构建，跳过测试：
./tool/windows.ps1 -Mode debug -SkipTests
```

脚本不修改系统执行策略。也可手动执行：

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

运行 `build/windows/x64/runner/Release/Dukto2.exe`。分发必须包含完整 Release 目录的 DLL、data 和许可文件。脚本输出 `artifacts/windows/Dukto2-windows-x64-release.zip` 及 SHA-256，不提供签名安装器。新构建使用工具链的可再分发 Release DLL 做应用本地部署，打包检查三项必要运行库；无需用户另装开发环境。现有 rc.2 仍按 [安装说明](install.md) 补装官方运行库。详见 [发行说明](release-ci.md)。

## 系统行为

- 使用系统计算机名称；默认接收至系统下载目录下的 Dukto2，支持重定向下载目录、自选目录、记忆和恢复默认。
- 打开目录在资源管理器中定位文件；目录不可用时明确报错，不改存其他位置。
- 完成提醒使用 Windows 通知区域 API，实际显示受系统设置影响。
- 收发时请求防止空闲休眠；不阻止主动睡眠或合盖，没有托盘常驻和进程死亡续传。
- TCP 默认 45879，UDP 发现 45878。首次运行按系统提示允许可信局域网接入；自动发现不可用时可手动连接，仍需核对身份码。

参考：[Flutter Windows 环境](https://docs.flutter.dev/platform-integration/windows/setup)、[Windows 分发](https://docs.flutter.dev/platform-integration/windows/building)。
