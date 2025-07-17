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

      // Handle the response structure from the Python API
      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> playlistsJson = data['playlists'] ?? data ?? [];
        return playlistsJson
            .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
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
        if (description != null && description.isNotEmpty)
          'description': description,
      };

      final response = await _apiService.makeRequest(
        method: 'POST',
        endpoint: '/playlists',
        body: body,
      );

      // Handle the response structure from the Python API
      if (response['status'] == 'success' && response['data'] != null) {
        return Playlist.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw Exception('Invalid response format');
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
      final body = {'song_id': musicId};

      await _apiService.makeRequest(
        method: 'POST',
        endpoint: '/playlists/$playlistId/songs',
        body: body,
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

  // Delete a playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _apiService.makeRequest(
        method: 'DELETE',
        endpoint: '/playlists/$playlistId',
      );
    } catch (e) {
      _logger.e('Failed to delete playlist $playlistId: $e');
      rethrow;
    }
  }
}
