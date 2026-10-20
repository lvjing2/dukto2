import 'localization.dart';

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
      title: Text(context.l10n.about),
      scrollable: true,
      content: SizedBox(
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
            Text(context.l10n.aboutTribute),
            SizedBox(height: 16),
            Text(context.l10n.aboutAi),
            SizedBox(height: 16),
            Text(context.l10n.aboutProject),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              showLicensePage(context: context, applicationName: 'Dukto2'),
          child: Text(context.l10n.licenses),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.close),
        ),
      ],
    ),
  );

  Future<void> _chooseLanguage() async {
    final selected = await showDialog<AppLanguage>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.language),
        children: [
          for (final language in AppLanguage.values)
            SimpleDialogOption(
              key: ValueKey('language-${language.tag}'),
              onPressed: () => Navigator.pop(context, language),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        language == AppLanguage.system
                            ? context.l10n.followSystem
                            : language.nativeName,
                        textDirection: language == AppLanguage.ar
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),
                    if (language == c.settings.language)
                      const Icon(Icons.check, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (selected != null && mounted) await c.setLanguage(selected);
  }

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
        'granted' => context.l10n.notificationsAllowed,
        'denied' => context.l10n.notificationsDenied,
        'notDetermined' => context.l10n.notificationsUndetermined,
        'managed' => context.l10n.notificationsManaged,
        'unavailable' => context.l10n.notificationsUnavailable,
        _ => context.l10n.notificationsChecking,
      };
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.settings)),
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
                      child: Text(context.l10n.folderBusy, style: secondary),
                    ),
                  _section(context.l10n.deviceName, Icons.devices_outlined, [
                    Text(
                      c.name.isEmpty ? context.l10n.readingDeviceName : c.name,
                    ),
                  ]),
                  _section(
                    context.l10n.receiveLocation,
                    Icons.folder_open_outlined,
                    [
                      SelectableText(c.receiveLocation),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton.icon(
                            onPressed:
                                canChangeFolder && c.canChooseReceiveFolder
                                ? c.chooseReceiveFolder
                                : null,
                            icon: const Icon(
                              Icons.folder_open_outlined,
                              size: 20,
                            ),
                            label: Text(context.l10n.changeFolder),
                          ),
                          if (c.customReceiveFolder)
                            TextButton(
                              onPressed: canChangeFolder
                                  ? c.resetReceiveFolder
                                  : null,
                              child: Text(context.l10n.restoreDefault),
                            ),
                        ],
                      ),
                    ],
                  ),
                  _section(
                    context.l10n.notifications,
                    Icons.notifications_outlined,
                    [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.l10n.completionNotifications),
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
                          child: Text(context.l10n.allowNotifications),
                        )
                      else if (c.canOpenNotificationSettings &&
                          (c.notificationPermission == 'granted' ||
                              c.notificationPermission == 'denied' ||
                              c.notificationPermission == 'managed'))
                        TextButton(
                          onPressed: c.openNotificationSettings,
                          child: Text(context.l10n.systemNotificationSettings),
                        ),
                      if (Platform.isAndroid &&
                          !c.settings.completionNotifications)
                        Text(
                          context.l10n.ongoingNotificationHint,
                          style: secondary,
                        ),
                    ],
                  ),
                  _section(context.l10n.language, Icons.language_outlined, [
                    ListTile(
                      key: const ValueKey('settings-language'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        c.settings.language == AppLanguage.system
                            ? context.l10n.followSystem
                            : c.settings.language.nativeName,
                      ),
                      trailing: const Icon(Icons.expand_more),
                      onTap: enabled ? _chooseLanguage : null,
                    ),
                  ]),
                  _section(context.l10n.appearance, Icons.palette_outlined, [
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
                            (AppAppearance.system, context.l10n.followSystem),
                            (AppAppearance.light, context.l10n.light),
                            (AppAppearance.dark, context.l10n.dark),
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
                      title: Text(context.l10n.about),
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
