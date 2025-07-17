import 'package:equatable/equatable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:huoo/base/db/provider.dart';

enum PlaylistType { local, online }

class Playlist extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final PlaylistType type;
  final String? apiId; // For online playlists
  final String? coverUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Playlist({
    this.id,
    required this.name,
    this.description,
    required this.type,
    this.apiId,
    this.coverUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Playlist.local({
    int? id,
    required String name,
    String? description,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return Playlist(
      id: id,
      name: name,
      description: description,
      type: PlaylistType.local,
      coverUrl: coverUrl,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  factory Playlist.online({
    int? id,
    required String name,
    String? description,
    required String apiId,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return Playlist(
      id: id,
      name: name,
      description: description,
      type: PlaylistType.online,
      apiId: apiId,
      coverUrl: coverUrl,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist.online(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      apiId: json['api_id'] ?? json['id'].toString(),
      coverUrl: json['cover_url'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': apiId ?? id?.toString(),
      'name': name,
      'description': description,
      'cover_url': coverUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Playlist copyWith({
    int? id,
    String? name,
    String? description,
    PlaylistType? type,
    String? apiId,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      apiId: apiId ?? this.apiId,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    type,
    apiId,
    coverUrl,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Playlist{id: $id, name: $name, type: $type}';
  }
}

class PlaylistSong extends Equatable {
  final int? id;
  final int playlistId;
  final String songId;
  final DateTime addedAt;

  const PlaylistSong({
    this.id,
    required this.playlistId,
    required this.songId,
    required this.addedAt,
  });

  factory PlaylistSong.fromMap(Map<String, dynamic> map) {
    return PlaylistSong(
      id: map['id'] as int?,
      playlistId: map['playlist_id'] as int,
      songId: map['song_id'] as String,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['added_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'playlist_id': playlistId,
      'song_id': songId,
      'added_at': addedAt.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [id, playlistId, songId, addedAt];
}

class PlaylistProvider extends BaseProvider<Playlist> {
  static const String _tableName = 'playlists';
  static const String _idColumnName = 'id';

  PlaylistProvider(super.databaseOperation);

  @override
  String get tableName => _tableName;

  @override
  String get idColumnName => _idColumnName;

  @override
  List<String> get columns => [
    'name',
    'description',
    'type',
    'api_id',
    'cover_url',
    'created_at',
    'updated_at',
  ];

  @override
  Map<String, dynamic> itemToMap(Playlist item) {
    return {
      if (item.id != null) 'id': item.id,
      'name': item.name,
      'description': item.description,
      'type': item.type.toString().split('.').last,
      'api_id': item.apiId,
      'cover_url': item.coverUrl,
      'created_at': item.createdAt.millisecondsSinceEpoch,
      'updated_at': item.updatedAt.millisecondsSinceEpoch,
    };
  }

  @override
  Future<Playlist> itemFromMap(Map<String, dynamic> map) async {
    return Playlist(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: PlaylistType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      apiId: map['api_id'] as String?,
      coverUrl: map['cover_url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  Playlist copyWithId(Playlist item, int? id) {
    return item.copyWith(id: id);
  }

  @override
  int? getItemId(Playlist item) {
    return item.id;
  }

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_idColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        api_id TEXT,
        cover_url TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $_tableName');
  }

  Future<List<PlaylistSong>> getPlaylistSongs(int playlistId) async {
    return PlaylistSongProvider(db).getByPlaylistId(playlistId);
  }

  Future<void> addSongToPlaylist(int playlistId, String songId) async {
    final playlistSong = PlaylistSong(
      id: null,
      playlistId: playlistId,
      songId: songId,
      addedAt: DateTime.now(),
    );
    await PlaylistSongProvider(db).insert(playlistSong);
  }

  Future<void> removeSongFromPlaylist(int playlistId, String songId) async {
    await PlaylistSongProvider(db).removeSong(playlistId, songId);
  }

  Future<List<Playlist>> getPlaylistsByType(PlaylistType type) async {
    final maps = await db.query(
      tableName,
      where: 'type = ?',
      whereArgs: [type.toString().split('.').last],
    );
    return Future.wait(maps.map((map) => itemFromMap(map)));
  }

  Future<void> delete(int id) async {
    await db.delete(tableName, where: '$idColumnName = ?', whereArgs: [id]);
  }
}

class PlaylistSongProvider extends BaseProvider<PlaylistSong> {
  static const String _tableName = 'playlist_songs';
  static const String _idColumnName = 'id';

  PlaylistSongProvider(super.databaseOperation);

  @override
  String get tableName => _tableName;

  @override
  String get idColumnName => _idColumnName;

  @override
  List<String> get columns => ['playlist_id', 'song_id', 'added_at'];

  @override
  Map<String, dynamic> itemToMap(PlaylistSong item) {
    return {
      if (item.id != null) 'id': item.id,
      'playlist_id': item.playlistId,
      'song_id': item.songId,
      'added_at': item.addedAt.millisecondsSinceEpoch,
    };
  }

  @override
  Future<PlaylistSong> itemFromMap(Map<String, dynamic> map) async {
    return PlaylistSong(
      id: map['id'] as int?,
      playlistId: map['playlist_id'] as int,
      songId: map['song_id'] as String,
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['added_at'] as int),
    );
  }

  @override
  PlaylistSong copyWithId(PlaylistSong item, int? id) {
    return PlaylistSong(
      id: id,
      playlistId: item.playlistId,
      songId: item.songId,
      addedAt: item.addedAt,
    );
  }

  @override
  int? getItemId(PlaylistSong item) {
    return item.id;
  }

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_idColumnName INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL,
        song_id TEXT NOT NULL,
        added_at INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE,
        UNIQUE(playlist_id, song_id)
      )
    ''');
  }

  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $_tableName');
  }

  Future<List<PlaylistSong>> getByPlaylistId(int playlistId) async {
    final maps = await db.query(
      tableName,
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );
    final results = await Future.wait(maps.map((map) => itemFromMap(map)));
    // Sort by added_at descending
    results.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return results;
  }

  Future<void> removeSong(int playlistId, String songId) async {
    await db.delete(
      tableName,
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
  }
}
