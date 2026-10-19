# Linux 接入（开发中）

首轮目标：Ubuntu 22.04 / 24.04 LTS x86_64 桌面版，与 Mac 位于同一局域网。2026-10-19 已在 Ubuntu 24.04.3 x64 完成原生 Release 编译和完整 bundle 打包，两个分析器、50 项应用测试与 42 项核心测试通过。用户已确认 Ubuntu 桌面启动成功，Mac 界面自动发现 Linux；双向 GUI 文件互传（1,048,607 字节）均通过独立落盘 SHA-256 校验。文本互传待验收；Ubuntu 22.04 与 ARM64 尚未实测，不能据此承诺兼容。

构建使用 Flutter 3.47.7、Dart 3.13.5、Clang 18.1.3、CMake 3.28.3、GTK 3.24.41、glibc 2.39。首轮原生编译发现并修复了 Linux 桥接中的 GTK 枚举参数类型问题；未修改共享代码。修复后仅重做原生构建，保留此前 92 项测试证据。重复 doctor 网络检查曾阻塞，最终构建明确使用 `--skip-tests --skip-doctor`；首次 Linux 工具链检查通过，Android SDK、Chrome 与 Maven 提示不属于本轮 Linux 桌面工具链要求。

## 已准备

0.1.6 本地回归：两个分析器、60 项应用测试、42 项核心测试与 2 项桌面安装脚本测试通过。这些检查在 Mac 执行，Linux 新版的原生构建和桌面验收仍待完成。

- 使用项目 Flutter 3.47.7 模板生成 GTK3 runner，窗口名 Dukto2，应用 ID `dev.dukto2.dukto2`，单实例窗口。
- Linux 原生 `dukto2/platform` 通道提供系统主机名、电脑设备类型、由桌面管理的完成通知、传输期间休眠抑制，以及通过 GIO 打开文件父目录。通知与休眠抑制都取决于桌面会话的服务，不保证所有桌面行为一致。
- `tool/linux.sh` 检查依赖、运行项目检查、原生 Release 构建、验证动态库并打包完整 bundle；记录日志、退出码和 SHA-256。不会安装系统软件或修改防火墙。
- 当前源码已将 Linux 接入共享桌面目录管理：默认「下载 / Dukto2」，支持选择与记忆、恢复默认、打开目录及传输期间休眠抑制。旧 0.1.4 包的系统文档目录 `Dukto2 Received` 是历史行为；源码接线与新增通知设置仍需使用新包完成桌面复验，不能用旧包互传结果代替。
- 自选接收目录不可用时提示重新选择，不自动改到其他位置。传输完成、失败、拒收、取消和退出时释放休眠抑制；允许正常锁屏。
- 应用内完成通知开关可直接使用；GNOME / Ubuntu 且安装 `gnome-control-center` 时显示「系统通知设置」，其他桌面隐藏该入口。系统通知服务和勿扰模式仍决定通知是否展示。

## 所需环境

建议 4 核 CPU、8 GB 内存、至少 20 GB 可用磁盘（开发建议，非应用最低要求）。需要普通登录用户、可联网下载依赖、桌面图形会话及 D-Bus；远程构建可通过已配置的 SSH 公钥登录。密码在本机终端输入，不发送到聊天。

原生 Linux 桌面或桥接网卡的 Linux 虚拟机均可。虚拟机 NAT、WSL2 NAT 可能影响入站连接和 UDP 自动发现；WSL2 可以先用于构建，但不能替代普通 Linux 桌面的局域网验收。仅有无桌面的服务器可编译，也可运行核心协议测试，不能据此宣称 GUI 通过。

Ubuntu 安装构建依赖：

```bash
sudo apt-get update
sudo apt-get install -y git curl xz-utils unzip zip clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

使用官方 Flutter 3.47.7 stable（Dart 3.13.5），CPU 架构与 SDK 匹配。将 Flutter 加入 PATH，或用 `FLUTTER_BIN=/绝对路径/flutter/bin/flutter`。不需要 Android SDK、Xcode、Visual Studio。

```bash
./tool/linux.sh --doctor-only
./tool/linux.sh
```

默认必须通过 `tool/check.sh` 才会构建；`--skip-tests` 仅供定位打包问题，使用时不能宣称本次运行执行过测试。已有近期工具链检查时可用 `--skip-doctor` 跳过重复网络资源探测，结果文件会记录跳过事实。构建脚本支持本机 x64 / arm64 路径，但 ARM64 尚未建立编译和运行验证基线。

产物为 `artifacts/linux/Dukto2-linux-x64.tar.gz`，日志保存在 `artifacts/linux/runs/`。需要分发整个目录，包括 `lib/`、`data/`、LICENSE、第三方声明和 licenses 目录，不能只复制可执行文件。目标机器依赖由脚本中的 `ldd` 记录；在较新发行版上构建不意味着可以在更旧发行版运行，兼容下限需在最低目标系统实测。

图形启动（在已登录的 Linux 桌面终端）：

```bash
./build/linux/x64/release/bundle/dukto2
```

桌面集成使用用户级注册脚本，在已解压的完整发行目录中执行：

```bash
python3 install_linux_user.py .
# 从源码构建目录注册时：
# python3 tool/install_linux_user.py build/linux/x64/release/bundle
```

脚本写入当前用户的 desktop 入口和品牌图标，不使用 sudo，不移动 bundle；移动或更新后重新注册。GNotification 依赖桌面服务与应用 ID 对应的已安装 desktop 文件。需要 Python 3；当前没有 deb / rpm / AppImage 安装包。

## 后续验收

1. 用新版桌面包复验共享控制器 Linux 分支：下载目录、选择与记住目录、目录不可用提示、历史记录打开目录、传输期间避免空闲休眠。
2. 重建当前 GTK/C++ 桥接，复验 file_picker/path_provider 插件、运行时依赖及中文目录。
3. 原生桌面检查设备名、通知、复制粘贴、文件选择和目录记忆。休眠抑制只防空闲休眠，不承诺合盖或用户主动休眠不中断。
4. 同一局域网 Linux ↔ Mac 文件与文本互传，实际屏幕核对身份码、接收确认，独立校验落盘 SHA-256；随后补 Android/Windows 对照。
5. 检查 UDP 45878 自动发现与 TCP 45879 传输。若防火墙拦截，只允许可信测试局域网的对应端口，保持 TLS 与指纹核对，不关闭防火墙。
6. 旧版真机截图已保存到 `docs/screenshots/linux-main.png`；新版再补单独应用窗口截图。

参考：[Flutter Linux 构建环境](https://docs.flutter.dev/platform-integration/linux/setup)、[Flutter Linux 分发](https://docs.flutter.dev/platform-integration/linux/building)。
