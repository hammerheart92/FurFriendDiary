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
  String medicationName;
  
  @HiveField(3)
  String dosage;
  
  @HiveField(4)
  String frequency; // "Once daily", "Twice daily", etc.
  
  @HiveField(5)
  DateTime startDate;
  
  @HiveField(6)
  DateTime? endDate;
  
  @HiveField(7)
  String administrationMethod; // "Oral", "Topical", "Injection"
  
  @HiveField(8)
  String? notes;
  
  @HiveField(9)
  bool isActive;
  
  @HiveField(10)
  DateTime createdAt;
  
  @HiveField(11)
  List<DateTime> administrationTimes; // Specific times of day
  
  MedicationEntry({
    String? id,
    required this.petId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.administrationMethod,
    this.notes,
    this.isActive = true,
    DateTime? createdAt,
    List<DateTime>? administrationTimes,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       administrationTimes = administrationTimes ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'medicationName': medicationName,
    'dosage': dosage,
    'frequency': frequency,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'administrationMethod': administrationMethod,
    'notes': notes,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'administrationTimes': administrationTimes.map((time) => time.toIso8601String()).toList(),
  };

  factory MedicationEntry.fromJson(Map<String, dynamic> json) => MedicationEntry(
    id: json['id'],
    petId: json['petId'],
    medicationName: json['medicationName'],
    dosage: json['dosage'],
    frequency: json['frequency'],
    startDate: DateTime.parse(json['startDate']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    administrationMethod: json['administrationMethod'],
    notes: json['notes'],
    isActive: json['isActive'] ?? true,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    administrationTimes: (json['administrationTimes'] as List<dynamic>?)
        ?.map((timeStr) => DateTime.parse(timeStr as String))
        .toList() ?? [],
  );

  MedicationEntry copyWith({
    String? id,
    String? petId,
    String? medicationName,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? administrationMethod,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    List<DateTime>? administrationTimes,
  }) {
    return MedicationEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      administrationMethod: administrationMethod ?? this.administrationMethod,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      administrationTimes: administrationTimes ?? this.administrationTimes,
    );
  }
}
