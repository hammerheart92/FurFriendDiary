// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseReportAdapter extends TypeAdapter<ExpenseReport> {
  @override
  final int typeId = 21;

  @override
  ExpenseReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseReport(
      id: fields[0] as String?,
      petId: fields[1] as String,
      month: fields[2] as DateTime,
      totalExpenses: fields[3] as double,
      categoryBreakdown: (fields[4] as Map).cast<String, double>(),
      averagePerWeek: fields[5] as double,
      mostExpensiveCategory: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseReport obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.totalExpenses)
      ..writeByte(4)
      ..write(obj.categoryBreakdown)
      ..writeByte(5)
      ..write(obj.averagePerWeek)
      ..writeByte(6)
      ..write(obj.mostExpensiveCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
