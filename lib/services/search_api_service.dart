import 'package:logger/logger.dart';
import 'package:huoo/services/api_service.dart';
import 'package:huoo/models/api/api_models.dart';

final Logger _logger = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class SearchApiService {
  final ApiService _apiService = ApiService();

  // Singleton pattern
  static final SearchApiService _instance = SearchApiService._internal();
  factory SearchApiService() => _instance;
  SearchApiService._internal();

  Future<SearchResponse> searchMusic({
    required String query,
    int page = 1,
    int limit = 20,
    String? searchType, // 'all', 'songs', 'artists', 'albums'
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (searchType != null) queryParams['type'] = searchType;

      final response = await _apiService
          .makeRequest(
            method: 'GET',
            endpoint: '/search',
            queryParams: queryParams,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Search request timed out. Please try again.');
            },
          );

      return SearchResponse.fromJson(response);
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to search music with query "$query": $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<SearchSuggestionsResponse> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'limit': limit.toString(),
      };

      final response = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/search/suggestions',
        queryParams: queryParams,
      );

      return SearchSuggestionsResponse.fromJson(response);
    } catch (e) {
      _logger.e('Failed to get search suggestions for "$query": $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTrendingSearches({int limit = 10}) async {
    try {
      final queryParams = <String, String>{'limit': limit.toString()};

      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/search/trending',
        queryParams: queryParams,
      );
    } catch (e) {
      _logger.e('Failed to get trending searches: $e');
      rethrow;
    }
  }
}
