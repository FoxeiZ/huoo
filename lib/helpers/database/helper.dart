import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:huoo/base/db/wrapper.dart';
import 'package:huoo/models/song.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/playlist.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/many/song_artist.dart';
import 'package:huoo/models/many/album_artist.dart';
import 'package:huoo/helpers/database/types.dart';

final log = Logger(
  filter: DevelopmentFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late Database _database;
  late DatabaseWrapper _databaseWrapper;

  SongProvider? _songProvider;
  AlbumProvider? _albumProvider;
  ArtistProvider? _artistProvider;
  PlaylistProvider? _playlistProvider;
  SongArtistProvider? _songArtistProvider;
  AlbumArtistProvider? _albumArtistProvider;

  bool _isInitialized = false;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  SongProvider get songProvider {
    if (_songProvider == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _songProvider!;
  }

  AlbumProvider get albumProvider {
    if (_albumProvider == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _albumProvider!;
  }

  ArtistProvider get artistProvider {
    if (_artistProvider == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _artistProvider!;
  }

  PlaylistProvider get playlistProvider {
    if (_playlistProvider == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _playlistProvider!;
  }

  SongArtistProvider get songArtistProvider {
    if (_songArtistProvider == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _songArtistProvider!;
  }

  AlbumArtistProvider get albumArtistProvider {
    if (_albumArtistProvider == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _albumArtistProvider!;
  }

  Future<Database> get db async {
    if (!_isInitialized) {
      await initialize();
    }
    return _database;
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      if (Platform.isWindows) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      _database = await _initDatabase();
      _databaseWrapper = DatabaseWrapper(_database);

      // init providers
      _songProvider = SongProvider(_databaseWrapper);
      _albumProvider = AlbumProvider(_databaseWrapper);
      _artistProvider = ArtistProvider(_databaseWrapper);
      _songArtistProvider = SongArtistProvider(_databaseWrapper);
      _albumArtistProvider = AlbumArtistProvider(_databaseWrapper);
      // _playlistProvider = PlaylistProvider(_database!);

      _isInitialized = true;
      await afterInitialize();
    }
  }

  Future<void> afterInitialize() async {
    if (!_isInitialized) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    await addTestData();
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationSupportDirectory();
    final path = join(documentsDirectory.path, 'huoo_music.db');
    log.i('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (database) async {
        // Enable foreign key constraints
        await database.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await SongProvider.createTable(db);
    await AlbumProvider.createTable(db);
    await ArtistProvider.createTable(db);
    await SongArtistProvider.createTable(db);
    await AlbumArtistProvider.createTable(db);
    // await PlaylistProvider.createTable(db);
    await _createIndexes(db);
  }

  /// Create database indexes for better query performance
  Future<void> _createIndexes(Database db) async {
    // Songs table indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_songs_album_id ON ${SongColumns.table}(${SongColumns.albumId})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_songs_path ON ${SongColumns.table}(${SongColumns.path})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_songs_title ON ${SongColumns.table}(${SongColumns.title})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_songs_year ON ${SongColumns.table}(${SongColumns.year})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_songs_genre ON ${SongColumns.table}(${SongColumns.genres})',
    );

    // Albums table indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_albums_title ON ${AlbumColumns.table}(${AlbumColumns.title})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_albums_release_date ON ${AlbumColumns.table}(${AlbumColumns.releaseDate})',
    );

    // Artists table indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_artists_name ON ${ArtistColumns.table}(${ArtistColumns.name})',
    );

    // Relationship table indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_song_artists_song_id ON ${SongArtistColumns.table}(${SongArtistColumns.songId})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_song_artists_artist_id ON ${SongArtistColumns.table}(${SongArtistColumns.artistId})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_album_artists_album_id ON ${AlbumArtistColumns.table}(${AlbumArtistColumns.albumId})',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_album_artists_artist_id ON ${AlbumArtistColumns.table}(${AlbumArtistColumns.artistId})',
    );
  }

  Future<void> addTestData() async {
    final testAlbum = Album(
      title: 'Test Album',
      coverUri: Uri.http('placehold.co', '/400.png').toString(),
      releaseDate: DateTime.now(),
    );
    final testArtist = Artist(
      name: 'Test Artist',
      imageUri: Uri.http('placehold.co', '/400.png').toString(),
      bio: 'This is a test artist bio.',
    );
    final testSong = await Song.fromAsset("assets/audios/sample.m4a");

    if ((await songProvider.getByItem(testSong)) != null) {
      log.i('Test song already exists, skipping insertion.');
      return;
    }

    // _databaseWrapper.beginBatch();

    final insertedArtist = await artistProvider.insertOrUpdate(testArtist);
    final insertedAlbum = await albumProvider.insertOrUpdate(testAlbum);

    final songWithAlbum = testSong.copyWith(
      albumId: insertedAlbum.id,
      cover: insertedAlbum.coverUri,
    );
    final insertedSong = await songProvider.insertOrUpdate(songWithAlbum);

    if (insertedSong.id == null ||
        insertedAlbum.id == null ||
        insertedArtist.id == null) {
      throw Exception('Failed to insert test data');
    }

    // relationships
    final songArtist = SongArtist(song: insertedSong, artist: insertedArtist);
    final albumArtist = AlbumArtist(
      album: insertedAlbum,
      artist: insertedArtist,
    );
    await songArtistProvider.insert(songArtist);
    await albumArtistProvider.insert(albumArtist);

    // await _databaseWrapper.commitBatch();
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE songs ADD COLUMN new_field TEXT');
    // }
  }

  Future<Object?> executeBatch(
    Function(DatabaseHelper helper) builder, {
    bool noResult = false,
    Batch? batch,
  }) async {
    await initialize();
    _databaseWrapper.beginBatch(batch: batch);
    builder(this);
    if (noResult) {
      await _databaseWrapper.commitBatch();
      return null;
    }
    return _databaseWrapper.commitBatchWithResult(
      exclusive: null,
      continueOnError: null,
    );
  }

  // Future<Object?> beginTransaction(
  //   Future<Object?> Function(Transaction txn, DatabaseHelper helper) builder,
  // ) {
  //   return _database.transaction((txn) async {
  //     return builder(txn, this);
  //   });
  // }

  // Future<Object?> batchTransaction(
  //   Future<Object?> Function(DatabaseHelper helper) builder, {
  //   bool noResult = false,
  // }) async {
  //   await initialize();
  //   return _database.transaction((txn) async {
  //     final batch = txn.batch();
  //     return executeBatch(builder, noResult: noResult, batch: batch);
  //   });
  // }

  Future<Song> insertSongWithDetails(
    Song song,
    Album album,
    List<Artist> artists,
  ) async {
    final insertedAlbum = await albumProvider.insertWithArtists(album, artists);
    final insertedSong = await songProvider.insertOrUpdate(song);
    if (insertedSong.id == null || insertedAlbum.id == null) {
      throw Exception('Failed to insert song or album');
    }
    for (final artist in artists) {
      final songArtist = SongArtist(song: insertedSong, artist: artist);
      await songArtistProvider.insert(songArtist);
    }
    return insertedSong.copyWith(
      album: insertedAlbum,
      artists: artists,
      albumId: insertedAlbum.id,
    );
  }

  /// ensures all relationships are created correctly and atomically
  Future<Song> insertSongWithAlbumAndArtists({
    required Song song,
    required Album album,
    required List<Artist> artists,
  }) async {
    await initialize();

    Album insertedAlbum;
    final existingAlbum = await albumProvider.getByTitle(album.title);
    if (existingAlbum != null) {
      insertedAlbum = existingAlbum;
    } else {
      insertedAlbum = await albumProvider.insert(album);
    }

    List<Artist> insertedArtists = [];
    for (final artist in artists) {
      Artist insertedArtist;
      final existingArtist = await artistProvider.getByName(artist.name);
      if (existingArtist != null) {
        insertedArtist = existingArtist;
      } else {
        insertedArtist = await artistProvider.insert(artist);
      }
      insertedArtists.add(insertedArtist);
    }

    for (final artist in insertedArtists) {
      final existingAlbumArtists = await albumArtistProvider.getByAlbumId(
        insertedAlbum.id!,
      );
      final relationshipExists = existingAlbumArtists.any(
        (aa) => aa.artist.id == artist.id,
      );

      if (!relationshipExists) {
        final albumArtist = AlbumArtist(album: insertedAlbum, artist: artist);
        await albumArtistProvider.insert(albumArtist);
      }
    }

    final songWithAlbum = song.copyWith(albumId: insertedAlbum.id);
    final insertedSong = await songProvider.insertOrUpdate(songWithAlbum);

    if (insertedSong.id == null) {
      throw Exception('Failed to insert song');
    }

    for (final artist in insertedArtists) {
      final existingSongArtists = await songArtistProvider.getBySongId(
        insertedSong.id!,
      );
      final relationshipExists = existingSongArtists.any(
        (sa) => sa.artist.id == artist.id,
      );

      if (!relationshipExists) {
        final songArtist = SongArtist(song: insertedSong, artist: artist);
        await songArtistProvider.insert(songArtist);
      }
    }

    return insertedSong.copyWith(
      album: insertedAlbum,
      artists: insertedArtists,
      albumId: insertedAlbum.id,
    );
  }

  Future<List<Song>> insertMultipleSongsWithDetails(
    List<Map<String, dynamic>> songData,
  ) async {
    await initialize();

    List<Song> insertedSongs = [];

    for (final data in songData) {
      final song = data['song'] as Song;
      final album = data['album'] as Album;
      final artists = data['artists'] as List<Artist>;

      Album insertedAlbum;
      final existingAlbum = await albumProvider.getByTitle(album.title);
      if (existingAlbum != null) {
        insertedAlbum = existingAlbum;
      } else {
        insertedAlbum = await albumProvider.insert(album);
      }

      List<Artist> insertedArtists = [];
      for (final artist in artists) {
        Artist insertedArtist;
        final existingArtist = await artistProvider.getByName(artist.name);
        if (existingArtist != null) {
          insertedArtist = existingArtist;
        } else {
          insertedArtist = await artistProvider.insert(artist);
        }
        insertedArtists.add(insertedArtist);
      }

      for (final artist in insertedArtists) {
        final existingAlbumArtists = await albumArtistProvider.getByAlbumId(
          insertedAlbum.id!,
        );
        final relationshipExists = existingAlbumArtists.any(
          (aa) => aa.artist.id == artist.id,
        );

        if (!relationshipExists) {
          final albumArtist = AlbumArtist(album: insertedAlbum, artist: artist);
          await albumArtistProvider.insert(albumArtist);
        }
      }

      final songWithAlbum = song.copyWith(albumId: insertedAlbum.id);
      final insertedSong = await songProvider.insertOrUpdate(songWithAlbum);

      if (insertedSong.id == null) {
        throw Exception('Failed to insert song: ${song.title}');
      }

      for (final artist in insertedArtists) {
        final existingSongArtists = await songArtistProvider.getBySongId(
          insertedSong.id!,
        );
        final relationshipExists = existingSongArtists.any(
          (sa) => sa.artist.id == artist.id,
        );

        if (!relationshipExists) {
          final songArtist = SongArtist(song: insertedSong, artist: artist);
          await songArtistProvider.insert(songArtist);
        }
      }

      insertedSongs.add(
        insertedSong.copyWith(
          album: insertedAlbum,
          artists: insertedArtists,
          albumId: insertedAlbum.id,
        ),
      );
    }

    return insertedSongs;
  }

  Future<Album> insertAlbumWithArtists({
    required Album album,
    required List<Artist> artists,
  }) async {
    await initialize();

    Album insertedAlbum;
    final existingAlbum = await albumProvider.getByTitle(album.title);
    if (existingAlbum != null) {
      insertedAlbum = existingAlbum;
    } else {
      insertedAlbum = await albumProvider.insert(album);
    }

    // create relationships
    for (final artist in artists) {
      Artist insertedArtist;
      final existingArtist = await artistProvider.getByName(artist.name);
      if (existingArtist != null) {
        insertedArtist = existingArtist;
      } else {
        insertedArtist = await artistProvider.insert(artist);
      }

      final existingAlbumArtists = await albumArtistProvider.getByAlbumId(
        insertedAlbum.id!,
      );
      final relationshipExists = existingAlbumArtists.any(
        (aa) => aa.artist.id == insertedArtist.id,
      );

      if (!relationshipExists) {
        final albumArtist = AlbumArtist(
          album: insertedAlbum,
          artist: insertedArtist,
        );
        await albumArtistProvider.insert(albumArtist);
      }
    }

    return insertedAlbum;
  }

  /// Bulk import method for large music libraries
  ///
  /// Processes songs in chunks to avoid memory issues and provides progress tracking
  Future<BulkImportResult> bulkImportSongs({
    required List<Map<String, dynamic>> songDataList,
    int chunkSize = 50,
    Function(int processed, int total)? onProgress,
  }) async {
    await initialize();

    final result = BulkImportResult();
    final total = songDataList.length;
    int processed = 0;

    for (int i = 0; i < songDataList.length; i += chunkSize) {
      final chunk = songDataList.skip(i).take(chunkSize).toList();

      try {
        final chunkResults = await insertMultipleSongsWithDetails(chunk);
        result.successfulSongs.addAll(chunkResults);
        processed += chunk.length;

        onProgress?.call(processed, total);
      } catch (e) {
        for (final songData in chunk) {
          try {
            final song = songData['song'] as Song;
            final album = songData['album'] as Album;
            final artists = songData['artists'] as List<Artist>;

            final insertedSong = await insertSongWithAlbumAndArtists(
              song: song,
              album: album,
              artists: artists,
            );
            result.successfulSongs.add(insertedSong);
          } catch (songError) {
            result.failedSongs.add(
              BulkImportError(songData: songData, error: songError.toString()),
            );
          }
          processed++;
        }

        onProgress?.call(processed, total);
      }
    }

    return result;
  }

  /// Optimized bulk import method with batching for maximum performance
  ///
  /// This method is specifically optimized for large music library imports
  /// by using database batching and minimizing individual queries
  Future<BulkImportResult> optimizedBulkImportSongs({
    required List<Map<String, dynamic>> songDataList,
    int chunkSize = 50,
    Function(int processed, int total)? onProgress,
  }) async {
    await initialize();

    final result = BulkImportResult();
    final total = songDataList.length;
    int processed = 0;

    for (int i = 0; i < songDataList.length; i += chunkSize) {
      final chunk = songDataList.skip(i).take(chunkSize).toList();
      try {
        final chunkResults = <Song>[];

        for (final songData in chunk) {
          try {
            final song = songData['song'] as Song;
            final album = songData['album'] as Album;
            final artists = songData['artists'] as List<Artist>;

            final insertedSong = await insertSongWithAlbumAndArtists(
              song: song,
              album: album,
              artists: artists,
            );
            chunkResults.add(insertedSong);
          } catch (e) {
            result.failedSongs.add(
              BulkImportError(songData: songData, error: e.toString()),
            );
          }
        }

        result.successfulSongs.addAll(chunkResults);
        processed += chunk.length;
        onProgress?.call(processed, total);
      } catch (e) {
        log.e('Error processing chunk starting at index $i: $e');

        // Fallback: process songs individually if batch fails
        for (final songData in chunk) {
          try {
            final song = songData['song'] as Song;
            final album = songData['album'] as Album;
            final artists = songData['artists'] as List<Artist>;

            final insertedSong = await insertSongWithAlbumAndArtists(
              song: song,
              album: album,
              artists: artists,
            );
            result.successfulSongs.add(insertedSong);
          } catch (songError) {
            result.failedSongs.add(
              BulkImportError(songData: songData, error: songError.toString()),
            );
          }
        }

        processed += chunk.length;
        onProgress?.call(processed, total);
      }
    }
    return result;
  }

  Future<void> dispose() async {
    await _database.close();
    _songProvider = null;
    _albumProvider = null;
    _artistProvider = null;
    _playlistProvider = null;
    _songArtistProvider = null;
    _albumArtistProvider = null;
    _isInitialized = false;
  }

  Future<DatabaseStatistics> getDatabaseStatistics() async {
    await initialize();

    final songCount = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM ${SongColumns.table}',
    );
    final albumCount = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM ${AlbumColumns.table}',
    );
    final artistCount = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM ${ArtistColumns.table}',
    );

    final totalDuration = await _database.rawQuery(
      'SELECT SUM(${SongColumns.duration}) as total FROM ${SongColumns.table}',
    );

    final topGenres = await _database.rawQuery('''
      SELECT ${SongColumns.genres}, COUNT(*) as count 
      FROM ${SongColumns.table} 
      WHERE ${SongColumns.genres} IS NOT NULL AND ${SongColumns.genres} != '' 
      GROUP BY ${SongColumns.genres} 
      ORDER BY count DESC 
      LIMIT 10
    ''');

    final recentlyAdded = await _database.rawQuery('''
      SELECT COUNT(*) as count 
      FROM ${SongColumns.table} 
      WHERE ${SongColumns.dateAdded} > datetime('now', '-7 days')
    ''');

    return DatabaseStatistics(
      totalSongs: songCount.first['count'] as int,
      totalAlbums: albumCount.first['count'] as int,
      totalArtists: artistCount.first['count'] as int,
      totalDurationMs: (totalDuration.first['total'] as int?) ?? 0,
      topGenres:
          topGenres
              .take(5)
              .map(
                (row) => GenreStatistic(
                  genre: row[SongColumns.genres] as String,
                  count: row['count'] as int,
                ),
              )
              .toList(),
      recentlyAddedCount: recentlyAdded.first['count'] as int,
    );
  }

  Future<CleanupResult> cleanupOrphanedRecords() async {
    await initialize();

    return await _database.transaction((txn) async {
      int deletedAlbums = 0;
      int deletedArtists = 0;

      final orphanedAlbums = await txn.rawQuery('''
        SELECT a.${AlbumColumns.id} 
        FROM ${AlbumColumns.table} a 
        LEFT JOIN ${SongColumns.table} s ON a.${AlbumColumns.id} = s.${SongColumns.albumId} 
        WHERE s.${SongColumns.id} IS NULL
      ''');

      for (final album in orphanedAlbums) {
        final albumId = album[AlbumColumns.id] as int;
        // Delete album-artist relationships first
        await txn.delete(
          AlbumArtistColumns.table,
          where: '${AlbumArtistColumns.albumId} = ?',
          whereArgs: [albumId],
        );
        // Delete the album
        await txn.delete(
          AlbumColumns.table,
          where: '${AlbumColumns.id} = ?',
          whereArgs: [albumId],
        );
        deletedAlbums++;
      }

      // find artists with no songs or albums
      final orphanedArtists = await txn.rawQuery('''
        SELECT ar.${ArtistColumns.id} 
        FROM ${ArtistColumns.table} ar 
        LEFT JOIN ${SongArtistColumns.table} sa ON ar.${ArtistColumns.id} = sa.${SongArtistColumns.artistId}
        LEFT JOIN ${AlbumArtistColumns.table} aa ON ar.${ArtistColumns.id} = aa.${AlbumArtistColumns.artistId}
        WHERE sa.${SongArtistColumns.id} IS NULL AND aa.${AlbumArtistColumns.id} IS NULL
      ''');

      for (final artist in orphanedArtists) {
        final artistId = artist[ArtistColumns.id] as int;
        await txn.delete(
          ArtistColumns.table,
          where: '${ArtistColumns.id} = ?',
          whereArgs: [artistId],
        );
        deletedArtists++;
      }

      return CleanupResult(
        deletedAlbums: deletedAlbums,
        deletedArtists: deletedArtists,
      );
    });
  }

  /// Simple song insertion method following the same pattern as addTestData
  Future<Song> insertSong({
    required Song song,
    required Album album,
    required Artist artist,
  }) async {
    await initialize();

    // Check if song already exists
    final existingSong = await songProvider.getByPath(song.path);
    if (existingSong != null) {
      return existingSong;
    }

    // Insert artist and album (insertOrUpdate handles duplicates)
    final insertedArtist = await artistProvider.insertOrUpdate(artist);
    final insertedAlbum = await albumProvider.insertOrUpdate(album);

    // Insert song with album reference
    final songWithAlbum = song.copyWith(
      albumId: insertedAlbum.id,
      cover: song.cover ?? insertedAlbum.coverUri,
    );
    final insertedSong = await songProvider.insertOrUpdate(songWithAlbum);

    if (insertedSong.id == null ||
        insertedAlbum.id == null ||
        insertedArtist.id == null) {
      throw Exception('Failed to insert song data');
    }

    // Create relationships
    final songArtist = SongArtist(song: insertedSong, artist: insertedArtist);
    final albumArtist = AlbumArtist(
      album: insertedAlbum,
      artist: insertedArtist,
    );

    await songArtistProvider.insert(songArtist);
    await albumArtistProvider.insert(albumArtist);

    return insertedSong.copyWith(
      album: insertedAlbum,
      artists: [insertedArtist],
    );
  }
}
