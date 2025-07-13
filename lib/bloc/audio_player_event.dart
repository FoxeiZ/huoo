part of 'audio_player_bloc.dart';

sealed class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

// Generic event
class AudioPlayerGenericEvent extends AudioPlayerEvent {
  final AudioSource? source;
  final List<IndexedAudioSource>? playlist;
  final int? currentIndex;
  final Song? songMetadata;
  final bool? loading;
  final bool? playing;
  final ProcessingState? processingState;
  final Duration? position;
  final Duration? duration;
  final Duration? bufferedPosition;
  final LoopMode? loopMode;
  final bool? shuffleModeEnabled;
  final double? volume;
  final double? speed;
  final double? pitch;
  final int? androidAudioSessionId;
  final bool? hasNext;
  final bool? hasPrevious;
  final Duration? sleepTimer;

  const AudioPlayerGenericEvent({
    this.source,
    this.playlist,
    this.currentIndex,
    this.songMetadata,
    this.loading,
    this.playing,
    this.processingState,
    this.position,
    this.duration,
    this.bufferedPosition,
    this.loopMode,
    this.shuffleModeEnabled,
    this.volume,
    this.speed,
    this.pitch,
    this.androidAudioSessionId,
    this.hasNext,
    this.hasPrevious,
    this.sleepTimer,
  });

  @override
  List<Object?> get props => [
    source,
    playlist,
    currentIndex,
    songMetadata,
    loading,
    playing,
    processingState,
    position,
    duration,
    bufferedPosition,
    loopMode,
    shuffleModeEnabled,
    volume,
    speed,
    pitch,
    androidAudioSessionId,
    hasNext,
    hasPrevious,
    sleepTimer,
  ];
}

class AudioPlayerSequenceUpdateEvent extends AudioPlayerEvent {
  final int? currentIndex;
  final IndexedAudioSource? currentSource;
  final List<IndexedAudioSource> sequence;
  final bool hasNext;
  final bool hasPrevious;

  const AudioPlayerSequenceUpdateEvent({
    this.currentIndex,
    this.currentSource,
    required this.sequence,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  @override
  List<Object> get props => [
    currentIndex ?? -1,
    hasNext,
    hasPrevious,
    sequence,
  ];
}

// ---------- Player State Events ---------- //
class AudioPlayerStateEvent extends AudioPlayerEvent {
  final bool playing;
  final bool loading;
  final ProcessingState processingState;

  const AudioPlayerStateEvent(this.playing, this.loading, this.processingState);

  @override
  List<Object> get props => [playing, loading, processingState];
}

// ---------- Position Events ---------- //
class AudioPlayerPositionEvent extends AudioPlayerEvent {
  final Duration position;
  final Duration duration;

  const AudioPlayerPositionEvent({
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  @override
  List<Object> get props => [position, duration];
}

class AudioPlayerBufferedPositionEvent extends AudioPlayerEvent {
  final Duration bufferedPosition;

  const AudioPlayerBufferedPositionEvent(this.bufferedPosition);

  @override
  List<Object> get props => [bufferedPosition];
}

// ---------- Player Events ---------- //
class AudioPlayerPlaylistStateEvent extends AudioPlayerEvent {
  final DateTime? lastPlayed;

  const AudioPlayerPlaylistStateEvent({this.lastPlayed});

  @override
  List<Object> get props => [lastPlayed ?? DateTime.now()];
}

class AudioPlayerLoopModeEvent extends AudioPlayerPlaylistStateEvent {
  final LoopMode loopMode;

  const AudioPlayerLoopModeEvent(this.loopMode);

  @override
  List<Object> get props => [loopMode];
}

class AudioPlayerShuffleModeEvent extends AudioPlayerPlaylistStateEvent {
  final bool shuffleModeEnabled;

  const AudioPlayerShuffleModeEvent(this.shuffleModeEnabled);

  @override
  List<Object> get props => [shuffleModeEnabled];
}

class AudioPlayerVolumeEvent extends AudioPlayerPlaylistStateEvent {
  final double volume;

  const AudioPlayerVolumeEvent(this.volume);

  @override
  List<Object> get props => [volume];
}

class AudioPlayerSpeedEvent extends AudioPlayerPlaylistStateEvent {
  final double speed;

  const AudioPlayerSpeedEvent(this.speed);

  @override
  List<Object> get props => [speed];
}

class AudioPlayerPitchEvent extends AudioPlayerPlaylistStateEvent {
  final double pitch;

  const AudioPlayerPitchEvent(this.pitch);

  @override
  List<Object> get props => [pitch];
}

class AudioPlayerAddSongEvent extends AudioPlayerEvent {
  final Song song;

  const AudioPlayerAddSongEvent(this.song);

  @override
  List<Object> get props => [song];
}

class AudioPlayerAddSongsEvent extends AudioPlayerEvent {
  final List<Song> songs;

  const AudioPlayerAddSongsEvent(this.songs);

  @override
  List<Object> get props => [songs];
}

class AudioPlayerRemoveSongEvent extends AudioPlayerEvent {
  final int index;

  const AudioPlayerRemoveSongEvent(this.index);

  @override
  List<Object> get props => [index];
}

class AudioPlayerClearPlaylistEvent extends AudioPlayerEvent {}

class AudioPlayerMovePlaylistItemEvent extends AudioPlayerEvent {
  final int oldIndex;
  final int newIndex;

  const AudioPlayerMovePlaylistItemEvent(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}

// ---------- Initialization and PlayerSaved Loading Events ---------- //
class AudioPlayerInitializeEvent extends AudioPlayerEvent {
  const AudioPlayerInitializeEvent();

  @override
  List<Object> get props => [];
}

class AudioPlayerLoadPlaylistEvent extends AudioPlayerEvent {
  final List<Song> songs;
  final int initialIndex;
  final bool autoPlay;

  const AudioPlayerLoadPlaylistEvent(
    this.songs, {
    this.initialIndex = 0,
    this.autoPlay = false,
  });

  @override
  List<Object> get props => [songs, initialIndex, autoPlay];
}

// ---------- Player Control Events ---------- //
class AudioPlayerPlayEvent extends AudioPlayerEvent {
  final Song? song;
  final bool clearPlaylist;

  const AudioPlayerPlayEvent({this.song, this.clearPlaylist = true});
}

class AudioPlayerPauseEvent extends AudioPlayerEvent {}

class AudioPlayerStopEvent extends AudioPlayerEvent {}

class AudioPlayerNextTrackEvent extends AudioPlayerEvent {}

class AudioPlayerPreviousTrackEvent extends AudioPlayerEvent {}

class AudioPlayerSeekEvent extends AudioPlayerEvent {
  final Duration position;

  const AudioPlayerSeekEvent(this.position);

  @override
  List<Object> get props => [position];
}

// ---------- testing events ---------- //
class AddTestSongEvent extends AudioPlayerEvent {}

// ----------- sleep timer ---------- //
class AudioPlayerSleepTimerEvent extends AudioPlayerEvent {
  final bool isActive;
  final Duration? duration;
  final void Function()? onTimerEnd;

  const AudioPlayerSleepTimerEvent({
    this.isActive = false,
    this.duration,
    this.onTimerEnd,
  });

  @override
  List<Object?> get props => [isActive, duration, onTimerEnd];
}

class AudioPlayerRecoverFromErrorEvent extends AudioPlayerEvent {
  const AudioPlayerRecoverFromErrorEvent();

  @override
  List<Object> get props => [];
}
