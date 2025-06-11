import 'package:sqflite/sqflite.dart';

import 'package:huoo/base/db/wrapper.dart';

abstract class BaseProvider<T> {
  final DatabaseOperation _dbOperation;
  DatabaseOperation get db => _dbOperation;

  const BaseProvider(DatabaseOperation databaseOperation)
    : _dbOperation = databaseOperation;

  static Future<void> createTable(Database db) async {
    throw UnimplementedError('createTable must be implemented in subclasses');
  }

  static Future<void> dropTable(Database db) async {
    throw UnimplementedError('createTable must be implemented in subclasses');
  }

  Future<T> insert(T item, [DatabaseOperation? dbWrapper]) {
    final wrapper = dbWrapper ?? _dbOperation;
    final id = getItemId(item);
    if (id != null && id != 0) {
      throw ArgumentError('Item must not have a valid ID for insert');
    }
    return wrapper.insert(tableName, itemToMap(item)).then((id) {
      return copyWithId(item, id);
    });
  }

  Future<int> update(T item, [DatabaseOperation? dbWrapper]) {
    final wrapper = dbWrapper ?? _dbOperation;
    final id = getItemId(item);
    if (id == null) {
      throw ArgumentError('Item must have a valid ID for update');
    }
    return wrapper.update(
      tableName,
      itemToMap(item),
      where: '$idColumnName = ?',
      whereArgs: [id],
    );
  }

  Future<T> insertOrUpdate(T item, [DatabaseOperation? dbWrapper]) {
    final wrapper = dbWrapper ?? _dbOperation;
    final id = getItemId(item);
    if (id != null && id != 0) {
      final oldItem = getById(id, wrapper);
      if (oldItem != item) return update(item, wrapper).then((_) => item);
      return Future.value(item);
    } else {}
    return insert(item, wrapper);
  }

  Future<void> insertAll(List<T> items, [DatabaseOperation? dbWrapper]) {
    final wrapper = dbWrapper ?? _dbOperation;
    return Future.wait(items.map((item) => insert(item, wrapper)));
  }

  Future<int> count([DatabaseOperation? dbWrapper]) {
    final wrapper = dbWrapper ?? _dbOperation;
    return wrapper.count(tableName);
  }

  String get tableName;
  String get idColumnName;

  /// Dont include the ID column in this list when implementing.
  List<String> get columns;
  Map<String, dynamic> itemToMap(T item);
  Future<T> itemFromMap(Map<String, dynamic> map);
  T copyWithId(T item, int? id);
  int? getItemId(T item);
  Future<T?> getByItem(T item, [DatabaseOperation? dbWrapper]) async {
    final wrapper = dbWrapper ?? _dbOperation;
    final cpItem = copyWithId(item, null);
    final itemMap = itemToMap(cpItem);
    final nonNullColumns =
        columns.where((col) => itemMap[col] != null).toList();
    if (nonNullColumns.isEmpty) return null;

    return wrapper
        .query(
          tableName,
          where: nonNullColumns.map((col) => '$col = ?').join(' AND '),
          whereArgs: nonNullColumns.map((col) => itemMap[col]).toList(),
        )
        .then((maps) => maps.isNotEmpty ? itemFromMap(maps.first) : null);
  }

  Future<List<T>> getAll([DatabaseOperation? dbWrapper]) {
    final wrapper = dbWrapper ?? _dbOperation;
    return wrapper.query(tableName).then((maps) {
      return Future.wait(maps.map((map) => itemFromMap(map)).toList());
    });
  }

  Future<T?> getById(int id, [DatabaseOperation? dbWrapper]) {
    final wrapper = dbWrapper ?? _dbOperation;
    return wrapper
        .query(tableName, where: '$idColumnName = ?', whereArgs: [id])
        .then((maps) {
          if (maps.isNotEmpty) {
            return itemFromMap(maps.first);
          }
          return null;
        });
  }
}
