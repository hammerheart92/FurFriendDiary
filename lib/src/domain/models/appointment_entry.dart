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
  DateTime dateTime;
  
  @HiveField(3)
  String appointmentType;
  
  @HiveField(4)
  String veterinarian;
  
  @HiveField(5)
  String? notes;
  
  @HiveField(6)
  bool isCompleted;
  
  @HiveField(7)
  String? location;
  
  AppointmentEntry({
    String? id,
    required this.petId,
    required this.dateTime,
    required this.appointmentType,
    required this.veterinarian,
    this.notes,
    this.isCompleted = false,
    this.location,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'dateTime': dateTime.toIso8601String(),
    'appointmentType': appointmentType,
    'veterinarian': veterinarian,
    'notes': notes,
    'isCompleted': isCompleted,
    'location': location,
  };

  factory AppointmentEntry.fromJson(Map<String, dynamic> json) => AppointmentEntry(
    id: json['id'],
    petId: json['petId'],
    dateTime: DateTime.parse(json['dateTime']),
    appointmentType: json['appointmentType'],
    veterinarian: json['veterinarian'],
    notes: json['notes'],
    isCompleted: json['isCompleted'] ?? false,
    location: json['location'],
  );

  AppointmentEntry copyWith({
    String? id,
    String? petId,
    DateTime? dateTime,
    String? appointmentType,
    String? veterinarian,
    String? notes,
    bool? isCompleted,
    String? location,
  }) {
    return AppointmentEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      dateTime: dateTime ?? this.dateTime,
      appointmentType: appointmentType ?? this.appointmentType,
      veterinarian: veterinarian ?? this.veterinarian,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      location: location ?? this.location,
    );
  }
}
