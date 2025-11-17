// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_protocol.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccinationProtocolAdapter extends TypeAdapter<VaccinationProtocol> {
  @override
  final int typeId = 22;

  @override
  VaccinationProtocol read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccinationProtocol(
      id: fields[0] as String,
      name: fields[1] as String,
      species: fields[2] as String,
      steps: (fields[3] as List).cast<VaccinationStep>(),
      description: fields[4] as String,
      isCustom: fields[5] as bool,
      region: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VaccinationProtocol obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.species)
      ..writeByte(3)
      ..write(obj.steps)
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
      other is VaccinationProtocolAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VaccinationStepAdapter extends TypeAdapter<VaccinationStep> {
  @override
  final int typeId = 23;

  @override
  VaccinationStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VaccinationStep(
      vaccineName: fields[0] as String,
      ageInWeeks: fields[1] as int,
      intervalDays: fields[2] as int?,
      notes: fields[3] as String?,
      isRequired: fields[4] as bool,
      recurring: fields[5] as RecurringSchedule?,
    );
  }

  @override
  void write(BinaryWriter writer, VaccinationStep obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.vaccineName)
      ..writeByte(1)
      ..write(obj.ageInWeeks)
      ..writeByte(2)
      ..write(obj.intervalDays)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.isRequired)
      ..writeByte(5)
      ..write(obj.recurring);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccinationStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringScheduleAdapter extends TypeAdapter<RecurringSchedule> {
  @override
  final int typeId = 24;

  @override
  RecurringSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringSchedule(
      intervalMonths: fields[0] as int,
      indefinitely: fields[1] as bool,
      numberOfDoses: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringSchedule obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.intervalMonths)
      ..writeByte(1)
      ..write(obj.indefinitely)
      ..writeByte(2)
      ..write(obj.numberOfDoses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
