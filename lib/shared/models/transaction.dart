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
  String? accountId; // Rendu optionnel pour éviter les crashs sur anciennes données

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.accountId,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      accountId: map['accountId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'accountId': accountId,
    };
  }
}
