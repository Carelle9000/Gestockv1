import 'package:hive/hive.dart';

part 'sale_item.g.dart';

@HiveType(typeId: 4)
class SaleItem extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String saleId;

  @HiveField(2)
  String productId;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  double price;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}