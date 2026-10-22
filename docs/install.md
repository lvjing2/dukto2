# 安装 Dukto2

下载对应系统的一个附件即可。APK 可直接安装；桌面压缩包需要完整解压，不能只取出可执行文件。当前为开发预览，从 [GitHub Releases](https://github.com/lvjing2/dukto2/releases) 下载。无商店账号阶段的分发范围与校验方法见 [直接下载发行方案](direct-downloads.md)。

## Android

下载 `android.apk`，从文件管理器打开，按系统提示允许本次来源安装，再打开 Dukto2。无需安装 Google Play。

如果提示“与现有应用冲突”，可能安装过签名不同的 debug 版本。先保留接收文件和需要的记录，再自行决定是否卸载旧开发版；卸载会删除应用私有数据。不要为解决冲突更换正式签名。提示版本过低时使用更新版本，不能靠重新安装旧包降级。

首次发现设备时按提示允许局域网权限；扫码才需要相机权限。Android 7 是目标最低版本，目前真机记录集中于 Android 16。

## Windows

按处理器选择 Windows x64 或 ARM64 包（ARM64 需 Windows 11）：右键 ZIP →「全部解压」，将文件夹保留在固定位置，运行 `Dukto2.exe`。可右键为它创建快捷方式。更新前退出应用，把新版解压到独立目录，确认能运行后再移除旧程序目录；不要删除接收目录或应用设置。

新构建会附带 Visual C++ 运行库。现有 rc.2 如果提示缺少 `MSVCP140.dll` 或 `VCRUNTIME140*.dll`，安装微软官方 [Visual C++ x64 运行库](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)，不要从 DLL 下载站补文件。

当前未做发布者代码签名。核对下载来源后，可在 SmartScreen 提示中查看「更多信息」；组织策略禁止运行时联系管理员。不要关闭 Defender。首次防火墙提示仅为可信家庭/办公局域网允许应用访问。已实测 Windows 11 x64，Windows 10 尚未实测。

## macOS

需要 macOS 12 或更新系统。完整解压 ZIP，把 `Dukto2.app` 拖到「应用程序」，再打开。更新前退出旧版并替换应用，保留下载目录中的接收文件。

当前是 ad-hoc 签名，未公证。首次打开若提示开发者无法验证，先确认来源，再到「系统设置 → 隐私与安全性」找到 Dukto2 的「仍要打开」，按系统提示确认。若提示文件损坏，重新下载并核对校验信息，不使用关闭 Gatekeeper 或批量删除隔离属性的命令。参考 [Apple 官方说明](https://support.apple.com/102445)。Apple Silicon 已实测，Intel 尚未实测。

## Linux

当前二进制基线为 Ubuntu 24.04 x64 / ARM64（分别下载对应架构）；旧版 Ubuntu 和其他发行版不能保证兼容。

把 TAR.GZ 完整解压到长期保留的位置，在解压后的 `Dukto2-linux-x64` 或 `Dukto2-linux-arm64` 目录打开终端：

```sh
bash install.sh
```

新包的脚本会检查动态库并注册当前用户的应用菜单入口，无需 sudo，不移动程序文件。旧 rc.2 包使用 `python3 install_linux_user.py .`。如需补装 Ubuntu 24.04 运行依赖：

```sh
sudo apt install python3 libgtk-3-0t64 libstdc++6
```

也可直接运行 `./dukto2`。更新到新目录后重新运行注册脚本；删除程序前可移除 `~/.local/share/applications/dev.dukto2.dukto2.desktop`，接收文件不受影响。

## iPhone / iPad

`ios-device-unsigned.zip` 是未签名开发构建，不能直接安装。当前没有公众可用的 IPA、TestFlight 或 App Store 版本。开发者可参考 [iOS 工程说明](ios.md) 用自己的 Xcode 签名测试，公众试用先使用其他平台。

## 打开后找不到设备

两端保持 Dukto2 打开，连接允许设备互通的局域网；访客网络、子路由隔离、VPN 和系统防火墙可能影响发现。自动发现使用 UDP 45878，传输默认 TCP 45879。可用「手动连接」输入对方显示的地址并核对身份码。不要关闭整个系统防火墙。

反馈请附两端系统、版本、错误提示和操作步骤，发送到 leojames.googol@gmail.com。不要附带私人文件或密码。
