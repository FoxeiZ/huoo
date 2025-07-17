import 'package:logger/logger.dart';
import 'package:huoo/services/api_service.dart';
import 'package:huoo/models/playlist.dart';

final Logger _logger = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class PlaylistApiService {
  final ApiService _apiService = ApiService();

  // Singleton pattern
  static final PlaylistApiService _instance = PlaylistApiService._internal();
  factory PlaylistApiService() => _instance;
  PlaylistApiService._internal();

  // Get all user playlists
  Future<List<Playlist>> getPlaylists() async {
    try {
      final response = await _apiService.makeRequest(
        method: 'GET',
        endpoint: '/playlists',
      );
      final List<dynamic> playlistsJson =
          response['items'] ?? response['data'] ?? [];
      return playlistsJson
          .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch playlists: $e');
      rethrow;
    }
  }

  // Create a new playlist
  Future<Playlist> createPlaylist({
    required String name,
    String? description,
  }) async {
    try {
      final body = {
        'name': name,
        if (description != null) 'description': description,
      };

      final response = await _apiService.makeRequest(
        method: 'POST',
        endpoint: '/playlists',
        body: body,
      );
      return Playlist.fromJson(response);
    } catch (e) {
      _logger.e('Failed to create playlist: $e');
      rethrow;
    }
  }

  // Add a song to a playlist
  Future<void> addSongToPlaylist({
    required String playlistId,
    required String musicId,
  }) async {
    try {
      await _apiService.makeRequest(
        method: 'POST',
        endpoint: '/playlists/$playlistId/songs/$musicId',
      );
    } catch (e) {
      _logger.e('Failed to add song $musicId to playlist $playlistId: $e');
      rethrow;
    }
  }

  // Remove a song from a playlist
  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String musicId,
  }) async {
    try {
      await _apiService.makeRequest(
        method: 'DELETE',
        endpoint: '/playlists/$playlistId/songs/$musicId',
      );
    } catch (e) {
      _logger.e('Failed to remove song $musicId from playlist $playlistId: $e');
      rethrow;
    }
  }
}
