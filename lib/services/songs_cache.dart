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

  /// get cached songs if available, otherwise loads from database
  Future<List<Song>> getSongs({bool forceRefresh = false}) async {
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedSongs ?? [];
    }

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

  void addSong(Song song) {
    if (_cachedSongs != null) {
      _cachedSongs!.add(song);
      _lastUpdated = DateTime.now();
      _notifyListeners();
    }
  }

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

  void addOrUpdateSong(Song song) {
    if (_cachedSongs != null) {
      final index = _cachedSongs!.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        _cachedSongs![index] = song;
      } else {
        _cachedSongs!.add(song);
      }
      _lastUpdated = DateTime.now();
      _notifyListeners();
    }
  }

  void removeSong(Song song) {
    if (_cachedSongs != null) {
      _cachedSongs!.removeWhere((s) => s.id == song.id);
      _lastUpdated = DateTime.now();
      _notifyListeners();
    }
  }

  void clearCache() {
    _cachedSongs = null;
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
    if (_cachedSongs == null || _lastUpdated == null) return true;

    final expiryTime = _lastUpdated!.add(const Duration(hours: 1));
    return DateTime.now().isAfter(expiryTime);
  }

  DateTime? get lastUpdated => _lastUpdated;

  bool get isLoading => _isLoading;
}
