import 'package:hive/hive.dart';

part 'purchase.g.dart';

@HiveType(typeId: 5)
class Purchase extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String supplierId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  double totalAmount;

  @HiveField(4)
  String status;

  @HiveField(5)
  String? receiptImagePath; // Chemin de l'image du bon fournisseur

  Purchase({
    required this.id,
    required this.supplierId,
    required this.date,
    required this.totalAmount,
    required this.status,
    this.receiptImagePath,
  });

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'],
      supplierId: map['supplierId'],
      date: DateTime.parse(map['date']),
      totalAmount: map['totalAmount'],
      status: map['status'],
      receiptImagePath: map['receiptImagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status,
      'receiptImagePath': receiptImagePath,
    };
  }
}
