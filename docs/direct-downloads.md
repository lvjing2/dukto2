# 直接下载发行

[English](en/direct-downloads.md) | 简体中文

应用商店接入前，通过 [GitHub Releases](https://github.com/lvjing2/dukto2/releases) 提供预览下载。

| 平台 | 下载与限制 |
| --- | --- |
| Android | 已签名 APK；开发包签名不同不能直接覆盖。 |
| Windows x64 / ARM64 | 完整 ZIP；未做发布者签名，系统可能拦截。ARM64 需 Windows 11。 |
| Linux x64 / ARM64 | TAR.GZ；当前基线为 Ubuntu 24.04，其他发行版需验证依赖。 |
| macOS | ad-hoc 签名 ZIP，未公证；安装可能受 Gatekeeper 限制。 |
| iPhone / iPad | 暂无公众安装包；未签名构建仅留 CI，待 Apple 分发条件具备后接入。 |

后续 Release 附六个应用包、`INSTALL.md` 和 `SHA256SUMS.txt`；Play AAB 留 CI。具体安装与校验步骤见 [发行说明](releases/DISTRIBUTION.md)及 [安装指引](install.md)。当前手动更新，保留用户数据和 Android 应用签名身份。

发布前：更新版本和构建号，运行检查，构建同一提交的产物，并验证最终包的安装、升级、互传和取消。验收后公开草稿，候选版标为 prerelease；已发布标签和附件不覆盖。命令与签名配置见 [Release CI](release-ci.md)。
