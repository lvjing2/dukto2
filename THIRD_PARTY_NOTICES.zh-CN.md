# 第三方来源与许可

[English](THIRD_PARTY_NOTICES.md) | 简体中文

Dukto2 自身代码采用 [Apache License 2.0](LICENSE)（`Apache-2.0`）。以下上游工作仍适用各自的版权声明和许可，不能用项目声明替代。

## 运行时与依赖

- Flutter / Dart：平台工程由 Flutter 3.47.7 模板生成，保留 Flutter Authors 的 BSD 许可，副本见 [licenses/Flutter-BSD-3-Clause.txt](licenses/Flutter-BSD-3-Clause.txt)。SDK 与引擎还包含其他组件，分发二进制时应保留构建生成的通知文件。
- 应用直接依赖 `file_picker`、`path_provider`、`path`；纯 Dart 核心直接依赖 `basic_utils`、`crypto`、`path`。具体版本及传递依赖由根目录和核心包的 `pubspec.lock` 锁定。
- 应用的“设置 → 关于 Dukto2 → 第三方许可”展示 Flutter 注册的运行时许可。完整构建目录中的 `flutter_assets/NOTICES.Z` 应与其他资源一起保留，不能只分发可执行文件。
- 本文件是来源索引，不是已完成的全依赖法律审计。每次更新依赖或改变发布方式时，重新检查对应平台实际打包的原生组件和许可文件。

## 设计与实现参考

- **Dukto / Emanuele Colombo**：产品体验与项目精神的来源。原作者页面声明 GPL，保留原作者版权头的核心源码声明 GPL-2.0-or-later。Dukto2 以 Flutter / Dart 独立重写为目标，采用新协议；首轮源码对照已完成，见 [核查报告](docs/source-provenance-audit.md)；仍有历史和素材来源待追溯项，不据此断言已排除复制、改写、翻译或衍生作品关系，也不声称获得官方继任授权。参考：[原作](https://www.msec.it/blog/dukto/)、[社区维护版源码许可头](https://github.com/xuzhen/dukto/blob/master/duktoprotocol.cpp)。社区维护版根目录的 LICENSE.txt 另有自定义免责声明，不能据此忽略源码原有声明。
- **LocalSend**：参考自动发现、前台传输生命周期和系统存储访问设计，并采用相同的 IPv4 组播地址选择；上游使用 Apache-2.0。当前未集成其 Rust 核心。首轮核查未发现可确认的业务代码复制，旧版证书生成流程仍有来源待追溯项，见 [核查报告](docs/source-provenance-audit.md)。参考位置与取舍见 [可靠性说明](docs/reliability.md) 和 [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.zh-CN.md)。后续若确认复用了具体代码，必须逐项记录来源并保留相应声明。[上游许可](https://github.com/localsend/localsend/blob/main/LICENSE)。
- **UI UX Pro Max**：开发阶段的设计指导工具，未作为运行时依赖引入，见 [致谢](ACKNOWLEDGEMENTS.zh-CN.md)。

## 图标与截图

图标矢量母版及平台导出位于 `design/app-icon/`，来源和生成方式见该目录 README。公开前仍需维护者确认这些素材可以随项目选择的许可证分发，不把常见纸飞机造型表述为独占标识。

`docs/screenshots/` 是测试设备或模拟器的实际截图，具体来源、版本及桌面附带内容见其 README。它们不是运行时素材；维护者应在公开前确认设备名称、桌面背景、系统提示和其他软件窗口适合公开。
