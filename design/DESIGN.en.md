# UI guidelines

English | [简体中文](DESIGN.md)

Dukto2 uses a minimal blue interface, system fonts and semantic colors, balancing desktop information density, mobile touch and large text.

## Visuals and layout

- Primary color `#2563EB`; light, dark and system appearance. Success and failure include text feedback.
- Spacing uses 4 / 8 / 12 / 16 / 24 / 32, subtle borders and light rounding; decoration should not crowd the task.
- Wide layouts put nearby devices / local information on the left and sending / history on the right. Narrow windows and large text reflow to one column.
- Touch targets are at least 48dp. Filenames can wrap, and accessibility retains the complete name.
- System fonts require no network. See [branding assets](app-icon/README.en.md).

## Interaction

Choose a device → compare its actual code → choose files / text → explicitly send → receiver approves → upload and verify → complete. A name does not prove identity; requests are not accepted automatically.

Local information shows code and addresses without keeping long fingerprints on the main screen. Nearby icons distinguish phone, tablet and computer, with a generic fallback. Empty discovery offers refresh and manual connection.

Mobile text editing uses a compact layout with actions above the keyboard. Dismissing it retains the draft and scroll position. Settings group receiving location, system name, notifications, appearance and About.

## Recent transfers

Name / size are primary, followed by direction / result and peer. Wide layouts separately right-align time and duration; narrow layouts reflow. The trailing area contains one action: view text or open the folder. Copying belongs in details.

Time, speed and progress come from actual transfers, not demonstration values. See [screenshots](../docs/screenshots/README.en.md), [validation coverage](../docs/en/validation.md) and [AI / design acknowledgements](../ACKNOWLEDGEMENTS.md).
