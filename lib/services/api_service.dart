import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final String _baseUrl = ApiConfig.baseUrl;
  String get baseUrl => _baseUrl;

  Future<Map<String, String>> headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$path');
    if (queryParams == null || queryParams.isEmpty) return uri;
    return uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        if (response.statusCode >= 200 && response.statusCode < 300) return null;
        throw ApiException(response.statusCode, 'Error ${response.statusCode}');
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    final message = body is Map
        ? (body['message'] ?? body['error'] ?? 'Error desconocido')
        : 'Error desconocido';
    throw ApiException(response.statusCode, message.toString());
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    final response = await http.get(_uri(path, queryParams), headers: await headers());
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      _uri(path),
      headers: await headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      _uri(path),
      headers: await headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(_uri(path), headers: await headers());
    return _handleResponse(response);
  }

  Future<dynamic> uploadFile(String path, File file, {String fieldName = 'file', String method = 'POST'}) async {
    final request = http.MultipartRequest(method, _uri(path));
    final hdrs = await headers();
    hdrs.remove('Content-Type');
    request.headers.addAll(hdrs);
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
