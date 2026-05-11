import 'dart:io' show Platform;

// Configuracion API
class ApiConfig {
  ApiConfig._();

  static const String _prodBaseUrl = 'http://18.205.191.250:3000/api/v1';

  static bool isProduction = false;

  static String get baseUrl {
    if (isProduction) return _prodBaseUrl;
    final host = Platform.isAndroid ? '10.0.2.2' : '192.168.100.185';
    return 'http://$host:3000/api/v1';
  }
}
