import 'package:hive/hive.dart';

part 'vaccination_protocol.g.dart';

/// Represents a vaccination protocol/schedule for a specific species
///
/// A vaccination protocol defines a series of vaccination steps that should
/// be administered at specific ages or intervals. Protocols can be predefined
/// (standard veterinary schedules) or custom (user-created).
@HiveType(typeId: 22)
class VaccinationProtocol extends HiveObject {
  /// Unique identifier for this protocol
  @HiveField(0)
  final String id;

  /// Name of the protocol (e.g., "Canine Core Vaccination Protocol")
  @HiveField(1)
  final String name;

  /// Romanian name of the protocol (optional, for localization)
  @HiveField(9)
  final String? nameRo;

  /// Species this protocol applies to ('dog', 'cat', 'other')
  @HiveField(2)
  final String species;

  /// List of vaccination steps in this protocol
  @HiveField(3)
  final List<VaccinationStep> steps;

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

  VaccinationProtocol({
    required this.id,
    required this.name,
    this.nameRo,
    required this.species,
    required this.steps,
    required this.description,
    this.descriptionRo,
    required this.isCustom,
    this.region,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a copy of this protocol with optional field modifications
  VaccinationProtocol copyWith({
    String? id,
    String? name,
    String? nameRo,
    String? species,
    List<VaccinationStep>? steps,
    String? description,
    String? descriptionRo,
    bool? isCustom,
    String? region,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaccinationProtocol(
      id: id ?? this.id,
      name: name ?? this.name,
      nameRo: nameRo ?? this.nameRo,
      species: species ?? this.species,
      steps: steps ?? this.steps,
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
      'steps': steps.map((step) => step.toJson()).toList(),
      'description': description,
      'descriptionRo': descriptionRo,
      'isCustom': isCustom,
      'region': region,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory VaccinationProtocol.fromJson(Map<String, dynamic> json) {
    return VaccinationProtocol(
      id: json['id'] as String,
      name: json['name'] as String,
      nameRo: json['nameRo'] as String?,
      species: json['species'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((stepJson) => VaccinationStep.fromJson(stepJson as Map<String, dynamic>))
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
    return 'VaccinationProtocol(id: $id, name: $name, species: $species, '
        'steps: ${steps.length}, isCustom: $isCustom, region: $region)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VaccinationProtocol &&
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

/// Represents a single step/dose in a vaccination protocol
///
/// Each step defines when a specific vaccine should be administered,
/// either based on the pet's age or as an interval after the previous dose.
@HiveType(typeId: 23)
class VaccinationStep {
  /// Name of the vaccine (e.g., "DHPPiL", "Rabies", "FVRCP")
  @HiveField(0)
  final String vaccineName;

  /// Age in weeks when this vaccine should be given
  /// Used for initial doses based on pet's birth date
  @HiveField(1)
  final int ageInWeeks;

  /// Days after previous dose (for booster shots)
  /// If null, use ageInWeeks instead
  @HiveField(2)
  final int? intervalDays;

  /// Additional notes or instructions (e.g., "First booster", "Legally required")
  @HiveField(3)
  final String? notes;

  /// Whether this is a core/required vaccine (true) or optional (false)
  @HiveField(4)
  final bool isRequired;

  /// Recurring schedule for annual/periodic boosters
  @HiveField(5)
  final RecurringSchedule? recurring;

  VaccinationStep({
    required this.vaccineName,
    required this.ageInWeeks,
    this.intervalDays,
    this.notes,
    this.isRequired = true,
    this.recurring,
  });

  /// Create a copy of this step with optional field modifications
  VaccinationStep copyWith({
    String? vaccineName,
    int? ageInWeeks,
    int? intervalDays,
    String? notes,
    bool? isRequired,
    RecurringSchedule? recurring,
  }) {
    return VaccinationStep(
      vaccineName: vaccineName ?? this.vaccineName,
      ageInWeeks: ageInWeeks ?? this.ageInWeeks,
      intervalDays: intervalDays ?? this.intervalDays,
      notes: notes ?? this.notes,
      isRequired: isRequired ?? this.isRequired,
      recurring: recurring ?? this.recurring,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'vaccineName': vaccineName,
      'ageInWeeks': ageInWeeks,
      'intervalDays': intervalDays,
      'notes': notes,
      'isRequired': isRequired,
      'recurring': recurring?.toJson(),
    };
  }

  /// Create from JSON map
  factory VaccinationStep.fromJson(Map<String, dynamic> json) {
    return VaccinationStep(
      vaccineName: json['vaccineName'] as String,
      ageInWeeks: json['ageInWeeks'] as int,
      intervalDays: json['intervalDays'] as int?,
      notes: json['notes'] as String?,
      isRequired: json['isRequired'] as bool? ?? true,
      recurring: json['recurring'] != null
          ? RecurringSchedule.fromJson(json['recurring'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'VaccinationStep(vaccineName: $vaccineName, ageInWeeks: $ageInWeeks, '
        'intervalDays: $intervalDays, isRequired: $isRequired)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VaccinationStep &&
        other.vaccineName == vaccineName &&
        other.ageInWeeks == ageInWeeks &&
        other.intervalDays == intervalDays &&
        other.notes == notes &&
        other.isRequired == isRequired;
  }

  @override
  int get hashCode {
    return vaccineName.hashCode ^
        ageInWeeks.hashCode ^
        intervalDays.hashCode ^
        notes.hashCode ^
        isRequired.hashCode;
  }
}

/// Defines a recurring schedule for periodic boosters
@HiveType(typeId: 24)
class RecurringSchedule {
  /// Interval in months between recurring doses
  @HiveField(0)
  final int intervalMonths;

  /// Whether to continue indefinitely (true) or end after certain number of doses (false)
  @HiveField(1)
  final bool indefinitely;

  /// If not indefinite, the number of recurring doses to schedule
  @HiveField(2)
  final int? numberOfDoses;

  RecurringSchedule({
    required this.intervalMonths,
    this.indefinitely = true,
    this.numberOfDoses,
  }) : assert(
          indefinitely || numberOfDoses != null,
          'numberOfDoses must be specified when not recurring indefinitely',
        );

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'intervalMonths': intervalMonths,
      'indefinitely': indefinitely,
      'numberOfDoses': numberOfDoses,
    };
  }

  /// Create from JSON map
  factory RecurringSchedule.fromJson(Map<String, dynamic> json) {
    return RecurringSchedule(
      intervalMonths: json['intervalMonths'] as int,
      indefinitely: json['indefinitely'] as bool? ?? true,
      numberOfDoses: json['numberOfDoses'] as int?,
    );
  }

  @override
  String toString() {
    return 'RecurringSchedule(intervalMonths: $intervalMonths, '
        'indefinitely: $indefinitely, numberOfDoses: $numberOfDoses)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RecurringSchedule &&
        other.intervalMonths == intervalMonths &&
        other.indefinitely == indefinitely &&
        other.numberOfDoses == numberOfDoses;
  }

  @override
  int get hashCode {
    return intervalMonths.hashCode ^
        indefinitely.hashCode ^
        numberOfDoses.hashCode;
  }
}
