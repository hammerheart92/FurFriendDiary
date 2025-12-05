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
      gender: fields[12] as PetGender,
    );
  }

  @override
  void write(BinaryWriter writer, PetProfile obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.dewormingProtocolId)
      ..writeByte(12)
      ..write(obj.gender);
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

class PetGenderAdapter extends TypeAdapter<PetGender> {
  @override
  final int typeId = 31;

  @override
  PetGender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PetGender.male;
      case 1:
        return PetGender.female;
      case 2:
        return PetGender.unknown;
      default:
        return PetGender.male;
    }
  }

  @override
  void write(BinaryWriter writer, PetGender obj) {
    switch (obj) {
      case PetGender.male:
        writer.writeByte(0);
        break;
      case PetGender.female:
        writer.writeByte(1);
        break;
      case PetGender.unknown:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetGenderAdapter &&
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
      gender: $enumDecodeNullable(_$PetGenderEnumMap, json['gender']) ??
          PetGender.unknown,
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
      'gender': _$PetGenderEnumMap[instance.gender]!,
    };

const _$PetGenderEnumMap = {
  PetGender.male: 'male',
  PetGender.female: 'female',
  PetGender.unknown: 'unknown',
};
