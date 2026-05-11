import 'dart:io' show Platform;

// Configuracion API
class ApiConfig {
  ApiConfig._();

  static const String _prodBaseUrl = 'http://54.234.182.20:3000/api/v1';

  static bool isProduction = false;

  static String get baseUrl {
    if (isProduction) return _prodBaseUrl;
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:3000/api/v1';
  }
}
