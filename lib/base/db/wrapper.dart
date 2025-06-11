import 'package:sqflite/sqflite.dart';

abstract class DatabaseOperation {
  bool get isOpen;
  Database get database;

  Future<int> insert(String table, Map<String, Object?> values);
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  });
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});
  Future<List<Map<String, Object?>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  });
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);
  Future<int> count(String table);
  Future<void> insertAll(String table, List<Map<String, Object?>> values);
  Future<void> close() async {
    // Default implementation does nothing, can be overridden
  }
}

class DatabaseWrapper implements DatabaseOperation {
  final Database _db;
  Batch? _batch;

  DatabaseWrapper(this._db, [this._batch]);

  @override
  Database get database => _db;
  @override
  bool get isOpen => _db.isOpen;

  @override
  Future<int> insert(String table, Map<String, Object?> values) {
    if (_batch != null) {
      _batch!.insert(table, values);
      return Future.value(-1);
    }
    return _db.insert(table, values);
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) {
    if (_batch != null) {
      _batch!.update(table, values, where: where, whereArgs: whereArgs);
      return Future.value(-1);
    }
    return _db.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    if (_batch != null) {
      _batch!.delete(table, where: where, whereArgs: whereArgs);
      return Future.value(-1);
    }
    return _db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) {
    return _db.query(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) {
    return _db.rawQuery(sql, arguments);
  }

  @override
  Future<int> count(String table) {
    return rawQuery('SELECT COUNT(*) FROM $table').then((result) {
      if (result.isNotEmpty && result.first.isNotEmpty) {
        return result.first.values.first as int;
      }
      return 0;
    });
  }

  @override
  Future<void> close() async {
    if (_batch != null) {
      throw StateError('Cannot close while a batch operation is in progress');
    }
    await _db.close();
  }

  /// Decide to use batch for better performance
  ///
  /// Use batch in the underlying database operations.
  /// If [_batch] is not available, call [beginBatch] to create a new batch ourself and commit immediately
  @override
  Future<void> insertAll(
    String table,
    List<Map<String, Object?>> values,
  ) async {
    final selfCommit = _batch == null;
    final _ = _batch ?? beginBatch();
    for (final value in values) {
      insert(table, value);
    }
    if (selfCommit) {
      await commitBatch();
    }
  }

  Batch beginBatch({Batch? batch}) {
    if (_batch != null) {
      throw StateError('Batch operation already in progress');
    }
    if (batch != null) {
      _batch = batch;
      return _batch!;
    }
    _batch = _db.batch();
    return _batch!;
  }

  Future<void> commitBatch({bool? exclusive, bool? continueOnError}) async {
    if (_batch == null) {
      throw StateError('No batch operation in progress');
    }
    await _batch!.commit(
      exclusive: exclusive,
      noResult: true,
      continueOnError: continueOnError,
    );
    _batch = null;
  }

  Future<Object?> commitBatchWithResult({
    bool? exclusive,
    bool? continueOnError,
  }) async {
    if (_batch == null) {
      throw StateError('No batch operation in progress');
    }
    final result = await _batch!.commit(
      exclusive: exclusive,
      noResult: false,
      continueOnError: continueOnError,
    );
    _batch = null;
    return result;
  }
}
