import 'package:flutter/material.dart';

abstract final class WorklogColors {
  static const background = Color(0xFF06111F);
  static const surface = Color(0xFF0B1E3A);
  static const surface2 = Color(0xFF102744);
  static const primary = Color(0xFF3B82F6);
  static const cyan = Color(0xFF14B8FF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFEF4444);
  static const violet = Color(0xFF7C3AED);
  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFF9CA3AF);
  static const border = Color(0xFF1B3B5F);
}

ThemeData buildWorklogTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: WorklogColors.primary,
    brightness: Brightness.dark,
    surface: WorklogColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme.copyWith(
      primary: WorklogColors.primary,
      secondary: WorklogColors.cyan,
      surface: WorklogColors.surface,
      error: WorklogColors.danger,
    ),
    scaffoldBackgroundColor: WorklogColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: WorklogColors.text,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: WorklogColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: WorklogColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WorklogColors.surface2,
      labelStyle: const TextStyle(color: WorklogColors.muted),
      hintStyle: const TextStyle(color: WorklogColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WorklogColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WorklogColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: WorklogColors.primary, width: 1.4),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF07182C),
      indicatorColor: Color(0xFF123A68),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: WorklogColors.surface2,
      contentTextStyle: TextStyle(color: WorklogColors.text),
    ),
  );
}
