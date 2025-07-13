import 'package:flutter/foundation.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/services/songs_cache.dart';

class ArtistsCache {
  static final ArtistsCache _instance = ArtistsCache._internal();

  factory ArtistsCache() => _instance;

  ArtistsCache._internal();

  List<Artist>? _cachedArtists;
  Map<int, List<int>>?
  _cachedArtistSongIds; // Store song IDs instead of Song objects
  DateTime? _lastUpdated;
  bool _isLoading = false;
  final _listeners = <Function>[];
  final SongsCache _songsCache = SongsCache();

  /// Returns cached artists if available, otherwise loads from database
  Future<Map<String, dynamic>> getArtists({bool forceRefresh = false}) async {
    // If we're already loading artists, wait for that to complete
    if (_isLoading) {
      // Wait until loading is complete and return the result
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Convert IDs back to songs
      final artistSongs = await _convertIdsToSongs(_cachedArtistSongIds ?? {});

      return {'artists': _cachedArtists ?? [], 'artistSongs': artistSongs};
    }

    // If we have cached artists and not forcing refresh, return them
    if (!forceRefresh &&
        _cachedArtists != null &&
        _cachedArtistSongIds != null) {
      // Convert IDs back to songs
      final artistSongs = await _convertIdsToSongs(_cachedArtistSongIds!);

      return {'artists': _cachedArtists!, 'artistSongs': artistSongs};
    }

    try {
      _isLoading = true;

      // Ensure songs cache is loaded first
      await _songsCache.getSongs(forceRefresh: forceRefresh);

      final artists = await DatabaseHelper().artistProvider.getAll();
      final Map<int, List<int>> artistSongIds = {};

      // Get songs for each artist
      for (final artist in artists) {
        if (artist.id != null) {
          final songs = await DatabaseHelper().songProvider
              .getSongsByArtistWithDetails(artist.id!);
          // Store only the song IDs
          artistSongIds[artist.id!] =
              songs.map((s) => s.id).whereType<int>().toList();

          // Make sure all songs are in the songs cache
          for (final song in songs) {
            _songsCache.addOrUpdateSong(song);
          }
        }
      }

      _cachedArtists = artists;
      _cachedArtistSongIds = artistSongIds;
      _lastUpdated = DateTime.now();

      // Convert IDs back to songs for the response
      final artistSongs = await _convertIdsToSongs(artistSongIds);

      return {'artists': artists, 'artistSongs': artistSongs};
    } catch (e) {
      debugPrint('Error loading artists: $e');
      rethrow;
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// Converts a map of artist IDs to song IDs into a map of artist IDs to Song objects
  Future<Map<int, List<Song>>> _convertIdsToSongs(
    Map<int, List<int>> artistSongIds,
  ) async {
    final Map<int, List<Song>> result = {};
    final allSongs = await _songsCache.getSongs();

    // Create a lookup map for quick access to songs by ID
    final songsById = {
      for (var song in allSongs)
        if (song.id != null) song.id!: song,
    };

    // Convert IDs to song objects
    for (final artistId in artistSongIds.keys) {
      final songIds = artistSongIds[artistId]!;
      result[artistId] =
          songIds.map((id) => songsById[id]).whereType<Song>().toList();
    }

    return result;
  }

  /// Clears the artists cache
  void clearCache() {
    _cachedArtists = null;
    _cachedArtistSongIds = null;
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
    if (_cachedArtists == null ||
        _cachedArtistSongIds == null ||
        _lastUpdated == null) {
      return true;
    }

    // Cache expires after 1 hour
    final expiryTime = _lastUpdated!.add(const Duration(hours: 1));
    return DateTime.now().isAfter(expiryTime);
  }

  /// Returns the last time the cache was updated
  DateTime? get lastUpdated => _lastUpdated;

  /// Returns true if artists are currently being loaded
  bool get isLoading => _isLoading;
}
