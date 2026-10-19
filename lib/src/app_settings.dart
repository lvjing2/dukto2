import 'dart:convert';
import 'dart:io';

import 'app_language.dart';
export 'app_language.dart';

enum AppAppearance { system, light, dark }

class AppSettings {
  final AppAppearance appearance;
  final AppLanguage language;
  final bool completionNotifications;
  const AppSettings({
    this.appearance = AppAppearance.system,
    this.language = AppLanguage.system,
    this.completionNotifications = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> data) {
    return AppSettings(
      language: AppLanguage.parse(data['language']),
      appearance: AppAppearance.values.firstWhere(
        (value) => value.name == data['appearance'],
        orElse: () => AppAppearance.system,
      ),
      completionNotifications: data['completionNotifications'] is bool
          ? data['completionNotifications'] as bool
          : true,
    );
  }

  AppSettings copyWith({
    AppAppearance? appearance,
    AppLanguage? language,
    bool? completionNotifications,
  }) => AppSettings(
    appearance: appearance ?? this.appearance,
    language: language ?? this.language,
    completionNotifications:
        completionNotifications ?? this.completionNotifications,
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'appearance': appearance.name,
    'language': language.tag,
    'completionNotifications': completionNotifications,
  };
}

class SettingsStore {
  final File file;
  Future<void> _writes = Future.value();
  SettingsStore(Directory support)
    : file = File('${support.path}${Platform.pathSeparator}settings.json');

  Future<AppSettings> load() async {
    try {
      final data = jsonDecode(await file.readAsString());
      if (data is Map<String, dynamic>) return AppSettings.fromJson(data);
    } on Object {
      // Missing or damaged preferences must not block transfers.
    }
    return const AppSettings();
  }

  Future<void> save(AppSettings settings) {
    final data = jsonEncode(settings.toJson());
    _writes = _writes.catchError((Object _) {}).then((_) async {
      await file.parent.create(recursive: true);
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsString(data, flush: true);
      await temporary.rename(file.path);
    });
    return _writes;
  }
}
