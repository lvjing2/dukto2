# Application icon

English | [简体中文](README.md)

White paper plane on blue `#355DEB`. SVG masters are in `source/`; platform PNGs are rendered from vectors rather than concept-image screenshots.

| Platform | Resources |
| --- | --- |
| Android | Legacy icons, adaptive foreground / background and monochrome theme layer under `android/app/src/main/res/` |
| macOS | `macos/Runner/Assets.xcassets/AppIcon.appiconset`, retaining transparent padding |
| iOS | `ios/Runner/Assets.xcassets/AppIcon.appiconset`, opaque square cropped by the system |
| Windows | `windows/runner/resources/app_icon.ico`, compiled through Runner.rc |
| Linux | `linux/hicolor/`, installed through user-level desktop registration |

`web/` retains web exports; there is no Web client. `preview.png` shows the vector, and `size-preview.png` checks small sizes. `asset-manifest.json` preserves the original asset package's export list; its paths are not the current build manifest.

In-app branding at `assets/branding/dukto2.png` reuses `web/icon-192.png`; action buttons use Material symbols. A paper plane is a common shape, not a claimed exclusive brand or cleared trademark. See [third-party sources](../../THIRD_PARTY_NOTICES.md).
