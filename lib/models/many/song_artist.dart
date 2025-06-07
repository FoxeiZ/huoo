import 'package:huoo/helpers/database/helper.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/song.dart';
import 'package:sqflite/sqflite.dart';

import 'package:huoo/base/db/provider.dart';

class SongArtistColumns {
  static const String table = 'song_artists';
  static const String id = 'id';
  static const String songId = 'song_id';
  static const String artistId = 'artist_id';

  static List<String> get allColumns => [id, songId, artistId];
}

class SongArtist {
  final int? id;
  final Song song;
  final Artist artist;

  SongArtist({this.id, required this.song, required this.artist});

  Map<String, dynamic> toMap() {
    return {
      SongArtistColumns.id: id,
      SongArtistColumns.songId: song.id ?? 0,
      SongArtistColumns.artistId: artist.id ?? 0,
    };
  }

  static Future<SongArtist> fromMap(Map<String, dynamic> map) async {
    return SongArtist(
      id: map[SongArtistColumns.id] as int?,
      song:
          await DatabaseHelper().songProvider.getById(
            map[SongArtistColumns.songId] as int,
          ) ??
          Song.empty(),
      artist:
          await DatabaseHelper().artistProvider.getById(
            map[SongArtistColumns.artistId] as int,
          ) ??
          Artist.empty(),
    );
  }
}

class SongArtistProvider extends BaseProvider<SongArtist> {
  SongArtistProvider({super.db, super.dbWrapper});

  static Future<void> createTable(Database db) async {
    await db.execute('''CREATE TABLE ${SongArtistColumns.table} (
        ${SongArtistColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${SongArtistColumns.songId} INTEGER NOT NULL,
        ${SongArtistColumns.artistId} INTEGER NOT NULL,
        FOREIGN KEY (${SongArtistColumns.songId}) REFERENCES ${SongColumns.table} (${SongColumns.id}) ON DELETE CASCADE,
        FOREIGN KEY (${SongArtistColumns.artistId}) REFERENCES ${ArtistColumns.table} (${ArtistColumns.id}) ON DELETE CASCADE,
        UNIQUE(${SongArtistColumns.songId}, ${SongArtistColumns.artistId})
      )''');
  }

  Future<List<SongArtist>> getBySongId(int songId) async {
    List<Map<String, dynamic>> maps = await db.query(
      SongArtistColumns.table,
      where: '${SongArtistColumns.songId} = ?',
      whereArgs: [songId],
    );
    return Future.wait(maps.map((map) => SongArtist.fromMap(map)).toList());
  }

  Future<List<Artist>> getArtistsBySongId(int songId) async {
    return (await getBySongId(
      songId,
    )).map((songArtist) => songArtist.artist).toList();
  }

  Future<List<SongArtist>> getByArtistId(int artistId) async {
    List<Map<String, dynamic>> maps = await db.query(
      SongArtistColumns.table,
      where: '${SongArtistColumns.artistId} = ?',
      whereArgs: [artistId],
    );
    return Future.wait(maps.map((map) => SongArtist.fromMap(map)).toList());
  }

  Future<List<Song>> getSongsByArtistId(int artistId) async {
    return (await getByArtistId(
      artistId,
    )).map((songArtist) => songArtist.song).toList();
  }

  @override
  SongArtist copyWithId(SongArtist item, int? id) {
    return SongArtist(id: id, song: item.song, artist: item.artist);
  }

  @override
  int? getItemId(SongArtist item) {
    return item.id;
  }

  @override
  String get idColumnName => SongArtistColumns.id;

  @override
  List<String> get columns => SongArtistColumns.allColumns;

  @override
  Future<SongArtist> itemFromMap(Map<String, dynamic> map) {
    return SongArtist.fromMap(map);
  }

  @override
  Map<String, dynamic> itemToMap(SongArtist item) {
    return item.toMap();
  }

  @override
  String get tableName => SongArtistColumns.table;
}
