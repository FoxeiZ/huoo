import 'package:logger/logger.dart';
import 'package:huoo/services/api_service.dart';

final Logger _logger = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class MusicApiService {
  final ApiService _apiService = ApiService();

  // Singleton pattern
  static final MusicApiService _instance = MusicApiService._internal();
  factory MusicApiService() => _instance;
  MusicApiService._internal();

  Future<Map<String, dynamic>> getMusicLibrary({
    int page = 1,
    int limit = 50,
    String? search,
    String? genre,
    String? artist,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (genre != null) queryParams['genre'] = genre;
      if (artist != null) queryParams['artist'] = artist;

      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/music/library',
        queryParams: queryParams,
      );
    } catch (e) {
      _logger.e('Failed to get music library: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadMusicMetadata({
    required String title,
    required String filePath,
    String? artist,
    String? album,
    String? genre,
    int? duration,
  }) async {
    try {
      final body = {
        'title': title,
        'file_path': filePath,
        if (artist != null) 'artist': artist,
        if (album != null) 'album': album,
        if (genre != null) 'genre': genre,
        if (duration != null) 'duration': duration,
      };

      return await _apiService.makeRequest(
        method: 'POST',
        endpoint: '/music/upload',
        body: body,
      );
    } catch (e) {
      _logger.e('Failed to upload music metadata: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMusicFile(String musicId) async {
    try {
      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/music/$musicId',
      );
    } catch (e) {
      _logger.e('Failed to get music file $musicId: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteMusicFile(String musicId) async {
    try {
      return await _apiService.makeRequest(
        method: 'DELETE',
        endpoint: '/music/$musicId',
      );
    } catch (e) {
      _logger.e('Failed to delete music file $musicId: $e');
      rethrow;
    }
  }
}
