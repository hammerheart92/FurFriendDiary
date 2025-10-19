import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'feeding_entry.g.dart';

@HiveType(typeId: 2)
class FeedingEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  String foodType;

  @HiveField(4)
  double amount;

  @HiveField(5)
  String? notes;

  FeedingEntry({
    String? id,
    required this.petId,
    required this.dateTime,
    required this.foodType,
    required this.amount,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'dateTime': dateTime.toIso8601String(),
        'foodType': foodType,
        'amount': amount,
        'notes': notes,
      };

  factory FeedingEntry.fromJson(Map<String, dynamic> json) => FeedingEntry(
        id: json['id'],
        petId: json['petId'],
        dateTime: DateTime.parse(json['dateTime']),
        foodType: json['foodType'],
        amount: (json['amount'] as num).toDouble(),
        notes: json['notes'],
      );

  FeedingEntry copyWith({
    String? id,
    String? petId,
    DateTime? dateTime,
    String? foodType,
    double? amount,
    String? notes,
  }) {
    return FeedingEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      dateTime: dateTime ?? this.dateTime,
      foodType: foodType ?? this.foodType,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }
}
