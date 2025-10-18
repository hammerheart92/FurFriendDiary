import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'weight_entry.g.dart';

@HiveType(typeId: 14)
class WeightEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String petId;

  @HiveField(2)
  final double weight; // in kilograms

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime createdAt;

  WeightEntry({
    String? id,
    required this.petId,
    required this.weight,
    required this.date,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  WeightEntry copyWith({
    String? petId,
    double? weight,
    DateTime? date,
    String? notes,
  }) {
    return WeightEntry(
      id: id,
      petId: petId ?? this.petId,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'WeightEntry(id: $id, petId: $petId, weight: $weight, date: $date, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WeightEntry &&
        other.id == id &&
        other.petId == petId &&
        other.weight == weight &&
        other.date == date &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        petId.hashCode ^
        weight.hashCode ^
        date.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }
}

@HiveType(typeId: 15)
enum WeightUnit {
  @HiveField(0)
  kilograms,

  @HiveField(1)
  pounds,
}

