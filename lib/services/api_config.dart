import 'dart:io' show Platform;

/// Configuración centralizada del API backend.
///
/// En desarrollo, el emulador Android necesita `10.0.2.2` para llegar
/// al `localhost` del host. iOS Simulator usa `localhost` directamente.
class ApiConfig {
  ApiConfig._();

  static const String _prodBaseUrl = 'https://api.bookio.com/api/v1';

  /// Cambia a `true` cuando despliegues a producción.
  static bool isProduction = false;

  static String get baseUrl {
    if (isProduction) return _prodBaseUrl;
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:3000/api/v1';
  }
}
