// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportEntryAdapter extends TypeAdapter<ReportEntry> {
  @override
  final int typeId = 9;

  @override
  ReportEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportEntry(
      id: fields[0] as String?,
      petId: fields[1] as String,
      reportType: fields[2] as String,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      data: (fields[6] as Map).cast<String, dynamic>(),
      filters: (fields[7] as Map?)?.cast<String, dynamic>(),
      generatedDate: fields[5] as DateTime?,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReportEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.reportType)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.generatedDate)
      ..writeByte(6)
      ..write(obj.data)
      ..writeByte(7)
      ..write(obj.filters)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
