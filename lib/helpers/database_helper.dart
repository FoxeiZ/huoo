import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:huoo/models/song.dart';

final log = Logger(
  filter: DevelopmentFilter(),
  level: Level.all,
  output: ConsoleOutput(),
);

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;
  SongProvider? _songProvider;
  bool _isInitialized = false;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  SongProvider get songProvider {
    if (_songProvider == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _songProvider!;
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
      _database = await _initDatabase();
      _songProvider = SongProvider(_database!);
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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await SongProvider.createTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE songs ADD COLUMN new_field TEXT');
    // }
  }

  // Optional: Add dispose method for cleanup
  Future<void> dispose() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _songProvider = null;
      _isInitialized = false;
    }
  }
}
