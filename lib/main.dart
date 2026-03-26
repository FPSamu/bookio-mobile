import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const BookioApp());
}

class BookioApp extends StatefulWidget {
  const BookioApp({super.key});

  static _BookioAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_BookioAppState>();

  @override
  State<BookioApp> createState() => _BookioAppState();
}

class _BookioAppState extends State<BookioApp> {
  bool isDarkMode = false;

  void toggleDarkMode(bool value) {
    setState(() => isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}
