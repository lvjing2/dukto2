# 多系统 Release CI

工作流：[Release builds](https://github.com/lvjing2/dukto2/actions/workflows/release.yml)，配置位于 [release.yml](../.github/workflows/release.yml)。仓库当前保持 Private，产物下载遵循仓库访问权限。

## 触发与下载

- Actions → Release builds → Run workflow：构建所选分支或标签，上传 Actions artifacts，不自动创建版本或标签。
- 推送匹配 `pubspec.yaml` 的 `v*` 标签：全部构建成功后创建 **Draft Release**；不会自动转为正式发布。已有正式 Release 不会被覆盖。
- 标签必须是 `v0.1.6` 或包含构建号的 `v0.1.6+7` 这种与当前源码版本一致的形式；不匹配会在构建前失败。

每个平台上传独立 artifact，默认保留 7 天；解压后得到版本化压缩包、SHA-256 sidecar 和 JSON 构建元数据。Actions artifact 有保留期限，草稿 Release 中的附件另行保存。当前不创建商店版本、安装器、自动更新服务或正式签名。

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
| Linux | Ubuntu 24.04 x64 | 完整 bundle tar.gz | 未签名；附运行库检查，其他发行版仍需实测 |
| Windows | Windows 2025 x64 | 完整 Release zip | 未签名；保留 DLL、data，不能只拷贝 exe |
| macOS | macOS 26 arm64 | 含 app 的 zip | ad-hoc 临时签名，未公证；实际二进制架构写入 JSON，不推定 Intel 通过 |
| Android | Ubuntu + Java 21 | 三 ABI APK 的 zip | 未签名 Release APK；签名后才能安装，非可直接上架的包 |
| iPhone / iPad | macOS 26 | 无签名 device app 的 zip | 同一个 iOS app 覆盖两类设备，不是可直接安装的 IPA，也不是 TestFlight 包 |

Android CI 设置 `DUKTO2_ANDROID_UNSIGNED=true`，不使用临时 debug key 假装正式签名。本地未设置该变量时保留已有 debug key 的开发构建行为。APK 打包时复核未签名状态；Apple 端复核 ad-hoc / unsigned 状态。后续接入 Android release key、Apple Developer ID、公证和 App Store / Ad Hoc 描述文件时，再使用 GitHub Secrets / Environments 配置，不将私钥放入仓库。

## 检查与追溯

先在 Linux 执行完整分析、Dart / Flutter / Python 测试及格式检查，再并行原生构建；Windows、macOS 额外执行对应宿主测试。任一平台失败不阻止其他平台给出结果，但会阻止草稿 Release 汇总。编译通过不代表真机 UI、系统权限、后台行为或局域网互传通过。

Flutter 固定为 3.47.7；各系统下载地址与官方 SHA-256 在 [flutter-sdk.json](../tool/ci/flutter-sdk.json)。官方 SDK 校验通过后才解压，Actions 依赖固定提交。原生产物附带 LICENSE、第三方说明和 Flutter 通知资源。元数据包含版本、Git 提交、平台、Runner 架构、Flutter 版本与签名状态；摘要用于检查下载完整性，不代表代码审计或可重现构建证明。

只有草稿汇总 job 获得 `contents: write`，构建 job 为只读；不读取个人签名配置，不改变仓库可见性。标签创建与正式发布由维护者安排，手动验收前不要把自动产物称为已通过跨平台互传测试。

仓库为私有时，GitHub 托管 Runner 使用账号 Actions 配额。流程仅手动或标签触发，设有超时和产物保留期限，不对每次代码推送重复启动五个平台。
