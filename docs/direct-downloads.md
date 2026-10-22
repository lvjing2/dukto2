# 无应用商店账号阶段的发行

[English](en/direct-downloads.md) | 简体中文

截至 2026-10-22。当前以 [GitHub Releases](https://github.com/lvjing2/dukto2/releases) 为预览版下载入口；应用商店账号、审核与正式 Apple 签名独立推进，不阻塞 Android 和桌面预览。源码保持公开并继续使用 Apache-2.0。构建脚本调整只影响下一次打包，不修改既有 Release 附件。

## 平台范围

| 平台 | 当前方式 | 限制与后续 |
| --- | --- | --- |
| Android | 使用固定应用密钥签名的通用 APK，用户通过系统安装器安装 | 不依赖 Play 商店安装；厂商可能要求单次来源许可或阻止安装。开发包签名不同不能覆盖。未来 Play 首次接入须延续同一应用签名身份，AAB 使用独立上传密钥。 |
| Windows x64 / ARM64 | 完整便携 ZIP，解压后运行 | 尚无发布者代码签名，可能被 SmartScreen 或组织策略阻止；不承诺无提示安装。后续补签名、安装器及商店渠道。 |
| Linux x64 / ARM64 | 完整 TAR.GZ 和用户级安装入口 | Ubuntu 24.04 为当前二进制基线；其他发行版依赖和 glibc 仍有限制。AppImage / Flatpak 不属于当前主线默认发布附件，不把其他分支的准备工作写成已发布能力。 |
| macOS | ad-hoc 签名 ZIP，仅面向了解限制的预览用户 | 未取得 Developer ID 签名和公证，可能被 Gatekeeper 阻止；按 [Apple 官方指引](https://support.apple.com/en-us/102445)处理，不关闭全局安全保护。大众分发待开发者账号、签名和公证完成。 |
| iPhone / iPad | 暂不提供普通用户安装包 | 未签名 device build 仅留 CI，不能当作 IPA 或 TestFlight。待 Apple 开发者签名和分发条件具备后接入；开发者自行 Xcode 测试另见 [iOS 文档](ios.md)。 |

Android APK 签名与 Play 上传签名的区别见 [官方说明](https://developer.android.com/studio/publish/app-signing)。Apple 账号与分发能力见 [开发者账号说明](https://developer.apple.com/help/account/basics/about-your-developer-account)。商店账号、发布者签名证书与操作系统允许打开应用是不同环节。

## 用户附件与校验

下次 Release 的默认用户附件为：Android APK、Windows x64 / ARM64 ZIP、Linux x64 / ARM64 TAR.GZ、macOS ZIP，以及 `INSTALL.md` 和 `SHA256SUMS.txt`。安装说明与 Release 正文共用英文 [发行说明模板](releases/DISTRIBUTION.md)，每次包含名称许可条件、独立维护及支持入口。未签名 iOS、Play AAB、详细元数据等保留在有期限的 Actions artifacts，不作为公众安装入口。

下载适合自己系统和架构的包，同时下载 `INSTALL.md`、`SHA256SUMS.txt`。macOS 用 `shasum -a 256 -c SHA256SUMS.txt`，Linux 用 `sha256sum -c SHA256SUMS.txt`；仅下载某个平台时其他文件会提示缺失，应核对所选包及安装说明均为 OK。Windows PowerShell 使用 `Get-FileHash .\实际包名 -Algorithm SHA256` 与清单对应项比较。摘要可发现损坏和内容变化，不等同于发布者认证。

详细安装操作见 [安装指引](install.md)。更新时先退出桌面应用，替换程序文件并保留用户数据；Android 延续包名和应用签名密钥，versionCode 单调增加，不要求用户为正常升级卸载应用。当前无自动更新。

## 发布前检查清单

1. 在公开源码中保留名称使用同意摘要、Apache-2.0 和第三方许可；原作者邮件全文及私人邮件头不进入公开仓库。支持与功能请求统一指向 Dukto2 Issues。
2. 确定待发提交；修改 `pubspec.yaml` 的项目版本与构建号，运行 `python3 tool/sync_project_version.py`。不重用或移动已发布标签，不覆盖历史附件。
3. 先运行 `tool/check.sh` 和 CI 格式检查，再手动触发所需平台构建。标签触发会创建草稿，不自动公开。只把本轮实际执行的检查写进英文 Release Note。
4. 按同一提交生成平台产物，校验 APK 固定签名、包名与 versionCode，验证所有附件及清单。普通用户下载列表不放未签名 iOS、AAB 或推广材料。
5. 从下载的最终包执行安装/升级检查、启动、两设备互传和取消/清理。安装升级时保留既有数据，记录系统版本、签名、架构与已知限制。跨渠道升级未实测就继续标注未验收。
6. 草稿逐平台标注已验证、待验证、未签名/未公证状态；候选版本标为 prerelease。维护者完成验收后再发布；不能将应用商店尚未接入写成商店已上线。
7. 保留版本标签、原始构建元数据、校验与验证记录。CI artifacts 有期限，发布附件与必要证据另行保存。出现问题新增修正版，不替换旧版本内容。

执行命令与签名边界见 [Release CI](release-ci.md)。本轮仅准备公开说明与打包流程，没有创建新版本标签、发布 Release 或提交商店审核。
