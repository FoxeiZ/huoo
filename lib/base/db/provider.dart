import 'package:sqflite/sqflite.dart';

abstract class BaseProvider<T> {
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

  Future<T> insert(T item);
  Future<int> update(T item);
  Future<int> delete(int id);
  Future<int> deleteAll();
  Future<T?> getById(int id);
  Future<List<T>> getAll();
  Future<T?> insertOrUpdate(T item);
  Future<int> count();
}
