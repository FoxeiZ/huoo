import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

final Logger log = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const Duration timeout = Duration(seconds: 30);
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String> _getToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const ApiException('User not authenticated');
    }
    try {
      final token = await user.getIdToken();
      if (token == null) {
        throw const ApiException('Failed to get authentication token');
      }
      return token;
    } catch (e) {
      throw ApiException('Failed to get authentication token: $e');
    }
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    if (includeAuth) {
      try {
        final token = await _getToken();
        headers['Authorization'] = 'Bearer $token';
      } catch (e) {
        log.w('Failed to get auth token: $e');
        rethrow;
      }
    }

    return headers;
  }

  // Public method for specialized services to make HTTP requests
  Future<Map<String, dynamic>> makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool requireAuth = true,
    Map<String, String>? queryParams,
  }) async {
    return await _makeRequest(
      method: method,
      endpoint: endpoint,
      body: body,
      requireAuth: requireAuth,
      queryParams: queryParams,
    );
  }

  // Public method to get headers for custom HTTP requests (like multipart uploads)
  Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    return await _getHeaders(includeAuth: includeAuth);
  }

  Future<Map<String, dynamic>> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    bool requireAuth = true,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}$endpoint',
      ).replace(queryParameters: queryParams);

      final headers = await _getHeaders(includeAuth: requireAuth);

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(ApiConfig.timeout);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(ApiConfig.timeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(ApiConfig.timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(ApiConfig.timeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      log.d('API Request: $method $endpoint - Status: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      log.e('API Request failed: $method $endpoint - Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    try {
      final responseBody = json.decode(response.body);

      if (statusCode >= 200 && statusCode < 300) {
        // Ensure we always return a Map
        if (responseBody is Map<String, dynamic>) {
          return responseBody;
        } else if (responseBody is List) {
          // Wrap Lists in a Map structure for consistency
          return {'items': responseBody, 'total_count': responseBody.length};
        } else {
          // Handle other types (strings, numbers, etc.)
          return {'data': responseBody};
        }
      } else {
        // Handle error responses (should be Map with error details)
        final errorMap =
            responseBody is Map<String, dynamic>
                ? responseBody
                : {'detail': responseBody.toString()};
        final message = errorMap['detail'] ?? 'Unknown error occurred';
        throw ApiException(
          message.toString(),
          statusCode: statusCode,
          details: errorMap,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;

      // Handle non-JSON responses
      if (statusCode >= 200 && statusCode < 300) {
        return {'message': response.body};
      } else {
        throw ApiException(
          'HTTP $statusCode: ${response.body}',
          statusCode: statusCode,
        );
      }
    }
  }
}
