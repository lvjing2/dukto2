import 'package:flutter/material.dart';

ThemeData dukto2Theme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colors =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: brightness,
      ).copyWith(
        primary: Color(dark ? 0xFF93B4FF : 0xFF2563EB),
        onPrimary: Color(dark ? 0xFF10214D : 0xFFFFFFFF),
        primaryContainer: Color(dark ? 0xFF293754 : 0xFFEDF3FF),
        onPrimaryContainer: Color(dark ? 0xFF93B4FF : 0xFF2563EB),
        surface: Color(dark ? 0xFF22262E : 0xFFFFFFFF),
        surfaceContainerLow: Color(dark ? 0xFF1B1F26 : 0xFFF7F8FA),
        onSurface: Color(dark ? 0xFFF0F2F6 : 0xFF192230),
        onSurfaceVariant: Color(dark ? 0xFFAFB9C8 : 0xFF596575),
        outlineVariant: Color(dark ? 0xFF424B59 : 0xFFDCE1E8),
        outline: Color(dark ? 0xFF8290A3 : 0xFF8694A6),
        tertiary: Color(dark ? 0xFF8BDBB4 : 0xFF16714C),
        error: Color(dark ? 0xFFFFABB5 : 0xFFB42333),
      );
  final base = ThemeData(useMaterial3: true, colorScheme: colors);
  return base.copyWith(
    scaffoldBackgroundColor: colors.surface,
    textTheme: base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerColor: colors.outlineVariant,
    iconTheme: IconThemeData(color: colors.onSurfaceVariant, size: 22),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
    ),
  );
}
