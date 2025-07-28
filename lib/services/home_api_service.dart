import 'package:logger/logger.dart';
import 'package:huoo/services/api_service.dart';
import 'package:huoo/models/api/api_models.dart';

final Logger _logger = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class HomeApiService {
  final ApiService _apiService = ApiService();

  // Singleton pattern
  static final HomeApiService _instance = HomeApiService._internal();
  factory HomeApiService() => _instance;
  HomeApiService._internal();

  Future<HomeScreenData> getHomeScreenData() async {
    try {
      final response = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home',
      );
      return HomeScreenData.fromJson(response);
    } catch (e) {
      _logger.e('Failed to get home screen data: $e');
      rethrow;
    }
  }

  Future<ContinueListeningResponse> getContinueListening({
    int limit = 6,
  }) async {
    try {
      final result = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/continue-listening',
        queryParams: {'limit': limit.toString()},
      );

      return ContinueListeningResponse.fromJson(result);
    } catch (e) {
      _logger.e('Failed to get continue listening data: $e');
      rethrow;
    }
  }

  Future<TopMixesResponse> getTopMixes({int limit = 4}) async {
    try {
      final result = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/top-mixes',
        queryParams: {'limit': limit.toString()},
      );

      return TopMixesResponse.fromJson(result);
    } catch (e) {
      _logger.e('Failed to get top mixes: $e');
      rethrow;
    }
  }

  Future<RecentListeningResponse> getRecentListening({int limit = 6}) async {
    try {
      final result = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/recent-listening',
        queryParams: {'limit': limit.toString()},
      );

      return RecentListeningResponse.fromJson(result);
    } catch (e) {
      _logger.e('Failed to get recent listening data: $e');
      rethrow;
    }
  }

  Future<UserStats> getUserStats() async {
    try {
      final result = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/stats',
      );

      return UserStats.fromJson(result);
    } catch (e) {
      _logger.e('Failed to get user stats: $e');
      rethrow;
    }
  }

  Future<SongListResponse> getRecommendedSongs({int limit = 20}) async {
    try {
      final result = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/recommend',
        queryParams: {'limit': limit.toString()},
      );

      return SongListResponse.fromJson(result);
    } catch (e) {
      _logger.e('Failed to get recommended songs: $e');
      rethrow;
    }
  }
}
