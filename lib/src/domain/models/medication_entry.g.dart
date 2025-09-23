// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationEntryAdapter extends TypeAdapter<MedicationEntry> {
  @override
  final int typeId = 5;

  @override
  MedicationEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationEntry(
      id: fields[0] as String?,
      petId: fields[1] as String,
      medicationName: fields[2] as String,
      dosage: fields[3] as String,
      frequency: fields[4] as String,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime?,
      administrationMethod: fields[7] as String,
      notes: fields[8] as String?,
      isActive: fields[9] as bool,
      createdAt: fields[10] as DateTime?,
      administrationTimes: (fields[11] as List?)?.cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, MedicationEntry obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.medicationName)
      ..writeByte(3)
      ..write(obj.dosage)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.administrationMethod)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.administrationTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
