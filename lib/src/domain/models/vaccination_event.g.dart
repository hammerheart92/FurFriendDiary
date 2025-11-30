// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccinationEventAdapter extends TypeAdapter<VaccinationEvent> {
  @override
  final int typeId = 30;

  @override
  VaccinationEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccinationEvent(
      id: fields[0] as String?,
      petId: fields[1] as String,
      vaccineType: fields[2] as String,
      administeredDate: fields[3] as DateTime,
      nextDueDate: fields[4] as DateTime?,
      batchNumber: fields[5] as String?,
      veterinarianName: fields[6] as String?,
      clinicName: fields[7] as String?,
      notes: fields[8] as String?,
      isFromProtocol: fields[9] as bool,
      protocolId: fields[10] as String?,
      protocolStepIndex: fields[11] as int?,
      createdAt: fields[12] as DateTime?,
      updatedAt: fields[13] as DateTime?,
      certificatePhotoUrls: (fields[14] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, VaccinationEvent obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.vaccineType)
      ..writeByte(3)
      ..write(obj.administeredDate)
      ..writeByte(4)
      ..write(obj.nextDueDate)
      ..writeByte(5)
      ..write(obj.batchNumber)
      ..writeByte(6)
      ..write(obj.veterinarianName)
      ..writeByte(7)
      ..write(obj.clinicName)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.isFromProtocol)
      ..writeByte(10)
      ..write(obj.protocolId)
      ..writeByte(11)
      ..write(obj.protocolStepIndex)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.certificatePhotoUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccinationEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
