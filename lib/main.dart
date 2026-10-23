import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';

import 'src/controller.dart';
import 'src/app_settings.dart';
import 'src/dashboard.dart';
import 'src/theme.dart';
import 'src/localization.dart';
export 'src/dashboard.dart' show TransferDashboard;
export 'src/theme.dart' show dukto2Theme;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Dukto2App());
}

class Dukto2App extends StatefulWidget {
  const Dukto2App({super.key});
  @override
  State<Dukto2App> createState() => _Dukto2AppState();
}

class _Dukto2AppState extends State<Dukto2App> with WidgetsBindingObserver {
  final controller = Dukto2Controller();
  ThemeMode mode = ThemeMode.system;
  AppLanguage language = AppLanguage.system;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_syncPreferences);
    unawaited(controller.start());
  }

  void _syncPreferences() {
    final next = switch (controller.settings.appearance) {
      AppAppearance.system => ThemeMode.system,
      AppAppearance.light => ThemeMode.light,
      AppAppearance.dark => ThemeMode.dark,
    };
    if (mounted && (next != mode || language != controller.settings.language)) {
      setState(() {
        mode = next;
        language = controller.settings.language;
      });
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    controller.systemLocaleChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(controller.setAppVisible(state == AppLifecycleState.resumed));
    if (state == AppLifecycleState.resumed && controller.ready) {
      unawaited(controller.refreshAddresses());
      unawaited(controller.refreshSystemSettings());
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await controller.shutdown();
    return AppExitResponse.exit;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_syncPreferences);
    unawaited(controller.shutdown());
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Dukto2',
    locale: language.locale,
    supportedLocales: AppLanguage.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    localeListResolutionCallback: (preferred, _) =>
        AppLanguage.resolve(preferred ?? []),
    debugShowCheckedModeBanner: false,
    theme: dukto2Theme(Brightness.light),
    darkTheme: dukto2Theme(Brightness.dark),
    themeMode: mode,
    home: TransferDashboard(controller: controller),
  );
}
