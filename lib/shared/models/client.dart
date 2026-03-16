import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Client extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String address;

  @HiveField(4)
  DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.createdAt,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}