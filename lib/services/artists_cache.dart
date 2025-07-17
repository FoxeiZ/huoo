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
  Map<int, List<int>>? _cachedArtistSongIds;
  DateTime? _lastUpdated;
  bool _isLoading = false;
  final _listeners = <Function>[];
  final SongsCache _songsCache = SongsCache();

  Future<Map<String, dynamic>> getArtists({bool forceRefresh = false}) async {
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final artistSongs = await _convertIdsToSongs(_cachedArtistSongIds ?? {});

      return {'artists': _cachedArtists ?? [], 'artistSongs': artistSongs};
    }

    if (!forceRefresh &&
        _cachedArtists != null &&
        _cachedArtistSongIds != null) {
      final artistSongs = await _convertIdsToSongs(_cachedArtistSongIds!);

      return {'artists': _cachedArtists!, 'artistSongs': artistSongs};
    }

    try {
      _isLoading = true;

      await _songsCache.getSongs(forceRefresh: forceRefresh);

      final artists = await DatabaseHelper().artistProvider.getAll();
      final Map<int, List<int>> artistSongIds = {};

      for (final artist in artists) {
        if (artist.id != null) {
          final songs = await DatabaseHelper().songProvider
              .getSongsByArtistWithDetails(artist.id!);

          artistSongIds[artist.id!] =
              songs.map((s) => s.id).whereType<int>().toList();

          for (final song in songs) {
            _songsCache.addOrUpdateSong(song);
          }
        }
      }

      _cachedArtists = artists;
      _cachedArtistSongIds = artistSongIds;
      _lastUpdated = DateTime.now();

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

  Future<Map<int, List<Song>>> _convertIdsToSongs(
    Map<int, List<int>> artistSongIds,
  ) async {
    final Map<int, List<Song>> result = {};
    final allSongs = await _songsCache.getSongs();

    final songsById = {
      for (var song in allSongs)
        if (song.id != null) song.id!: song,
    };

    for (final artistId in artistSongIds.keys) {
      final songIds = artistSongIds[artistId]!;
      result[artistId] =
          songIds.map((id) => songsById[id]).whereType<Song>().toList();
    }

    return result;
  }

  void clearCache() {
    _cachedArtists = null;
    _cachedArtistSongIds = null;
    _lastUpdated = null;
    _notifyListeners();
  }

  void addListener(Function listener) {
    _listeners.add(listener);
  }

  void removeListener(Function listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  bool get needsRefresh {
    if (_cachedArtists == null ||
        _cachedArtistSongIds == null ||
        _lastUpdated == null) {
      return true;
    }

    final expiryTime = _lastUpdated!.add(const Duration(hours: 1));
    return DateTime.now().isAfter(expiryTime);
  }

  DateTime? get lastUpdated => _lastUpdated;

  bool get isLoading => _isLoading;
}
