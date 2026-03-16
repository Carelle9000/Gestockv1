import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  int minStock;

  @HiveField(5)
  String supplierId;

  @HiveField(6)
  String category;

  @HiveField(7)
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.minStock,
    required this.supplierId,
    required this.category,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      minStock: map['minStock'],
      supplierId: map['supplierId'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'minStock': minStock,
      'supplierId': supplierId,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}