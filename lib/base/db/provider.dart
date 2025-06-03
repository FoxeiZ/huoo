import 'package:sqflite/sqflite.dart';

abstract class BaseProvider<T> {
  final Database db;

  BaseProvider(this.db);

  static Future<void> createTable(Database db) {
    throw UnimplementedError(
      'createSongsTable needs to be implemented by a subclass',
    );
  }

  static Future<void> dropTable(Database db) {
    throw UnimplementedError(
      'dropSongsTable needs to be implemented by a subclass',
    );
  }

  String get tableName;
  String get idColumnName;

  Map<String, dynamic> itemToMap(T item);
  Future<T> itemFromMap(Map<String, dynamic> map);
  T copyWithId(T item, int? id);
  int? getItemId(T item);

  Future<T> insert(T item) {
    final id = getItemId(item);
    if (id != null && id != 0) {
      throw ArgumentError('Item must not have a valid ID for insert');
    }
    return db.insert(tableName, itemToMap(item)).then((id) {
      return copyWithId(item, id);
    });
  }

  Future<int> update(T item) async {
    final id = getItemId(item);
    if (id == null) {
      throw ArgumentError('Item must have a valid ID for update');
    }
    return db.update(
      tableName,
      itemToMap(item),
      where: '$idColumnName = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int? id) async {
    if (id == 0 || id == null) {
      throw ArgumentError('Cannot delete item with ID 0 or null');
    }
    return db.delete(tableName, where: '$idColumnName = ?', whereArgs: [id]);
  }

  Future<T?> get(int? id) async {
    if (id == null || id == 0) {
      return null;
    }
    final maps = await db.query(
      tableName,
      where: '$idColumnName = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return await itemFromMap(maps.first);
    }
    return null;
  }
}

abstract class CrudProvider<T> extends BaseProvider<T> {
  CrudProvider(super.db);

  Future<List<T>> getAll();

  Future<T?> insertOrUpdate(T item) async {
    var existing = await get(getItemId(item));
    if (existing == null || item == 0) {
      return insert(item);
    } else {
      return update(item).then((_) => get(getItemId(item)));
    }
  }

  Future<int> count() {
    return db.rawQuery('SELECT COUNT(*) FROM $tableName').then((value) {
      if (value.isNotEmpty) {
        return Sqflite.firstIntValue(value) ?? 0;
      }
      return 0;
    });
  }

  Future<int> deleteAll() {
    return db.delete(tableName);
  }

  void batchInsert(Batch batch, T item) {
    batch.insert(tableName, itemToMap(item));
  }

  void batchUpdate(Batch batch, T item) {
    final id = getItemId(item);
    if (id != null) {
      batch.update(
        tableName,
        itemToMap(item),
        where: '$idColumnName = ?',
        whereArgs: [id],
      );
    }
  }

  void batchDelete(Batch batch, int id) {
    batch.delete(tableName, where: '$idColumnName = ?', whereArgs: [id]);
  }

  void batchDeleteWhere(Batch batch, String where, List<Object?> whereArgs) {
    batch.delete(tableName, where: where, whereArgs: whereArgs);
  }

  void batchUpdateWhere(
    Batch batch,
    Map<String, Object?> values,
    String where,
    List<Object?> whereArgs,
  ) {
    batch.update(tableName, values, where: where, whereArgs: whereArgs);
  }

  Batch createBatch() => db.batch();

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
}
