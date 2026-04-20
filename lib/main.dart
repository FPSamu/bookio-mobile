import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

  void toggleDarkMode(bool value) => setState(() => isDarkMode = value);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppAuthProvider(),
      child: MaterialApp(
        title: 'Bookio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const AuthGate(),
      ),
    );
  }
}