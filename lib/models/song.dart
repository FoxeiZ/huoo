import 'dart:developer';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart'
    as audio_metadata;
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:huoo/base/db/provider.dart';
import 'package:huoo/helpers/database_helper.dart';

enum AudioSourceEnum { local, api, asset }

const String table = 'songs';
const String columnId = 'id';
const String columnPath = 'path';
const String albumColumn = 'album';
const String yearColumn = 'year';
const String languageColumn = 'language';
const String artistColumn = 'artist';
const String performersColumn = 'performers';
const String titleColumn = 'title';
const String trackNumberColumn = 'track_number';
const String trackTotalColumn = 'track_total';
const String durationColumn = 'duration';
const String genresColumn = 'genres';
const String discNumberColumn = 'disc_number';
const String totalDiscColumn = 'total_disc';
const String lyricsColumn = 'lyrics';
const String playCountColumn = 'play_count';
const String dateAddedColumn = 'date_added';
const String lastPlayedColumn = 'last_played';
const String ratingColumn = 'rating';
const String coverColumn = 'cover';

class Song extends Equatable {
  final int? id;
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
  // stats
  final double? rating;
  final int playCount;
  final DateTime? dateAdded;
  final DateTime? lastPlayed;

  const Song({
    this.id,
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
    this.rating,
    this.playCount = 0,
    this.dateAdded,
    this.lastPlayed,
  });

  factory Song._fromAudioMetadata({
    required String path,
    required AudioSourceEnum source,
    required audio_metadata.AudioMetadata metadata,
  }) {
    log(
      'Creating Song from AudioMetadata: ${metadata.title} by ${metadata.artist}',
    );

    return Song(
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
      rating: 0.0,
      playCount: 0,
      dateAdded: DateTime.now(),
      lastPlayed: null,
    );
  }

  static Future<String?> _getOrSaveCoverPath(
    audio_metadata.AudioMetadata metadata,
  ) async {
    if (metadata.pictures.isEmpty) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final coverDir = Directory('${appDir.path}/covers');
    if (!await coverDir.exists()) {
      await coverDir.create();
    }

    final coverData = metadata.pictures.first;
    final checksum = md5.convert(coverData.bytes);
    final fileName = checksum.toString();
    final coverFile = File('${coverDir.path}/$fileName');
    if (await coverFile.exists()) {
      return coverFile.path;
    }

    await coverFile.writeAsBytes(coverData.bytes);
    return coverFile.path;
  }

  static Future<Song> fromLocalFile(String filePath) async {
    var metadata = audio_metadata.readMetadata(
      File.fromUri(Uri.file(filePath)),
    );
    log('Song has ${metadata.pictures.length} pictures');

    var song = Song._fromAudioMetadata(
      path: filePath,
      source: AudioSourceEnum.local,
      metadata: metadata,
    );
    String? coverPath = await _getOrSaveCoverPath(metadata);

    final savedSong = song.copyWith(
      cover: coverPath,
      dateAdded: DateTime.now(),
    );
    await DatabaseHelper().songProvider.insert(savedSong);

    return savedSong;
  }

  static Future<Song> fromAsset(String assetPath) async {
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
    return Song.fromLocalFile(file.path);
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map[columnId] as int?,
      path: map[columnPath] as String,
      album: map[albumColumn] as String? ?? 'Unknown Album',
      year:
          map[yearColumn] != null
              ? DateTime.parse(map[yearColumn] as String)
              : null,
      language: map[languageColumn] as String?,
      artist: map[artistColumn] as String? ?? 'Unknown Artist',
      performers:
          (map[performersColumn] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList() ??
          [],
      title: map[titleColumn] as String? ?? 'Unknown Title',
      trackNumber: map[trackNumberColumn] as int? ?? 0,
      trackTotal: map[trackTotalColumn] as int? ?? 0,
      duration: Duration(milliseconds: map[durationColumn] as int? ?? 0),
      genres:
          (map[genresColumn] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList() ??
          [],
      discNumber: map[discNumberColumn] as int? ?? 0,
      totalDisc: map[totalDiscColumn] as int? ?? 0,
      lyrics: map[lyricsColumn] as String?,
      playCount: map[playCountColumn] as int? ?? 0,
      dateAdded:
          map[dateAddedColumn] != null
              ? DateTime.parse(map[dateAddedColumn] as String)
              : null,
      lastPlayed:
          map[lastPlayedColumn] != null
              ? DateTime.parse(map[lastPlayedColumn] as String)
              : null,
      source: AudioSourceEnum.local,
      rating:
          map[ratingColumn] != null
              ? (map[ratingColumn] as num).toDouble()
              : 0.0,
      cover: map[coverColumn] as String?,
    );
  }

  factory Song.empty() {
    return Song(
      id: null,
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
      rating: 0.0,
      playCount: 0,
      dateAdded: null,
      lastPlayed: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      columnId: id,
      columnPath: path,
      albumColumn: album,
      yearColumn: year?.toIso8601String(),
      languageColumn: language,
      artistColumn: artist,
      performersColumn: performers.join(', '),
      titleColumn: title,
      trackNumberColumn: trackNumber,
      trackTotalColumn: trackTotal,
      durationColumn: duration.inMilliseconds,
      genresColumn: genres.join(', '),
      discNumberColumn: discNumber,
      totalDiscColumn: totalDisc,
      lyricsColumn: lyrics,
      playCountColumn: playCount,
      dateAddedColumn: dateAdded?.toIso8601String(),
      lastPlayedColumn: lastPlayed?.toIso8601String(),
      ratingColumn: rating ?? 0.0,
      coverColumn: cover,
    };
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
    int? id,
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

class SongProvider extends BaseProvider<Song> {
  final Database db;

  SongProvider(this.db);

  static Future<void> createTable(Database db) async {
    await db.execute('''CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnPath TEXT NOT NULL UNIQUE,
        $albumColumn TEXT,
        $yearColumn TEXT,
        $languageColumn TEXT,
        $artistColumn TEXT,
        $performersColumn TEXT,
        $titleColumn TEXT NOT NULL,
        $trackNumberColumn INTEGER,
        $trackTotalColumn INTEGER,
        $durationColumn INTEGER NOT NULL,
        $genresColumn TEXT,
        $discNumberColumn INTEGER,
        $totalDiscColumn INTEGER,
        $lyricsColumn TEXT,
        $playCountColumn INTEGER DEFAULT 0,
        $dateAddedColumn TEXT DEFAULT CURRENT_TIMESTAMP,
        $lastPlayedColumn TEXT,
        $ratingColumn REAL DEFAULT 0.0,
        $coverColumn TEXT
      )''');
  }

  @override
  Future<Song?> getById(int id) async {
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Song.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<Song?> insertOrUpdate(Song song) async {
    var existing = await getById(song.id ?? -1);
    if (existing != null) {
      if (existing == song) {
        return existing;
      }
      var newId = await update(song);
      return song.copyWith(id: newId);
    } else {
      return insert(song);
    }
  }

  @override
  Future<Song> insert(Song song) async {
    var id = await db.insert(table, song.toMap());
    return song.copyWith(id: id);
  }

  @override
  Future<int> update(Song song) async {
    return await db.update(
      table,
      song.toMap(),
      where: '$columnId = ?',
      whereArgs: [song.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  @override
  Future<int> count() {
    return db.rawQuery('SELECT COUNT(*) FROM $table').then((value) {
      if (value.isNotEmpty) {
        return Sqflite.firstIntValue(value) ?? 0;
      }
      return 0;
    });
  }

  @override
  Future<int> deleteAll() {
    return db.delete(table);
  }

  @override
  Future<List<Song>> getAll() {
    return db.query(table).then((maps) {
      return maps.map((map) => Song.fromMap(map)).toList();
    });
  }
}
