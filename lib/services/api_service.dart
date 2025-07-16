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

/// Exception class for API errors
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

  /// Get the current Firebase user token
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

  /// Create HTTP headers with authentication token
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

  /// Handle HTTP response and parse JSON
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    try {
      final responseBody = json.decode(response.body) as Map<String, dynamic>;

      if (statusCode >= 200 && statusCode < 300) {
        return responseBody;
      } else {
        final message = responseBody['detail'] ?? 'Unknown error occurred';
        throw ApiException(
          message.toString(),
          statusCode: statusCode,
          details: responseBody,
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

  // ============ USER ENDPOINTS ============

  /// Get the current user's profile
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _makeRequest(method: 'GET', endpoint: '/users/me');
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (photoUrl != null) body['photo_url'] = photoUrl;

    return await _makeRequest(method: 'PUT', endpoint: '/users/me', body: body);
  }

  // ============ MUSIC ENDPOINTS ============

  /// Get user's music library
  Future<Map<String, dynamic>> getMusicLibrary({
    int page = 1,
    int limit = 50,
    String? search,
    String? genre,
    String? artist,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null) queryParams['search'] = search;
    if (genre != null) queryParams['genre'] = genre;
    if (artist != null) queryParams['artist'] = artist;

    return await _makeRequest(
      method: 'GET',
      endpoint: '/music/library',
      queryParams: queryParams,
    );
  }

  /// Upload music metadata
  Future<Map<String, dynamic>> uploadMusicMetadata({
    required String title,
    required String filePath,
    String? artist,
    String? album,
    String? genre,
    int? duration,
  }) async {
    final body = {
      'title': title,
      'file_path': filePath,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (genre != null) 'genre': genre,
      if (duration != null) 'duration': duration,
    };

    return await _makeRequest(
      method: 'POST',
      endpoint: '/music/upload',
      body: body,
    );
  }

  /// Get music file by ID
  Future<Map<String, dynamic>> getMusicFile(String musicId) async {
    return await _makeRequest(method: 'GET', endpoint: '/music/$musicId');
  }

  /// Delete music file
  Future<Map<String, dynamic>> deleteMusicFile(String musicId) async {
    return await _makeRequest(method: 'DELETE', endpoint: '/music/$musicId');
  }

  /// Search for music
  Future<Map<String, dynamic>> searchMusic({
    required String query,
    int page = 1,
    int limit = 20,
    String? searchType, // 'all', 'songs', 'artists', 'albums'
  }) async {
    final queryParams = <String, String>{
      'q': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (searchType != null) queryParams['type'] = searchType;

    return await _makeRequest(
      method: 'GET',
      endpoint: '/search',
      queryParams: queryParams,
    );
  }

  // ============ PLAYLIST ENDPOINTS ============

  /// Get user's playlists
  Future<Map<String, dynamic>> getPlaylists() async {
    return await _makeRequest(method: 'GET', endpoint: '/playlists');
  }

  /// Create a new playlist
  Future<Map<String, dynamic>> createPlaylist({
    required String name,
    String? description,
  }) async {
    final body = {
      'name': name,
      if (description != null) 'description': description,
    };

    return await _makeRequest(
      method: 'POST',
      endpoint: '/playlists',
      body: body,
    );
  }

  /// Add song to playlist
  Future<Map<String, dynamic>> addToPlaylist({
    required String playlistId,
    required String musicId,
  }) async {
    return await _makeRequest(
      method: 'POST',
      endpoint: '/playlists/$playlistId/songs/$musicId',
    );
  }

  /// Remove song from playlist
  Future<Map<String, dynamic>> removeFromPlaylist({
    required String playlistId,
    required String musicId,
  }) async {
    return await _makeRequest(
      method: 'DELETE',
      endpoint: '/playlists/$playlistId/songs/$musicId',
    );
  }

  // ============ UTILITY ENDPOINTS ============

  /// Health check
  Future<Map<String, dynamic>> healthCheck() async {
    return await _makeRequest(
      method: 'GET',
      endpoint: '/health',
      requireAuth: false,
    );
  }

  /// Test protected endpoint
  Future<Map<String, dynamic>> testProtectedEndpoint() async {
    return await _makeRequest(
      method: 'GET',
      endpoint: '/users/protected-resource',
    );
  }
}
