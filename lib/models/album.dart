import 'package:equatable/equatable.dart';
import 'package:huoo/models/artist.dart';
import 'package:sqflite/sqflite.dart';

import 'package:huoo/base/db/provider.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/many/album_artist.dart';

class AlbumColumns {
  static const table = 'album';
  static const String id = 'id';
  static const String title = 'title';
  static const String coverUri = 'cover_uri';
  static const String year = 'year';
}

class Album extends Equatable {
  final int? id;
  final String title;
  final String? coverUri;
  final DateTime? year;

  const Album({this.id, required this.title, this.coverUri, this.year});

  factory Album.empty() {
    return const Album(
      id: 0,
      title: 'Unknown Album',
      coverUri: null,
      year: null,
    );
  }

  @override
  List<Object?> get props => [id, title, coverUri, year];

  @override
  String toString() {
    return 'Album{id: $id, title: $title, coverUri: $coverUri, year: $year}';
  }

  Album copyWith({int? id, String? title, String? coverUri, DateTime? year}) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUri: coverUri ?? this.coverUri,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AlbumColumns.id: id,
      AlbumColumns.title: title,
      AlbumColumns.coverUri: coverUri,
      AlbumColumns.year: year?.toIso8601String(),
    };
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map[AlbumColumns.id] as int,
      title: map[AlbumColumns.title] as String,
      coverUri: map[AlbumColumns.coverUri] as String?,
      year:
          map[AlbumColumns.year] != null
              ? DateTime.parse(map[AlbumColumns.year] as String)
              : null,
    );
  }
}

class AlbumProvider extends CrudProvider<Album> {
  AlbumProvider(super.db);

  @override
  String get tableName => AlbumColumns.table;

  @override
  String get idColumnName => AlbumColumns.id;

  Future<Album> insertWithArtists(Album album, List<Artist> artists) async {
    final insertedAlbum = await insert(album);

    if (artists.isNotEmpty && insertedAlbum.id != null) {
      final albumArtistProvider = AlbumArtistProvider(db);
      for (final artist in artists) {
        final albumArtist = AlbumArtist(album: insertedAlbum, artist: artist);
        await albumArtistProvider.insert(albumArtist);
      }
    }

    return insertedAlbum;
  }

  Future<Album?> getByTitle(String? title) async {
    final maps = await db.query(
      tableName,
      where: '${AlbumColumns.title} = ?',
      whereArgs: [title],
    );
    if (maps.isNotEmpty) {
      return Album.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Album>> getAll() async {
    final maps = await db.query(tableName);
    return maps.map((map) => Album.fromMap(map)).toList();
  }

  @override
  Map<String, dynamic> itemToMap(Album album) {
    return album.toMap();
  }

  @override
  int? getItemId(Album album) {
    return album.id;
  }

  Future<List<Song>> getSongs(int albumId) async {
    final maps = await db.query(
      SongColumns.table,
      where: '${AlbumColumns.id} = ?',
      whereArgs: [albumId],
    );
    return Future.wait(maps.map((map) => Song.fromMap(map)).toList());
  }

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AlbumColumns.table} (
        ${AlbumColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AlbumColumns.title} TEXT NOT NULL,
        ${AlbumColumns.coverUri} TEXT,
        ${AlbumColumns.year} TEXT
      )
    ''');
  }

  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS ${AlbumColumns.table}');
  }

  @override
  Album copyWithId(Album item, int? id) {
    return item.copyWith(id: id);
  }

  @override
  Future<Album> itemFromMap(Map<String, dynamic> map) {
    return Future.value(Album.fromMap(map));
  }
}
