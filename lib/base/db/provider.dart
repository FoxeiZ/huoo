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

  Map<String, dynamic> filterMap(
    Map<String, dynamic> map, {
    bool filterNulls = true,
    bool filterEmptyStrings = false,
    List<String>? filterColumns,
  }) {
    return Map.fromEntries(
      map.entries.where((entry) {
        if (filterColumns != null && !filterColumns.contains(entry.key)) {
          return false;
        }

        final value = entry.value;
        if (filterNulls && value == null) return false;
        if (filterEmptyStrings && value is String && value.isEmpty) {
          return false;
        }
        return true;
      }),
    );
  }

  Future<int> update(T item, {DatabaseOperation? dbWrapper, int? itemId}) {
    final wrapper = dbWrapper ?? _dbOperation;
    final id = itemId ?? getItemId(item);
    if (id == null) {
      throw ArgumentError('Item must have a valid ID for update');
    }
    return wrapper.update(
      tableName,
      filterMap(itemToMap(item)),
      where: '$idColumnName = ?',
      whereArgs: [id],
    );
  }

  Future<T> insertOrUpdate(T item, [DatabaseOperation? dbWrapper]) {
    final wrapper = dbWrapper ?? _dbOperation;
    final id = getItemId(item);
    if (id != null && id != 0) {
      final oldItem = getById(id, wrapper);
      if (oldItem != item) {
        return update(item, dbWrapper: wrapper).then((_) => item);
      }
      return Future.value(item);
    } else {
      return getByItem(item, wrapper).then((existingItem) {
        if (existingItem != null) {
          return update(
            item,
            dbWrapper: wrapper,
            itemId: getItemId(existingItem),
          ).then((_) => item);
        } else {
          return insert(item, wrapper);
        }
      });
    }
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
    final filteredMap = filterMap(itemToMap(cpItem), filterColumns: columns);
    if (filteredMap.isEmpty) return null;

    return wrapper
        .query(
          tableName,
          where: filteredMap.keys.map((col) => '$col = ?').join(' AND '),
          whereArgs: filteredMap.values.toList(),
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
