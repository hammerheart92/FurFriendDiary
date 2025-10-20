// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vet_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VetProfileAdapter extends TypeAdapter<VetProfile> {
  @override
  final int typeId = 19;

  @override
  VetProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VetProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      clinicName: fields[2] as String,
      specialty: fields[3] as String?,
      phoneNumber: fields[4] as String?,
      email: fields[5] as String?,
      address: fields[6] as String?,
      website: fields[7] as String?,
      notes: fields[8] as String?,
      isPreferred: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      lastVisitDate: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VetProfile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.clinicName)
      ..writeByte(3)
      ..write(obj.specialty)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.website)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.isPreferred)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.lastVisitDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VetProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
