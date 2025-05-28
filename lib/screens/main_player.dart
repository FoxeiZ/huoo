import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/widgets/audio/seekbar.dart';

class MainPlayer extends StatefulWidget {
  final Song? song;
  const MainPlayer({super.key, this.song});

  @override
  State<MainPlayer> createState() => _MainPlayerState();
}

class _SeekBarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        if (previous is AudioPlayerReady && current is AudioPlayerReady) {
          return previous.position != current.position ||
              previous.duration != current.duration ||
              previous.bufferedPosition != current.bufferedPosition;
        }
        return true;
      },
      builder: (context, state) {
        if (state is AudioPlayerReady) {
          return SeekBar(
            position: state.position,
            duration: state.duration,
            bufferedPosition: state.bufferedPosition,
            onChangeEnd: (value) {
              context.read<AudioPlayerBloc>().add(AudioPlayerSeekEvent(value));
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PlayControlsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        if (previous is AudioPlayerReady && current is AudioPlayerReady) {
          return previous.playing != current.playing ||
              previous.hasNext != current.hasNext ||
              previous.hasPrevious != current.hasPrevious ||
              previous.playlist != current.playlist;
        }
        return true;
      },
      builder: (context, state) {
        if (state is AudioPlayerReady) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 32,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(12),
                onPressed:
                    state.hasPrevious
                        ? () {
                          context.read<AudioPlayerBloc>().add(
                            AudioPlayerPreviousTrackEvent(),
                          );
                          log("Previous song");
                        }
                        : null,
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      state.playing ? Icons.pause : Icons.play_arrow,
                      size: 32,
                      color: Colors.white,
                      key: ValueKey<bool>(state.playing),
                    ),
                  ),
                  onPressed: () {
                    if (state is AudioPlayerLoading) {
                      log("Cannot toggle play/pause while loading");
                      return;
                    }
                    if (state.playlist.isEmpty) {
                      log("No songs in playlist to play");
                      return;
                    }
                    if (state.playing) {
                      context.read<AudioPlayerBloc>().add(
                        AudioPlayerPauseEvent(),
                      );
                      log("Pausing audio");
                    } else {
                      context.read<AudioPlayerBloc>().add(
                        AudioPlayerPlayEvent(),
                      );
                      log("Playing audio");
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 32,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(12),
                onPressed:
                    state.hasNext
                        ? () {
                          context.read<AudioPlayerBloc>().add(
                            AudioPlayerNextTrackEvent(),
                          );
                          log("Next song");
                        }
                        : null,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PlayerControlsSection extends StatelessWidget {
  const _PlayerControlsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        // rebuild when in different type of state or loading/error states
        return current is AudioPlayerLoading ||
            current is AudioPlayerError ||
            current.runtimeType != previous.runtimeType;
      },
      builder: (context, state) {
        if (state is AudioPlayerReady) {
          return Column(
            children: [
              _SeekBarSection(),
              const SizedBox(height: 16),

              _PlayControlsSection(),
              const SizedBox(height: 16),
            ],
          );
        }

        if (state is AudioPlayerLoading) {
          return const Column(
            children: [
              SizedBox(height: 50),
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 50),
            ],
          );
        }

        if (state is AudioPlayerError) {
          return Column(
            children: [
              const SizedBox(height: 50),
              Center(
                child: Text(
                  "Error: ${state.message}",
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _AlbumArtSection extends StatelessWidget {
  final double imageSize;

  const _AlbumArtSection({required this.imageSize});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        // rebuild when song metadata changes
        if (previous is AudioPlayerReady && current is AudioPlayerReady) {
          return previous.songMetadata != current.songMetadata;
        }
        return true;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Image.network(
              "",
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                log("Error loading image: $error");
                return Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.error, size: 50, color: Colors.red),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SongTextInfoSection extends StatelessWidget {
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteChanged;

  const _SongTextInfoSection({
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        if (previous is AudioPlayerReady && current is AudioPlayerReady) {
          return previous.songMetadata != current.songMetadata;
        }
        return true;
      },
      builder: (context, state) {
        Song? audioMetadata =
            state is AudioPlayerReady ? state.songMetadata : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Song title
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  audioMetadata?.title ?? "Unknown Title",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Artist name and buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        audioMetadata?.artist ?? "Unknown Artist",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Buttons on the right
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          log("Share button pressed");
                        },
                        icon: const Icon(Icons.share),
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        onPressed: () {
                          onFavoriteChanged(!isFavorite);
                          log("Favorite button pressed");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MainPlayerState extends State<MainPlayer> {
  bool _isFavorite = false;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.playlist_add),
                    title: const Text('Add to playlist'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: const Text('Add to favorites'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('Share'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Download'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Load test song'),
                    onTap: () {
                      context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.song != null) {
      context.read<AudioPlayerBloc>().add(
        AudioPlayerAddSongEvent(widget.song!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imageSize = screenSize.width < 400 ? screenSize.width * 0.7 : 300.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => _showBottomSheet(context),
                  icon: const Icon(Icons.more_vert),
                ),
              ),

              // Content section
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _AlbumArtSection(imageSize: imageSize),
                            const SizedBox(height: 16),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SongTextInfoSection(
                                  isFavorite: _isFavorite,
                                  onFavoriteChanged: (value) {
                                    setState(() {
                                      _isFavorite = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                const _PlayerControlsSection(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
