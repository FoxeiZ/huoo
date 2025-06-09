import 'package:equatable/equatable.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:sqflite/sqflite.dart';

import 'package:huoo/base/db/provider.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/album.dart';

class ArtistColumns {
  static const String table = 'artists';
  static const String id = 'id';
  static const String name = 'name';
  static const String imageUri = 'image_uri';
  static const String bio = 'bio';

  static List<String> get allColumns => [id, name, imageUri, bio];
}

class Artist extends Equatable {
  final int? id;
  final String name;
  final String? imageUri;
  final String? bio;

  const Artist({this.id, required this.name, this.imageUri, this.bio});

  factory Artist.empty() {
    return const Artist(
      id: 0,
      name: 'Unknown Artist',
      imageUri: null,
      bio: null,
    );
  }

  @override
  List<Object?> get props => [id, name, imageUri, bio];

  @override
  String toString() {
    return 'Artist{id: $id, name: $name, imageUri: $imageUri, bio: $bio}';
  }

  Artist copyWith({int? id, String? name, String? imageUri, String? bio}) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUri: imageUri ?? this.imageUri,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ArtistColumns.id: id,
      ArtistColumns.name: name,
      ArtistColumns.imageUri: imageUri,
      ArtistColumns.bio: bio,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      id: map[ArtistColumns.id] as int,
      name: map[ArtistColumns.name] as String,
      imageUri: map[ArtistColumns.imageUri] as String?,
      bio: map[ArtistColumns.bio] as String?,
    );
  }
}

class ArtistProvider extends BaseProvider<Artist> {
  ArtistProvider(super.databaseOperation);

  @override
  String get tableName => ArtistColumns.table;

  @override
  String get idColumnName => ArtistColumns.id;

  @override
  List<String> get columns => ArtistColumns.allColumns;

  Future<Artist?> getByName(String name) async {
    final maps = await db.query(
      tableName,
      where: '${ArtistColumns.name} = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Artist.fromMap(maps.first);
    }
    return null;
  }

  @override
  Map<String, dynamic> itemToMap(Artist artist) {
    return artist.toMap();
  }

  @override
  int? getItemId(Artist artist) {
    return artist.id;
  }

  @override
  Artist copyWithId(Artist item, int? id) {
    return item.copyWith(id: id);
  }

  Future<List<Song>> getSongs(int artistId) async {
    final maps = await db.query(
      SongColumns.table,
      where: 'artist = ?',
      whereArgs: [artistId.toString()],
    );
    return Future.wait(maps.map((map) => Song.fromMap(map)).toList());
  }

  Future<List<Album>> getAlbums(int artistId) async {
    final albumArtistProvider = DatabaseHelper().albumArtistProvider;
    final albumArtists = await albumArtistProvider.getByArtistId(artistId);

    final albumIds =
        albumArtists
            .map((albumArtist) => albumArtist.album.id)
            .whereType<int>()
            .toList();

    if (albumIds.isEmpty) {
      return [];
    }

    final placeholders = List.filled(albumIds.length, '?').join(',');
    final maps = await db.query(
      AlbumColumns.table,
      where: '${AlbumColumns.id} IN ($placeholders)',
      whereArgs: albumIds,
    );

    return maps.map((map) => Album.fromMap(map)).toList();
  }

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${ArtistColumns.table} (
        ${ArtistColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${ArtistColumns.name} TEXT NOT NULL UNIQUE,
        ${ArtistColumns.imageUri} TEXT,
        ${ArtistColumns.bio} TEXT
      )
    ''');
  }

  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS ${ArtistColumns.table}');
  }

  @override
  Future<Artist> itemFromMap(Map<String, dynamic> map) {
    return Future.value(Artist.fromMap(map));
  }
}
