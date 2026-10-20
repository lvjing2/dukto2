# 多系统 Release CI

[English](en/release-ci.md) | 简体中文

工作流：[Release builds](https://github.com/lvjing2/dukto2/actions/workflows/release.yml)，配置位于 [release.yml](../.github/workflows/release.yml)。产物下载遵循仓库访问权限。

## 触发与下载

- Actions → Release builds → Run workflow：可选 all 或单个平台，上传 Actions artifacts，不自动创建版本或标签；Android 签名仅支持 main 或版本标签。
- 推送匹配 `pubspec.yaml` 的 `v*` 标签：全部构建成功后创建 **Draft Release**；不会自动转为正式发布。已有正式 Release 不会被覆盖。
- 标签必须是 `v0.1.6` 或包含构建号的 `v0.1.6+7` 这种与当前源码版本一致的形式；不匹配会在构建前失败。

每个平台上传独立 artifact，默认保留 30 天；解压后得到版本化压缩包或 APK / AAB、SHA-256 sidecar 和 JSON 构建元数据。Actions artifact 有保留期限，草稿 Release 中的附件另行保存。当前不创建商店版本、安装器或自动更新服务；Android 签名及 Play 首次配置见 [双渠道签名说明](android-signing.md)。

GitHub Release 面向用户只附七个文件：Android APK、Windows x64 / ARM64 zip、Linux x64 / ARM64 tar.gz、macOS 通用 zip、iOS unsigned zip。Android APK 保持原始字节和签名，应用许可已在 APK 内；其他压缩包内附 `RELEASE-INFO.json` 和 `SHA256SUMS.txt`，原始文件、权限和链接保留。iOS 仍需自行签名后使用。Play AAB、独立 JSON、外置校验文件及许可包保留在 CI artifact；推广素材保留在仓库与本机。CI 重跑已有草稿时保留人工整理的 Release Note。

```sh
gh workflow run release.yml --repo lvjing2/dukto2 --ref main
gh run list --repo lvjing2/dukto2 --workflow release.yml
gh run download <run-id> --repo lvjing2/dukto2 --dir ./release-downloads
# 在对应文件目录中检查：
sha256sum --check *.sha256
```

## 平台与签名边界

| 平台 | Runner | 产物 | 当前签名与用途 |
| --- | --- | --- | --- |
| Linux | Ubuntu 24.04 x64 / ARM64 | 完整 bundle tar.gz | 未签名；附运行库检查，其他发行版仍需实测 |
| Windows | Windows 2025 x64 / Windows 11 ARM64 | 完整 Release zip | 未签名；保留 DLL、data，不能只拷贝 exe |
| macOS | macOS 26 arm64 | 含 app 的 zip | ad-hoc 临时签名，未公证；实际二进制架构写入 JSON，不推定 Intel 通过 |
| Android | Ubuntu + Java 21 | 已签名通用 APK、Play AAB、许可 zip | APK 用应用密钥，AAB 用上传密钥；Play 首次须导入应用密钥 |
| iPhone / iPad | macOS 26 | 无签名 device app 的 zip | 同一个 iOS app 覆盖两类设备，不是可直接安装的 IPA，也不是 TestFlight 包 |

Windows 压缩包附带对应架构的工具链 Release Visual C++ 运行库，采用应用本地部署。打包前检查主程序、Flutter 引擎、插件及运行库二进制架构。Linux 仍依赖目标系统的 GTK3 / glibc；原生依赖由构建日志中的 `ldd` 记录。

Android CI 已接入两套 GitHub Secrets，并验证 APK/AAB 签名、统一包名和版本号，以及从 AAB 派生的应用密钥签名 APK；详见 [双渠道签名](android-signing.md)。本地未配置签名参数时仍使用开发用 debug key。Apple 端继续复核 ad-hoc / unsigned 状态，正式 Apple 签名另行配置，不将私钥放入仓库。

## 检查与追溯

先在 Linux 执行完整分析、Dart / Flutter / Python 测试及格式检查，再并行原生构建；Windows、macOS 额外执行对应宿主测试。任一平台失败不阻止其他平台给出结果，但会阻止草稿 Release 汇总。编译通过不代表真机 UI、系统权限、后台行为或局域网互传通过。

Flutter 固定为 3.47.7；各系统下载地址与官方 SHA-256 在 [flutter-sdk.json](../tool/ci/flutter-sdk.json)。官方 SDK 校验通过后才解压，Actions 依赖固定提交。原生产物附带 LICENSE、第三方说明和 Flutter 通知资源。元数据包含版本、Git 提交、平台、Runner 架构、Flutter 版本与签名状态；摘要用于检查下载完整性，不代表代码审计或可重现构建证明。

只有草稿汇总 job 获得 `contents: write`，构建 job 为只读；Android 签名材料仅由对应构建步骤从 Secrets 恢复到临时目录并清理，不改变仓库可见性。标签创建与正式发布由维护者安排，手动验收前不要把自动产物称为已通过跨平台互传测试。

流程仅手动或标签触发，设有超时和产物保留期限，不对每次代码推送重复启动五个平台。

ARM64 构建使用原生 `windows-11-arm` 和 `ubuntu-24.04-arm` Runner。Flutter 3.47.7 未发布这两种宿主的 ARM64 SDK 整包，因此从官方版本标签检出源码，核对 `flutter-sdk.json` 固定的完整提交，再启动原生 Dart；二进制头检查会拒绝退回 x64。ARM64 产物仍需真机验收。
