import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import '../models/song_reference.dart';
import '../helpers/database/helper.dart';

final log = Logger(
  filter: DevelopmentFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class PlayerPersistenceService {
  static const String _playlistKey = 'lightweight_playlist';
  static const String _currentIndexKey = 'current_index';
  static const String _currentPositionKey = 'current_position';
  static const String _loopModeKey = 'loop_mode';
  static const String _shuffleModeKey = 'shuffle_mode';
  static const String _volumeKey = 'volume';
  static const String _lastPlayedKey = 'last_played';

  static Future<void> savePlayerState({
    required List<SongReference> songReferences,
    int? currentIndex,
    Duration? currentPosition,
    String? loopMode,
    bool? shuffleMode,
    double? volume,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final referencesJson = songReferences.map((ref) => ref.toMap()).toList();
      await prefs.setString(_playlistKey, jsonEncode(referencesJson));

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

      log.i(
        'Lightweight player state saved: ${songReferences.length} song references',
      );
    } catch (e) {
      log.e('Error saving lightweight player state: $e');
    }
  }

  static Future<LightweightPlayerState?> loadPlayerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final playlistJson = prefs.getString(_playlistKey);
      if (playlistJson == null) {
        log.i('No saved lightweight playlist found');
        return null;
      }

      final referencesData = jsonDecode(playlistJson) as List;
      final songReferences =
          referencesData
              .map(
                (data) => SongReference.fromMap(data as Map<String, dynamic>),
              )
              .toList();

      if (songReferences.isEmpty) {
        log.i('Saved lightweight playlist is empty');
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

      log.i(
        'Lightweight player state loaded: ${songReferences.length} song references',
      );

      return LightweightPlayerState(
        songReferences: songReferences,
        currentIndex: currentIndex.clamp(0, songReferences.length - 1),
        currentPosition: currentPosition,
        loopMode: loopMode,
        shuffleMode: shuffleMode,
        volume: volume,
        lastPlayed: lastPlayed,
      );
    } catch (e) {
      log.e('Error loading lightweight player state: $e');
      return null;
    }
  }

  /// Convert song references back to full Song objects (only when needed)
  static Future<List<Song>> reconstructSongs(
    List<SongReference> references,
  ) async {
    final helper = DatabaseHelper();
    final songs = <Song>[];

    for (final ref in references) {
      try {
        final song = await helper.songProvider.getSongWithDetails(ref.id);
        if (song != null) {
          songs.add(song);
        } else {
          log.w(
            'Warning: Could not find song with id ${ref.id} (${ref.title})',
          );
        }
      } catch (e) {
        log.e('Error reconstructing song ${ref.id}: $e');
      }
    }

    return songs;
  }

  /// Extract song references from audio sources (fast operation)
  static List<SongReference> extractSongReferences(List<dynamic> audioSources) {
    final references = <SongReference>[];

    for (final source in audioSources) {
      try {
        final mediaItem = source.tag;
        if (mediaItem != null) {
          references.add(SongReference.fromMediaItem(mediaItem));
        }
      } catch (e) {
        log.e('Error extracting song reference: $e');
      }
    }

    return references;
  }

  static Future<void> saveCurrentPosition(Duration position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentPositionKey, position.inMilliseconds);
    } catch (e) {
      log.e('Error saving current position: $e');
    }
  }

  static Future<void> clearPlayerState() async {
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

      log.i('Lightweight player state cleared');
    } catch (e) {
      log.e('Error clearing lightweight player state: $e');
    }
  }
}

class LightweightPlayerState {
  final List<SongReference> songReferences;
  final int currentIndex;
  final Duration currentPosition;
  final String loopMode;
  final bool shuffleMode;
  final double volume;
  final DateTime lastPlayed;

  const LightweightPlayerState({
    required this.songReferences,
    required this.currentIndex,
    required this.currentPosition,
    required this.loopMode,
    required this.shuffleMode,
    required this.volume,
    required this.lastPlayed,
  });

  @override
  String toString() {
    return 'LightweightPlayerState(songRefs: ${songReferences.length}, '
        'currentIndex: $currentIndex, position: ${currentPosition.inSeconds}s, '
        'loopMode: $loopMode, shuffleMode: $shuffleMode, volume: $volume)';
  }
}
