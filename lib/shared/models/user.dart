import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 8)
class User extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String email;

  @HiveField(4)
  String password;

  @HiveField(5)
  DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['address'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}