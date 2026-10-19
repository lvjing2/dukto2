import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'controller.dart';

class SettingsPage extends StatefulWidget {
  final Dukto2Controller controller;
  const SettingsPage({super.key, required this.controller});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Dukto2Controller get c => widget.controller;
  @override
  void initState() {
    super.initState();
    unawaited(c.refreshSystemSettings());
  }

  Future<void> _about() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('关于 Dukto2'),
      scrollable: true,
      content: const SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dukto2 · 0.1.6 (7)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text('致敬 Dukto 与原作者 Emanuele Colombo，感谢 xuzhen 及社区贡献者的持续维护。'),
            SizedBox(height: 16),
            Text('由 OpenAI Codex 在人工指导下创作代码、UI、测试与文档。'),
            SizedBox(height: 16),
            Text('一个希望延续 Dukto 简单、直接体验的独立重写项目。'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              showLicensePage(context: context, applicationName: 'Dukto2'),
          child: const Text('第三方许可'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    ),
  );

  Widget _section(String title, IconData icon, List<Widget> children) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: 22, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: c,
    builder: (context, _) {
      final enabled = c.canEditSettings && !c.savingSettings;
      final canChangeFolder = enabled && c.ready && !c.busy;
      final secondary = TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 13,
      );
      final permission = switch (c.notificationPermission) {
        'granted' => '系统通知已允许',
        'denied' => '系统通知已关闭',
        'notDetermined' => '尚未授权',
        'managed' => '通知由系统管理',
        'unavailable' => '暂时无法读取系统通知状态',
        _ => '正在检查系统通知…',
      };
      return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (c.settingsError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          c.settingsError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  if (c.busy && !c.picking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('传输中，暂不可更改接收目录。', style: secondary),
                    ),
                  _section('接收位置', Icons.folder_open_outlined, [
                    SelectableText(c.receiveLocation),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        TextButton.icon(
                          onPressed: canChangeFolder && c.canChooseReceiveFolder
                              ? c.chooseReceiveFolder
                              : null,
                          icon: const Icon(
                            Icons.folder_open_outlined,
                            size: 20,
                          ),
                          label: const Text('更改目录'),
                        ),
                        if (c.customReceiveFolder)
                          TextButton(
                            onPressed: canChangeFolder
                                ? c.resetReceiveFolder
                                : null,
                            child: const Text('恢复默认'),
                          ),
                      ],
                    ),
                  ]),
                  _section('设备名称', Icons.devices_outlined, [
                    Text(c.name.isEmpty ? '正在读取设备名称…' : c.name),
                  ]),
                  _section('通知', Icons.notifications_outlined, [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('传输完成通知'),
                      value: c.settings.completionNotifications,
                      onChanged: enabled
                          ? (value) =>
                                unawaited(c.setCompletionNotifications(value))
                          : null,
                    ),
                    if (c.notificationPermission != 'granted')
                      Text(permission, style: secondary),
                    if (c.notificationPermission == 'notDetermined')
                      TextButton(
                        onPressed: enabled ? c.requestNotifications : null,
                        child: const Text('允许通知'),
                      )
                    else if (c.canOpenNotificationSettings &&
                        (c.notificationPermission == 'granted' ||
                            c.notificationPermission == 'denied' ||
                            c.notificationPermission == 'managed'))
                      TextButton(
                        onPressed: c.openNotificationSettings,
                        child: const Text('系统通知设置'),
                      ),
                    if (Platform.isAndroid &&
                        !c.settings.completionNotifications)
                      Text('传输中的状态通知仍会保留。', style: secondary),
                  ]),
                  _section('外观', Icons.palette_outlined, [
                    RadioGroup<AppAppearance>(
                      groupValue: c.settings.appearance,
                      onChanged: (value) {
                        if (enabled && value != null) {
                          unawaited(c.setAppearance(value));
                        }
                      },
                      child: Column(
                        children: [
                          for (final (value, label) in [
                            (AppAppearance.system, '跟随系统'),
                            (AppAppearance.light, '浅色'),
                            (AppAppearance.dark, '深色'),
                          ])
                            RadioListTile<AppAppearance>(
                              contentPadding: EdgeInsets.zero,
                              value: value,
                              title: Text(label),
                              enabled: enabled,
                            ),
                        ],
                      ),
                    ),
                  ]),
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      key: const ValueKey('settings-about'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: ExcludeSemantics(
                        child: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: const Text('关于 Dukto2'),
                      trailing: const ExcludeSemantics(
                        child: Icon(Icons.chevron_right),
                      ),
                      onTap: _about,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
