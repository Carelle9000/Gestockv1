import 'package:hive/hive.dart';

part 'supplier.g.dart';

@HiveType(typeId: 2)
class Supplier extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String address;

  @HiveField(4)
  String email;


  @HiveField(5)
  DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.createdAt,
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      email: map['email'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}