import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:huoo/bloc/audio_player_bloc.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/widgets/audio/seekbar.dart';

final log = Logger(
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

void _showSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: "Dismiss",
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        // showCloseIcon: true,
      ),
    );
}

class _SleepTimerDialog extends StatefulWidget {
  @override
  State<_SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<_SleepTimerDialog> {
  // Timer duration in minutes (10 min to 5 hours = 300 minutes)
  double _timerMinutes = 30.0;
  static const double _minMinutes = 10.0;
  static const double _maxMinutes = 300.0; // 5 hours
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize text controller with default duration
    _updateTextController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateTextController() {
    final hours = (_timerMinutes / 60).floor();
    final minutes = (_timerMinutes % 60).round();

    if (hours > 0) {
      _textController.text = '${hours}h ${minutes}m';
    } else {
      _textController.text = '${minutes}m';
    }
  }

  // manually input time
  void _showTimeInputDialog() {
    final inputController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter Duration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter duration in minutes (10-300):'),
                const SizedBox(height: 16),
                TextField(
                  controller: inputController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                    suffixText: 'min',
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final input = double.tryParse(inputController.text);
                  if (input != null) {
                    final normalizedMinutes = input.clamp(
                      _minMinutes,
                      _maxMinutes,
                    );
                    setState(() {
                      _timerMinutes = normalizedMinutes;
                      _updateTextController();
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Set'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext _) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Sleep Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // tap-able text field
              GestureDetector(
                onTap: _showTimeInputDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _textController.text,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // slider
              Column(
                children: [
                  Text(
                    'Adjust Duration',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _timerMinutes,
                    min: _minMinutes,
                    max: _maxMinutes,
                    divisions: 58, // 10min steps approximately
                    onChanged: (value) {
                      setState(() {
                        _timerMinutes = value;
                        _updateTextController();
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_minMinutes.round()}m'),
                      Text('${(_maxMinutes / 60).round()}h'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AudioPlayerBloc>().add(
                  AudioPlayerSleepTimerEvent(
                    isActive: true,
                    duration: Duration(minutes: _timerMinutes.round()),
                    onTimerEnd: () {
                      log.i('Sleep timer ended');
                      _showSnackBar(context, 'Sleep timer ended');
                      context.read<AudioPlayerBloc>().add(
                        AudioPlayerPauseEvent(),
                      );
                    },
                  ),
                );
                log.i('Sleep timer set for ${_timerMinutes.round()} minutes');
                _showSnackBar(
                  context,
                  'Sleep timer set for ${_textController.text}',
                );
                Navigator.pop(context);
              },
              child: const Text('Start Timer'),
            ),
          ],
        );
      },
    );
  }
}

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

        // Show disabled seek bar in error state
        if (state is AudioPlayerError) {
          return SeekBar(
            position: Duration.zero,
            duration: const Duration(minutes: 3), // Default duration
            bufferedPosition: Duration.zero,
            onChangeEnd: null, // Disabled
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
        // Show controls for both Ready and Error states
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
                          log.i("Previous song");
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
                      color: Theme.of(context).colorScheme.onPrimary,
                      key: ValueKey<bool>(state.playing),
                    ),
                  ),
                  onPressed: () {
                    if (state is AudioPlayerLoading) {
                      log.e("Cannot toggle play/pause while loading");
                      return;
                    }
                    if (state.playlist.isEmpty) {
                      _showSnackBar(context, "No songs in playlist to play");
                      return;
                    }
                    if (state.playing) {
                      context.read<AudioPlayerBloc>().add(
                        AudioPlayerPauseEvent(),
                      );
                      log.i("Pausing audio");
                    } else {
                      context.read<AudioPlayerBloc>().add(
                        AudioPlayerPlayEvent(),
                      );
                      log.i("Playing audio");
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
                          log.i("Next song");
                        }
                        : null,
              ),
            ],
          );
        }

        // Show basic controls even in error state to allow retry
        if (state is AudioPlayerError) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 32,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(12),
                onPressed: null, // Disabled in error state
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 32,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Try to recover from error without full reinitialization
                    context.read<AudioPlayerBloc>().add(
                      const AudioPlayerRecoverFromErrorEvent(),
                    );
                    log.i("Attempting error recovery");
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 32,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(12),
                onPressed: null, // Disabled in error state
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
    return BlocListener<AudioPlayerBloc, AudioPlayerState>(
      listener: (context, state) {
        // Show error via snackbar instead of replacing UI
        if (state is AudioPlayerError) {
          _showSnackBar(context, "Player Error: ${state.message}");
        }
      },
      child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        buildWhen: (previous, current) {
          // rebuild when in different type of state or loading states (but not error)
          return current is AudioPlayerLoading ||
              (current is AudioPlayerReady && previous is! AudioPlayerReady) ||
              current.runtimeType != previous.runtimeType;
        },
        builder: (context, state) {
          // Show controls for both Ready and Error states
          if (state is AudioPlayerReady || state is AudioPlayerError) {
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

          return const SizedBox.shrink();
        },
      ),
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
              cacheHeight:
                  (imageSize * MediaQuery.of(context).devicePixelRatio).round(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                log.e("Error loading image: $error", stackTrace: stackTrace);
                return Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onErrorContainer.withAlpha(48),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.error,
                    size: 50,
                    color: Theme.of(context).colorScheme.error,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SongTextInfoSection extends StatefulWidget {
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteChanged;

  const _SongTextInfoSection({
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<_SongTextInfoSection> createState() => _SongTextInfoSectionState();
}

class _SongTextInfoSectionState extends State<_SongTextInfoSection> {
  String artistName = "Unknown Artist";

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
        audioMetadata?.artist.then((artist) {
          setState(() {
            artistName = artist;
          });
        });

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
                        artistName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(153),
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
                          log.i("Share button pressed");
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
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        onPressed: () {
                          widget.onFavoriteChanged(!widget.isFavorite);
                          log.i("Favorite button pressed");
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

  Future<void> _showTimerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return _SleepTimerDialog();
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    final currentState = context.read<AudioPlayerBloc>().state;
    var isLocal = false;

    if (currentState is AudioPlayerReady && currentState.songMetadata != null) {
      isLocal = currentState.songMetadata!.source == AudioSourceEnum.local;
    }

    showModalBottomSheet(
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.3,
          maxChildSize: 0.8,
          snap: true,
          snapSizes: [0.3, 0.8],
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              children: [
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('Add To Playlist'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Add To Queue'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.clear_all),
                  title: const Text('Clear Queue'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(
                      AudioPlayerClearPlaylistEvent(),
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.album),
                  title: const Text('View Album'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_pin),
                  title: const Text('View Artist'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                // Conditional options based on song source
                if (isLocal) ...[
                  ListTile(
                    leading: const Icon(Icons.drive_file_rename_outline_sharp),
                    title: const Text('Modify tags'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.cloud_download),
                    title: const Text('Download song'),
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
                ],
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Sleep Timer'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _showTimerDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Load test song'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    _showSnackBar(context, "Test song loaded");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Load test song'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    _showSnackBar(context, "Test song loaded");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Load test song'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    _showSnackBar(context, "Test song loaded");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Load test song'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    _showSnackBar(context, "Test song loaded");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Load test song'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    _showSnackBar(context, "Test song loaded");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Load test song'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    _showSnackBar(context, "Test song loaded");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Load test song'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    _showSnackBar(context, "Test song loaded");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Load test song'),
                  onTap: () {
                    context.read<AudioPlayerBloc>().add(AddTestSongEvent());
                    _showSnackBar(context, "Test song loaded");
                  },
                ),
              ],
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
          padding: const EdgeInsets.all(16),
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
                      physics: const NeverScrollableScrollPhysics(),
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
