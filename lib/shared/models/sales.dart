import 'package:hive/hive.dart';

part 'sales.g.dart';

@HiveType(typeId: 3)
class Sales extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  String paymentMethod;

  @HiveField(4)
  String clientId;

  Sales({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.paymentMethod,
    required this.clientId,
  });

  factory Sales.fromMap(Map<String, dynamic> map) {
    return Sales(
      id: map['id'],
      date: DateTime.parse(map['date']),
      totalAmount: map['totalAmount'],
      paymentMethod: map['paymentMethod'],
      clientId: map['clientId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'clientId': clientId,
    };
  }
}