// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedingEntryAdapter extends TypeAdapter<FeedingEntry> {
  @override
  final int typeId = 2;

  @override
  FeedingEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedingEntry(
      id: fields[0] as String?,
      petId: fields[1] as String,
      dateTime: fields[2] as DateTime,
      foodType: fields[3] as String,
      amount: fields[4] as double,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FeedingEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.foodType)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedingEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
