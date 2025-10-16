// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 12;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String?,
      petId: fields[1] as String,
      type: fields[2] as ReminderType,
      title: fields[3] as String,
      description: fields[4] as String?,
      scheduledTime: fields[5] as DateTime,
      frequency: fields[6] as ReminderFrequency,
      isActive: fields[7] as bool,
      linkedEntityId: fields[8] as String?,
      createdAt: fields[9] as DateTime?,
      lastTriggered: fields[10] as DateTime?,
      customDays: (fields[11] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.scheduledTime)
      ..writeByte(6)
      ..write(obj.frequency)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.linkedEntityId)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.lastTriggered)
      ..writeByte(11)
      ..write(obj.customDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderTypeAdapter extends TypeAdapter<ReminderType> {
  @override
  final int typeId = 10;

  @override
  ReminderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderType.medication;
      case 1:
        return ReminderType.appointment;
      case 2:
        return ReminderType.feeding;
      case 3:
        return ReminderType.walk;
      default:
        return ReminderType.medication;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderType obj) {
    switch (obj) {
      case ReminderType.medication:
        writer.writeByte(0);
        break;
      case ReminderType.appointment:
        writer.writeByte(1);
        break;
      case ReminderType.feeding:
        writer.writeByte(2);
        break;
      case ReminderType.walk:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderFrequencyAdapter extends TypeAdapter<ReminderFrequency> {
  @override
  final int typeId = 11;

  @override
  ReminderFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderFrequency.once;
      case 1:
        return ReminderFrequency.daily;
      case 2:
        return ReminderFrequency.twiceDaily;
      case 3:
        return ReminderFrequency.weekly;
      case 4:
        return ReminderFrequency.custom;
      default:
        return ReminderFrequency.once;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderFrequency obj) {
    switch (obj) {
      case ReminderFrequency.once:
        writer.writeByte(0);
        break;
      case ReminderFrequency.daily:
        writer.writeByte(1);
        break;
      case ReminderFrequency.twiceDaily:
        writer.writeByte(2);
        break;
      case ReminderFrequency.weekly:
        writer.writeByte(3);
        break;
      case ReminderFrequency.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
