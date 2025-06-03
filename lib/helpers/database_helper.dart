import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:huoo/models/song.dart';
import 'package:huoo/models/artist.dart';
import 'package:huoo/models/playlist.dart';
import 'package:huoo/models/album.dart';
import 'package:huoo/models/many/song_artist.dart';
import 'package:huoo/models/many/album_artist.dart';

final log = Logger(
  filter: DevelopmentFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;
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
    return _database!;
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      if (Platform.isWindows) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      _database = await _initDatabase(); // init providers
      _songProvider = SongProvider(_database!);
      _albumProvider = AlbumProvider(_database!);
      _artistProvider = ArtistProvider(_database!);
      _songArtistProvider = SongArtistProvider(_database!);
      _albumArtistProvider = AlbumArtistProvider(_database!);
      // _playlistProvider = PlaylistProvider(_database!);

      _isInitialized = true;
    }
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

    // indexes
    // await db.execute(
    //   'CREATE INDEX idx_songs_album_id ON ${SongColumns.table}(${SongColumns.albumId})',
    // );
    // await db.execute(
    //   'CREATE INDEX idx_songs_path ON ${SongColumns.table}(${SongColumns.path})',
    // );
    // await db.execute(
    //   'CREATE INDEX idx_songs_title ON ${SongColumns.table}(${SongColumns.title})',
    // );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE songs ADD COLUMN new_field TEXT');
    // }
  }

  // Generic batch operations that work with any provider
  Batch createBatch() {
    if (!_isInitialized) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _database!.batch();
  }

  Future<List<Object?>> commitBatch(
    Batch batch, {
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) {
    return batch.commit(
      exclusive: exclusive,
      noResult: noResult,
      continueOnError: continueOnError,
    );
  }

  // Generic convenience method for batch operations
  Future<List<Object?>> executeBatch(
    Function(Batch batch, DatabaseProviders providers) batchBuilder,
  ) async {
    await initialize();
    final batch = createBatch();
    final providers = DatabaseProviders(
      songProvider: _songProvider!,
      albumProvider: _albumProvider!,
      artistProvider: _artistProvider!,
      playlistProvider: _playlistProvider!,
      songArtistProvider: _songArtistProvider!,
      albumArtistProvider: _albumArtistProvider!,
    );
    batchBuilder(batch, providers);
    return await commitBatch(batch);
  }

  // Generic transaction-based batch operations
  Future<R> batchTransaction<R>(
    Future<R> Function(Batch batch, DatabaseProviders providers) action,
  ) async {
    await initialize();
    return await _database!.transaction((txn) async {
      final batch = txn.batch();
      final providers = DatabaseProviders(
        songProvider: _songProvider!,
        albumProvider: _albumProvider!,
        artistProvider: _artistProvider!,
        playlistProvider: _playlistProvider!,
        songArtistProvider: _songArtistProvider!,
        albumArtistProvider: _albumArtistProvider!,
      );
      return await action(batch, providers);
    });
  }

  Future<void> dispose() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _songProvider = null;
      _albumProvider = null;
      _artistProvider = null;
      _playlistProvider = null;
      _songArtistProvider = null;
      _albumArtistProvider = null;
      _isInitialized = false;
    }
  }
}

class DatabaseProviders {
  final SongProvider songProvider;
  final AlbumProvider albumProvider;
  final ArtistProvider artistProvider;
  final PlaylistProvider playlistProvider;
  final SongArtistProvider songArtistProvider;
  final AlbumArtistProvider albumArtistProvider;

  DatabaseProviders({
    required this.songProvider,
    required this.albumProvider,
    required this.artistProvider,
    required this.playlistProvider,
    required this.songArtistProvider,
    required this.albumArtistProvider,
  });
}
