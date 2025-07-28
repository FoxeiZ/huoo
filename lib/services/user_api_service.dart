import 'package:logger/logger.dart';
import 'package:huoo/services/api_service.dart';

final Logger _logger = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class UserApiService {
  final ApiService _apiService = ApiService();

  // Singleton pattern
  static final UserApiService _instance = UserApiService._internal();
  factory UserApiService() => _instance;
  UserApiService._internal();

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/users/me',
      );
    } catch (e) {
      _logger.e('Failed to get user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['display_name'] = displayName;
      if (photoUrl != null) body['photo_url'] = photoUrl;

      return await _apiService.makeRequest(
        method: 'PUT',
        endpoint: '/users/me',
        body: body,
      );
    } catch (e) {
      _logger.e('Failed to update user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> testProtectedEndpoint() async {
    try {
      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/users/protected-resource',
      );
    } catch (e) {
      _logger.e('Failed to test protected endpoint: $e');
      rethrow;
    }
  }

  /// Get detailed user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/users/stats',
      );
    } catch (e) {
      _logger.e('Failed to get user stats: $e');
      rethrow;
    }
  }

  /// Get user's favorite songs
  Future<Map<String, dynamic>> getFavoriteSongs() async {
    try {
      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/users/favorites/songs',
      );
    } catch (e) {
      _logger.e('Failed to get favorite songs: $e');
      rethrow;
    }
  }

  /// Get user's listening history
  Future<Map<String, dynamic>> getListeningHistory() async {
    try {
      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/users/history',
      );
    } catch (e) {
      _logger.e('Failed to get listening history: $e');
      rethrow;
    }
  }
}
