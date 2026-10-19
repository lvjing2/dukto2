# Dukto2 应用图标

2026-10-19 接入蓝底白色飞机图标，纯色 #355DEB。SVG 母版位于 source/，所有平台 PNG 从矢量直接渲染，未使用带展示背景的概念图截图。

原生工程已经引用以下资源，后续构建自动使用：

- Android：android/app/src/main/res 内的传统启动图标和自适应前景/背景；API 33+ 提供单色主题层，Manifest 引用 ic_launcher / ic_launcher_round。
- macOS：macos/Runner/Assets.xcassets/AppIcon.appiconset，保留透明留白。
- iOS：ios/Runner/Assets.xcassets/AppIcon.appiconset，提供无 alpha 的满幅方形图标，交给系统裁形。
- Windows：windows/runner/resources/app_icon.ico，由现有 Runner.rc 编译到应用。

web/ 和 linux/ 是附加导出资源。网页工程尚未接入；Linux 工程已另行完成首轮原生构建和文件互传，但当前源码通过 `tool/install_linux_user.py` 注册品牌图标和桌面入口，新增注册流程仍需 Linux 桌面复验。

preview.png 是本版矢量预览，size-preview.png 是小尺寸对照。外部资源包 asset-manifest.json 记录的是原始导出包路径，不能当作工程构建清单。

启动图标和应用内左上角品牌标识使用同一套图形。Flutter 品牌图片位于 assets/branding/dukto2.png，直接复用本目录 web/icon-192.png，在 32 逻辑像素位置显示；操作按钮仍使用 Material 操作符号。纸飞机属于常见造型，这一版不作品牌唯一性或商标可用性承诺。

0.1.5+6 修正了先前仅更新启动图标、应用内品牌标识仍使用 Material 飞机符号的不一致。

本次 0.1.5+6 的 macOS Debug 构建、主界面和「关于」实机检查通过，打包后的品牌图片与源图 SHA-256 相同。两个分析器无问题，50 项应用 / 平台测试和 42 项核心测试通过。Flutter 3.47 的 InkSparkle 在软件测试渲染器中缺少 SkSL 阶段，组件测试使用 InkRipple 保留交互反馈，正式应用效果未更改。Windows、Linux 与移动端尚未重建这次应用内品牌标识修正。

## 本次构建验证

- `tool/check.sh` 执行成功，Flutter / 核心测试全部通过；静态分析保留一个现有 dashboard.dart 的 use_null_aware_elements 信息提示。
- macOS debug 构建成功；从成品 App 的 AppIcon.icns 提取图片确认是蓝底白飞机。
- Android debug 构建成功；APK 包含启动图标资源。未重新安装到用户设备。
- Windows / iOS 图标已接入现有资源引用，本次未在对应平台构建验收。
- 独立新产物：artifacts/Dukto2-0.1.4-new-icon-android-debug.apk 与 artifacts/Dukto2-0.1.4-new-icon-macos-debug.zip。应用版本仍为当前工程的 0.1.4+5，未代替发布流程递增。
