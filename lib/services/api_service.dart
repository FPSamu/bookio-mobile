import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Cliente HTTP centralizado con inyección automática del token de Firebase.
///
/// Equivalente al `api.js` con interceptor de Axios del frontend web.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final String _baseUrl = ApiConfig.baseUrl;

  // ──────────────────────────── Helpers ────────────────────────────

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$path');
    if (queryParams == null || queryParams.isEmpty) return uri;

    return uri.replace(
      queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  /// Parsea la respuesta y lanza excepciones descriptivas en caso de error.
  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body is Map ? (body['message'] ?? body['error'] ?? 'Error desconocido') : 'Error desconocido';
    throw ApiException(response.statusCode, message.toString());
  }

  // ──────────────────────────── HTTP Verbs ────────────────────────────

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    final response = await http.get(_uri(path, queryParams), headers: await _headers());
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      _uri(path),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(_uri(path), headers: await _headers());
    return _handleResponse(response);
  }
}

/// Excepción tipada para errores del API.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
