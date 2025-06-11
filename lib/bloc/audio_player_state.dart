part of 'audio_player_bloc.dart';

sealed class AudioPlayerState extends Equatable {
  const AudioPlayerState();

  @override
  List<Object?> get props => [];
}

final class AudioPlayerInitial extends AudioPlayerState {
  final bool isRestored;

  const AudioPlayerInitial({this.isRestored = false});

  @override
  List<Object> get props => [isRestored];
}

class AudioPlayerLoading extends AudioPlayerState {}

class AudioPlayerReady extends AudioPlayerState {
  final AudioSource? source;
  final List<IndexedAudioSource> playlist;
  final int? currentIndex;
  final Song? songMetadata;
  // event
  final bool loading;
  final bool playing;
  final ProcessingState processingState;
  // postion
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  // playlist
  final LoopMode loopMode;
  final bool shuffleModeEnabled;
  final double volume;
  final double speed;
  final double pitch;
  // Android specific
  final int? androidAudioSessionId;
  // queue state
  final bool hasNext;
  final bool hasPrevious;
  // sleep timer
  final Duration? sleepTimer;

  const AudioPlayerReady({
    this.source,
    this.playlist = const [],
    this.currentIndex,
    this.songMetadata,
    this.loading = false,
    this.playing = false,
    required this.processingState,
    required this.duration,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.loopMode = LoopMode.off,
    this.shuffleModeEnabled = false,
    required this.volume,
    required this.speed,
    required this.pitch,
    this.androidAudioSessionId,
    this.hasNext = false,
    this.hasPrevious = false,
    this.sleepTimer,
  });

  AudioPlayerReady copyWith({
    AudioSource? source,
    List<IndexedAudioSource>? playlist,
    int? currentIndex,
    Song? songMetadata,
    bool? loading,
    bool? playing,
    ProcessingState? processingState,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    LoopMode? loopMode,
    bool? shuffleModeEnabled,
    double? volume,
    double? speed,
    double? pitch,
    int? androidAudioSessionId,
    bool? hasNext,
    bool? hasPrevious,
    Duration? sleepTimer,
  }) {
    return AudioPlayerReady(
      source: source ?? this.source,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      songMetadata: songMetadata ?? this.songMetadata,
      loading: loading ?? this.loading,
      playing: playing ?? this.playing,
      processingState: processingState ?? this.processingState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      loopMode: loopMode ?? this.loopMode,
      shuffleModeEnabled: shuffleModeEnabled ?? this.shuffleModeEnabled,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      androidAudioSessionId:
          androidAudioSessionId ?? this.androidAudioSessionId,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      sleepTimer: sleepTimer ?? this.sleepTimer,
    );
  }

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

class AudioPlayerError extends AudioPlayerState {
  final String message;

  const AudioPlayerError(this.message);

  @override
  List<Object> get props => [message];
}
