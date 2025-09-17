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
      id: fields[0] as String,
      petId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      duration: fields[4] as Duration?,
      distance: fields[5] as double?,
      notes: fields[6] as String?,
      walkType: fields[7] as WalkType,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Walk obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.distance)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.walkType)
      ..writeByte(8)
      ..write(obj.createdAt);
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

class WalkTypeAdapter extends TypeAdapter<WalkType> {
  @override
  final int typeId = 4;

  @override
  WalkType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WalkType.regular;
      case 1:
        return WalkType.short;
      case 2:
        return WalkType.long;
      case 3:
        return WalkType.training;
      default:
        return WalkType.regular;
    }
  }

  @override
  void write(BinaryWriter writer, WalkType obj) {
    switch (obj) {
      case WalkType.regular:
        writer.writeByte(0);
        break;
      case WalkType.short:
        writer.writeByte(1);
        break;
      case WalkType.long:
        writer.writeByte(2);
        break;
      case WalkType.training:
        writer.writeByte(3);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Walk _$WalkFromJson(Map<String, dynamic> json) => Walk(
      id: json['id'] as String,
      petId: json['petId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      distance: (json['distance'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      walkType: $enumDecodeNullable(_$WalkTypeEnumMap, json['walkType']) ??
          WalkType.regular,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WalkToJson(Walk instance) => <String, dynamic>{
      'id': instance.id,
      'petId': instance.petId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration?.inMicroseconds,
      'distance': instance.distance,
      'notes': instance.notes,
      'walkType': _$WalkTypeEnumMap[instance.walkType]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$WalkTypeEnumMap = {
  WalkType.regular: 'regular',
  WalkType.short: 'short',
  WalkType.long: 'long',
  WalkType.training: 'training',
};
