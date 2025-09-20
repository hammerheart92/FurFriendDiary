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
      dateTime: fields[2] as DateTime,
      medicationName: fields[3] as String,
      dosage: fields[4] as String,
      notes: fields[5] as String?,
      nextDose: fields[6] as DateTime?,
      isCompleted: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.medicationName)
      ..writeByte(4)
      ..write(obj.dosage)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.nextDose)
      ..writeByte(7)
      ..write(obj.isCompleted);
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
