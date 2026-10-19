import 'dart:async';

import 'package:flutter/material.dart';

import 'src/controller.dart';
import 'src/app_settings.dart';
import 'src/dashboard.dart';
import 'src/theme.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_syncAppearance);
    unawaited(controller.start());
  }

  void _syncAppearance() {
    final next = switch (controller.settings.appearance) {
      AppAppearance.system => ThemeMode.system,
      AppAppearance.light => ThemeMode.light,
      AppAppearance.dark => ThemeMode.dark,
    };
    if (mounted && next != mode) setState(() => mode = next);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && controller.ready) {
      unawaited(controller.refreshAddresses());
      unawaited(controller.refreshSystemSettings());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_syncAppearance);
    unawaited(controller.shutdown());
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Dukto2',
    debugShowCheckedModeBanner: false,
    theme: dukto2Theme(Brightness.light),
    darkTheme: dukto2Theme(Brightness.dark),
    themeMode: mode,
    home: TransferDashboard(controller: controller),
  );
}
