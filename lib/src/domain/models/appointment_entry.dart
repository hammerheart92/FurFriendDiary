import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'appointment_entry.g.dart';

@HiveType(typeId: 6)
class AppointmentEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String veterinarian;

  @HiveField(3)
  String clinic;

  @HiveField(4)
  DateTime appointmentDate;

  @HiveField(5)
  DateTime appointmentTime;

  @HiveField(6)
  String reason;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  String? vetId;

  AppointmentEntry({
    String? id,
    required this.petId,
    required this.veterinarian,
    required this.clinic,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.reason,
    this.notes,
    this.isCompleted = false,
    DateTime? createdAt,
    this.vetId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'veterinarian': veterinarian,
        'clinic': clinic,
        'appointmentDate': appointmentDate.toIso8601String(),
        'appointmentTime': appointmentTime.toIso8601String(),
        'reason': reason,
        'notes': notes,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'vetId': vetId,
      };

  factory AppointmentEntry.fromJson(Map<String, dynamic> json) =>
      AppointmentEntry(
        id: json['id'],
        petId: json['petId'],
        veterinarian: json['veterinarian'],
        clinic: json['clinic'],
        appointmentDate: DateTime.parse(json['appointmentDate']),
        appointmentTime: DateTime.parse(json['appointmentTime']),
        reason: json['reason'],
        notes: json['notes'],
        isCompleted: json['isCompleted'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        vetId: json['vetId'],
      );

  AppointmentEntry copyWith({
    String? id,
    String? petId,
    String? veterinarian,
    String? clinic,
    DateTime? appointmentDate,
    DateTime? appointmentTime,
    String? reason,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
    String? vetId,
  }) {
    return AppointmentEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      veterinarian: veterinarian ?? this.veterinarian,
      clinic: clinic ?? this.clinic,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      vetId: vetId ?? this.vetId,
    );
  }
}
