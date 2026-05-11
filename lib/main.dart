import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <-- Nueva importación
import 'package:provider/provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/business_provider.dart';
import 'providers/appointment_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'services/storage_service.dart';

// Función para manejar mensajes cuando la app está cerrada o en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Notificación en segundo plano: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- INICIO: CONFIGURACIÓN DE NOTIFICACIONES PUSH ---

  // 1. Manejador de notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 2. Solicitar permisos (obligatorio para iOS y Android 13+)
  await FirebaseMessaging.instance.requestPermission();

  // 3. Obtener e imprimir el Token para probar desde Firebase Console
  String? token = await FirebaseMessaging.instance.getToken();
  print("=======================================");
  print("TOKEN DE ESTE DISPOSITIVO:");
  print(token);
  print("=======================================");

  // 4. Escuchar notificaciones mientras la app está abierta (primer plano)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('¡Notificación recibida en primer plano!');
    if (message.notification != null) {
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
    }
  });

  // --- FIN: CONFIGURACIÓN DE NOTIFICACIONES PUSH ---

  await StorageService.instance.init();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
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
