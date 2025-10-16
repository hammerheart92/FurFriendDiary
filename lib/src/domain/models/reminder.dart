import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reminder.g.dart';

@HiveType(typeId: 10)
enum ReminderType {
  @HiveField(0)
  medication,
  @HiveField(1)
  appointment,
  @HiveField(2)
  feeding,
  @HiveField(3)
  walk,
}

@HiveType(typeId: 11)
enum ReminderFrequency {
  @HiveField(0)
  once,
  @HiveField(1)
  daily,
  @HiveField(2)
  twiceDaily,
  @HiveField(3)
  weekly,
  @HiveField(4)
  custom,
}

@HiveType(typeId: 12)
class Reminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  ReminderType type;

  @HiveField(3)
  String title;

  @HiveField(4)
  String? description;

  @HiveField(5)
  DateTime scheduledTime;

  @HiveField(6)
  ReminderFrequency frequency;

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  String? linkedEntityId; // ID of medication/appointment/etc

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime? lastTriggered;

  @HiveField(11)
  List<int>? customDays; // For weekly: [1,3,5] = Mon, Wed, Fri

  Reminder({
    String? id,
    required this.petId,
    required this.type,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.frequency,
    this.isActive = true,
    this.linkedEntityId,
    DateTime? createdAt,
    this.lastTriggered,
    this.customDays,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Reminder copyWith({
    String? id,
    String? petId,
    ReminderType? type,
    String? title,
    String? description,
    DateTime? scheduledTime,
    ReminderFrequency? frequency,
    bool? isActive,
    String? linkedEntityId,
    DateTime? createdAt,
    DateTime? lastTriggered,
    List<int>? customDays,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      linkedEntityId: linkedEntityId ?? this.linkedEntityId,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      customDays: customDays ?? this.customDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'type': type.index,
        'title': title,
        'description': description,
        'scheduledTime': scheduledTime.toIso8601String(),
        'frequency': frequency.index,
        'isActive': isActive,
        'linkedEntityId': linkedEntityId,
        'createdAt': createdAt.toIso8601String(),
        'lastTriggered': lastTriggered?.toIso8601String(),
        'customDays': customDays,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'],
        petId: json['petId'],
        type: ReminderType.values[json['type']],
        title: json['title'],
        description: json['description'],
        scheduledTime: DateTime.parse(json['scheduledTime']),
        frequency: ReminderFrequency.values[json['frequency']],
        isActive: json['isActive'] ?? true,
        linkedEntityId: json['linkedEntityId'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        lastTriggered: json['lastTriggered'] != null
            ? DateTime.parse(json['lastTriggered'])
            : null,
        customDays: json['customDays'] != null
            ? List<int>.from(json['customDays'] as List)
            : null,
      );
}
