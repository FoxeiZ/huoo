import 'package:logger/logger.dart';
import 'package:huoo/services/api_service.dart';

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

  Future<Map<String, dynamic>> getHomeScreenData() async {
    try {
      return await _apiService.makeRequest(method: 'GET', endpoint: '/home');
    } catch (e) {
      _logger.e('Failed to get home screen data: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getContinueListening({int limit = 6}) async {
    try {
      final result = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/continue-listening',
        queryParams: {'limit': limit.toString()},
      );

      // API now returns {items: [...], total_count: N}
      if (result['items'] is List) {
        return result['items'];
      }

      _logger.w('Expected items List but got ${result.runtimeType}: $result');
      return <dynamic>[];
    } catch (e) {
      _logger.e('Failed to get continue listening data: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getTopMixes({int limit = 4}) async {
    try {
      final result = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/top-mixes',
        queryParams: {'limit': limit.toString()},
      );

      // API now returns {items: [...], total_count: N}
      if (result['items'] is List) {
        return result['items'];
      }

      _logger.w('Expected items List but got ${result.runtimeType}: $result');
      return <dynamic>[];
    } catch (e) {
      _logger.e('Failed to get top mixes: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getRecentListening({int limit = 6}) async {
    try {
      final result = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/recent-listening',
        queryParams: {'limit': limit.toString()},
      );

      // API now returns {items: [...], total_count: N}
      if (result['items'] is List) {
        return result['items'];
      }

      _logger.w('Expected items List but got ${result.runtimeType}: $result');
      return <dynamic>[];
    } catch (e) {
      _logger.e('Failed to get recent listening data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/home/stats',
      );
    } catch (e) {
      _logger.e('Failed to get user stats: $e');
      rethrow;
    }
  }
}
