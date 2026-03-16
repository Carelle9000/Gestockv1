import 'package:hive_flutter/hive_flutter.dart';

class HiveService {

  static Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }

}