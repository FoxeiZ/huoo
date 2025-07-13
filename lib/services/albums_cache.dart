import 'package:flutter/foundation.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/services/songs_cache.dart';

class AlbumsCache {
  static final AlbumsCache _instance = AlbumsCache._internal();

  factory AlbumsCache() => _instance;

  AlbumsCache._internal();
  List<Album>? _cachedAlbums;
  Map<int, List<int>>?
  _cachedAlbumSongIds; // Store song IDs instead of Song objects
  DateTime? _lastUpdated;
  bool _isLoading = false;
  final _listeners = <Function>[];
  final SongsCache _songsCache = SongsCache();

  /// Returns cached albums if available, otherwise loads from database
  Future<Map<String, dynamic>> getAlbums({bool forceRefresh = false}) async {
    // If we're already loading albums, wait for that to complete
    if (_isLoading) {
      // Wait until loading is complete and return the result
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Convert IDs back to songs
      final albumSongs = await _convertIdsToSongs(_cachedAlbumSongIds ?? {});

      return {'albums': _cachedAlbums ?? [], 'albumSongs': albumSongs};
    }

    // If we have cached albums and not forcing refresh, return them
    if (!forceRefresh && _cachedAlbums != null && _cachedAlbumSongIds != null) {
      // Convert IDs back to songs
      final albumSongs = await _convertIdsToSongs(_cachedAlbumSongIds!);

      return {'albums': _cachedAlbums!, 'albumSongs': albumSongs};
    }
    try {
      _isLoading = true;

      // Ensure songs cache is loaded first
      await _songsCache.getSongs(forceRefresh: forceRefresh);

      final albums = await DatabaseHelper().albumProvider.getAll();
      final Map<int, List<int>> albumSongIds = {};

      // Get songs for each album
      for (final album in albums) {
        if (album.id != null) {
          final songs = await DatabaseHelper().songProvider
              .getSongsByAlbumWithDetails(album.id!);
          // Store only the song IDs
          albumSongIds[album.id!] =
              songs.map((s) => s.id).whereType<int>().toList();

          // Make sure all songs are in the songs cache
          for (final song in songs) {
            _songsCache.addOrUpdateSong(song);
          }
        }
      }

      _cachedAlbums = albums;
      _cachedAlbumSongIds = albumSongIds;
      _lastUpdated = DateTime.now();

      // Convert IDs back to songs for the response
      final albumSongs = await _convertIdsToSongs(albumSongIds);

      return {'albums': albums, 'albumSongs': albumSongs};
    } catch (e) {
      debugPrint('Error loading albums: $e');
      rethrow;
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// Converts a map of album IDs to song IDs into a map of album IDs to Song objects
  Future<Map<int, List<Song>>> _convertIdsToSongs(
    Map<int, List<int>> albumSongIds,
  ) async {
    final Map<int, List<Song>> result = {};
    final allSongs = await _songsCache.getSongs();

    // Create a lookup map for quick access to songs by ID
    final songsById = {
      for (var song in allSongs)
        if (song.id != null) song.id!: song,
    };

    // Convert IDs to song objects
    for (final albumId in albumSongIds.keys) {
      final songIds = albumSongIds[albumId]!;
      result[albumId] =
          songIds.map((id) => songsById[id]).whereType<Song>().toList();
    }

    return result;
  }

  /// Clears the albums cache
  void clearCache() {
    _cachedAlbums = null;
    _cachedAlbumSongIds = null;
    _lastUpdated = null;
    _notifyListeners();
  }

  /// Adds a listener to be notified when the cache changes
  void addListener(Function listener) {
    _listeners.add(listener);
  }

  /// Removes a listener
  void removeListener(Function listener) {
    _listeners.remove(listener);
  }

  /// Notifies all listeners that the cache has changed
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Returns true if the cache is empty or has expired
  bool get needsRefresh {
    if (_cachedAlbums == null ||
        _cachedAlbumSongIds == null ||
        _lastUpdated == null) {
      return true;
    }

    // Cache expires after 1 hour
    final expiryTime = _lastUpdated!.add(const Duration(hours: 1));
    return DateTime.now().isAfter(expiryTime);
  }

  /// Returns the last time the cache was updated
  DateTime? get lastUpdated => _lastUpdated;

  /// Returns true if albums are currently being loaded
  bool get isLoading => _isLoading;
}
