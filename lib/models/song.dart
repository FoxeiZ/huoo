import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart'
    as audio_metadata;

enum AudioSourceEnum { local, api, asset }

class Song extends Equatable {
  final String id;
  final String path;
  final AudioSourceEnum source;
  final String? cover;
  // metadata
  final String album;
  final DateTime? year;
  final String? language;
  final String artist;
  final List<String> performers;
  final String title;
  final int trackNumber;
  final int trackTotal;
  final Duration duration;
  final List<String> genres;
  final int discNumber;
  final int totalDisc;
  final String? lyrics;
  final int? bitrate;
  final int? sampleRate;
  // stats
  final double? rating;
  final int playCount;
  final DateTime? dateAdded;
  final DateTime? lastPlayed;

  const Song({
    required this.id,
    required this.path,
    this.source = AudioSourceEnum.local,
    this.cover,
    required this.album,
    this.year,
    this.language,
    this.artist = 'Unknown Artist',
    this.performers = const [],
    this.title = 'Unknown Title',
    required this.trackNumber,
    required this.trackTotal,
    required this.duration,
    this.genres = const [],
    required this.discNumber,
    required this.totalDisc,
    this.lyrics,
    this.bitrate,
    this.sampleRate,
    this.rating,
    this.playCount = 0,
    this.dateAdded,
    this.lastPlayed,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      path: json['url'] as String,
      album: json['album'] as String? ?? 'Unknown Album',
      year:
          json['year'] != null ? DateTime.parse(json['year'] as String) : null,
      language: json['language'] as String?,
      artist: json['artist'] as String? ?? 'Unknown Artist',
      performers:
          (json['performers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      title: json['title'] as String? ?? 'Unknown Title',
      trackNumber: json['trackNumber'] as int? ?? 0,
      trackTotal: json['trackTotal'] as int? ?? 0,
      duration:
          json['durationMs'] != null
              ? Duration(milliseconds: json['durationMs'] as int)
              : Duration(seconds: 0),
      genres:
          (json['genre'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      discNumber: json['discNumber'] as int? ?? 0,
      totalDisc: json['totalDisc'] as int? ?? 0,
      lyrics: json['lyrics'] as String?,
      bitrate: json['bitrate'] as int?,
      sampleRate: json['sampleRate'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      playCount: json['playCount'] as int? ?? 0,
      lastPlayed:
          json['lastPlayed'] != null
              ? DateTime.parse(json['lastPlayed'] as String)
              : null,
    );
  }

  factory Song._fromAudioMetadata({
    required String id,
    required String path,
    required AudioSourceEnum source,
    required audio_metadata.AudioMetadata metadata,
  }) {
    log(
      'Creating Song from AudioMetadata: ${metadata.title} by ${metadata.artist}',
    );

    return Song(
      id: id,
      path: path,
      source: source,
      album: metadata.album ?? 'Unknown Album',
      year: metadata.year ?? DateTime.now(),
      language: metadata.language,
      artist: metadata.artist ?? 'Unknown Artist',
      performers: metadata.performers,
      title: metadata.title ?? 'Unknown Title',
      trackNumber: metadata.trackNumber ?? 0,
      trackTotal: metadata.trackTotal ?? 0,
      duration: metadata.duration ?? const Duration(seconds: 0),
      genres: metadata.genres,
      discNumber: metadata.discNumber ?? 0,
      totalDisc: metadata.totalDisc ?? 0,
      lyrics: metadata.lyrics,
      bitrate: metadata.bitrate,
      sampleRate: metadata.sampleRate,
      rating: 0.0,
      playCount: 0,
      dateAdded: DateTime.now(),
      lastPlayed: null,
    );
  }

  factory Song.fromLocalFile({required String id, required String filePath}) {
    var metadata = audio_metadata.readMetadata(
      File.fromUri(Uri.file(filePath)),
    );
    log('Song has ${metadata.pictures.length} pictures');

    return Song._fromAudioMetadata(
      id: id,
      path: filePath,
      source: AudioSourceEnum.local,
      metadata: metadata,
    );
  }

  static Future<Song> testLoad({
    required String id,
    required String assetPath,
  }) async {
    var dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'just_audio_cache'),
    );
    var file = File(
      p.joinAll([dir.path, 'assets', ...Uri.parse(assetPath).pathSegments]),
    );
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      await file.writeAsBytes(
        (await PlatformAssetBundle().load(assetPath)).buffer.asUint8List(),
      );
    }

    var fileUri = Uri.file(file.path);
    var metadata = audio_metadata.readMetadata(File.fromUri(fileUri));
    log('Test song has ${metadata.pictures.length} pictures');
    return Song._fromAudioMetadata(
      id: id,
      path: file.path,
      source: AudioSourceEnum.local,
      metadata: metadata,
    );
  }

  factory Song.fromAsset({required String id, required String assetPath}) {
    File.fromUri(Uri.parse(assetPath));
    var metadata = audio_metadata.readMetadata(
      File.fromUri(Uri.parse('asset:///$assetPath')),
    );
    log('Asset song has ${metadata.pictures.length} pictures');

    return Song._fromAudioMetadata(
      id: id,
      path: assetPath,
      source: AudioSourceEnum.asset,
      metadata: metadata,
    );
  }

  factory Song.empty() {
    return Song(
      id: "",
      path: "",
      source: AudioSourceEnum.local,
      album: 'Unknown Album',
      year: null,
      language: null,
      artist: 'Unknown Artist',
      performers: const [],
      title: 'Unknown Title',
      trackNumber: 0,
      trackTotal: 0,
      duration: const Duration(seconds: 0),
      genres: const [],
      discNumber: 0,
      totalDisc: 0,
      lyrics: null,
      bitrate: null,
      sampleRate: null,
      rating: 0.0,
      playCount: 0,
      dateAdded: null,
      lastPlayed: null,
    );
  }

  AudioSource toAudioSource() {
    switch (source) {
      case AudioSourceEnum.local:
        return AudioSource.file(path, tag: this);
      case AudioSourceEnum.api:
        return AudioSource.uri(Uri.parse(path), tag: this);
      case AudioSourceEnum.asset:
        return AudioSource.asset(path, tag: this);
    }
  }

  IndexedAudioSource toIndexedAudioSource() {
    return toAudioSource() as IndexedAudioSource;
  }

  String get coverOrDefault => cover ?? 'assets/images/default_cover.png';
  String get displayDuration => _formatDuration(duration);
  String get artistAlbum => '$artist • $album';
  String get genre => genres.isNotEmpty ? genres.join(', ') : 'Unknown Genre';
  String get formattedYear => year?.year.toString() ?? 'Unknown Year';
  String get performer =>
      performers.isNotEmpty ? performers.join(', ') : 'Various Artists';
  bool get isLocal => source == AudioSourceEnum.local;
  bool get isRemote => source == AudioSourceEnum.api;
  bool get isAsset => source == AudioSourceEnum.asset;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Song copyWith({
    String? id,
    String? path,
    AudioSourceEnum? source,
    String? cover,
    String? album,
    DateTime? year,
    String? language,
    String? artist,
    List<String>? performers,
    String? title,
    int? trackNumber,
    int? trackTotal,
    Duration? duration,
    List<String>? genres,
    int? discNumber,
    int? totalDisc,
    String? lyrics,
    int? bitrate,
    int? sampleRate,
    double? rating,
    int? playCount,
    DateTime? dateAdded,
    DateTime? lastPlayed,
  }) {
    return Song(
      id: id ?? this.id,
      path: path ?? this.path,
      source: source ?? this.source,
      cover: cover ?? this.cover,
      album: album ?? this.album,
      year: year ?? this.year,
      language: language ?? this.language,
      artist: artist ?? this.artist,
      performers: performers ?? this.performers,
      title: title ?? this.title,
      trackNumber: trackNumber ?? this.trackNumber,
      trackTotal: trackTotal ?? this.trackTotal,
      duration: duration ?? this.duration,
      genres: genres ?? this.genres,
      discNumber: discNumber ?? this.discNumber,
      totalDisc: totalDisc ?? this.totalDisc,
      lyrics: lyrics ?? this.lyrics,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      rating: rating ?? this.rating,
      playCount: playCount ?? this.playCount,
      dateAdded: dateAdded ?? this.dateAdded,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  Song incrementPlayCount() {
    return copyWith(playCount: playCount + 1, lastPlayed: DateTime.now());
  }

  Song updateRating(double newRating) {
    return copyWith(rating: newRating.clamp(0.0, 5.0));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'url': path,
      'coverUrl': cover,
      'durationMs': duration.inMilliseconds,
      'source': source.name,
      'dateAdded': dateAdded?.toIso8601String(),
      'trackNumber': trackNumber,
      'genre': genre,
      'year': year?.toIso8601String(),
      'rating': rating,
      'playCount': playCount,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    path,
    source,
    cover,
    album,
    year,
    language,
    artist,
    performers,
    title,
    trackNumber,
    trackTotal,
    duration,
    genres,
    discNumber,
    totalDisc,
    lyrics,
    bitrate,
    sampleRate,
    rating,
    playCount,
    dateAdded,
    lastPlayed,
  ];

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, album: $album)';
  }
}
