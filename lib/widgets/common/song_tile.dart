import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huoo/models/artist.dart';
import 'package:path/path.dart' as p;
import 'package:huoo/widgets/common/play_indicator_widget.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final List<ListTile>? extraOptionTiles;
  final void Function(Song)? onPlayOptionPressed;
  final void Function(Song)? onQueueOptionPressed;
  final void Function(Song)? onAddToPlaylistOptionPressed;
  final VoidCallback? onMorePressed;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onPlayOptionPressed,
    this.onQueueOptionPressed,
    this.onAddToPlaylistOptionPressed,
    this.onMorePressed,
    this.extraOptionTiles,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        // Check if this song is currently playing
        bool isCurrentSong = false;

        if (playerState is AudioPlayerReady) {
          final currentSong = playerState.songMetadata;
          isCurrentSong = currentSong?.path == song.path;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color:
                isCurrentSong
                    ? const Color(0xFF1DB954).withValues(alpha: 0.1)
                    : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
            border:
                isCurrentSong
                    ? Border.all(color: const Color(0xFF1DB954), width: 1)
                    : null,
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  song.cover != null && song.cover!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          song.cover!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: Color(0xFF1DB954),
                            );
                          },
                        ),
                      )
                      : const Icon(Icons.music_note, color: Color(0xFF1DB954)),
            ),
            title: Text(
              song.title,
              style: TextStyle(
                color: isCurrentSong ? const Color(0xFF1DB954) : Colors.white,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (song.artist.isNotEmpty && song.artist != 'Various Artists')
                  Text(
                    song.artist,
                    style: TextStyle(
                      color:
                          isCurrentSong
                              ? const Color(0xFF1DB954).withValues(alpha: 0.8)
                              : Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  p.basename(song.path),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated play indicator for current song
                AnimatedPlayIndicator(song: song),

                if (song.duration.inSeconds > 0)
                  Text(
                    song.displayDuration,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  onPressed:
                      onMorePressed ??
                      () => showSongOptions(
                        context,
                        song,
                        onPlayPressed: onPlayOptionPressed,
                        onAddToQueuePressed: onQueueOptionPressed,
                        onAddToPlaylistPressed: onAddToPlaylistOptionPressed,
                      ),
                ),
              ],
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }
}

Widget buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void showSongInfo(BuildContext context, Song song) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Song Information',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoRow('Title', song.title),
            buildInfoRow(
              'Artist',
              song.artist.isNotEmpty ? song.artist : 'Unknown',
            ),
            buildInfoRow('Duration', song.displayDuration),
            buildInfoRow(
              'Artist',
              song.artist.isNotEmpty ? song.artist : 'Unknown',
            ),
            buildInfoRow('Duration', song.displayDuration),
            if (song.album != null) ...[
              buildInfoRow('Album', song.album!.title),
            ],
            if (song.year != null) ...[
              buildInfoRow('Year', song.year.toString()),
            ],
            buildInfoRow('Track', '${song.trackNumber}'),
            buildInfoRow('Path', song.path),
            buildInfoRow('Source', song.source.toString()),
            buildInfoRow('Date Added', song.dateAdded.toString().split(' ')[0]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      );
    },
  );
}

void _showOptions<T>(
  BuildContext context,
  T object, {
  List<ListTile>? extraTopTiles,
  List<ListTile>? extraBottomTiles,
  void Function(T)? onQueueOptionPressed,
  void Function(T)? onAddToPlaylistOptionPressed,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF2A2A2A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder:
        (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...?extraTopTiles,
              ListTile(
                leading: const Icon(Icons.queue_music, color: Colors.white),
                title: const Text(
                  'Add to Queue',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onQueueOptionPressed?.call(object);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text(
                  'Add to Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onAddToPlaylistOptionPressed?.call(object);
                  // TODO: Add to playlist
                },
              ),
              ...?extraBottomTiles,
            ],
          ),
        ),
  );
}

void showSongOptions(
  BuildContext context,
  Song song, {
  List<ListTile>? extraOptionTiles,
  void Function(Song)? onPlayPressed,
  void Function(Song)? onAddToQueuePressed,
  void Function(Song)? onAddToPlaylistPressed,
}) {
  _showOptions<Song>(
    context,
    song,
    extraTopTiles: [
      ListTile(
        leading: const Icon(Icons.play_arrow, color: Colors.white),
        title: const Text('Play', style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context);
          onPlayPressed?.call(song);
        },
      ),
    ],
    extraBottomTiles: [
      if (extraOptionTiles != null) ...extraOptionTiles,
      ListTile(
        leading: const Icon(Icons.info, color: Colors.white),
        title: const Text('Song Info', style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context);
          showSongInfo(context, song);
        },
      ),
    ],
    onQueueOptionPressed: onAddToQueuePressed,
    onAddToPlaylistOptionPressed: onAddToPlaylistPressed,
  );
}

void showSongsOptions(
  BuildContext context,
  Artist artist,
  List<Song> songs, {
  List<ListTile>? extraOptionTiles,
  void Function(List<Song>)? onPlayAllPressed,
  void Function(List<Song>)? onShufflePressed,
  void Function(List<Song>)? onAddToQueuePressed,
  void Function(List<Song>)? onAddToPlaylistPressed,
}) {
  _showOptions<List<Song>>(
    context,
    songs,
    onQueueOptionPressed: onAddToQueuePressed,
    onAddToPlaylistOptionPressed: onAddToPlaylistPressed,
    extraTopTiles: [
      ListTile(
        leading: const Icon(Icons.play_arrow, color: Colors.white),
        title: const Text('Play All', style: TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context);
          onPlayAllPressed?.call(songs);
        },
      ),
      ListTile(
        leading: const Icon(Icons.shuffle, color: Colors.white),
        title: const Text(
          'Shuffle Play',
          style: TextStyle(color: Colors.white),
        ),
        onTap: () {
          Navigator.pop(context);
          onShufflePressed?.call(songs);
        },
      ),
    ],
    extraBottomTiles: extraOptionTiles,
  );
}
