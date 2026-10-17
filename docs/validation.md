# 验证记录

日期：2026-10-18（Asia/Shanghai）。所有结果来自本次实际执行。

## 构建与自动检查

- Flutter **3.47.7 stable** / Dart **3.13.5**，Xcode **27.1 (27A9275)**，Java **21**。
- macOS Apple Silicon 图形应用构建并启动成功，产物为 arm64 调试版。
- Android 调试 APK 构建成功，已安装到连接的 Android 16 / arm64 真机。
- `tool/check.sh` 通过：Dart 静态检查无问题；15 项真实 TLS/UDP 核心测试全部通过；手机与桌面尺寸的 Flutter 界面测试通过。
- 核心测试覆盖空文件、小文件、3 MiB 二进制、Unicode 名称、同名不覆盖、拒收、错误证书、非法路径与大小、错误摘要、并发拒绝、取消清理、无本地路径的流、重启清理与 UDP 发现。

## 真机局域网传输

电脑与手机通过真实 Wi-Fi IPv4 连接。USB 仅用于安装、模拟点击、采集界面与独立读取结果，**文件传输本身通过两端应用的 HTTPS 服务完成，没有使用 adb 网络转发**。

| 链路 | 结果 | 字节数 | SHA-256 |
| --- | --- | ---: | --- |
| Android 系统文件选择器 → Mac CLI | 成功，Mac 实际文件再次校验一致 | 1,048,599 | `84bec5e53235079aca8403efb6057e4b089d692a8615eebd0f8b8602f44a00c8` |
| Mac CLI → Android，接收并导出到下载目录 | 成功，导出文件用手机 sha256sum 再次校验一致 | 1,048,599 | `6c055eabb08b2146c4cfd544bb46aeb0d3e62a0250b2876bfd7a0e1e1556d80e` |
| macOS 图形版系统文件选择器 → Android | 成功，手机接收确认、Mac 显示对方校验通过 | 1,048,599 | `6c055eabb08b2146c4cfd544bb46aeb0d3e62a0250b2876bfd7a0e1e1556d80e` |
| Android 系统文件选择器 → macOS 图形版 | 成功，Mac 接收确认与落盘文件独立校验一致 | 1,048,599 | `84bec5e53235079aca8403efb6057e4b089d692a8615eebd0f8b8602f44a00c8` |

发送前分别核对了接收设备本机界面展示的证书码。Mac/Android 图形应用均走人工接收确认；CLI 受控测试采用显式 `--auto-accept`。临时 CLI 接收服务已关闭。

## 发现结果与实际限制

两端均有 VPN 虚拟网卡。初版默认路由发现不稳定，已修改为逐个 IPv4 接口发送组播，并保留广播及手动连接。修改后 **Mac 可以自动发现 Android**；当前手机 VPN 环境下自动发现 Mac 仍不稳定，验收通过手动 IPv4 地址连接完成。这一限制不能描述为双向自动发现已全面解决。

尚未验证：关闭 VPN 后所有网络/路由器组合、跨品牌 Android、Intel Mac、超过 1 GB 文件、长时间后台运行。未实现的功能见 README；当前交付为开发调试构建。

## 本机产物

- `artifacts/Lanbeam-macos-debug.zip`：可解压运行的 macOS Apple Silicon 图形应用。
- `artifacts/lanbeam-android-debug.apk`：已安装验证的 Android 调试包。
- `artifacts/lanbeam-macos-arm64-cli`：独立命令行收发工具。
- `artifacts/fixtures.json` 及测试文件、接收副本：独立校验依据。

构建产物和测试文件被 `.gitignore` 排除，源代码与依赖锁文件属于独立 Git 仓库。开发工具链位于项目外相邻的 `.toolchains` 目录。


## dukto2 冻结基线（2026-10-18，改名和 UI 落地后）

项目从 Lanbeam 更名为 `dukto2`，源码目录、Dart 包、原生应用标识和发现标识已同步调整。原 Lanbeam 实现、旧安装包和上文历史记录保留；本节只记录最终 `dev.dukto2.dukto2` 构建的验证结果。

- 已应用确认的蓝色极简 UI：Mac 双栏、手机单列、深浅色、独立选文件 / 发送、前台接收确认、超时和返回 / Esc 拒收。
- 使用系统设备名称；真机本机信息显示 `REDMI K90`，Mac 发现 / 连接 / 接收提示使用此名称。Mac 从系统电脑名称读取，不再按主机名规则猜测。
- README 与“关于 dukto2”页面已加入 Emanuele Colombo、xuzhen / 社区致谢及 AI 创作说明。尚未声称官方继任授权，开源许可证待正式发布前确定。
- `tool/check.sh` 全通过：静态检查无问题，9 项 Flutter / 平台桥测试及 15 项真实 TLS / UDP 核心测试通过。
- macOS 图形应用、Android APK、独立 Mac CLI 均构建成功；真机已安装新应用。

| 最终包实际链路 | 字节数 | 独立 SHA-256 结果 |
| --- | ---: | --- |
| Android 系统选择器 → Mac 图形应用，Mac 确认接收后实际落盘 | 1,048,599 | `84bec5e53235079aca8403efb6057e4b089d692a8615eebd0f8b8602f44a00c8`，一致 |
| Mac 系统选择器 → Android，手机确认接收并经系统保存界面导出 | 4,194,321 | `49fadda230debf70e38afe1975fe45b2be5b40e637b2d429fc0055200d26a1bb`，手机 sha256sum 与源文件一致 |

传输走真实 Wi-Fi HTTPS，USB 只用于安装、选择专用测试文件、读取结果和截图，没有使用 adb 转发代替局域网。

### 本轮限制与网络现象

当前 VPN / Wi-Fi 环境下发现不稳定。旧名称构建曾在 Mac 发现 Android；最终改名后的双向验收均使用手动 IPv4 地址。一次 Mac → 手机连接因 ARP / TCP 不可达超时；反向探测后邻居解析恢复，重试成功。不能将这些结果描述为最终包双向自动发现已验证成功。

尚未验证 >1 GB、老系统 / 低内存设备、Intel Mac、Android 32 位 CPU、长时间后台和应用重启续传。当前核心没有断点续传，重启会清理未完成临时文件。

### 最终产物与恢复

`artifacts/dukto2-android-debug.apk`、`artifacts/dukto2-macos-debug.zip`、`artifacts/dukto2-macos-arm64-cli` 为本轮最终调试构建。`dukto2-toolchain.json`、`dukto2-apk-info.txt`、`dukto2-artifacts-manifest.json`、日志、截图、测试文件和接收副本均保留在同目录；该目录不进入源代码提交。

Android 产物按 `android-arm64` 构建，已在 Android 16 / arm64 运行；aapt 列出的其他 ABI 可能来自原生依赖，不能据此认定 Flutter 引擎的所有架构均已打包或验证。macOS 最低部署目标为 12.0，本轮只验证 Apple Silicon。具体包内容见基线记录。

按用户指令暂停新增功能和 UI 扩展。接下来只比较现有核心与 LocalSend，不实施迁移。
