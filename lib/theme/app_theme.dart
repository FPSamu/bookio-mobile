import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores profesional
  static const Color primaryDark = Color(0xFF1E293B); // Slate 800
  static const Color accentBlue = Color(0xFF3B82F6); // Blue 500 elegante

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
      inputDecorationTheme: _inputTheme(Colors.black),
      elevatedButtonTheme: _buttonTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentBlue,
        primary: Colors.white,
        secondary: accentBlue,
        surface: const Color(0xFF0F172A), // Slate 900
        brightness: Brightness.dark,
      ),
      inputDecorationTheme: _inputTheme(Colors.white),
      elevatedButtonTheme: _buttonTheme,
    );
  }

  // Estilos comunes para mantener limpieza
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