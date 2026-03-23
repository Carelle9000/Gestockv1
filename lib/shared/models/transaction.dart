import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 6)
class Transaction extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // INCOME or EXPENSE

  @HiveField(2)
  double amount;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? accountId;

  @HiveField(6)
  String category; // SALE, PURCHASE, CLIENT_PAYMENT, EXPENSE, REFUND

  @HiveField(7)
  String? referenceId; // ID de la vente, de l'achat ou du besoin lié

  @HiveField(8)
  String? personId; // ID du Client ou du Fournisseur lié

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    this.accountId,
    this.referenceId,
    this.personId,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      category: map['category'] ?? 'EXPENSE',
      accountId: map['accountId'],
      referenceId: map['referenceId'],
      personId: map['personId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'accountId': accountId,
      'referenceId': referenceId,
      'personId': personId,
    };
  }
}
