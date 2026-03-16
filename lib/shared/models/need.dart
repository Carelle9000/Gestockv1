import 'package:hive/hive.dart';

part 'need.g.dart';

@HiveType(typeId: 7)
class Need extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  double estimatedCost;

  @HiveField(4)
  String status;

  @HiveField(5)
  DateTime date;

  Need({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedCost,
    required this.status,
    required this.date,
  });

  factory Need.fromMap(Map<String, dynamic> map) {
    return Need(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      estimatedCost: map['estimatedCost'],
      status: map['status'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimatedCost': estimatedCost,
      'status': status,
      'date': date.toIso8601String(),
    };
  }
}