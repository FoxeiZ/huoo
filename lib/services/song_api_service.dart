import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:huoo/services/api_service.dart';
import 'package:huoo/models/api/api_models.dart';

final Logger _logger = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class SongApiService {
  final ApiService _apiService = ApiService();

  static final SongApiService _instance = SongApiService._internal();
  factory SongApiService() => _instance;
  SongApiService._internal();

  Future<List<SongApiModel>> getSongs({
    int limit = 50,
    int offset = 0,
    SongSearchFilters? filters,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (filters != null) {
        queryParams.addAll(filters.toQueryParams());
      }

      final response = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/songs',
        queryParams: queryParams,
      );

      if (response['songs'] is List) {
        return (response['songs'] as List<dynamic>)
            .map(
              (songJson) =>
                  SongApiModel.fromJson(songJson as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      _logger.e('Failed to get songs: $e');
      rethrow;
    }
  }

  Future<SongApiModel> getSongById(String songId) async {
    try {
      final response = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/songs/$songId',
      );

      return SongApiModel.fromJson(response);
    } catch (e) {
      _logger.e('Failed to get song by ID $songId: $e');
      rethrow;
    }
  }

  Future<SongApiModel> createSong(SongCreateRequest request) async {
    try {
      final response = await _apiService.makeRequest(
        method: 'POST',
        endpoint: '/songs',
        body: request.toJson(),
      );

      return SongApiModel.fromJson(response);
    } catch (e) {
      _logger.e('Failed to create song: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSong({
    required String songId,
    String? title,
    List<String>? artists,
    String? album,
    int? year,
    int? trackNumber,
    int? trackTotal,
    int? duration,
    List<String>? genres,
    String? lyrics,
    double? rating,
    String? filePath,
    String? coverUrl,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (title != null) body['title'] = title;
      if (artists != null) body['artists'] = artists;
      if (album != null) body['album'] = album;
      if (year != null) body['year'] = year;
      if (trackNumber != null) body['track_number'] = trackNumber;
      if (trackTotal != null) body['track_total'] = trackTotal;
      if (duration != null) body['duration'] = duration;
      if (genres != null) body['genres'] = genres;
      if (lyrics != null) body['lyrics'] = lyrics;
      if (rating != null) body['rating'] = rating;
      if (filePath != null) body['file_path'] = filePath;
      if (coverUrl != null) body['cover_url'] = coverUrl;

      return await _apiService.makeRequest(
        method: 'PUT',
        endpoint: '/songs/$songId',
        body: body,
      );
    } catch (e) {
      _logger.e('Failed to update song $songId: $e');
      rethrow;
    }
  }

  Future<void> deleteSong(String songId) async {
    try {
      await _apiService.makeRequest(
        method: 'DELETE',
        endpoint: '/songs/$songId',
      );
    } catch (e) {
      _logger.e('Failed to delete song $songId: $e');
      rethrow;
    }
  }

  Future<void> playSong(String songId) async {
    try {
      await _apiService.makeRequest(
        method: 'POST',
        endpoint: '/songs/$songId/play',
      );
    } catch (e) {
      _logger.e('Failed to record song play $songId: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleFavoriteSong(String songId) async {
    try {
      return await _apiService.makeRequest(
        method: 'POST',
        endpoint: '/songs/$songId/favorite',
      );
    } catch (e) {
      _logger.e('Failed to toggle favorite for song $songId: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPopularSongs({int limit = 20}) async {
    try {
      final queryParams = <String, String>{'limit': limit.toString()};

      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/songs/popular/trending',
        queryParams: queryParams,
      );
    } catch (e) {
      _logger.e('Failed to get popular songs: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRecentSongs({int limit = 20}) async {
    try {
      final queryParams = <String, String>{'limit': limit.toString()};

      return await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/songs/recent/new',
        queryParams: queryParams,
      );
    } catch (e) {
      _logger.e('Failed to get recent songs: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadSong({
    required String title,
    required List<String> artists,
    required File audioFile,
    String? album,
    int? year,
    int trackNumber = 0,
    int trackTotal = 0,
    int? duration,
    List<String> genres = const [],
    String? lyrics,
    double? rating,
    File? coverImage,
  }) async {
    try {
      final headers = await _apiService.getHeaders(includeAuth: true);

      final uri = Uri.parse('${ApiConfig.baseUrl}/songs/upload');
      final request = http.MultipartRequest('POST', uri);

      headers.forEach((key, value) {
        if (key != 'Content-Type') {
          request.headers[key] = value;
        }
      });

      request.fields['title'] = title;
      request.fields['artists'] = artists.join(',');
      request.fields['track_number'] = trackNumber.toString();
      request.fields['track_total'] = trackTotal.toString();
      request.fields['genres'] = genres.join(',');

      if (album != null) request.fields['album'] = album;
      if (year != null) request.fields['year'] = year.toString();
      if (duration != null) request.fields['duration'] = duration.toString();
      if (lyrics != null) request.fields['lyrics'] = lyrics;
      if (rating != null) request.fields['rating'] = rating.toString();

      request.files.add(
        await http.MultipartFile.fromPath('audio_file', audioFile.path),
      );

      if (coverImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('cover_image', coverImage.path),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(responseBody);
      } else {
        throw ApiException(
          'Upload failed with status ${response.statusCode}: $responseBody',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      _logger.e('Failed to upload song: $e');
      rethrow;
    }
  }

  Future<String> getSongFileUrl(String songId) async {
    try {
      return '${ApiConfig.baseUrl}/songs/file/$songId';
    } catch (e) {
      _logger.e('Failed to get song file URL for $songId: $e');
      rethrow;
    }
  }
}
