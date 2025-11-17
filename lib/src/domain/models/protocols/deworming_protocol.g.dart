// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deworming_protocol.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DewormingProtocolAdapter extends TypeAdapter<DewormingProtocol> {
  @override
  final int typeId = 25;

  @override
  DewormingProtocol read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DewormingProtocol(
      id: fields[0] as String,
      name: fields[1] as String,
      species: fields[2] as String,
      schedules: (fields[3] as List).cast<DewormingSchedule>(),
      description: fields[4] as String,
      isCustom: fields[5] as bool,
      region: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DewormingProtocol obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.species)
      ..writeByte(3)
      ..write(obj.schedules)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.isCustom)
      ..writeByte(6)
      ..write(obj.region)
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
      other is DewormingProtocolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DewormingScheduleAdapter extends TypeAdapter<DewormingSchedule> {
  @override
  final int typeId = 26;

  @override
  DewormingSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DewormingSchedule(
      dewormingType: fields[0] as String,
      ageInWeeks: fields[1] as int,
      intervalDays: fields[2] as int?,
      notes: fields[3] as String?,
      recurring: fields[4] as RecurringSchedule?,
      productName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DewormingSchedule obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dewormingType)
      ..writeByte(1)
      ..write(obj.ageInWeeks)
      ..writeByte(2)
      ..write(obj.intervalDays)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.recurring)
      ..writeByte(5)
      ..write(obj.productName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DewormingScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
