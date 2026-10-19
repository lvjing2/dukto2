import 'dart:ui';

/// Stable preference tags; labels use each language's own name.
enum AppLanguage {
  system('system', '', null),
  zhHans(
    'zh-Hans',
    '简体中文',
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ),
  en('en', 'English', Locale('en')),
  es('es', 'Español', Locale('es')),
  ptBr('pt-BR', 'Português (Brasil)', Locale('pt', 'BR')),
  fr('fr', 'Français', Locale('fr')),
  de('de', 'Deutsch', Locale('de')),
  ru('ru', 'Русский', Locale('ru')),
  ja('ja', '日本語', Locale('ja')),
  ko('ko', '한국어', Locale('ko')),
  ar('ar', 'العربية', Locale('ar'));

  final String tag;
  final String nativeName;
  final Locale? locale;
  const AppLanguage(this.tag, this.nativeName, this.locale);

  static AppLanguage parse(Object? tag) =>
      values.firstWhere((value) => value.tag == tag, orElse: () => system);

  static List<Locale> get supportedLocales => [
    for (final value in values)
      if (value.locale != null) value.locale!,
  ];

  static Locale resolve(Iterable<Locale> preferred) {
    for (final locale in preferred) {
      for (final supported in supportedLocales) {
        if (locale.languageCode == supported.languageCode) return supported;
      }
    }
    return const Locale('en');
  }
}
