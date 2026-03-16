import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 10)
class Account extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // ex: Caisse Centrale, Orange Money, Banque

  @HiveField(2)
  double balance;

  @HiveField(3)
  String type; // ex: CASH, MOBILE_MONEY, BANK

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type,
    };
  }
}
