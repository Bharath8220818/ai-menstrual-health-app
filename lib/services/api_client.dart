import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = _normalizeBaseUrl(
          baseUrl ??
              const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'https://femi-friendly.up.railway.app',
              ),
        ),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static String _normalizeBaseUrl(String value) {
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> health() async {
    final uri = Uri.parse('$baseUrl/health');
    final response = await _client
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));
    return _decodeJsonResponse(response);
  }

  Future<Map<String, dynamic>> predictAll(Map<String, dynamic> payload) async {
    return _post('/predict', payload);
  }

  Future<Map<String, dynamic>> recommend(Map<String, dynamic> payload) async {
    return _post('/recommend', payload);
  }

  Future<Map<String, dynamic>> recommendProducts(
    Map<String, dynamic> payload,
  ) async {
    return _post('/recommend-products', payload);
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    List<Map<String, String>> history = const [],
    Map<String, dynamic> profile = const {},
    Map<String, dynamic> cycle = const {},
  }) async {
    return _post('/chat', {
      'message': message,
      'history': history,
      'profile': profile,
      'cycle': cycle,
    });
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client
        .post(
          uri,
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));

    return _decodeJsonResponse(response);
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    Map<String, dynamic> parsed = {};

    if (response.body.isNotEmpty) {
      final dynamic body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        parsed = body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return parsed;
    }

    final detail = parsed['detail'] ?? parsed['message'] ?? response.body;
    throw ApiException(
      statusCode: response.statusCode,
      message: detail.toString(),
    );
  }
}

class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
