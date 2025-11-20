import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'pet_profile.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class PetProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String species;

  @HiveField(3)
  final String? breed;

  @HiveField(4)
  final DateTime? birthday;

  @HiveField(5)
  final String? photoPath;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final String? vaccinationProtocolId;

  @HiveField(11)
  final String? dewormingProtocolId;

  PetProfile({
    String? id,
    required this.name,
    required this.species,
    this.breed,
    this.birthday,
    this.photoPath,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = false,
    this.vaccinationProtocolId,
    this.dewormingProtocolId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory PetProfile.fromJson(Map<String, dynamic> json) =>
      _$PetProfileFromJson(json);
  Map<String, dynamic> toJson() => _$PetProfileToJson(this);

  int get age {
    if (birthday == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  PetProfile copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    DateTime? birthday,
    String? photoPath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? vaccinationProtocolId,
    String? dewormingProtocolId,
  }) {
    return PetProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthday: birthday ?? this.birthday,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      vaccinationProtocolId: vaccinationProtocolId ?? this.vaccinationProtocolId,
      dewormingProtocolId: dewormingProtocolId ?? this.dewormingProtocolId,
    );
  }
}
