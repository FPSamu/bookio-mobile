import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const BookioApp());
}

class BookioApp extends StatefulWidget {
  const BookioApp({super.key});

  // Global state for Dark Mode
  static ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

  @override
  State<BookioApp> createState() => _BookioAppState();
}

class _BookioAppState extends State<BookioApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: BookioApp.isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'Bookio',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const LoginScreen(),
        );
      },
    );
  }
}
