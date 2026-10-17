# 致敬与创作说明

## Dukto

感谢 **Emanuele Colombo** 创作 Dukto。dukto2 希望延续原作让局域网文件传输简单、直接的产品精神。

- 原作者的项目介绍：[Dukto R6](https://www.msec.it/blog/dukto/)
- 社区维护版本：[xuzhen/dukto](https://github.com/xuzhen/dukto)
- 感谢参与移植和维护的[社区贡献者](https://github.com/xuzhen/dukto/graphs/contributors)。

dukto2 是使用 Flutter / Dart 编写的独立重写项目，当前没有复制 Dukto 的源代码、美术素材或图标，也尚不兼容旧协议。我们希望与原作者沟通延续项目的意向；当前没有声称获得原作者的官方继任授权、认可或背书。后续介绍将根据实际沟通结果更新。

## LocalSend 设计参考

自动发现的分阶段探测、按网络接口处理组播、传输前台服务生命周期及 Android 系统文件访问设计，参考了 [LocalSend v1.18.2](https://github.com/localsend/localsend/tree/v1.18.2) 的实现。感谢 LocalSend 作者及贡献者。本项目继续使用自己的 Dart 传输协议与实现，没有引入 LocalSend 的 Rust 核心或直接复制其实现代码；参考位置和取舍见 [改进说明](docs/reliability.md)。

## AI 创作

本项目主要由 OpenAI Codex 在人工指导下生成并迭代，覆盖代码、界面、测试与文档。人类发起人提出目标、确定取舍并审阅成果。开发过程中使用了 GPT-6.1 Sol；UI 设计参考了 [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) 的本地设计指导。

Flutter / Dart 及其他依赖为各自作者的工作，不属于本项目或 AI 的原创。应用提供“第三方许可”页面展示运行时依赖的许可信息。正式开源发布前将确定 dukto2 自身的开源许可证。
