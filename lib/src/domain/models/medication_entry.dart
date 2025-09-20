import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'medication_entry.g.dart';

@HiveType(typeId: 5)
class MedicationEntry extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String petId;
  
  @HiveField(2)
  DateTime dateTime;
  
  @HiveField(3)
  String medicationName;
  
  @HiveField(4)
  String dosage;
  
  @HiveField(5)
  String? notes;
  
  @HiveField(6)
  DateTime? nextDose;
  
  @HiveField(7)
  bool isCompleted;
  
  MedicationEntry({
    String? id,
    required this.petId,
    required this.dateTime,
    required this.medicationName,
    required this.dosage,
    this.notes,
    this.nextDose,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'dateTime': dateTime.toIso8601String(),
    'medicationName': medicationName,
    'dosage': dosage,
    'notes': notes,
    'nextDose': nextDose?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory MedicationEntry.fromJson(Map<String, dynamic> json) => MedicationEntry(
    id: json['id'],
    petId: json['petId'],
    dateTime: DateTime.parse(json['dateTime']),
    medicationName: json['medicationName'],
    dosage: json['dosage'],
    notes: json['notes'],
    nextDose: json['nextDose'] != null ? DateTime.parse(json['nextDose']) : null,
    isCompleted: json['isCompleted'] ?? false,
  );

  MedicationEntry copyWith({
    String? id,
    String? petId,
    DateTime? dateTime,
    String? medicationName,
    String? dosage,
    String? notes,
    DateTime? nextDose,
    bool? isCompleted,
  }) {
    return MedicationEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      dateTime: dateTime ?? this.dateTime,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      nextDose: nextDose ?? this.nextDose,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
