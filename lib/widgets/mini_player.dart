import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/screens/main_player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        // Only rebuild when relevant state changes
        if (previous is AudioPlayerReady && current is AudioPlayerReady) {
          return previous.playing != current.playing ||
              previous.songMetadata != current.songMetadata ||
              previous.playlist.length != current.playlist.length;
        }
        return true;
      },
      builder: (context, state) {
        // Only show mini player when there's a song to play
        if (state is! AudioPlayerReady || state.playlist.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentSong = state.songMetadata;
        if (currentSong == null) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MainPlayer()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Album art
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          currentSong.cover != null &&
                                  currentSong.cover!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  currentSong.cover!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.music_note,
                                      color: Color(0xFF1DB954),
                                    );
                                  },
                                ),
                              )
                              : const Icon(
                                Icons.music_note,
                                color: Color(0xFF1DB954),
                              ),
                    ),
                    const SizedBox(width: 12),

                    // Song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentSong.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (currentSong.performers.isNotEmpty)
                            Text(
                              currentSong.performers.first,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),

                    // Play/pause button
                    IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          state.playing ? Icons.pause : Icons.play_arrow,
                          size: 28,
                          color: Colors.white,
                          key: ValueKey<bool>(state.playing),
                        ),
                      ),
                      onPressed: () {
                        if (state.playing) {
                          context.read<AudioPlayerBloc>().add(
                            AudioPlayerPauseEvent(),
                          );
                        } else {
                          context.read<AudioPlayerBloc>().add(
                            AudioPlayerPlayEvent(),
                          );
                        }
                      },
                    ),

                    // Next button
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next,
                        size: 28,
                        color: Colors.white,
                      ),
                      onPressed:
                          state.hasNext
                              ? () {
                                context.read<AudioPlayerBloc>().add(
                                  AudioPlayerNextTrackEvent(),
                                );
                              }
                              : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
