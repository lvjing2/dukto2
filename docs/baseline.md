# dukto2 可恢复基线

日期：2026-10-18。项目此前称 Lanbeam；本基线已完成更名、批准的 UI 和系统设备名称读取。根据用户安排，暂停新增功能与 UI 扩展，后续迁移须先给出对比结论。

## 已保存内容

- 独立 Git 仓库中的完整源代码、Flutter / 核心包的依赖锁、Android 与 macOS 平台工程、测试和文档；不重置或丢弃用户修改。
- `artifacts/dukto2-android-debug.apk`：最终 Android 开发签名包。
- `artifacts/dukto2-macos-debug.zip`：最终 macOS 图形应用。
- `artifacts/dukto2-macos-arm64-cli`：同一核心编译的独立命令行工具。
- `artifacts/dukto2-toolchain.json`：实际 Flutter / Dart / 引擎版本。
- `artifacts/dukto2-apk-info.txt`、`dukto2-artifacts-manifest.json`：包信息、产物大小和 SHA-256。
- `artifacts/dukto2-fixtures.json`、发送文件、实际接收副本、日志和截图：本轮验收证据。
- 原 Lanbeam 构建产物和历史验证记录保留在本地，原 Dukto 参考仓库保持独立。

二进制、身份私钥、接收文件、工具链与设备操作日志不进入源码 Git 提交。工具链留在项目外相邻的 `.toolchains/`，不会随源码打包。

## 工具链与包范围

| 项目 | 本次实际值 |
| --- | --- |
| Flutter / Dart | 3.47.7 stable / 3.13.5 |
| Flutter revision | abaf9c523780a608bd46686fd5e53740a07077f8 |
| Xcode | 27.1 (27A9275) |
| JDK / Gradle | Java 21 / Gradle 9.3.1 |
| Android | compile / target API 36，min API 24，NDK 28.2.13676358 |
| macOS | 工程最低部署目标 12.0；本轮 arm64 图形包与 CLI |
| 已验证设备 | Apple Silicon Mac、Android 16 / arm64 真机 |

当前 APK 的 Flutter 引擎只包含 `lib/arm64-v8a/libflutter.so`。aapt 的 ABI 列表还列出 armeabi-v7a / x86_64，但这来自其他原生依赖，不能当作这些 CPU 可运行的证据。

## 已执行验收

静态检查无问题；9 项 Flutter / 平台桥测试和 15 项 TLS / UDP 核心测试全部通过。最终 `dukto2` 图形应用通过 Wi-Fi 双向传输：Android → Mac 为 1,048,599 字节，Mac → Android 为 4,194,321 字节。接收端文件独立计算的 SHA-256 均与源文件一致，详见 [验证记录](validation.md)。

Android 真机验收已结束，可退出应用并断开 USB。没有挂起的收发请求。

## 已知限制

当前 VPN / Wi-Fi 环境下自动发现不稳定，最终包验收使用手动 IPv4。尚未验证 >1 GB、老设备、Intel Mac、ARM32 Android 和长时间后台。没有断点续传；重启清理临时文件；Android 接收后另存会额外占用一份文件空间。原 Dukto 协议尚不兼容。调试包尚未做正式发布签名，dukto2 的开源许可证尚待确定。

## 恢复方式

源码基线使用 Git 提交与 `baseline-2026-10-18` 标签保存。`artifacts/dukto2-baseline.bundle` 是包含该提交的 Git 备份，可用 `git clone` 恢复到新目录；`dukto2-baseline-source.tar.gz` 是对应的纯源码快照。产物清单中的摘要用于确认本地安装包与归档一致。

工具链在当前机器仍可通过 `tool/flutterw` / `tool/dartw` 使用；其他机器需要安装匹配版本的 Flutter、Xcode / Android SDK，再执行 `tool/check.sh` 与平台构建。不要在原目录执行重置以恢复副本。


## 后续状态

本页描述 0.1.0 历史基线。用户随后已授权保留 dukto2，研究 LocalSend 后继续实现自动发现、Android 后台与直接保存。0.1.1 的实现和分层验收见 [可靠性改进](reliability.md)；本页标签与旧安装包继续保留。
