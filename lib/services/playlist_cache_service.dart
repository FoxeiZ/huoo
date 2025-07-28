import 'package:logger/logger.dart';
import 'package:huoo/models/playlist.dart';
import 'package:huoo/services/playlist_api_service.dart';
import 'package:huoo/base/db/wrapper.dart';

final Logger _logger = Logger(
  printer: SimplePrinter(),
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class PlaylistCacheService {
  final PlaylistApiService _apiService = PlaylistApiService();
  late final PlaylistProvider _playlistProvider;

  // Singleton pattern
  static final PlaylistCacheService _instance =
      PlaylistCacheService._internal();
  factory PlaylistCacheService() => _instance;
  PlaylistCacheService._internal();

  Future<void> initialize(DatabaseOperation dbWrapper) async {
    _playlistProvider = PlaylistProvider(dbWrapper);
  }

  // Get all local playlists
  Future<List<Playlist>> getLocalPlaylists() async {
    try {
      return await _playlistProvider.getPlaylistsByType(PlaylistType.local);
    } catch (e) {
      _logger.e('Failed to get local playlists: $e');
      return [];
    }
  }

  // Get all online playlists (cached)
  Future<List<Playlist>> getCachedOnlinePlaylists() async {
    try {
      return await _playlistProvider.getPlaylistsByType(PlaylistType.online);
    } catch (e) {
      _logger.e('Failed to get cached online playlists: $e');
      return [];
    }
  }

  // Sync online playlists from API
  Future<List<Playlist>> syncOnlinePlaylists() async {
    try {
      final onlinePlaylistsResponse = await _apiService.getPlaylists();
      final onlinePlaylists = onlinePlaylistsResponse.playlists;

      // Clear existing online playlists
      final existingOnline = await getCachedOnlinePlaylists();
      for (final playlist in existingOnline) {
        if (playlist.id != null) {
          await _playlistProvider.delete(playlist.id!);
        }
      }

      // Insert new online playlists
      final cachedPlaylists = <Playlist>[];
      for (final playlistApi in onlinePlaylists) {
        // Convert PlaylistApiModel to legacy Playlist model
        final playlist = Playlist.online(
          name: playlistApi.name,
          description: playlistApi.description,
          apiId: playlistApi.id,
          coverUrl: playlistApi.coverUrl,
          createdAt: DateTime.parse(playlistApi.createdAt),
          updatedAt: DateTime.parse(playlistApi.updatedAt),
        );
        final cached = await _playlistProvider.insert(playlist);
        cachedPlaylists.add(cached);
      }

      return cachedPlaylists;
    } catch (e) {
      _logger.e('Failed to sync online playlists: $e');
      // Return cached playlists if sync fails
      return await getCachedOnlinePlaylists();
    }
  }

  // Create a local playlist
  Future<Playlist> createLocalPlaylist({
    required String name,
    String? description,
    String? coverUrl,
  }) async {
    try {
      final playlist = Playlist.local(
        name: name,
        description: description,
        coverUrl: coverUrl,
      );
      return await _playlistProvider.insert(playlist);
    } catch (e) {
      _logger.e('Failed to create local playlist: $e');
      rethrow;
    }
  }

  // Create an online playlist
  Future<Playlist> createOnlinePlaylist({
    required String name,
    String? description,
  }) async {
    try {
      // Create via API
      final onlinePlaylist = await _apiService.createPlaylist(
        name: name,
        description: description,
      );

      // Convert PlaylistApiModel to legacy Playlist model
      final playlist = Playlist.online(
        name: onlinePlaylist.name,
        description: onlinePlaylist.description,
        apiId: onlinePlaylist.id,
        coverUrl: onlinePlaylist.coverUrl,
        createdAt: DateTime.parse(onlinePlaylist.createdAt),
        updatedAt: DateTime.parse(onlinePlaylist.updatedAt),
      );

      // Cache locally
      return await _playlistProvider.insert(playlist);
    } catch (e) {
      _logger.e('Failed to create online playlist: $e');
      rethrow;
    }
  }

  // Delete a playlist
  Future<void> deletePlaylist(Playlist playlist) async {
    try {
      // Note: API service doesn't have delete method, so only delete locally
      if (playlist.id != null) {
        await _playlistProvider.delete(playlist.id!);
      }
    } catch (e) {
      _logger.e('Failed to delete playlist: $e');
      rethrow;
    }
  }

  // Add song to playlist
  Future<void> addSongToPlaylist(Playlist playlist, String songId) async {
    try {
      if (playlist.type == PlaylistType.online && playlist.apiId != null) {
        // Add to API if online
        await _apiService.addSongToPlaylist(
          playlistId: playlist.apiId!,
          musicId: songId,
        );
      }

      // Add locally
      if (playlist.id != null) {
        await _playlistProvider.addSongToPlaylist(playlist.id!, songId);
      }
    } catch (e) {
      _logger.e('Failed to add song to playlist: $e');
      rethrow;
    }
  }

  // Remove song from playlist
  Future<void> removeSongFromPlaylist(Playlist playlist, String songId) async {
    try {
      if (playlist.type == PlaylistType.online && playlist.apiId != null) {
        // Remove from API if online
        await _apiService.removeSongFromPlaylist(
          playlistId: playlist.apiId!,
          musicId: songId,
        );
      }

      // Remove locally
      if (playlist.id != null) {
        await _playlistProvider.removeSongFromPlaylist(playlist.id!, songId);
      }
    } catch (e) {
      _logger.e('Failed to remove song from playlist: $e');
      rethrow;
    }
  }

  // Get songs in a playlist
  Future<List<PlaylistSong>> getPlaylistSongs(Playlist playlist) async {
    try {
      if (playlist.id != null) {
        return await _playlistProvider.getPlaylistSongs(playlist.id!);
      }
      return [];
    } catch (e) {
      _logger.e('Failed to get playlist songs: $e');
      return [];
    }
  }

  // Update playlist
  Future<Playlist> updatePlaylist(
    Playlist playlist, {
    String? name,
    String? description,
    String? coverUrl,
  }) async {
    try {
      final updatedPlaylist = playlist.copyWith(
        name: name,
        description: description,
        coverUrl: coverUrl,
        updatedAt: DateTime.now(),
      );

      // Update locally
      if (playlist.id != null) {
        await _playlistProvider.update(updatedPlaylist);
      }

      return updatedPlaylist;
    } catch (e) {
      _logger.e('Failed to update playlist: $e');
      rethrow;
    }
  }
}
