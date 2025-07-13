import 'package:flutter/foundation.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/helpers/database/helper.dart';

class SongsCache {
  static final SongsCache _instance = SongsCache._internal();

  factory SongsCache() => _instance;

  SongsCache._internal();

  List<Song>? _cachedSongs;
  DateTime? _lastUpdated;
  bool _isLoading = false;
  final _listeners = <Function>[];

  /// Returns cached songs if available, otherwise loads from database
  Future<List<Song>> getSongs({bool forceRefresh = false}) async {
    // If we're already loading songs, wait for that to complete
    if (_isLoading) {
      // Wait until loading is complete and return the result
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedSongs ?? [];
    }

    // If we have cached songs and not forcing refresh, return them
    if (!forceRefresh && _cachedSongs != null) {
      return _cachedSongs!;
    }

    try {
      _isLoading = true;
      final songs =
          await DatabaseHelper().songProvider.getAllSongsWithDetails();
      _cachedSongs = songs;
      _lastUpdated = DateTime.now();
      return songs;
    } catch (e) {
      debugPrint('Error loading songs: $e');
      rethrow;
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// Adds a song to the cache
  void addSong(Song song) {
    if (_cachedSongs != null) {
      _cachedSongs!.add(song);
      _lastUpdated = DateTime.now();
      _notifyListeners();
    }
  }

  /// Updates a song in the cache
  void updateSong(Song song) {
    if (_cachedSongs != null) {
      final index = _cachedSongs!.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        _cachedSongs![index] = song;
        _lastUpdated = DateTime.now();
        _notifyListeners();
      }
    }
  }

  /// Adds or updates a song in the cache
  void addOrUpdateSong(Song song) {
    if (_cachedSongs != null) {
      final index = _cachedSongs!.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        _cachedSongs![index] = song; // Update
      } else {
        _cachedSongs!.add(song); // Add
      }
      _lastUpdated = DateTime.now();
      _notifyListeners();
    }
  }

  /// Removes a song from the cache
  void removeSong(Song song) {
    if (_cachedSongs != null) {
      _cachedSongs!.removeWhere((s) => s.id == song.id);
      _lastUpdated = DateTime.now();
      _notifyListeners();
    }
  }

  /// Clears the songs cache
  void clearCache() {
    _cachedSongs = null;
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
    if (_cachedSongs == null || _lastUpdated == null) return true;

    // Cache expires after 1 hour
    final expiryTime = _lastUpdated!.add(const Duration(hours: 1));
    return DateTime.now().isAfter(expiryTime);
  }

  /// Returns the last time the cache was updated
  DateTime? get lastUpdated => _lastUpdated;

  /// Returns true if songs are currently being loaded
  bool get isLoading => _isLoading;
}
