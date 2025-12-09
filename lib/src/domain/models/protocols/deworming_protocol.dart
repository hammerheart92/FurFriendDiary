import 'package:hive/hive.dart';
import 'vaccination_protocol.dart'; // Import RecurringSchedule

part 'deworming_protocol.g.dart';

/// Represents a deworming protocol/schedule for a specific species
///
/// A deworming protocol defines a series of deworming treatments that should
/// be administered at specific ages or intervals. Protocols can be predefined
/// (standard veterinary schedules) or custom (user-created).
@HiveType(typeId: 25)
class DewormingProtocol extends HiveObject {
  /// Unique identifier for this protocol
  @HiveField(0)
  final String id;

  /// Name of the protocol (e.g., "Canine Standard Deworming Protocol")
  @HiveField(1)
  final String name;

  /// Romanian name of the protocol (optional, for localization)
  @HiveField(9)
  final String? nameRo;

  /// Species this protocol applies to ('dog', 'cat', 'other')
  @HiveField(2)
  final String species;

  /// List of deworming schedules in this protocol
  @HiveField(3)
  final List<DewormingSchedule> schedules;

  /// Detailed description of the protocol
  @HiveField(4)
  final String description;

  /// Romanian description of the protocol (optional, for localization)
  @HiveField(10)
  final String? descriptionRo;

  /// Whether this is a user-created protocol (true) or predefined (false)
  @HiveField(5)
  final bool isCustom;

  /// Optional region/country this protocol is designed for
  @HiveField(6)
  final String? region;

  /// Timestamp when this protocol was created
  @HiveField(7)
  final DateTime createdAt;

  /// Timestamp when this protocol was last modified
  @HiveField(8)
  final DateTime? updatedAt;

  DewormingProtocol({
    required this.id,
    required this.name,
    this.nameRo,
    required this.species,
    required this.schedules,
    required this.description,
    this.descriptionRo,
    required this.isCustom,
    this.region,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a copy of this protocol with optional field modifications
  DewormingProtocol copyWith({
    String? id,
    String? name,
    String? nameRo,
    String? species,
    List<DewormingSchedule>? schedules,
    String? description,
    String? descriptionRo,
    bool? isCustom,
    String? region,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DewormingProtocol(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRo: nameRo ?? this.nameRo,
      species: species ?? this.species,
      schedules: schedules ?? this.schedules,
      description: description ?? this.description,
      descriptionRo: descriptionRo ?? this.descriptionRo,
      isCustom: isCustom ?? this.isCustom,
      region: region ?? this.region,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameRo': nameRo,
      'species': species,
      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
      'description': description,
      'descriptionRo': descriptionRo,
      'isCustom': isCustom,
      'region': region,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory DewormingProtocol.fromJson(Map<String, dynamic> json) {
    return DewormingProtocol(
      id: json['id'] as String,
      name: json['name'] as String,
      nameRo: json['nameRo'] as String?,
      species: json['species'] as String,
      schedules: (json['schedules'] as List<dynamic>)
          .map((scheduleJson) =>
              DewormingSchedule.fromJson(scheduleJson as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String,
      descriptionRo: json['descriptionRo'] as String?,
      isCustom: json['isCustom'] as bool,
      region: json['region'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'DewormingProtocol(id: $id, name: $name, species: $species, '
        'schedules: ${schedules.length}, isCustom: $isCustom, region: $region)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DewormingProtocol &&
        other.id == id &&
        other.name == name &&
        other.species == species &&
        other.description == description &&
        other.isCustom == isCustom &&
        other.region == region;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        species.hashCode ^
        description.hashCode ^
        isCustom.hashCode ^
        region.hashCode;
  }
}

/// Represents a single deworming treatment in a protocol
///
/// Each schedule defines when a specific type of deworming should be administered,
/// either based on the pet's age or as an interval after the previous treatment.
@HiveType(typeId: 26)
class DewormingSchedule {
  /// Type of deworming ('external' for fleas/ticks, 'internal' for intestinal parasites)
  @HiveField(0)
  final String dewormingType;

  /// Age in weeks when this deworming should be given
  /// Used for initial treatments based on pet's birth date
  @HiveField(1)
  final int ageInWeeks;

  /// Days after previous treatment (for follow-up treatments)
  /// If null, use ageInWeeks instead
  @HiveField(2)
  final int? intervalDays;

  /// Additional notes or instructions (e.g., "Initial treatment", "Summer season only")
  @HiveField(3)
  final String? notes;

  /// Romanian translation of notes (optional, for localization)
  @HiveField(6)
  final String? notesRo;

  /// Recurring schedule for periodic treatments (e.g., monthly, quarterly)
  @HiveField(4)
  final RecurringSchedule? recurring;

  /// Product name or active ingredient recommendation (optional)
  @HiveField(5)
  final String? productName;

  DewormingSchedule({
    required this.dewormingType,
    required this.ageInWeeks,
    this.intervalDays,
    this.notes,
    this.notesRo,
    this.recurring,
    this.productName,
  }) : assert(
          dewormingType == 'external' || dewormingType == 'internal',
          'dewormingType must be either "external" or "internal"',
        );

  /// Create a copy of this schedule with optional field modifications
  DewormingSchedule copyWith({
    String? dewormingType,
    int? ageInWeeks,
    int? intervalDays,
    String? notes,
    String? notesRo,
    RecurringSchedule? recurring,
    String? productName,
  }) {
    return DewormingSchedule(
      dewormingType: dewormingType ?? this.dewormingType,
      ageInWeeks: ageInWeeks ?? this.ageInWeeks,
      intervalDays: intervalDays ?? this.intervalDays,
      notes: notes ?? this.notes,
      notesRo: notesRo ?? this.notesRo,
      recurring: recurring ?? this.recurring,
      productName: productName ?? this.productName,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'dewormingType': dewormingType,
      'ageInWeeks': ageInWeeks,
      'intervalDays': intervalDays,
      'notes': notes,
      'notesRo': notesRo,
      'recurring': recurring?.toJson(),
      'productName': productName,
    };
  }

  /// Create from JSON map
  factory DewormingSchedule.fromJson(Map<String, dynamic> json) {
    return DewormingSchedule(
      dewormingType: json['dewormingType'] as String,
      ageInWeeks: json['ageInWeeks'] as int,
      intervalDays: json['intervalDays'] as int?,
      notes: json['notes'] as String?,
      notesRo: json['notesRo'] as String?,
      recurring: json['recurring'] != null
          ? RecurringSchedule.fromJson(
              json['recurring'] as Map<String, dynamic>)
          : null,
      productName: json['productName'] as String?,
    );
  }

  @override
  String toString() {
    return 'DewormingSchedule(dewormingType: $dewormingType, ageInWeeks: $ageInWeeks, '
        'intervalDays: $intervalDays, productName: $productName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DewormingSchedule &&
        other.dewormingType == dewormingType &&
        other.ageInWeeks == ageInWeeks &&
        other.intervalDays == intervalDays &&
        other.notes == notes &&
        other.productName == productName;
  }

  @override
  int get hashCode {
    return dewormingType.hashCode ^
        ageInWeeks.hashCode ^
        intervalDays.hashCode ^
        notes.hashCode ^
        productName.hashCode;
  }
}
