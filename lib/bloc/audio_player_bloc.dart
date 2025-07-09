import 'dart:async';
import 'package:huoo/helpers/database/helper.dart';
import 'package:logger/logger.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';

import 'package:huoo/services/lightweight_player_persistence.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/song_reference.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

final log = Logger(
  filter: ProductionFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

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

  Timer? _sleepTimerInstance;
  bool _isPlayerInitialized = false;

  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<AddTestSongEvent>((event, emit) async {
      var song = await DatabaseHelper().songProvider.getById(1);
      add(AudioPlayerAddSongEvent(song!));
    });
    on<AudioPlayerInitializeEvent>(_onInitialize);
    on<AudioPlayerRecoverFromErrorEvent>(_onRecoverFromError);
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
    // Timer events
    on<AudioPlayerSleepTimerEvent>(_onSleepTimerEvent);

    // Initial state
    _initSubscriptions();
    add(const AudioPlayerInitializeEvent());
  }

  Future<void> _initSubscriptions() async {
    // AudioPlayerStateEvent
    _playerStateSubscription = _player.playerStateStream.listen((
      playerState,
    ) async {
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
          // Extract lightweight song references from audio sources
          final songReferences = PlayerPersistenceService.extractSongReferences(
            currentReadyState.playlist,
          );

          PlayerPersistenceService.savePlayerState(
            songReferences: songReferences,
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
        PlayerPersistenceService.saveCurrentPosition(position);
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

  Future<void> _emitStateFromPlayer(
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
  }) async {
    emit(
      AudioPlayerReady(
        source: source ?? _player.audioSource,
        playlist: playlist ?? _player.sequence,
        currentIndex: currentIndex ?? _player.currentIndex,
        songMetadata:
            songMetadata ??
            (await Song.fromMediaItem(
              "_emitStateFromPlayer",
              _player.sequenceState.currentSource?.tag,
            )),
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
      // Check if player is already initialized and working
      if (_player.processingState != ProcessingState.idle &&
          _isPlayerInitialized) {
        log.d('Player already initialized, just emitting current state');
        await _emitStateFromPlayer(emit);
        return;
      }

      final savedState = await PlayerPersistenceService.loadPlayerState();
      if (savedState != null && savedState.songReferences.isNotEmpty) {
        // Reconstruct full Song objects from lightweight references
        final songs = await PlayerPersistenceService.reconstructSongs(
          savedState.songReferences,
        );

        if (songs.isEmpty) {
          log.w(
            'No valid songs reconstructed from saved state, initializing empty.',
          );
          await _emitStateFromPlayer(emit);
          _isPlayerInitialized = true;
          return;
        }

        final audioSources = await Future.wait(
          songs.map((song) => song.toAudioSource()).toList(),
        );

        if (audioSources.isEmpty) {
          log.w(
            'No valid audio sources from reconstructed songs, initializing empty.',
          );
          await _emitStateFromPlayer(emit);
          _isPlayerInitialized = true;
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
        if (sequenceState.currentSource?.tag != null) {
          currentSong = await Song.fromMediaItem(
            "_onInitialize",
            sequenceState.currentSource!.tag,
          );
          actualCurrentIndex = sequenceState.currentIndex;
        } else if (songs.isNotEmpty && savedState.currentIndex < songs.length) {
          currentSong = songs[savedState.currentIndex];
        }

        await _emitStateFromPlayer(emit);
        _isPlayerInitialized = true;
        log.d(
          'Player initialized and playlist restored. Index: $actualCurrentIndex, Song: ${currentSong?.title}',
        );
      } else {
        await _emitStateFromPlayer(emit);
        _isPlayerInitialized = true;
        log.w('Player initialized. No saved playlist or playlist was empty.');
      }
    } catch (e, stackTrace) {
      _isPlayerInitialized = false;
      log.e(
        'Error initializing player: ${e.toString()}',
        stackTrace: stackTrace,
      );
      emit(AudioPlayerError('Failed to initialize player: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPlaylist(
    AudioPlayerLoadPlaylistEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerLoading());
    try {
      final audioSources = await Future.wait(
        event.songs.map((song) => song.toAudioSource()).toList(),
      );

      if (audioSources.isEmpty) {
        log.w('Cannot load an empty playlist.');
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

      if (_player.playing) {
        await _player.pause();
      }
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

      await _emitStateFromPlayer(emit);
      add(AudioPlayerPlayEvent());
      log.d(
        'New playlist loaded. Index: ${_player.currentIndex}, Song: ${currentSong?.title}',
      );

      final songReferences =
          event.songs.map((song) => SongReference.fromSong(song)).toList();
      PlayerPersistenceService.savePlayerState(
        songReferences: songReferences,
        currentIndex: _player.currentIndex,
        currentPosition: _player.position,
        loopMode: _player.loopMode.name,
        shuffleMode: _player.shuffleModeEnabled,
        volume: _player.volume,
      );
    } catch (e, stackTrace) {
      log.e('Error loading playlist: ${e.toString()}', stackTrace: stackTrace);
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
      final currentState = state;
      if (currentState is AudioPlayerReady) {
        if (_player.sequenceState.sequence.isEmpty) {
          await _player.setAudioSource(await event.song.toAudioSource());
          await _player.playerStateStream.firstWhere(
            (ps) => ps.processingState != ProcessingState.loading,
          );
          log.w('First song added to empty playlist: ${event.song.title}');
        } else {
          await _player.addAudioSource(await event.song.toAudioSource());
          log.w('Song added to existing playlist: ${event.song.title}');
        }
      }
    } catch (e, stackTrace) {
      log.e('Error adding song: ${e.toString()}', stackTrace: stackTrace);
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
        await _player.clearAudioSources();
        await _player.stop();
        await _emitStateFromPlayer(emit);
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

  bool _areWeThereYet(
    Duration? duration,
    Duration position, {
    int offset = 100,
  }) {
    if (duration == null) {
      return false;
    }
    if (duration.inMilliseconds <= 0) {
      return false;
    }
    return position.inMilliseconds >= duration.inMilliseconds - offset;
  }

  Future<void> _onPlay(
    AudioPlayerPlayEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is AudioPlayerReady) {
      try {
        if (_player.sequence.isEmpty) {
          final song = event.song;
          if (song != null) {
            if (event.clearPlaylist) {
              await _player.clearAudioSources();
            }
            await _player.setAudioSource(await song.toAudioSource());
          } else {
            emit(AudioPlayerError('No song to play'));
            return;
          }
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
        await _emitStateFromPlayer(emit, playing: true);
        await _player.play();
        if (_player.playing &&
            _player.currentIndex == _player.sequence.length - 1 &&
            !_player.hasNext &&
            _areWeThereYet(_player.duration, _player.position)) {
          await _player.stop();
        }
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
        if (currentState.source == null) {
          return;
        }
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
      if (currentPlaylist.isEmpty) {
        log.w('Received empty playlist in sequence update');
        emit(
          currentState.copyWith(
            playlist: currentPlaylist,
            currentIndex: null,
            songMetadata: null,
            hasNext: false,
            hasPrevious: false,
          ),
        );
        return;
      }
      final currentCurrentIndex = event.currentIndex ?? _player.currentIndex;

      emit(
        currentState.copyWith(
          playlist: currentPlaylist,
          currentIndex: currentCurrentIndex,
          hasNext: event.hasNext,
          hasPrevious: event.hasPrevious,
        ),
      );
    }
  }

  Future<void> _onSleepTimerEvent(
    AudioPlayerSleepTimerEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (event.isActive) {
      _sleepTimerInstance?.cancel();
      _sleepTimerInstance = Timer(event.duration!, () {
        add(AudioPlayerStopEvent());
        event.onTimerEnd?.call();
      });
    } else {
      _sleepTimerInstance?.cancel();
      _sleepTimerInstance = null;
    }
  }

  Future<void> _onRecoverFromError(
    AudioPlayerRecoverFromErrorEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      log.i('Attempting error recovery without full reinitialization');

      // Check if the player is in a valid state for recovery
      if (_player.processingState == ProcessingState.idle) {
        log.w(
          'Player is idle, cannot recover - user should retry initialization',
        );
        emit(
          AudioPlayerError(
            'Player needs reinitialization. Please restart the app or try again later.',
          ),
        );
        return;
      }

      // Simply try to emit the current state from the player
      // This avoids reinitializing the background service
      await _emitStateFromPlayer(emit);

      log.i('Error recovery successful');
    } catch (e, stackTrace) {
      log.e('Error during recovery: ${e.toString()}', stackTrace: stackTrace);
      emit(
        AudioPlayerError(
          'Recovery failed: ${e.toString()}. Please restart the app.',
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
