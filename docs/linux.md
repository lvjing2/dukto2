# Linux

[English](en/linux.md) | 简体中文

已验证 Ubuntu 24.04.3 x64 / GTK3。Ubuntu 22.04、其他发行版及 ARM64 尚未实测；较新发行版构建的包不保证可在旧系统运行。具体测试范围见 [验证范围](validation.md)。

## 构建

Ubuntu 构建依赖：

```sh
sudo apt-get update
sudo apt-get install -y git curl xz-utils unzip zip clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

安装 Flutter 3.47.7 stable / Dart 3.13.5，加入 PATH 或设置 `FLUTTER_BIN`。不需要 Android SDK、Xcode 或 Visual Studio。

```sh
./tool/linux.sh --doctor-only
./tool/linux.sh
```

脚本默认先运行 `tool/check.sh`，再原生构建、检查动态库并打包。`--skip-tests` 仅供定位构建问题；已检查工具链时可用 `--skip-doctor`。结果记录跳过项，跳过不能算作本次验证通过。

产物为 `artifacts/linux/Dukto2-linux-x64.tar.gz`，运行日志在 `artifacts/linux/runs/`。分发完整 bundle，包括 lib、data、许可证和第三方声明；不能只复制可执行文件。目标系统需要相应 GTK3 / glibc。

## 启动与桌面集成

在已登录的图形桌面启动：

```sh
./build/linux/x64/release/bundle/dukto2
# 从源码构建目录注册用户级桌面入口：
python3 tool/install_linux_user.py build/linux/x64/release/bundle
# 已解压发行包中：
bash install.sh
# 旧 rc.2 包：python3 install_linux_user.py .
```

注册脚本写入当前用户的 desktop 入口与图标，不需要 sudo，不移动 bundle。移动或更新后需重新注册。完成通知依赖桌面服务及对应应用 ID 的 desktop 文件，当前没有 deb、rpm 或 AppImage 安装包。

## 系统行为

- 默认接收至「下载 / Dukto2」，支持自选目录、重启记忆和恢复默认；目录失效时提示重新选择。旧位置文件与历史保留。
- 通过 GIO 打开文件父目录，使用桌面通知服务发送完成提醒。
- GNOME / Ubuntu 安装 `gnome-control-center` 时可打开系统通知设置；其他桌面按能力隐藏入口。
- 收发时请求防止空闲休眠，完成、失败、取消和退出后释放；不阻止主动睡眠、合盖或锁屏。
- 使用 UDP 45878 发现与默认 TCP 45879 传输。虚拟机 NAT / WSL2 可能影响入站连接，不能代替普通桌面的局域网验证。

参考：[Flutter Linux 环境](https://docs.flutter.dev/platform-integration/linux/setup)、[Linux 分发](https://docs.flutter.dev/platform-integration/linux/building)。
