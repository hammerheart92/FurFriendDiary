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
      dateTime: fields[2] as DateTime,
      appointmentType: fields[3] as String,
      veterinarian: fields[4] as String,
      notes: fields[5] as String?,
      isCompleted: fields[6] as bool,
      location: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.appointmentType)
      ..writeByte(4)
      ..write(obj.veterinarian)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.location);
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
