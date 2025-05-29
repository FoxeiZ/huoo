import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:huoo/services/playlist_persistence_service.dart';

import 'package:huoo/models/song.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _bufferedPositionSubscription;
  StreamSubscription<LoopMode>? _loopModeSubscription;
  StreamSubscription<bool>? _shuffleModeSubscription;
  StreamSubscription<double>? _volumeSubscription;
  StreamSubscription<double>? _speedSubscription;
  StreamSubscription<double>? _pitchSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<SequenceState?>? _sequenceStateSubscription;

  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    JustAudioMediaKit.ensureInitialized();
    on<AddTestSongEvent>((event, emit) async {
      var song = await Song.fromAsset("assets/audios/sample.m4a");
      add(AudioPlayerAddSongEvent(song));
    });
    on<AudioPlayerInitializeEvent>(_onInitialize);
    // playlist event
    on<AudioPlayerLoadPlaylistEvent>(_onLoadPlaylist);
    on<AudioPlayerAddSongEvent>(_onPlaylistAdded);
    on<AudioPlayerRemoveSongEvent>(_onPlaylistRemoved);
    on<AudioPlayerClearPlaylistEvent>(_onPlaylistCleared);
    on<AudioPlayerMovePlaylistItemEvent>(_onPlaylistMoved);
    // Event handlers
    on<AudioPlayerSequenceUpdateEvent>(_onSequenceStateChanged);
    on<AudioPlayerStateEvent>(_onPlayerStateChanged);
    on<AudioPlayerPositionEvent>(_onPositionChanged);
    on<AudioPlayerBufferedPositionEvent>(_onBufferedPositionChanged);
    on<AudioPlayerLoopModeEvent>(_onLoopModeChanged);
    on<AudioPlayerShuffleModeEvent>(_onShuffleModeChanged);
    on<AudioPlayerVolumeEvent>(_onVolumeChanged);
    on<AudioPlayerSpeedEvent>(_onSpeedChanged);
    on<AudioPlayerPitchEvent>(_onPitchChanged);
    // Player control events
    on<AudioPlayerPlayEvent>(_onPlay);
    on<AudioPlayerPauseEvent>(_onPause);
    on<AudioPlayerStopEvent>(_onStop);
    on<AudioPlayerNextTrackEvent>(_onNextTrack);
    on<AudioPlayerPreviousTrackEvent>(_onPreviousTrack);
    on<AudioPlayerSeekEvent>(_onSeek);
    // Initial state
    _initSubscriptions();
    add(const AudioPlayerInitializeEvent());
  }

  void _initSubscriptions() {
    // AudioPlayerStateEvent
    _playerStateSubscription = _player.playerStateStream.listen((playerState) {
      add(
        AudioPlayerStateEvent(
          playerState.playing,
          playerState.processingState == ProcessingState.loading ||
              playerState.processingState == ProcessingState.buffering,
          playerState.processingState,
        ),
      );

      if (state is AudioPlayerReady) {
        final currentReadyState = state as AudioPlayerReady;
        if (currentReadyState.playlist.isNotEmpty) {
          PlaylistPersistenceService.savePlaylistState(
            songs:
                currentReadyState.playlist
                    .map((source) => source.tag as Song)
                    .toList(),
            currentIndex: currentReadyState.currentIndex,
            currentPosition: currentReadyState.position,
            loopMode: currentReadyState.loopMode.name,
            shuffleMode: currentReadyState.shuffleModeEnabled,
            volume: currentReadyState.volume,
          );
        }
      }
    });

    _positionSubscription = _player.positionStream.listen((position) {
      add(
        AudioPlayerPositionEvent(
          position: position,
          duration: _player.duration ?? Duration.zero,
        ),
      );
      if (state is AudioPlayerReady) {
        PlaylistPersistenceService.saveCurrentPosition(position);
      }
    });

    _bufferedPositionSubscription = _player.bufferedPositionStream.listen((
      bufferedPosition,
    ) {
      add(AudioPlayerBufferedPositionEvent(bufferedPosition));
    });

    // AudioPlayerPlaylistStateEvent
    _loopModeSubscription = _player.loopModeStream.listen((loopMode) {
      add(AudioPlayerLoopModeEvent(loopMode));
    });

    _shuffleModeSubscription = _player.shuffleModeEnabledStream.listen((
      shuffleModeEnabled,
    ) {
      add(AudioPlayerShuffleModeEvent(shuffleModeEnabled));
    });

    _volumeSubscription = _player.volumeStream.listen((volume) {
      add(AudioPlayerVolumeEvent(volume));
    });

    _speedSubscription = _player.speedStream.listen((speed) {
      add(AudioPlayerSpeedEvent(speed));
    });

    _pitchSubscription = _player.pitchStream.listen((pitch) {
      add(AudioPlayerPitchEvent(pitch));
    });

    _sequenceStateSubscription = _player.sequenceStateStream.listen((
      sequenceState,
    ) {
      add(
        AudioPlayerSequenceUpdateEvent(
          currentIndex: sequenceState.currentIndex,
          currentSource: sequenceState.currentSource,
          sequence: sequenceState.sequence,
          hasNext: _player.hasNext,
          hasPrevious: _player.hasPrevious,
        ),
      );
    });
  }

  void _emitStateFromPlayer(
    Emitter<AudioPlayerState> emit, {
    AudioSource? source,
    List<IndexedAudioSource>? playlist,
    int? currentIndex,
    Song? songMetadata,
    bool? loading,
    bool? playing,
    ProcessingState? processingState,
    Duration? duration,
    Duration? position,
    Duration? bufferedPosition,
    LoopMode? loopMode,
    bool? shuffleModeEnabled,
    double? volume,
    double? speed,
    double? pitch,
    int? androidAudioSessionId,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    emit(
      AudioPlayerReady(
        source: source ?? _player.audioSource,
        playlist: playlist ?? _player.sequence,
        currentIndex: currentIndex ?? _player.currentIndex,
        songMetadata:
            songMetadata ?? (_player.sequenceState.currentSource?.tag as Song?),
        loading:
            loading ??
            _player.processingState == ProcessingState.loading ||
                _player.processingState == ProcessingState.buffering,
        playing: playing ?? _player.playing,
        processingState: processingState ?? _player.processingState,
        duration: duration ?? _player.duration ?? Duration.zero,
        position: position ?? _player.position,
        bufferedPosition: bufferedPosition ?? _player.bufferedPosition,
        loopMode: loopMode ?? _player.loopMode,
        shuffleModeEnabled: shuffleModeEnabled ?? _player.shuffleModeEnabled,
        volume: volume ?? _player.volume,
        speed: speed ?? _player.speed,
        pitch: pitch ?? _player.pitch,
        androidAudioSessionId:
            androidAudioSessionId ?? _player.androidAudioSessionId,
        hasNext: hasNext ?? _player.hasNext,
        hasPrevious: hasPrevious ?? _player.hasPrevious,
      ),
    );
  }

  Future<void> _onInitialize(
    AudioPlayerInitializeEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerLoading());
    try {
      final savedState = await PlaylistPersistenceService.loadPlaylistState();
      if (savedState != null && savedState.songs.isNotEmpty) {
        final audioSources =
            savedState.songs
                .map(
                  (song) => AudioSource.uri(Uri.parse(song.path), tag: song),
                ) // Use song.path
                .toList();

        if (audioSources.isEmpty) {
          log('No valid audio sources from saved state, initializing empty.');
          _emitStateFromPlayer(emit);
          return;
        }

        await _player.setAudioSources(
          audioSources,
          initialIndex: savedState.currentIndex,
          initialPosition: savedState.currentPosition,
        );

        // wait for player to be somewhat ready. freaking just_audio
        await _player.playerStateStream.firstWhere(
          (ps) =>
              ps.processingState != ProcessingState.loading &&
              ps.processingState != ProcessingState.buffering,
        );

        await _player.setLoopMode(_parseLoopMode(savedState.loopMode));
        await _player.setShuffleModeEnabled(savedState.shuffleMode);
        await _player.setVolume(savedState.volume);

        final sequenceState = _player.sequenceState;
        Song? currentSong;
        int? actualCurrentIndex = savedState.currentIndex;
        if (sequenceState.currentSource?.tag is Song) {
          currentSong = sequenceState.currentSource!.tag as Song;
          actualCurrentIndex = sequenceState.currentIndex;
        } else if (savedState.songs.isNotEmpty &&
            savedState.currentIndex < savedState.songs.length) {
          currentSong = savedState.songs[savedState.currentIndex];
        }

        _emitStateFromPlayer(emit);
        log(
          'Player initialized and playlist restored. Index: $actualCurrentIndex, Song: ${currentSong?.title}',
        );
      } else {
        _emitStateFromPlayer(emit);
        log('Player initialized. No saved playlist or playlist was empty.');
      }
    } catch (e, stackTrace) {
      log('Error initializing player: ${e.toString()}\n$stackTrace');
      emit(AudioPlayerError('Failed to initialize player: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPlaylist(
    AudioPlayerLoadPlaylistEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerLoading());
    try {
      final audioSources =
          event.songs
              .map(
                (song) => AudioSource.uri(Uri.parse(song.path), tag: song),
              ) // Use song.path
              .toList();

      if (audioSources.isEmpty) {
        log('Cannot load an empty playlist.');
        emit(
          AudioPlayerReady(
            processingState: ProcessingState.idle,
            duration: Duration.zero,
            volume: 0.3,
            speed: 1.0,
            pitch: 1.0,
            loopMode: LoopMode.off,
          ),
        );
        return;
      }

      final initialIndex =
          event.initialIndex < audioSources.length ? event.initialIndex : 0;

      await _player.setAudioSources(
        audioSources,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );
      await _player.playerStateStream.firstWhere(
        (ps) =>
            ps.processingState != ProcessingState.loading &&
            ps.processingState != ProcessingState.buffering,
      );

      Song? currentSong;
      if (event.songs.isNotEmpty && initialIndex < event.songs.length) {
        currentSong = event.songs[initialIndex];
      }

      _emitStateFromPlayer(emit);
      log(
        'New playlist loaded. Index: ${_player.currentIndex}, Song: ${currentSong?.title}',
      );
      PlaylistPersistenceService.savePlaylistState(
        songs: event.songs,
        currentIndex: _player.currentIndex,
        currentPosition: _player.position,
        loopMode: _player.loopMode.name,
        shuffleMode: _player.shuffleModeEnabled,
        volume: _player.volume,
      );
    } catch (e, stackTrace) {
      log('Error loading playlist: ${e.toString()}\n$stackTrace');
      emit(AudioPlayerError('Failed to load playlist: ${e.toString()}'));
    }
  }

  LoopMode _parseLoopMode(String loopModeStr) {
    switch (loopModeStr.toLowerCase()) {
      case 'one':
        return LoopMode.one;
      case 'all':
        return LoopMode.all;
      default:
        return LoopMode.off;
    }
  }

  Future<void> _onPlaylistAdded(
    AudioPlayerAddSongEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      if (state is AudioPlayerReady) {
        if (_player.sequenceState.sequence.isEmpty) {
          await _player.setAudioSource(event.song.toAudioSource());
          await _player.playerStateStream.firstWhere(
            (ps) => ps.processingState != ProcessingState.loading,
          );
          log('First song added to empty playlist: ${event.song.title}');
        } else {
          await _player.addAudioSource(event.song.toAudioSource());
          log('Song added to existing playlist: ${event.song.title}');
        }
        _emitStateFromPlayer(emit);
      }
    } catch (e) {
      log('Error adding song: ${e.toString()}');
      emit(AudioPlayerError('Failed to add song: ${e.toString()}'));
    }
  }

  Future<void> _onPlaylistRemoved(
    AudioPlayerRemoveSongEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      if (state is AudioPlayerReady) {
        _player.removeAudioSourceAt(event.index);
      }
    } catch (e) {
      emit(AudioPlayerError('Failed to remove song: ${e.toString()}'));
    }
  }

  Future<void> _onPlaylistCleared(
    AudioPlayerClearPlaylistEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      if (state is AudioPlayerReady) {
        _player.clearAudioSources();
      }
    } catch (e) {
      emit(AudioPlayerError('Failed to clear playlist: ${e.toString()}'));
    }
  }

  Future<void> _onPlaylistMoved(
    AudioPlayerMovePlaylistItemEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      if (state is AudioPlayerReady) {
        _player.moveAudioSource(event.oldIndex, event.newIndex);
      }
    } catch (e) {
      emit(AudioPlayerError('Failed to move playlist item: ${e.toString()}'));
    }
  }

  Future<void> _onPlayerStateChanged(
    AudioPlayerStateEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady) {
      emit(
        currentState.copyWith(
          playing: event.playing,
          loading: event.loading,
          processingState: event.processingState,
        ),
      );
    }
  }

  Future<void> _onPositionChanged(
    AudioPlayerPositionEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady) {
      emit(
        currentState.copyWith(
          position: event.position,
          duration: event.duration,
        ),
      );
    }
  }

  Future<void> _onBufferedPositionChanged(
    AudioPlayerBufferedPositionEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state is AudioPlayerReady) {
      final currentState = state as AudioPlayerReady;
      emit(currentState.copyWith(bufferedPosition: event.bufferedPosition));
    }
  }

  Future<void> _onLoopModeChanged(
    AudioPlayerLoopModeEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state is AudioPlayerReady) {
      final currentState = state as AudioPlayerReady;
      emit(currentState.copyWith(loopMode: event.loopMode));
    }
  }

  Future<void> _onShuffleModeChanged(
    AudioPlayerShuffleModeEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state is AudioPlayerReady) {
      final currentState = state as AudioPlayerReady;
      emit(currentState.copyWith(shuffleModeEnabled: event.shuffleModeEnabled));
    }
  }

  Future<void> _onVolumeChanged(
    AudioPlayerVolumeEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state is AudioPlayerReady) {
      final currentState = state as AudioPlayerReady;
      emit(currentState.copyWith(volume: event.volume));
    }
  }

  Future<void> _onSpeedChanged(
    AudioPlayerSpeedEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state is AudioPlayerReady) {
      final currentState = state as AudioPlayerReady;
      emit(currentState.copyWith(speed: event.speed));
    }
  }

  Future<void> _onPitchChanged(
    AudioPlayerPitchEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state is AudioPlayerReady) {
      final currentState = state as AudioPlayerReady;
      emit(currentState.copyWith(pitch: event.pitch));
    }
  }

  Future<void> _onPlay(
    AudioPlayerPlayEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady) {
      try {
        if (_player.sequence.isEmpty) {
          emit(
            AudioPlayerError('No songs in playlist. Please add a song first.'),
          );
          return;
        }

        if (_player.audioSource == null && _player.sequence.isNotEmpty) {
          await _player.seek(Duration.zero, index: 0);
        }

        if (currentState.position.inMilliseconds.compareTo(
              currentState.duration.inMilliseconds - 10,
            ) >=
            0) {
          _player.seek(Duration.zero);
        }
        await _player.play();
        _emitStateFromPlayer(emit);
      } catch (e) {
        emit(AudioPlayerError('Failed to play song: ${e.toString()}'));
      }
    }
  }

  Future<void> _onPause(
    AudioPlayerPauseEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady) {
      try {
        await _player.pause();
      } catch (e) {
        emit(AudioPlayerError('Failed to pause song: ${e.toString()}'));
      }
    }
  }

  Future<void> _onStop(
    AudioPlayerStopEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady) {
      try {
        await _player.stop();
      } catch (e) {
        emit(AudioPlayerError('Failed to stop song: ${e.toString()}'));
      }
    }
  }

  Future<void> _onNextTrack(
    AudioPlayerNextTrackEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady && currentState.hasNext) {
      try {
        await _player.seekToNext();
      } catch (e) {
        emit(AudioPlayerError('Failed to skip to next track: ${e.toString()}'));
      }
    }
  }

  Future<void> _onPreviousTrack(
    AudioPlayerPreviousTrackEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady && currentState.hasPrevious) {
      try {
        await _player.seekToPrevious();
      } catch (e) {
        emit(
          AudioPlayerError('Failed to skip to previous track: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _onSeek(
    AudioPlayerSeekEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady) {
      try {
        await _player.seek(event.position);
      } catch (e) {
        emit(AudioPlayerError('Failed to seek: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSequenceStateChanged(
    AudioPlayerSequenceUpdateEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady) {
      final currentPlaylist = event.sequence;
      final currentCurrentIndex = event.currentIndex ?? _player.currentIndex;
      final currentCurrentSource =
          event.currentSource ?? _player.audioSource as IndexedAudioSource?;

      emit(
        currentState.copyWith(
          playlist: currentPlaylist,
          currentIndex: currentCurrentIndex,
          songMetadata: currentCurrentSource?.tag as Song?,
          hasNext: event.hasNext,
          hasPrevious: event.hasPrevious,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _loopModeSubscription?.cancel();
    _shuffleModeSubscription?.cancel();
    _volumeSubscription?.cancel();
    _speedSubscription?.cancel();
    _pitchSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _sequenceStateSubscription?.cancel();
    _player.dispose();
    return super.close();
  }
}
