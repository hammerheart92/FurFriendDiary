import 'package:hive/hive.dart';

part 'reminder_config.g.dart';

/// Represents a reminder configuration for pet care events
///
/// ReminderConfig allows users to customize notification settings for various
/// pet care events. Users can set multiple reminder offsets (e.g., 1 day, 7 days
/// before an event) and customize messages for different event types.
@HiveType(typeId: 29)
class ReminderConfig extends HiveObject {
  /// Unique identifier for this reminder configuration
  @HiveField(0)
  final String id;

  /// ID of the pet this configuration applies to
  @HiveField(1)
  final String petId;

  /// Type of event this reminder is for
  /// Valid values: 'vaccination', 'deworming', 'appointment', 'medication', 'custom'
  @HiveField(2)
  final String eventType;

  /// List of days before the event when reminders should be sent
  /// Example: [1, 7, 14] means reminders at 1 day, 1 week, and 2 weeks before
  @HiveField(3)
  final List<int> reminderDays;

  /// Whether this reminder configuration is currently enabled
  @HiveField(4)
  final bool isEnabled;

  /// Custom title for the reminder (only used when eventType='custom')
  @HiveField(5)
  final String? customTitle;

  /// Custom message for the reminder (only used when eventType='custom')
  @HiveField(6)
  final String? customMessage;

  /// Timestamp when this configuration was created
  @HiveField(7)
  final DateTime createdAt;

  /// Timestamp when this configuration was last modified
  @HiveField(8)
  final DateTime? updatedAt;

  ReminderConfig({
    required this.id,
    required this.petId,
    required this.eventType,
    required this.reminderDays,
    this.isEnabled = true,
    this.customTitle,
    this.customMessage,
    DateTime? createdAt,
    this.updatedAt,
  })  : assert(
          eventType == 'vaccination' ||
              eventType == 'deworming' ||
              eventType == 'appointment' ||
              eventType == 'medication' ||
              eventType == 'custom',
          'eventType must be one of: "vaccination", "deworming", "appointment", "medication", "custom"',
        ),
        assert(
          reminderDays.isNotEmpty,
          'reminderDays must contain at least one value',
        ),
        assert(
          eventType != 'custom' || (customTitle != null && customTitle.isNotEmpty),
          'customTitle is required when eventType is "custom"',
        ),
        createdAt = createdAt ?? DateTime.now();

  /// Create a copy of this config with optional field modifications
  ReminderConfig copyWith({
    String? id,
    String? petId,
    String? eventType,
    List<int>? reminderDays,
    bool? isEnabled,
    String? customTitle,
    String? customMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderConfig(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      eventType: eventType ?? this.eventType,
      reminderDays: reminderDays ?? this.reminderDays,
      isEnabled: isEnabled ?? this.isEnabled,
      customTitle: customTitle ?? this.customTitle,
      customMessage: customMessage ?? this.customMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'eventType': eventType,
      'reminderDays': reminderDays,
      'isEnabled': isEnabled,
      'customTitle': customTitle,
      'customMessage': customMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory ReminderConfig.fromJson(Map<String, dynamic> json) {
    return ReminderConfig(
      id: json['id'] as String,
      petId: json['petId'] as String,
      eventType: json['eventType'] as String,
      reminderDays: (json['reminderDays'] as List<dynamic>)
          .map((day) => day as int)
          .toList(),
      isEnabled: json['isEnabled'] as bool? ?? true,
      customTitle: json['customTitle'] as String?,
      customMessage: json['customMessage'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Get a human-readable description of reminder timing
  /// Example: "1 day, 1 week before"
  String get reminderDescription {
    if (reminderDays.isEmpty) return 'No reminders';

    final sortedDays = List<int>.from(reminderDays)..sort();
    final descriptions = sortedDays.map((days) {
      if (days == 0) return 'on the day';
      if (days == 1) return '1 day before';
      if (days == 7) return '1 week before';
      if (days == 14) return '2 weeks before';
      if (days == 30) return '1 month before';
      return '$days days before';
    }).toList();

    if (descriptions.length == 1) return descriptions.first;
    if (descriptions.length == 2) {
      return '${descriptions[0]} and ${descriptions[1]}';
    }

    final last = descriptions.removeLast();
    return '${descriptions.join(', ')}, and $last';
  }

  /// Get the earliest reminder time (largest number of days before event)
  int get earliestReminderDays {
    if (reminderDays.isEmpty) return 0;
    return reminderDays.reduce((a, b) => a > b ? a : b);
  }

  /// Check if this is a custom reminder (as opposed to built-in event type)
  bool get isCustom => eventType == 'custom';

  @override
  String toString() {
    return 'ReminderConfig(id: $id, petId: $petId, eventType: $eventType, '
        'reminderDays: $reminderDays, isEnabled: $isEnabled, '
        'customTitle: $customTitle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReminderConfig &&
        other.id == id &&
        other.petId == petId &&
        other.eventType == eventType &&
        _listEquals(other.reminderDays, reminderDays) &&
        other.isEnabled == isEnabled &&
        other.customTitle == customTitle &&
        other.customMessage == customMessage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        petId.hashCode ^
        eventType.hashCode ^
        reminderDays.fold(0, (prev, element) => prev ^ element.hashCode) ^
        isEnabled.hashCode ^
        customTitle.hashCode ^
        customMessage.hashCode;
  }

  /// Helper method to compare lists for equality
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
