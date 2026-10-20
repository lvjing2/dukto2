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

## 扫码连接

点击连接区的「扫码连接」，可使用摄像头或「从图片识别」。图片支持 PNG、JPEG、BMP，文件最多 20 MiB、解码尺寸最多 1600 万像素。识别在本机执行，不上传图片。

有多个摄像头时可在列表中切换；Windows 相机插件目前把摄像头方向统一报告为前置，因此部分平板需要手动选择后置摄像头。控件支持触屏、横竖屏及大字体。Windows ARM64 平板的原生构建仍未验证。

若无法打开摄像头，请检查 Windows「设置 → 隐私和安全性 → 摄像头」中的设备及桌面应用访问权限；仍可从图片识别或手动连接。后台、切换摄像头和退出扫码页会释放摄像头。拍摄用于识码的临时照片在处理后删除，不加入传输记录；用户选择的图片不会删除。应用异常终止时，系统临时目录中可能留有尚未清理的照片。

扫码仍核对二维码内的完整证书指纹与设备 ID；传输接收确认独立执行。
