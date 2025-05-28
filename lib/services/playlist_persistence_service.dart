import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

/// Service responsible for persisting playlist state and restoring it
class PlaylistPersistenceService {
  static const String _playlistKey = 'saved_playlist';
  static const String _currentIndexKey = 'current_index';
  static const String _currentPositionKey = 'current_position';
  static const String _loopModeKey = 'loop_mode';
  static const String _shuffleModeKey = 'shuffle_mode';
  static const String _volumeKey = 'volume';
  static const String _lastPlayedKey = 'last_played';

  /// Save the current playlist state
  static Future<void> savePlaylistState({
    required List<Song> songs,
    int? currentIndex,
    Duration? currentPosition,
    String? loopMode,
    bool? shuffleMode,
    double? volume,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final songsJson = songs.map((song) => song.toJson()).toList();
      await prefs.setString(_playlistKey, jsonEncode(songsJson));

      if (currentIndex != null) {
        await prefs.setInt(_currentIndexKey, currentIndex);
      }
      if (currentPosition != null) {
        await prefs.setInt(_currentPositionKey, currentPosition.inMilliseconds);
      }
      if (loopMode != null) {
        await prefs.setString(_loopModeKey, loopMode);
      }
      if (shuffleMode != null) {
        await prefs.setBool(_shuffleModeKey, shuffleMode);
      }
      if (volume != null) {
        await prefs.setDouble(_volumeKey, volume);
      }
      await prefs.setInt(_lastPlayedKey, DateTime.now().millisecondsSinceEpoch);
      log('Playlist state saved successfully');
    } catch (e) {
      log('Error saving playlist state: $e');
    }
  }

  static Future<PlaylistState?> loadPlaylistState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load playlist songs
      final playlistJson = prefs.getString(_playlistKey);
      if (playlistJson == null) {
        log('No saved playlist found');
        return null;
      }

      final songsData = jsonDecode(playlistJson) as List;
      final songs =
          songsData
              .map(
                (songData) => Song.fromJson(songData as Map<String, dynamic>),
              )
              .toList();

      if (songs.isEmpty) {
        log('Saved playlist is empty');
        return null;
      }

      // Load other state data
      final currentIndex = prefs.getInt(_currentIndexKey) ?? 0;
      final positionMs = prefs.getInt(_currentPositionKey) ?? 0;
      final currentPosition = Duration(milliseconds: positionMs);
      final loopMode = prefs.getString(_loopModeKey) ?? 'off';
      final shuffleMode = prefs.getBool(_shuffleModeKey) ?? false;
      final volume = prefs.getDouble(_volumeKey) ?? 0.3;
      final lastPlayedMs = prefs.getInt(_lastPlayedKey) ?? 0;
      final lastPlayed = DateTime.fromMillisecondsSinceEpoch(lastPlayedMs);

      log('Playlist state loaded successfully: ${songs.length} songs');

      return PlaylistState(
        songs: songs,
        currentIndex: currentIndex.clamp(0, songs.length - 1),
        currentPosition: currentPosition,
        loopMode: loopMode,
        shuffleMode: shuffleMode,
        volume: volume,
        lastPlayed: lastPlayed,
      );
    } catch (e) {
      log('Error loading playlist state: $e');
      return null;
    }
  }

  static Future<void> clearPlaylistState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_playlistKey),
        prefs.remove(_currentIndexKey),
        prefs.remove(_currentPositionKey),
        prefs.remove(_loopModeKey),
        prefs.remove(_shuffleModeKey),
        prefs.remove(_volumeKey),
        prefs.remove(_lastPlayedKey),
      ]);

      log('Playlist state cleared');
    } catch (e) {
      log('Error clearing playlist state: $e');
    }
  }

  /// Check if there's a saved playlist
  static Future<bool> hasSavedPlaylist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_playlistKey);
    } catch (e) {
      log('Error checking for saved playlist: $e');
      return false;
    }
  }

  /// Get the timestamp of when the playlist was last played
  static Future<DateTime?> getLastPlayedTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPlayedMs = prefs.getInt(_lastPlayedKey);
      if (lastPlayedMs != null) {
        return DateTime.fromMillisecondsSinceEpoch(lastPlayedMs);
      }
      return null;
    } catch (e) {
      log('Error getting last played time: $e');
      return null;
    }
  }

  /// Save only the current position (for frequent updates)
  static Future<void> saveCurrentPosition(Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentPositionKey, position.inMilliseconds);
    } catch (e) {
      log('Error saving current position: $e');
    }
  }

  /// Save only the current index (when skipping tracks)
  static Future<void> saveCurrentIndex(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentIndexKey, index);
    } catch (e) {
      log('Error saving current index: $e');
    }
  }
}

class PlaylistState {
  final List<Song> songs;
  final int currentIndex;
  final Duration currentPosition;
  final String loopMode;
  final bool shuffleMode;
  final double volume;
  final DateTime lastPlayed;

  const PlaylistState({
    required this.songs,
    required this.currentIndex,
    required this.currentPosition,
    required this.loopMode,
    required this.shuffleMode,
    required this.volume,
    required this.lastPlayed,
  });

  @override
  String toString() {
    return 'PlaylistState(songs: ${songs.length}, currentIndex: $currentIndex, '
        'position: ${currentPosition.inSeconds}s, loopMode: $loopMode, '
        'shuffleMode: $shuffleMode, volume: $volume, lastPlayed: $lastPlayed)';
  }
}
