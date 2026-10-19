import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';
export '../l10n/generated/app_localizations.dart';

// Standalone legacy widgets/tests may not install the application delegates.
AppLocalizations get fallbackMessages =>
    lookupAppLocalizations(const Locale('zh'));

extension AppLocalizationContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      fallbackMessages;
}
