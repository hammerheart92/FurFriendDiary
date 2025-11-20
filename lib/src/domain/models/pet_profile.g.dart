// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetProfileAdapter extends TypeAdapter<PetProfile> {
  @override
  final int typeId = 1;

  @override
  PetProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetProfile(
      id: fields[0] as String?,
      name: fields[1] as String,
      species: fields[2] as String,
      breed: fields[3] as String?,
      birthday: fields[4] as DateTime?,
      photoPath: fields[5] as String?,
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
      isActive: fields[9] as bool,
      vaccinationProtocolId: fields[10] as String?,
      dewormingProtocolId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PetProfile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.species)
      ..writeByte(3)
      ..write(obj.breed)
      ..writeByte(4)
      ..write(obj.birthday)
      ..writeByte(5)
      ..write(obj.photoPath)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.vaccinationProtocolId)
      ..writeByte(11)
      ..write(obj.dewormingProtocolId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PetProfile _$PetProfileFromJson(Map<String, dynamic> json) => PetProfile(
      id: json['id'] as String?,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      birthday: json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      photoPath: json['photoPath'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
      vaccinationProtocolId: json['vaccinationProtocolId'] as String?,
      dewormingProtocolId: json['dewormingProtocolId'] as String?,
    );

Map<String, dynamic> _$PetProfileToJson(PetProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'birthday': instance.birthday?.toIso8601String(),
      'photoPath': instance.photoPath,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'vaccinationProtocolId': instance.vaccinationProtocolId,
      'dewormingProtocolId': instance.dewormingProtocolId,
    };
