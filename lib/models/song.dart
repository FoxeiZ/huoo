import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart'
    as audio_metadata;
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/many/song_artist.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:huoo/base/db/provider.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/models/album.dart';

enum AudioSourceEnum { local, api, asset }

class SongColumns {
  static const String table = 'songs';
  static const String id = 'id';
  static const String path = 'path';
  static const String albumId = 'album_id';
  static const String year = 'year';
  static const String language = 'language';
  static const String performers = 'performers';
  static const String title = 'title';
  static const String trackNumber = 'track_number';
  static const String trackTotal = 'track_total';
  static const String duration = 'duration';
  static const String genres = 'genres';
  static const String discNumber = 'disc_number';
  static const String totalDisc = 'total_disc';
  static const String lyrics = 'lyrics';
  static const String playCount = 'play_count';
  static const String dateAdded = 'date_added';
  static const String lastPlayed = 'last_played';
  static const String rating = 'rating';
  static const String cover = 'cover';

  static List<String> get allColumns => [
    id,
    path,
    albumId,
    year,
    language,
    performers,
    title,
    trackNumber,
    trackTotal,
    duration,
    genres,
    discNumber,
    totalDisc,
    lyrics,
    playCount,
    dateAdded,
    lastPlayed,
    rating,
    cover,
  ];
}

class Song extends Equatable {
  final int? id;
  final String path;
  final AudioSourceEnum source;
  final String? cover;
  final int? albumId;
  final DateTime? year;
  final String? language;
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
  // extra model info
  final List<Artist>? artists;
  final Album? album;

  const Song({
    this.id,
    required this.path,
    this.source = AudioSourceEnum.local,
    this.cover,
    this.albumId,
    this.year,
    this.language,
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
    this.artists,
    this.album,
  });

  static Future<Song> _fromAudioMetadata({
    required String path,
    required AudioSourceEnum source,
    required audio_metadata.AudioMetadata metadata,
  }) async {
    return Song(
      path: path,
      source: source,
      year: metadata.year ?? DateTime.now(),
      language: metadata.language,
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

    final songProvider = DatabaseHelper().songProvider;
    final existingSong = await songProvider.getByPath(filePath);
    if (existingSong != null) {
      return existingSong;
    }

    var song = await Song._fromAudioMetadata(
      path: filePath,
      source: AudioSourceEnum.local,
      metadata: metadata,
    );
    String? coverPath = await _getOrSaveCoverPath(metadata);

    final savedSong = song.copyWith(
      cover: coverPath,
      dateAdded: DateTime.now(),
    );
    await songProvider.insertOrUpdate(savedSong);
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

  static Future<Song> fromMap(Map<String, dynamic> map) async {
    return Song(
      id: map[SongColumns.id] as int?,
      path: map[SongColumns.path] as String,
      year:
          map[SongColumns.year] != null
              ? DateTime.parse(map[SongColumns.year] as String)
              : null,
      language: map[SongColumns.language] as String?,
      albumId: map[SongColumns.albumId] as int?,
      performers:
          (map[SongColumns.performers] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList() ??
          [],
      title: map[SongColumns.title] as String? ?? 'Unknown Title',
      trackNumber: map[SongColumns.trackNumber] as int? ?? 0,
      trackTotal: map[SongColumns.trackTotal] as int? ?? 0,
      duration: Duration(milliseconds: map[SongColumns.duration] as int? ?? 0),
      genres:
          (map[SongColumns.genres] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .toList() ??
          [],
      discNumber: map[SongColumns.discNumber] as int? ?? 0,
      totalDisc: map[SongColumns.totalDisc] as int? ?? 0,
      lyrics: map[SongColumns.lyrics] as String?,
      playCount: map[SongColumns.playCount] as int? ?? 0,
      dateAdded:
          map[SongColumns.dateAdded] != null
              ? DateTime.parse(map[SongColumns.dateAdded] as String)
              : null,
      lastPlayed:
          map[SongColumns.lastPlayed] != null
              ? DateTime.parse(map[SongColumns.lastPlayed] as String)
              : null,
      source: AudioSourceEnum.local,
      rating:
          map[SongColumns.rating] != null
              ? (map[SongColumns.rating] as num).toDouble()
              : 0.0,
      cover: map[SongColumns.cover] as String?,
    );
  }

  factory Song.empty() {
    return Song(
      id: null,
      path: "",
      source: AudioSourceEnum.local,
      year: null,
      language: null,
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
      SongColumns.id: id,
      SongColumns.path: path,
      SongColumns.year: year?.toIso8601String(),
      SongColumns.albumId: albumId,
      SongColumns.language: language,
      SongColumns.performers: performers.join(', '),
      SongColumns.title: title,
      SongColumns.trackNumber: trackNumber,
      SongColumns.trackTotal: trackTotal,
      SongColumns.duration: duration.inMilliseconds,
      SongColumns.genres: genres.join(', '),
      SongColumns.discNumber: discNumber,
      SongColumns.totalDisc: totalDisc,
      SongColumns.lyrics: lyrics,
      SongColumns.playCount: playCount,
      SongColumns.dateAdded: dateAdded?.toIso8601String(),
      SongColumns.lastPlayed: lastPlayed?.toIso8601String(),
      SongColumns.rating: rating ?? 0.0,
      SongColumns.cover: cover,
    };
  }

  static Future<Song> fromMediaItem(MediaItem? mediaItem) async {
    if (mediaItem == null) {
      return Song.empty();
    }
    return Song(
      id: int.tryParse(mediaItem.id),
      title: mediaItem.title,
      cover: mediaItem.artUri?.toFilePath(),
      duration: mediaItem.duration ?? const Duration(seconds: 0),
      genres: mediaItem.extras?['genres']?.toString().split(', ') ?? [],
      albumId: mediaItem.extras?['albumId'] as int?,
      path: mediaItem.extras?['path'] ?? '',
      source:
          mediaItem.extras?['source'] == 'AudioSourceEnum.local'
              ? AudioSourceEnum.local
              : mediaItem.extras?['source'] == 'AudioSourceEnum.api'
              ? AudioSourceEnum.api
              : AudioSourceEnum.asset,
      year:
          mediaItem.extras?['year'] != null
              ? DateTime.tryParse(mediaItem.extras!['year'])
              : null,
      language: mediaItem.extras?['language'],
      performers: mediaItem.extras?['performers']?.toString().split(', ') ?? [],
      trackNumber: mediaItem.extras?['trackNumber'] ?? 0,
      trackTotal: mediaItem.extras?['trackTotal'] ?? 0,
      discNumber: mediaItem.extras?['discNumber'] ?? 0,
      totalDisc: mediaItem.extras?['totalDisc'] ?? 0,
      lyrics: mediaItem.extras?['lyrics'],
      rating: (mediaItem.extras?['rating'] as num?)?.toDouble() ?? 0.0,
      playCount: mediaItem.extras?['playCount'] ?? 0,
      dateAdded:
          mediaItem.extras?['dateAdded'] != null
              ? DateTime.tryParse(mediaItem.extras!['dateAdded'])
              : null,
      lastPlayed:
          mediaItem.extras?['lastPlayed'] != null
              ? DateTime.tryParse(mediaItem.extras!['lastPlayed'])
              : null,
    );
  }

  Future<MediaItem> toMediaItem() async {
    return MediaItem(
      id: id?.toString() ?? path,
      title: title,
      artist: await artist,
      artUri: cover != null ? Uri.file(cover!) : null,
      duration: duration,
      genre: genres.isNotEmpty ? genres.join(', ') : null,
      album: await getAlbum().then((album) => album.title),
      extras: {
        'path': path,
        'source': source.toString(),
        'year': year?.year.toString(),
        'language': language,
        'performers': performers,
        'trackNumber': trackNumber,
        'trackTotal': trackTotal,
        'discNumber': discNumber,
        'totalDisc': totalDisc,
        'lyrics': lyrics,
        'rating': rating ?? 0.0,
        'playCount': playCount,
        'dateAdded': dateAdded?.toIso8601String(),
        'lastPlayed': lastPlayed?.toIso8601String(),
      },
    );
  }

  Future<AudioSource> toAudioSource() async {
    switch (source) {
      case AudioSourceEnum.local:
        return AudioSource.file(path, tag: await toMediaItem());
      case AudioSourceEnum.api:
        return AudioSource.uri(Uri.parse(path), tag: await toMediaItem());
      case AudioSourceEnum.asset:
        return AudioSource.asset(path, tag: await toMediaItem());
    }
  }

  IndexedAudioSource toIndexedAudioSource() {
    return toAudioSource() as IndexedAudioSource;
  }

  String get coverOrDefault => cover ?? 'assets/images/default_cover.png';
  String get displayDuration => _formatDuration(duration);
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
    int? albumId,
    DateTime? year,
    String? language,
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
    Album? album,
    List<Artist>? artists,
  }) {
    return Song(
      id: id ?? this.id,
      path: path ?? this.path,
      source: source ?? this.source,
      cover: cover ?? this.cover,
      albumId: albumId ?? this.albumId,
      year: year ?? this.year,
      language: language ?? this.language,
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
      artists: artists ?? this.artists,
      album: album ?? this.album,
    );
  }

  Song incrementPlayCount() {
    return copyWith(playCount: playCount + 1, lastPlayed: DateTime.now());
  }

  Song updateRating(double newRating) {
    return copyWith(rating: newRating.clamp(0.0, 5.0));
  }

  Future<List<Artist>> getArtists() async {
    if (artists != null && artists!.isNotEmpty) {
      return artists!;
    }
    return DatabaseHelper().songArtistProvider
        .getArtistsBySongId(id ?? 0)
        .then((artists) => artists.isNotEmpty ? artists : [Artist.empty()]);
  }

  Future<String> get artist {
    return getArtists().then(
      (artists) =>
          artists.isNotEmpty
              ? artists.map((a) => a.name).join(', ')
              : 'Unknown',
    );
  }

  Future<Album> getAlbum() async {
    if (album != null) {
      return album!;
    }
    if (albumId == null || albumId == 0) {
      return Album.empty();
    }
    return DatabaseHelper().albumProvider
        .getById(albumId ?? 0)
        .then((album) => album ?? Album.empty());
  }

  @override
  List<Object?> get props => [
    id,
    path,
    source,
    cover,
    year,
    language,
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
    return 'Song(id: $id, title: $title)';
  }
}

class SongProvider extends BaseProvider<Song> {
  SongProvider({super.db, super.dbWrapper});

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${SongColumns.table} (
        ${SongColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SongColumns.path} TEXT NOT NULL UNIQUE,
        ${SongColumns.albumId} INTEGER,
        ${SongColumns.year} TEXT,
        ${SongColumns.language} TEXT,
        ${SongColumns.performers} TEXT,
        ${SongColumns.title} TEXT NOT NULL,
        ${SongColumns.trackNumber} INTEGER,
        ${SongColumns.trackTotal} INTEGER,
        ${SongColumns.duration} INTEGER NOT NULL,
        ${SongColumns.genres} TEXT,
        ${SongColumns.discNumber} INTEGER,
        ${SongColumns.totalDisc} INTEGER,
        ${SongColumns.lyrics} TEXT,
        ${SongColumns.playCount} INTEGER DEFAULT 0,
        ${SongColumns.dateAdded} TEXT DEFAULT CURRENT_TIMESTAMP,
        ${SongColumns.lastPlayed} TEXT,
        ${SongColumns.rating} REAL DEFAULT 0.0,
        ${SongColumns.cover} TEXT,
        FOREIGN KEY (${SongColumns.albumId}) REFERENCES ${AlbumColumns.table} (${AlbumColumns.id}) ON DELETE SET NULL
    )''');
  }

  @override
  int? getItemId(Song item) {
    return item.id;
  }

  @override
  String get idColumnName => SongColumns.id;

  @override
  List<String> get columns => SongColumns.allColumns;

  @override
  Map<String, dynamic> itemToMap(Song item) {
    return item.toMap();
  }

  @override
  String get tableName => SongColumns.table;

  Future<Song?> getByPath(String path) async {
    List<Map<String, dynamic>> maps = await db.query(
      SongColumns.table,
      where: '${SongColumns.path} = ?',
      whereArgs: [path],
    );

    if (maps.isNotEmpty) {
      return Song.fromMap(maps.first);
    }
    return null;
  }

  @override
  Song copyWithId(Song item, int? id) {
    return item.copyWith(id: id);
  }

  @override
  Future<Song> itemFromMap(Map<String, dynamic> map) async {
    return Song.fromMap(map);
  }

  Future<Song?> getSongWithDetails(int songId) async {
    // Get song with album data in one query
    final songMaps = await db.rawQuery(
      '''
      SELECT 
        s.*,
        a.${AlbumColumns.id} as album_id,
        a.${AlbumColumns.title} as album_title,
        a.${AlbumColumns.coverUri} as album_cover_uri,
        a.${AlbumColumns.releaseDate} as album_year
      FROM ${SongColumns.table} s
      LEFT JOIN ${AlbumColumns.table} a ON s.${SongColumns.albumId} = a.${AlbumColumns.id}
      WHERE s.${SongColumns.id} = ?
    ''',
      [songId],
    );

    if (songMaps.isEmpty) return null;

    final songMap = songMaps.first;
    final song = await Song.fromMap(songMap);

    // Build album from the joined data
    final album =
        songMap['album_id'] != null
            ? Album(
              id: songMap['album_id'] as int?,
              title: songMap['album_title'] as String? ?? 'Unknown Album',
              coverUri: songMap['album_cover_uri'] as String?,
              releaseDate:
                  songMap['album_year'] != null
                      ? DateTime.parse(songMap['album_year'] as String)
                      : null,
            )
            : Album.empty();

    // Get artists for this song
    final artistMaps = await db.rawQuery(
      '''
      SELECT ar.*
      FROM ${ArtistColumns.table} ar
      INNER JOIN ${SongArtistColumns.table} sa ON ar.${ArtistColumns.id} = sa.${SongArtistColumns.artistId}
      WHERE sa.${SongArtistColumns.songId} = ?
      ORDER BY ar.${ArtistColumns.name}
    ''',
      [songId],
    );

    final artists =
        artistMaps.isNotEmpty
            ? artistMaps.map((map) => Artist.fromMap(map)).toList()
            : [Artist.empty()];

    return song.copyWith(album: album, artists: artists);
  }

  Future<List<Song>> getAllSongsWithDetails() async {
    final songMaps = await db.rawQuery('''
      SELECT DISTINCT
        s.*,
        a.${AlbumColumns.id} as album_id,
        a.${AlbumColumns.title} as album_title,
        a.${AlbumColumns.coverUri} as album_cover_uri,
        a.${AlbumColumns.releaseDate} as album_year
      FROM ${SongColumns.table} s
      LEFT JOIN ${AlbumColumns.table} a ON s.${SongColumns.albumId} = a.${AlbumColumns.id}
      ORDER BY s.${SongColumns.title}
    ''');

    List<Song> results = [];

    for (final songMap in songMaps) {
      final song = await Song.fromMap(songMap);

      final album =
          songMap['album_id'] != null
              ? Album(
                id: songMap['album_id'] as int?,
                title: songMap['album_title'] as String? ?? 'Unknown Album',
                coverUri: songMap['album_cover_uri'] as String?,
                releaseDate:
                    songMap['album_year'] != null
                        ? DateTime.parse(songMap['album_year'] as String)
                        : null,
              )
              : Album.empty();

      // Get artists for this song
      final artistMaps = await db.rawQuery(
        '''
        SELECT ar.*
        FROM ${ArtistColumns.table} ar
        INNER JOIN ${SongArtistColumns.table} sa ON ar.${ArtistColumns.id} = sa.${SongArtistColumns.artistId}
        WHERE sa.${SongArtistColumns.songId} = ?
        ORDER BY ar.${ArtistColumns.name}
      ''',
        [song.id],
      );

      final artists =
          artistMaps.isNotEmpty
              ? artistMaps.map((map) => Artist.fromMap(map)).toList()
              : [Artist.empty()];

      results.add(song.copyWith(album: album, artists: artists));
    }

    return results;
  }

  Future<List<Song>> getSongsByAlbumWithDetails(int albumId) async {
    final songMaps = await db.rawQuery(
      '''
      SELECT 
        s.*,
        a.${AlbumColumns.id} as album_id,
        a.${AlbumColumns.title} as album_title,
        a.${AlbumColumns.coverUri} as album_cover_uri,
        a.${AlbumColumns.releaseDate} as album_year
      FROM ${SongColumns.table} s
      LEFT JOIN ${AlbumColumns.table} a ON s.${SongColumns.albumId} = a.${AlbumColumns.id}
      WHERE s.${SongColumns.albumId} = ?
      ORDER BY s.${SongColumns.trackNumber}, s.${SongColumns.title}
    ''',
      [albumId],
    );

    List<Song> results = [];

    for (final songMap in songMaps) {
      final song = await Song.fromMap(songMap);

      final album = Album(
        id: songMap['album_id'] as int?,
        title: songMap['album_title'] as String? ?? 'Unknown Album',
        coverUri: songMap['album_cover_uri'] as String?,
        releaseDate:
            songMap['album_year'] != null
                ? DateTime.parse(songMap['album_year'] as String)
                : null,
      );

      final artistMaps = await db.rawQuery(
        '''
        SELECT ar.*
        FROM ${ArtistColumns.table} ar
        INNER JOIN ${SongArtistColumns.table} sa ON ar.${ArtistColumns.id} = sa.${SongArtistColumns.artistId}
        WHERE sa.${SongArtistColumns.songId} = ?
        ORDER BY ar.${ArtistColumns.name}
      ''',
        [song.id],
      );

      final artists =
          artistMaps.isNotEmpty
              ? artistMaps.map((map) => Artist.fromMap(map)).toList()
              : [Artist.empty()];

      results.add(song.copyWith(album: album, artists: artists));
    }

    return results;
  }

  Future<List<Song>> getSongsByArtistWithDetails(int artistId) async {
    final songMaps = await db.rawQuery(
      '''
      SELECT DISTINCT
        s.*,
        a.${AlbumColumns.id} as album_id,
        a.${AlbumColumns.title} as album_title,
        a.${AlbumColumns.coverUri} as album_cover_uri,
        a.${AlbumColumns.releaseDate} as album_year
      FROM ${SongColumns.table} s
      LEFT JOIN ${AlbumColumns.table} a ON s.${SongColumns.albumId} = a.${AlbumColumns.id}
      INNER JOIN ${SongArtistColumns.table} sa ON s.${SongColumns.id} = sa.${SongArtistColumns.songId}
      WHERE sa.${SongArtistColumns.artistId} = ?
      ORDER BY s.${SongColumns.title}
    ''',
      [artistId],
    );

    List<Song> results = [];

    for (final songMap in songMaps) {
      final song = await Song.fromMap(songMap);

      final album =
          songMap['album_id'] != null
              ? Album(
                id: songMap['album_id'] as int?,
                title: songMap['album_title'] as String? ?? 'Unknown Album',
                coverUri: songMap['album_cover_uri'] as String?,
                releaseDate:
                    songMap['album_year'] != null
                        ? DateTime.parse(songMap['album_year'] as String)
                        : null,
              )
              : Album.empty();

      final artistMaps = await db.rawQuery(
        '''
        SELECT ar.*
        FROM ${ArtistColumns.table} ar
        INNER JOIN ${SongArtistColumns.table} sa ON ar.${ArtistColumns.id} = sa.${SongArtistColumns.artistId}
        WHERE sa.${SongArtistColumns.songId} = ?
        ORDER BY ar.${ArtistColumns.name}
      ''',
        [song.id],
      );

      final artists =
          artistMaps.isNotEmpty
              ? artistMaps.map((map) => Artist.fromMap(map)).toList()
              : [Artist.empty()];

      results.add(song.copyWith(album: album, artists: artists));
    }

    return results;
  }

  Future<List<Song>> searchSongsWithDetails(String query) async {
    final songMaps = await db.rawQuery(
      '''
      SELECT DISTINCT
        s.*,
        a.${AlbumColumns.id} as album_id,
        a.${AlbumColumns.title} as album_title,
        a.${AlbumColumns.coverUri} as album_cover_uri,
        a.${AlbumColumns.releaseDate} as album_year
      FROM ${SongColumns.table} s
      LEFT JOIN ${AlbumColumns.table} a ON s.${SongColumns.albumId} = a.${AlbumColumns.id}
      LEFT JOIN ${SongArtistColumns.table} sa ON s.${SongColumns.id} = sa.${SongArtistColumns.songId}
      LEFT JOIN ${ArtistColumns.table} ar ON sa.${SongArtistColumns.artistId} = ar.${ArtistColumns.id}
      WHERE s.${SongColumns.title} LIKE ? 
         OR a.${AlbumColumns.title} LIKE ?
         OR ar.${ArtistColumns.name} LIKE ?
         OR s.${SongColumns.genres} LIKE ?
      ORDER BY s.${SongColumns.title}
    ''',
      ['%$query%', '%$query%', '%$query%', '%$query%'],
    );

    List<Song> results = [];

    for (final songMap in songMaps) {
      final song = await Song.fromMap(songMap);

      final album =
          songMap['album_id'] != null
              ? Album(
                id: songMap['album_id'] as int?,
                title: songMap['album_title'] as String? ?? 'Unknown Album',
                coverUri: songMap['album_cover_uri'] as String?,
                releaseDate:
                    songMap['album_year'] != null
                        ? DateTime.parse(songMap['album_year'] as String)
                        : null,
              )
              : Album.empty();

      final artistMaps = await db.rawQuery(
        '''
        SELECT ar.*
        FROM ${ArtistColumns.table} ar
        INNER JOIN ${SongArtistColumns.table} sa ON ar.${ArtistColumns.id} = sa.${SongArtistColumns.artistId}
        WHERE sa.${SongArtistColumns.songId} = ?
        ORDER BY ar.${ArtistColumns.name}
      ''',
        [song.id],
      );

      final artists =
          artistMaps.isNotEmpty
              ? artistMaps.map((map) => Artist.fromMap(map)).toList()
              : [Artist.empty()];

      results.add(song.copyWith(album: album, artists: artists));
    }

    return results;
  }

  // // Batch operations for better performance
  // Future<List<SongWithAlbumAndArtists>> insertBatchWithDetails(
  //   List<Song> songs,
  //   List<Album> albums,
  //   List<Artist> artists,
  //   List<Map<String, int>> relationships,
  // ) async {
  //   return await db.transaction((txn) async {
  //     final songProvider = SongProvider(txn);
  //     final albumProvider = AlbumProvider(txn);
  //     final artistProvider = ArtistProvider(txn);
  //     final songArtistProvider = SongArtistProvider(txn);

  //     // Insert all entities
  //     final insertedSongs = await Future.wait(
  //       songs.map((song) => songProvider.insert(song)),
  //     );
  //     final insertedAlbums = await Future.wait(
  //       albums.map((album) => albumProvider.insert(album)),
  //     );
  //     final insertedArtists = await Future.wait(
  //       artists.map((artist) => artistProvider.insert(artist)),
  //     );

  //     // Insert relationships
  //     for (final relationship in relationships) {
  //       final songId = relationship['songId'];
  //       final artistId = relationship['artistId'];
  //       if (songId != null && artistId != null) {
  //         await songArtistProvider.insert(
  //           SongArtist(
  //             song: insertedSongs.firstWhere((s) => s.id == songId),
  //             artist: insertedArtists.firstWhere((a) => a.id == artistId),
  //           ),
  //         );
  //       }
  //     }

  //     // Return combined results
  //     return Future.wait(
  //       insertedSongs.map((song) => getSongWithDetails(song.id!)),
  //     ).then(
  //       (results) => results.whereType<SongWithAlbumAndArtists>().toList(),
  //     );
  //   });
  // }
}
