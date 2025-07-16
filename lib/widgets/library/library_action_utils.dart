import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/audio_player_bloc.dart';
import '../../models/song.dart';
import '../../screens/main_player.dart';

/// Utility class for common library actions across widgets
class LibraryActionUtils {
  /// Shows a snackbar with the given message
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1DB954),
      ),
    );
  }

  /// Plays a single song
  static void playSong(BuildContext context, Song song) {
    playSongs(context, [song]);
  }

  /// Plays a list of songs starting from the specified index
  static void playSongs(
    BuildContext context,
    List<Song> songs, [
    int startIndex = 0,
  ]) {
    if (songs.isEmpty) return;

    context.read<AudioPlayerBloc>().add(
      AudioPlayerLoadPlaylistEvent(
        songs,
        initialIndex: startIndex,
        autoPlay: true,
      ),
    );

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }

  /// Adds a single song to queue
  static void addSongToQueue(BuildContext context, Song song) {
    context.read<AudioPlayerBloc>().add(AudioPlayerAddSongEvent(song));
    showSnackBar(context, 'Added "${song.title}" to queue');
  }

  /// Adds multiple songs to queue
  static void addSongsToQueue(BuildContext context, List<Song> songs) {
    if (songs.isEmpty) return;

    context.read<AudioPlayerBloc>().add(AudioPlayerAddSongsEvent(songs));
    showSnackBar(context, 'Added ${songs.length} songs to queue');
  }

  /// Shuffles and plays songs
  static void shufflePlay(BuildContext context, List<Song> songs) {
    if (songs.isEmpty) return;

    final shuffledSongs = List<Song>.from(songs)..shuffle();
    playSongs(context, shuffledSongs);
  }

  /// Alternative shuffle play implementation (using clear playlist)
  static void shufflePlayWithClear(BuildContext context, List<Song> songs) {
    if (songs.isEmpty) return;

    // Create a shuffled copy of the songs
    final shuffledSongs = List<Song>.from(songs)..shuffle();

    // Clear playlist and add shuffled songs
    context.read<AudioPlayerBloc>().add(AudioPlayerClearPlaylistEvent());

    for (final song in shuffledSongs) {
      context.read<AudioPlayerBloc>().add(AudioPlayerAddSongEvent(song));
    }

    context.read<AudioPlayerBloc>().add(AudioPlayerPlayEvent());

    // Navigate to main player
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MainPlayer()));
  }
}
