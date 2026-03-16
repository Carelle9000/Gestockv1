import 'package:hive/hive.dart';

class BaseRepository<T> {

  final Box<T> box;

  BaseRepository(this.box);

  // CREATE
  Future<void> add(String key, T item) async {
    await box.put(key, item);
  }

  // READ ALL
  List<T> getAll() {
    return box.values.toList();
  }

  // READ ONE
  T? get(String key) {
    return box.get(key);
  }

  // UPDATE
  Future<void> update(String key, T item) async {
    await box.put(key, item);
  }

  // DELETE
  Future<void> delete(String key) async {
    await box.delete(key);
  }

}