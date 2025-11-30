import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'vaccination_event.g.dart';

/// Represents a vaccination event/record for a pet
///
/// A VaccinationEvent tracks when a vaccine was administered (or is scheduled),
/// along with relevant details like batch number, veterinarian, and clinic.
/// Events can be manually created or auto-generated from vaccination protocols.
@HiveType(typeId: 30)
class VaccinationEvent extends HiveObject {
  /// Unique identifier for this vaccination event
  @HiveField(0)
  final String id;

  /// ID of the pet this vaccination belongs to
  @HiveField(1)
  final String petId;

  /// Type of vaccine administered (e.g., "DHPPiL", "FVRCP", "Rabies", "FeLV", "Bordetella")
  @HiveField(2)
  final String vaccineType;

  /// Date when the vaccine was administered
  @HiveField(3)
  final DateTime administeredDate;

  /// Next due date for booster vaccination (optional)
  @HiveField(4)
  final DateTime? nextDueDate;

  /// Vaccine batch/lot number from the vial (optional)
  @HiveField(5)
  final String? batchNumber;

  /// Name of the veterinarian who administered the vaccine (optional)
  @HiveField(6)
  final String? veterinarianName;

  /// Name of the clinic where vaccination was performed (optional)
  @HiveField(7)
  final String? clinicName;

  /// Additional notes about the vaccination (optional)
  @HiveField(8)
  final String? notes;

  /// Whether this event was auto-generated from a protocol
  @HiveField(9)
  final bool isFromProtocol;

  /// ID of the vaccination protocol this event is linked to (optional)
  @HiveField(10)
  final String? protocolId;

  /// Index of the step in the protocol (0-based, optional)
  @HiveField(11)
  final int? protocolStepIndex;

  /// Timestamp when this event was created
  @HiveField(12)
  final DateTime createdAt;

  /// Timestamp when this event was last updated (optional)
  @HiveField(13)
  final DateTime? updatedAt;

  /// List of paths to vaccination certificate photos (optional)
  @HiveField(14)
  final List<String>? certificatePhotoUrls;

  VaccinationEvent({
    String? id,
    required this.petId,
    required this.vaccineType,
    required this.administeredDate,
    this.nextDueDate,
    this.batchNumber,
    this.veterinarianName,
    this.clinicName,
    this.notes,
    this.isFromProtocol = false,
    this.protocolId,
    this.protocolStepIndex,
    DateTime? createdAt,
    this.updatedAt,
    this.certificatePhotoUrls,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Create a copy of this event with optional field modifications
  VaccinationEvent copyWith({
    String? id,
    String? petId,
    String? vaccineType,
    DateTime? administeredDate,
    DateTime? nextDueDate,
    String? batchNumber,
    String? veterinarianName,
    String? clinicName,
    String? notes,
    bool? isFromProtocol,
    String? protocolId,
    int? protocolStepIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? certificatePhotoUrls,
  }) {
    return VaccinationEvent(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      vaccineType: vaccineType ?? this.vaccineType,
      administeredDate: administeredDate ?? this.administeredDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      batchNumber: batchNumber ?? this.batchNumber,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      clinicName: clinicName ?? this.clinicName,
      notes: notes ?? this.notes,
      isFromProtocol: isFromProtocol ?? this.isFromProtocol,
      protocolId: protocolId ?? this.protocolId,
      protocolStepIndex: protocolStepIndex ?? this.protocolStepIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      certificatePhotoUrls: certificatePhotoUrls ?? this.certificatePhotoUrls,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'vaccineType': vaccineType,
      'administeredDate': administeredDate.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'batchNumber': batchNumber,
      'veterinarianName': veterinarianName,
      'clinicName': clinicName,
      'notes': notes,
      'isFromProtocol': isFromProtocol,
      'protocolId': protocolId,
      'protocolStepIndex': protocolStepIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'certificatePhotoUrls': certificatePhotoUrls,
    };
  }

  /// Create from JSON map
  factory VaccinationEvent.fromJson(Map<String, dynamic> json) {
    return VaccinationEvent(
      id: json['id'] as String,
      petId: json['petId'] as String,
      vaccineType: json['vaccineType'] as String,
      administeredDate: DateTime.parse(json['administeredDate'] as String),
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'] as String)
          : null,
      batchNumber: json['batchNumber'] as String?,
      veterinarianName: json['veterinarianName'] as String?,
      clinicName: json['clinicName'] as String?,
      notes: json['notes'] as String?,
      isFromProtocol: json['isFromProtocol'] as bool? ?? false,
      protocolId: json['protocolId'] as String?,
      protocolStepIndex: json['protocolStepIndex'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      certificatePhotoUrls: json['certificatePhotoUrls'] != null
          ? List<String>.from(json['certificatePhotoUrls'] as List)
          : null,
    );
  }

  @override
  String toString() {
    return 'VaccinationEvent(id: $id, petId: $petId, vaccineType: $vaccineType, '
        'administeredDate: $administeredDate, isFromProtocol: $isFromProtocol)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VaccinationEvent &&
        other.id == id &&
        other.petId == petId &&
        other.vaccineType == vaccineType &&
        other.administeredDate == administeredDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        petId.hashCode ^
        vaccineType.hashCode ^
        administeredDate.hashCode;
  }
}
