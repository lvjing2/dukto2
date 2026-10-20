# Linux 通用安装包（候选）

[English](en/linux-portable.md) | 简体中文

通用打包采用 Flatpak 和 AppImage，覆盖原生 x86_64 与 ARM64。它们目前是独立 CI 的候选产物，不会自动发布到 Release 或 Flathub，也不改变现有 tar.gz 的构建流程。

## 选择安装方式

| 格式 | 用途 | 前提 |
| --- | --- | --- |
| Flatpak | 常规桌面安装，统一运行库与文件授权 | 发行版支持 Flatpak，首次安装可下载 Flathub 的 GNOME 49 运行时 |
| AppImage | 便携运行，免系统级安装 | 64 位 Linux，glibc 至少 2.35，兼容的桌面、图形驱动及系统服务 |
| tar.gz | 手动部署、排障 | 自行满足 GTK3 和构建对应的系统依赖 |

Flatpak 带来独立运行时，但不能消除内核、驱动、桌面 Portal 和网络策略的差异。AppImage 不捆绑替换系统 glibc；Ubuntu 22.04 构建基线也不等于已验证所有旧发行版。不支持 32 位系统、musl 环境或无法满足所需运行时的旧系统。

## 构建与校验

在对应架构的 Ubuntu 22.04 上安装现有 Linux 构建依赖，以及 `binutils patchelf file squashfs-tools desktop-file-utils appstream flatpak`。使用仓库锁定的 Flutter SDK：

```sh
./tool/linux.sh
# ARM64 主机请改为 arm64；不通过 x64 模拟打 ARM64 标签。
python3 tool/ci/package_linux_portable.py appimage --arch x64 --bundle build/linux/x64/release/bundle
python3 tool/ci/package_linux_portable.py flatpak --arch x64 --bundle build/linux/x64/release/bundle
(cd dist && sha256sum --check *.sha256)
```

`.github/workflows/linux-portable.yml` 在 Ubuntu 22.04 容器内原生构建两种架构。打包前检查完整 Flutter bundle、ELF 架构和所有 ELF 的 GLIBC 符号需求；AppImage 补入的依赖再次检查。超过 GLIBC 2.35 会失败，不用放宽检查冒充兼容。外部打包工具来自官方发布，并在执行前核验固定 SHA-256；上游连续发布变化时需审查并更新 `linux/packaging/portable/toolchain.json`。

每个包同时输出 `.sha256` 与 `.json`，记录源提交、版本、架构、构建基线、依赖检查及 Flatpak 权限。流水线保留 14 天的私有构建附件，不创建版本、标签、商店条目或公开下载。

CI 另检查 Xvfb 下的可见窗口与进程存活；Flatpak 在宿主测试机按默认沙箱安装、启动。窗口启动只能说明该 CI 环境可启动，不能替代文件授权和真实局域网互传验收。

## 安装候选包

包名中的版本和架构以实际附件为准：

```sh
# 首次使用 Flatpak 时添加运行时来源；这不是把 Dukto2 发布到 Flathub。
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user ./Dukto2-版本-linux-x64.flatpak
flatpak run dev.dukto2.dukto2

# AppImage
chmod +x ./Dukto2-版本-linux-x64.AppImage
./Dukto2-版本-linux-x64.AppImage
# 无 FUSE 时可尝试提取后运行：
./Dukto2-版本-linux-x64.AppImage --appimage-extract-and-run
```

Flatpak 更新同一个候选应用可重新安装新版包；离线包不会自动获得商店更新。卸载可用 `flatpak uninstall --user dev.dukto2.dukto2`；不加 `--delete-data` 可保留应用设置。

## 权限与网络

Flatpak 允许网络、图形显示和 `下载/Dukto2` 接收目录。其他收发文件与目录通过桌面文件选择 Portal 授权；不授予整个主目录、全部设备或整个会话总线。设置保存在 Flatpak 应用私有目录，与普通版可能独立；首次迁移应重新选择接收目录。

使用 UDP 45878 发现与默认 TCP 45879 连接。主机防火墙仍需允许通信，扫码也需要两端 IP 可互通。不同子网不保证自动发现；支持 Flatpak 不会改变路由、AP 隔离或 VPN 策略。

发布前仍需在 Ubuntu 22.04 / 24.04、Debian、Fedora，以及目标 Mint、deepin / UOS 版本上记录实际安装结果，覆盖 GNOME / KDE、Wayland / X11、发送与接收的文件授权、默认和自选目录、通知、防休眠，以及大文件双向传输。ARM64 还需真实硬件测试。当前通用包测试结果以对应 CI 记录为准，不能把计划矩阵写为已支持清单。
