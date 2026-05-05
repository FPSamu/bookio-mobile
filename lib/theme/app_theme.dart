import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF1E293B); // Slate 800
  static const Color accentBlue = Color(0xFF3B82F6);  // Blue 500

  static const Color _darkSurface = Color(0xFF0F172A);   // Slate 900 — scaffold bg
  static const Color _darkCard    = Color(0xFF1E293B);   // Slate 800 — cards
  static const Color _darkElevated = Color(0xFF334155);  // Slate 700 — elevated surfaces

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: accentBlue,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: _inputTheme(Colors.black),
      elevatedButtonTheme: _buttonTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _darkSurface,
      cardColor: _darkCard,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentBlue,
        primary: Colors.white,
        secondary: accentBlue,
        surface: _darkSurface,
        brightness: Brightness.dark,
      ).copyWith(
        surfaceContainerLow: _darkCard,
        surfaceContainer: _darkCard,
        surfaceContainerHigh: _darkElevated,
        surfaceContainerHighest: _darkElevated,
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _darkSurface,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: _inputTheme(Colors.white),
      elevatedButtonTheme: _buttonTheme,
      dividerColor: Colors.white24,
    );
  }

  static InputDecorationTheme _inputTheme(Color dividerColor) => InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.withValues(alpha: 0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: dividerColor.withValues(alpha: 0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: dividerColor.withValues(alpha: 0.1)),
    ),
  );

  static final _buttonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  );
}
