import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/models/song.dart';

class PlayIndicatorWidget extends StatelessWidget {
  final Song song;
  final double size;
  final Color? color;
  final bool showWhenNotCurrent;
  final Widget? fallbackWidget;

  const PlayIndicatorWidget({
    super.key,
    required this.song,
    this.size = 20,
    this.color,
    this.showWhenNotCurrent = false,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        bool isCurrentSong = false;
        bool isPlaying = false;
        bool isLoading = false;

        if (playerState is AudioPlayerReady) {
          final currentSong = playerState.songMetadata;
          isCurrentSong = currentSong?.path == song.path;
          isPlaying = playerState.playing;
          isLoading = playerState.loading;
        }

        // If this is not the current song and we don't want to show anything
        if (!isCurrentSong && !showWhenNotCurrent) {
          return fallbackWidget ?? const SizedBox.shrink();
        }

        // Determine which icon to show
        IconData iconData;
        Color iconColor = color ?? const Color(0xFF1DB954);

        if (!isCurrentSong) {
          // Song is not current, show a subtle play button
          iconData = Icons.play_arrow;
          iconColor = iconColor.withValues(alpha: 0.5);
        } else if (isLoading) {
          // Song is current but loading
          return SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          );
        } else if (isPlaying) {
          // Song is current and playing
          iconData = Icons.volume_up;
        } else {
          // Song is current but paused
          iconData = Icons.pause;
        }

        return Icon(iconData, size: size, color: iconColor);
      },
    );
  }
}

class AnimatedPlayIndicator extends StatelessWidget {
  final Song song;
  final double size;
  final Color? color;

  const AnimatedPlayIndicator({
    super.key,
    required this.song,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        bool isCurrentSong = false;
        bool isPlaying = false;

        if (playerState is AudioPlayerReady) {
          final currentSong = playerState.songMetadata;
          isCurrentSong = currentSong?.path == song.path;
          isPlaying = playerState.playing;
        }

        if (!isCurrentSong) {
          return const SizedBox.shrink();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey('$isPlaying-$isCurrentSong'),
            margin: const EdgeInsets.only(right: 8),
            child: Icon(
              isPlaying ? Icons.volume_up : Icons.pause,
              color: color ?? const Color(0xFF1DB954),
              size: size,
            ),
          ),
        );
      },
    );
  }
}

class WaveformPlayIndicator extends StatefulWidget {
  final Song song;
  final double width;
  final double height;
  final Color? color;

  const WaveformPlayIndicator({
    super.key,
    required this.song,
    this.width = 24,
    this.height = 16,
    this.color,
  });

  @override
  State<WaveformPlayIndicator> createState() => _WaveformPlayIndicatorState();
}

class _WaveformPlayIndicatorState extends State<WaveformPlayIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioPlayerBloc, AudioPlayerState>(
      listener: (context, playerState) {
        bool isCurrentSong = false;
        bool isPlaying = false;

        if (playerState is AudioPlayerReady) {
          final currentSong = playerState.songMetadata;
          isCurrentSong = currentSong?.path == widget.song.path;
          isPlaying = playerState.playing;
        }

        if (isCurrentSong && isPlaying) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      },
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, playerState) {
          bool isCurrentSong = false;
          bool isPlaying = false;

          if (playerState is AudioPlayerReady) {
            final currentSong = playerState.songMetadata;
            isCurrentSong = currentSong?.path == widget.song.path;
            isPlaying = playerState.playing;
          }

          if (!isCurrentSong) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: widget.width,
            height: widget.height,
            child:
                isPlaying
                    ? AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(4, (index) {
                            final height =
                                widget.height *
                                (0.3 +
                                    0.7 *
                                        (0.5 +
                                            0.5 *
                                                math.sin(
                                                  _animationController.value *
                                                          2 *
                                                          math.pi +
                                                      index * 0.5,
                                                )));
                            return Container(
                              width: 2,
                              height: height,
                              decoration: BoxDecoration(
                                color: widget.color ?? const Color(0xFF1DB954),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            );
                          }),
                        );
                      },
                    )
                    : Icon(
                      Icons.pause,
                      color: widget.color ?? const Color(0xFF1DB954),
                      size: 16,
                    ),
          );
        },
      ),
    );
  }
}
