import 'package:huoo/services/user_api_service.dart';
import 'package:huoo/services/api_service.dart';
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

  /// Get user profile data
  Future<UserProfile?> getUserProfile() async {
    try {
      final response = await _userApiService.getUserProfile();
      return UserProfile.fromJson(response);
    } on ApiException catch (e) {
      log.e('Failed to get user profile: ${e.message}');
      return null;
    } catch (e) {
      log.e('Unexpected error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
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

  /// Test API connection with a protected endpoint
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

  /// Check if API is healthy (doesn't require auth)
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
}

/// User profile model
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
