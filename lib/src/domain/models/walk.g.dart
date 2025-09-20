// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'walk.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalkAdapter extends TypeAdapter<Walk> {
  @override
  final int typeId = 3;

  @override
  Walk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Walk(
      id: fields[0] as String?,
      petId: fields[1] as String,
      start: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      durationMinutes: fields[4] as int,
      distance: fields[5] as double?,
      walkType: fields[6] as WalkType,
      isActive: fields[7] as bool,
      isComplete: fields[8] as bool,
      notes: fields[9] as String?,
      startTime: fields[10] as DateTime?,
      locations: (fields[11] as List?)?.cast<WalkLocation>(),
    );
  }

  @override
  void write(BinaryWriter writer, Walk obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.distance)
      ..writeByte(6)
      ..write(obj.walkType)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.isComplete)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.startTime)
      ..writeByte(11)
      ..write(obj.locations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalkLocationAdapter extends TypeAdapter<WalkLocation> {
  @override
  final int typeId = 7;

  @override
  WalkLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalkLocation(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WalkLocation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalkLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalkTypeAdapter extends TypeAdapter<WalkType> {
  @override
  final int typeId = 4;

  @override
  WalkType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WalkType.walk;
      case 1:
        return WalkType.run;
      case 2:
        return WalkType.hike;
      case 3:
        return WalkType.play;
      case 4:
        return WalkType.regular;
      case 5:
        return WalkType.short;
      case 6:
        return WalkType.long;
      case 7:
        return WalkType.training;
      default:
        return WalkType.walk;
    }
  }

  @override
  void write(BinaryWriter writer, WalkType obj) {
    switch (obj) {
      case WalkType.walk:
        writer.writeByte(0);
        break;
      case WalkType.run:
        writer.writeByte(1);
        break;
      case WalkType.hike:
        writer.writeByte(2);
        break;
      case WalkType.play:
        writer.writeByte(3);
        break;
      case WalkType.regular:
        writer.writeByte(4);
        break;
      case WalkType.short:
        writer.writeByte(5);
        break;
      case WalkType.long:
        writer.writeByte(6);
        break;
      case WalkType.training:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalkTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
