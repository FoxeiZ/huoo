import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:huoo/widgets/common/play_indicator_widget.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onMorePressed;
  final String Function(Duration) formatDuration;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    required this.onMorePressed,
    required this.formatDuration,
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
                    formatDuration(song.duration),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  onPressed: onMorePressed,
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
