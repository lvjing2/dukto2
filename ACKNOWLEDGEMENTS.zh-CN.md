# 致敬与创作说明

[English](ACKNOWLEDGEMENTS.md) | 简体中文

## Dukto

感谢 **Emanuele Colombo** 创作 Dukto。Dukto2 希望延续原作让局域网文件传输简单、直接的产品精神。

- 原作者的项目介绍：[Dukto R6](https://www.msec.it/blog/dukto/)
- 社区维护版本：[xuzhen/dukto](https://github.com/xuzhen/dukto)
- 感谢参与移植和维护的[社区贡献者](https://github.com/xuzhen/dukto/graphs/contributors)。

原作者已同意使用 Dukto2 名称，条件是源码保持开源。项目采用 [Apache-2.0](LICENSE)，由 lvjing2 独立维护，问题反馈请至 [Issues](https://github.com/lvjing2/dukto2/issues)。

Dukto2 使用 Flutter / Dart 重写，尚不兼容旧协议。来源与待追溯项见 [来源核查](docs/source-provenance-audit.md)。

## LocalSend 设计参考

自动发现的分阶段探测、按网络接口处理组播、传输前台服务生命周期及 Android 系统文件访问设计，参考了 [LocalSend v1.18.2](https://github.com/localsend/localsend/tree/v1.18.2) 的实现。感谢 LocalSend 作者及贡献者。本项目使用自身的 Dart 协议与传输核心，未把 LocalSend Rust 核心作为运行时组件集成；具体代码相似性及不能确认来源的部分见 [核查报告](docs/source-provenance-audit.md)，不把开发时“自行实现”的自述当作完整来源证明。参考位置和取舍见 [改进说明](docs/reliability.md)。

## AI 创作

本项目主要由 OpenAI Codex 在人工指导下生成并迭代，覆盖代码、界面、测试与文档。人类发起人提出目标、确定取舍并审阅成果。开发过程中使用了 GPT-6.1 Sol；UI 设计参考了 [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) 的本地设计指导。

Flutter / Dart 及其他依赖为各自作者的工作，不属于本项目或 AI 的原创。应用提供“第三方许可”页面展示运行时依赖的许可信息。Dukto2 自身代码采用 [Apache License 2.0](LICENSE)。

上游许可证与当前项目的来源边界见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.zh-CN.md)，Flutter 模板许可副本保存在 `licenses/`。本项目采用 Apache-2.0，不把 AI 创作声明视作第三方许可的替代。
