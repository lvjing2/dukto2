# 国内社区发布安排

状态：仅准备；仓库 private，Release Draft，不创建公开下载，不发帖。当前版本 0.1.6-rc.3+10；新安装修复已通过 Windows / Linux 原生 CI，仍需干净环境复验，不能使用旧包冒充修复版。

## 顺序与素材

| 顺序 | 平台 | 内容 | 草稿 | 发布前条件 |
| --- | --- | --- | --- | --- |
| 1 | V2EX | 简短介绍，收集安装与发现反馈 | [V2EX](platforms/v2ex.md) | 可用下载；核对节点 |
| 1 | 酷安 | Android 安装、跨设备与后台体验 | [酷安](platforms/coolapk.md) | 真机正式 APK 安装/更新复验 |
| 2 | 掘金 | Flutter 架构、文件流与平台适配 | [掘金](platforms/juejin.md) | 技术内容与当前实现一致 |
| 2 | 知乎 | 做这个工具的原因与真实限制 | [知乎](platforms/zhihu.md) | 补入真实反馈后发布 |
| 3 | 少数派 | 一套实际跨设备使用流程与图片 | [少数派](platforms/sspai.md) | 独立体验稿；补新包截图 |

这是拟定顺序，不表示已取得平台推荐或审核通过。各平台使用不同文稿，不机械重复粘贴。所有稿件保留 AI 创作说明与 Dukto 致谢，不称为官方继任。

## 安装验收

| 系统 | 目前准备 | 对外试用前还需要 |
| --- | --- | --- |
| Android | 正式签名 APK，已有签名一致性校验 | 真机文件管理器安装；同签名更高 versionCode 覆盖且保留数据 |
| Windows | 原生 CI 通过；随包附带 Release CRT，下载包内容与 x64 架构已核对 | 没有开发环境的 Windows 11 启动与互传 |
| macOS | 完整 app、来源提示操作说明 | 从浏览器下载后的安装与首次启动；无 Developer ID 公证，不能承诺无提示 |
| Linux | 原生 CI 与动态库检查通过；完整 bundle、依赖检查与应用菜单入口 | Ubuntu 24.04 桌面按包内 install.sh 安装、启动、更新 |
| iOS/iPadOS | 未签名开发构建 | 无付费 Apple 会员，公众分发暂缓 |

[用户安装指引](../../docs/install.md)；[原有真机范围](../../docs/validation.md)。保留当前不可变候选包，新代码的修复不倒写到历史验证记录。

本轮构建源码为 `8bf258a8d6f625967f87660d9e4fb4fadbc2a054`，不是旧标签 `v0.1.6-rc.2` 的历史二进制。本机 `tool/check.sh` 通过（含 18 项 Python 工具测试与 App / core 分析和测试）；[Windows 产物](https://github.com/lvjing2/dukto2/actions/runs/39218405754)、[Linux 产物](https://github.com/lvjing2/dukto2/actions/runs/39218470040) 均在私有 CI 中保留。仅构建与包内容核验，不代表已在用户设备重新安装；用户选择稍后连接设备验收。

## 公开前最后一步

维护者决定公开下载渠道、安装复验完成后，填写各草稿中的下载入口并确认最终包名。先小范围收集反馈，再扩展平台。现阶段不向应用商店提交，也不改变仓库可见性。

## 核对过的平台资料（2026-10-19）

- [V2EX 节点说明](https://www.v2ex.com/help/node)：按内容选合适节点；营销内容有推广节点，不把节点选择当成平台推荐。
- [少数派创作手册](https://manual.sspai.com/guides/quickstart/) 与 [提交及审阅](https://manual.sspai.com/guides/review-procedure/)：深度投稿原则上要求首发，AI 辅助创作须披露。已发其他平台的通稿不作为相同内容的首发投稿。
- [酷安](https://www.coolapk.com/)：当前官网以 App 为入口；未验证开发者上架权限，本轮先准备社区介绍，不承诺应用商店收录。
- 掘金、知乎账号权限与编辑入口尚未在登录态核验，发帖前再检查，不预填认证身份。

rc.3 统一候选构建：[五平台 CI](https://github.com/lvjing2/dukto2/actions/runs/39398667423)，源码标签 `v0.1.6-rc.3`。先前安装测试结果不等于本次候选已完成干净环境或全部真机复验。
