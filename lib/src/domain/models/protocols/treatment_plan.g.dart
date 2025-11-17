// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TreatmentPlanAdapter extends TypeAdapter<TreatmentPlan> {
  @override
  final int typeId = 27;

  @override
  TreatmentPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TreatmentPlan(
      id: fields[0] as String,
      petId: fields[1] as String,
      name: fields[2] as String,
      description: fields[3] as String,
      veterinarianName: fields[4] as String?,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime?,
      tasks: (fields[7] as List).cast<TreatmentTask>(),
      isActive: fields[8] as bool,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TreatmentPlan obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.veterinarianName)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.tasks)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreatmentPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TreatmentTaskAdapter extends TypeAdapter<TreatmentTask> {
  @override
  final int typeId = 28;

  @override
  TreatmentTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TreatmentTask(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      scheduledDate: fields[3] as DateTime,
      scheduledTime: fields[4] as TimeOfDayModel?,
      isCompleted: fields[5] as bool,
      completedAt: fields[6] as DateTime?,
      notes: fields[7] as String?,
      taskType: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TreatmentTask obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.scheduledDate)
      ..writeByte(4)
      ..write(obj.scheduledTime)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.taskType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreatmentTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
