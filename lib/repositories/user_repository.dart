import 'package:huoo/services/user_api_service.dart';
import 'package:huoo/services/api_service.dart';
import 'package:huoo/models/api/api_models.dart';
import 'package:logger/logger.dart';

final log = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class UserRepository {
  final UserApiService _userApiService = UserApiService();
  final ApiService _apiService = ApiService(); // Keep for healthCheck

  // Singleton pattern
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  Future<UserApiModel?> getUserProfile() async {
    try {
      final response = await _userApiService.getUserProfile();
      return UserApiModel.fromJson(response);
    } on ApiException catch (e) {
      log.e('Failed to get user profile: ${e.message}');
      return null;
    } catch (e) {
      log.e('Unexpected error getting user profile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _userApiService.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return true;
    } on ApiException catch (e) {
      log.e('Failed to update user profile: ${e.message}');
      return false;
    } catch (e) {
      log.e('Unexpected error updating user profile: $e');
      return false;
    }
  }

  Future<bool> testApiConnection() async {
    try {
      await _userApiService.testProtectedEndpoint();
      return true;
    } on ApiException catch (e) {
      log.e('API connection test failed: ${e.message}');
      return false;
    } catch (e) {
      log.e('Unexpected error testing API connection: $e');
      return false;
    }
  }

  Future<bool> checkApiHealth() async {
    try {
      final response = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/health',
        requireAuth: false,
      );
      return response['status'] == 'healthy';
    } on ApiException catch (e) {
      log.e('API health check failed: ${e.message}');
      return false;
    } catch (e) {
      log.e('Unexpected error checking API health: $e');
      return false;
    }
  }

  /// Get detailed user statistics
  Future<UserStatsApiModel?> getUserStats() async {
    try {
      final response = await _userApiService.getUserStats();
      return UserStatsApiModel.fromJson(response);
    } on ApiException catch (e) {
      log.e('Failed to get user stats: ${e.message}');
      return null;
    } catch (e) {
      log.e('Unexpected error getting user stats: $e');
      return null;
    }
  }

  /// Get user's favorite songs
  Future<List<String>?> getFavoriteSongs() async {
    try {
      final response = await _userApiService.getFavoriteSongs();
      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];
        return List<String>.from(data['favorite_songs'] ?? []);
      }
      return [];
    } on ApiException catch (e) {
      log.e('Failed to get favorite songs: ${e.message}');
      return null;
    } catch (e) {
      log.e('Unexpected error getting favorite songs: $e');
      return null;
    }
  }

  /// Get user's listening history
  Future<List<Map<String, dynamic>>?> getListeningHistory() async {
    try {
      final response = await _userApiService.getListeningHistory();
      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];
        return List<Map<String, dynamic>>.from(data['listening_history'] ?? []);
      }
      return [];
    } on ApiException catch (e) {
      log.e('Failed to get listening history: ${e.message}');
      return null;
    } catch (e) {
      log.e('Unexpected error getting listening history: $e');
      return null;
    }
  }
}

// Deprecated - use UserApiModel instead
class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'email_verified': emailVerified,
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, emailVerified: $emailVerified)';
  }
}
