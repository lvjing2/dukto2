import 'dart:async';

import 'package:flutter/material.dart';

import 'src/controller.dart';
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
    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && controller.ready) {
      unawaited(controller.refreshAddresses());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(controller.shutdown());
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'dukto2',
    debugShowCheckedModeBanner: false,
    theme: dukto2Theme(Brightness.light),
    darkTheme: dukto2Theme(Brightness.dark),
    themeMode: mode,
    home: Builder(
      builder: (context) => TransferDashboard(
        controller: controller,
        onToggleTheme: () => setState(() {
          mode = Theme.of(context).brightness == Brightness.light
              ? ThemeMode.dark
              : ThemeMode.light;
        }),
      ),
    ),
  );
}
