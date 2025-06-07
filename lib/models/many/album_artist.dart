import 'package:huoo/base/db/wrapper.dart';
import 'package:sqflite/sqflite.dart';

import 'package:huoo/models/album.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/base/db/provider.dart';

class AlbumArtistColumns {
  static const String table = 'album_artists';
  static const String id = 'id';
  static const String albumId = 'album_id';
  static const String artistId = 'artist_id';

  static List<String> get allColumns => [id, albumId, artistId];
}

class AlbumArtist {
  final int? id;
  final Album album;
  final Artist artist;

  AlbumArtist({this.id, required this.album, required this.artist});

  Map<String, dynamic> toMap() {
    return {
      AlbumArtistColumns.id: id,
      AlbumArtistColumns.albumId: album.id ?? 0,
      AlbumArtistColumns.artistId: artist.id ?? 0,
    };
  }

  static Future<AlbumArtist> fromMap(Map<String, dynamic> map) async {
    return AlbumArtist(
      id: map[AlbumArtistColumns.id] as int?,
      album:
          await DatabaseHelper().albumProvider.getById(
            map[AlbumArtistColumns.albumId] as int,
          ) ??
          Album.empty(),
      artist:
          await DatabaseHelper().artistProvider.getById(
            map[AlbumArtistColumns.artistId] as int,
          ) ??
          Artist.empty(),
    );
  }

  AlbumArtist copyWith({int? id, Album? album, Artist? artist}) {
    return AlbumArtist(
      id: id ?? this.id,
      album: album ?? this.album,
      artist: artist ?? this.artist,
    );
  }
}

class AlbumArtistProvider extends BaseProvider<AlbumArtist> {
  AlbumArtistProvider({super.db, super.dbWrapper});

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AlbumArtistColumns.table} (
        ${AlbumArtistColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AlbumArtistColumns.albumId} INTEGER NOT NULL,
        ${AlbumArtistColumns.artistId} INTEGER NOT NULL,
        FOREIGN KEY (${AlbumArtistColumns.albumId}) REFERENCES ${AlbumColumns.table} (${AlbumColumns.id}) ON DELETE CASCADE,
        FOREIGN KEY (${AlbumArtistColumns.artistId}) REFERENCES ${ArtistColumns.table} (${ArtistColumns.id}) ON DELETE CASCADE,
        UNIQUE(${AlbumArtistColumns.albumId}, ${AlbumArtistColumns.artistId})
      )
    ''');
  }

  Future<List<AlbumArtist>> getByAlbumId(int albumId) async {
    List<Map<String, dynamic>> maps = await db.query(
      AlbumArtistColumns.table,
      where: '${AlbumArtistColumns.albumId} = ?',
      whereArgs: [albumId],
    );
    return Future.wait(maps.map((map) => AlbumArtist.fromMap(map)).toList());
  }

  Future<List<Artist>?> getArtistByAlbumId(int albumId) async {
    return (await getByAlbumId(
      albumId,
    )).map((albumArtist) => albumArtist.artist).toList();
  }

  Future<List<AlbumArtist>> getByArtistId(int artistId) async {
    List<Map<String, dynamic>> maps = await db.query(
      AlbumArtistColumns.table,
      where: '${AlbumArtistColumns.artistId} = ?',
      whereArgs: [artistId],
    );
    return Future.wait(maps.map((map) => AlbumArtist.fromMap(map)).toList());
  }

  Future<List<Album>> getAlbumsByArtistId(int artistId) async {
    return (await getByArtistId(
      artistId,
    )).map((albumArtist) => albumArtist.album).toList();
  }

  @override
  AlbumArtist copyWithId(AlbumArtist item, int? id) {
    return AlbumArtist(id: id, album: item.album, artist: item.artist);
  }

  @override
  int? getItemId(AlbumArtist item) {
    return item.id;
  }

  @override
  String get idColumnName => AlbumArtistColumns.id;

  @override
  List<String> get columns => AlbumArtistColumns.allColumns;

  @override
  Future<AlbumArtist> itemFromMap(Map<String, dynamic> map) {
    return AlbumArtist.fromMap(map);
  }

  @override
  Map<String, dynamic> itemToMap(AlbumArtist item) {
    return item.toMap();
  }

  @override
  Future<AlbumArtist> insert(AlbumArtist item, [DatabaseOperation? dbWrapper]) {
    final artistProvider = DatabaseHelper().artistProvider;
    final albumProvider = DatabaseHelper().albumProvider;
    if (item.artist.id == null) {
      artistProvider.insert(item.artist, dbWrapper).then((artist) {
        item = item.copyWith(artist: artist);
      });
    }
    if (item.album.id == null) {
      albumProvider.insert(item.album, dbWrapper).then((album) {
        item = item.copyWith(album: album);
      });
    }
    return super.insert(item, dbWrapper);
  }

  @override
  String get tableName => AlbumArtistColumns.table;
}
