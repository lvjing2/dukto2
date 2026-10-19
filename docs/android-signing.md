# Android 双渠道签名

[English](en/android-signing.md) | 简体中文

Google Play 使用上传密钥签名的 AAB；GitHub 使用应用签名密钥签名的通用 APK。**首次启用 Play App Signing 必须导入本项目已有的应用签名密钥，不要选择让 Google 另生成一个密钥。** 这是两个渠道保留相同安装身份的前提。[Android 官方说明](https://developer.android.com/studio/publish/app-signing)、[跨商店签名 FAQ](https://developer.android.com/guide/app-bundle/faq)。

## 已准备的材料

- 包名：`dev.dukto2.dukto2`。首次注册 Play 应用时确认可用；签名证书本身不占用包名。
- 两套独立 RSA-4096 密钥：应用签名和上传，证书有效期 10,000 天。
- 仓库只保存 [应用公钥证书](../certificates/android/app-signing.pem)、[上传公钥证书](../certificates/android/upload-signing.pem) 和 [证书指纹](../tool/ci/android-signing.json)，不含私钥或密码。
- 两套私钥分别存入 GitHub Secrets；Gradle 仅接收当前构建角色的密钥参数，构建完清理临时文件。

| 用途 | SHA-256 证书指纹（忽略大小写和冒号） |
| --- | --- |
| Play 应用签名 / GitHub APK | `4f0c7dab4b81912270656b3e7c0c5cdcd11702fb2b16eca6b6b89f4aad207823` |
| Play AAB 上传 | `c2576e3d890f4a0c08dfcf03bae7540c77de120f2704bdf5bcc8e4f8eb2aab28` |

Secrets 为 `ANDROID_APP_` 与 `ANDROID_UPLOAD_` 两组，各包含 `KEYSTORE_BASE64`、`STORE_PASSWORD`、`KEY_ALIAS`、`KEY_PASSWORD`。缺少任一项会失败，不回退到 debug key 或未签名发布。

## 本机原件与备份

私有材料位于本机 `~/Library/Application Support/Dukto2/AndroidSigning/`，仅当前用户可访问。两个 PKCS#12 文件各自用随机密码保护；密码和备份解密密码保存在 macOS 登录钥匙串，项目为 **Dukto2 Android release signing**，service 为 `dev.dukto2.android.release`、account 为 `lvjing2`。通过「钥匙串访问」解锁查看，值为包含 `app`、`upload` 和 `backupPassword` 的 JSON，不要复制到 Issue、聊天或日志。

`~/Dukto2-Key-Backups/` 下保存 AES-256 加密的 DMG。创建后已只读解密回读，对比两套密钥与密码记录。它是**同一台 Mac 上的本地备份**，还需要维护者另拷至离线盘，并将解密密码单独保存在密码管理器；Mac 和登录钥匙串同时丢失时，不能只靠加密镜像恢复。不要在已有应用发布后重新生成密钥来“修复”构建问题。

## 首次配置 Google Play

1. 在 Play Console 创建 Dukto2，首次 AAB 的包名应为 `dev.dukto2.dukto2`。
2. 在 Play App Signing 设置中选择**使用/导入已有应用签名密钥**。按 Console 提供的命令下载 Google PEPK 工具和加密公钥，导出本机 `dukto2-app-signing.p12`（alias `dukto2-app`）的加密私钥包并上传。仅上传公开 PEM 证书不能代替导入私钥。
3. 上传密钥使用另一套 `dukto2-upload-signing.p12`（alias `dukto2-upload`）。需要登记上传证书时使用仓库中的 `upload-signing.pem`。
4. 对照 Console 的“应用签名证书”和“上传证书”SHA-256，分别与上表相同；不要把两者对调。
5. 首次人工上传 CI 的 `*-android-play.aab` 到测试轨道，完成 Play 要求的应用信息及发布配置，再做真实的 Play ↔ GitHub 安装升级验收。

本轮只准备密钥和 CI，尚未创建 Play 应用、执行 PEPK 导入或配置 Play 自动上传账号。`playAppSigningKeyImportRequired: true` 会保留在构建报告里，直到实际完成该配置。

## CI 验证与版本规则

Actions → Release builds → Run workflow → platform 选择 `android`，只验证 Android；`all` 或版本标签仍构建五个平台。签名仅接受 `main` 或匹配版本的 `v*` 标签。

CI 生成三个可下载文件：直接安装的通用 `.apk`、供 Play 上传的 `.aab`、包含许可/公开证书/报告的 notices zip，并附各文件 SHA-256。通用 APK 支持 ARMv7、ARM64、x86_64，不再使用 Flutter 分 ABI APK 的版本号偏移。

两种包统一使用 `pubspec.yaml` 的版本名和 `+` 后的构建号。例如 `0.1.6+7` 对应两端 versionCode **7**，下次发布统一增加为 **8** 或更大值；不要在两个渠道各自维护版本号。同版本通常不会触发 Play 的自动更新提示，目标是后续更高版本可从任一渠道覆盖升级。[Android 版本规则](https://developer.android.com/studio/publish/versioning)。

验证包含 APK 签名、AAB JAR 签名与结构，以及包名/版本/证书固定值检查；还用校验过摘要的 Google bundletool，从 AAB 派生应用密钥签名的通用 APK，比对它与 GitHub APK 的更新身份。错用 debug key、错用上传密钥签 APK、分 ABI 版本偏移或篡改签名后的文件都会阻止打包。报告不含密钥路径、私钥或密码。

本地派生校验不能代替 Play 完成密钥导入后的真实验收。以后若更换或升级 Play 应用签名密钥，要同步规划 GitHub 签名与证书轮换。现有调试版使用另一套签名，不能直接当成正式双渠道包的覆盖升级基线；不要为测试自动卸载或删除用户数据。
