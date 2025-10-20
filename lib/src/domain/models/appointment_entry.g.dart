// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentEntryAdapter extends TypeAdapter<AppointmentEntry> {
  @override
  final int typeId = 6;

  @override
  AppointmentEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppointmentEntry(
      id: fields[0] as String?,
      petId: fields[1] as String,
      veterinarian: fields[2] as String,
      clinic: fields[3] as String,
      appointmentDate: fields[4] as DateTime,
      appointmentTime: fields[5] as DateTime,
      reason: fields[6] as String,
      notes: fields[7] as String?,
      isCompleted: fields[8] as bool,
      createdAt: fields[9] as DateTime?,
      vetId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.veterinarian)
      ..writeByte(3)
      ..write(obj.clinic)
      ..writeByte(4)
      ..write(obj.appointmentDate)
      ..writeByte(5)
      ..write(obj.appointmentTime)
      ..writeByte(6)
      ..write(obj.reason)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.vetId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
