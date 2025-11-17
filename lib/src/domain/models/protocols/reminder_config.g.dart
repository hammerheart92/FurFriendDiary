// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderConfigAdapter extends TypeAdapter<ReminderConfig> {
  @override
  final int typeId = 29;

  @override
  ReminderConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderConfig(
      id: fields[0] as String,
      petId: fields[1] as String,
      eventType: fields[2] as String,
      reminderDays: (fields[3] as List).cast<int>(),
      isEnabled: fields[4] as bool,
      customTitle: fields[5] as String?,
      customMessage: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderConfig obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.eventType)
      ..writeByte(3)
      ..write(obj.reminderDays)
      ..writeByte(4)
      ..write(obj.isEnabled)
      ..writeByte(5)
      ..write(obj.customTitle)
      ..writeByte(6)
      ..write(obj.customMessage)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
