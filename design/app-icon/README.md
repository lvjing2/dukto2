# 应用图标

[English](README.en.md) | 简体中文

蓝底白色纸飞机，底色 `#355DEB`。SVG 母版位于 `source/`，平台 PNG 从矢量渲染；不使用概念图截图生成图标。

| 平台 | 工程资源 |
| --- | --- |
| Android | `android/app/src/main/res/` 的传统图标、自适应前景 / 背景及主题单色层 |
| macOS | `macos/Runner/Assets.xcassets/AppIcon.appiconset`，保留透明留白 |
| iOS | `ios/Runner/Assets.xcassets/AppIcon.appiconset`，无 alpha 方形，由系统裁形 |
| Windows | `windows/runner/resources/app_icon.ico`，由 Runner.rc 编译 |
| Linux | `linux/hicolor/`，由用户级桌面注册脚本安装 |

`web/` 保留网页导出素材，当前没有 Web 客户端。`preview.png` 是矢量预览，`size-preview.png` 用于检查小尺寸。`asset-manifest.json` 保留原始素材包的导出清单，其路径不代表当前工程构建清单。

应用内品牌图片 `assets/branding/dukto2.png` 复用 `web/icon-192.png`，操作按钮使用 Material 符号。纸飞机是常见造型，不作品牌唯一性或商标可用性承诺；素材来源边界见 [第三方声明](../../THIRD_PARTY_NOTICES.zh-CN.md)。
