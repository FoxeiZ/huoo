import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:huoo/models/song.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _isInitialized = false;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  late final SongProvider songProvider;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Add this method to ensure initialization
  Future<void> initialize() async {
    if (!_isInitialized) {
      // Initialize database factory for desktop platforms
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      await database; // This will trigger _initDatabase if needed
      _isInitialized = true;
    }
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'huoo_music.db');
    log('Database path: $path');

    var db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    // init providers
    songProvider = SongProvider(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await SongProvider.createTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations
  }
}
