// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_purchase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationPurchaseAdapter extends TypeAdapter<MedicationPurchase> {
  @override
  final int typeId = 18;

  @override
  MedicationPurchase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationPurchase(
      id: fields[0] as String?,
      medicationId: fields[1] as String,
      petId: fields[2] as String,
      quantity: fields[3] as int,
      cost: fields[4] as double,
      purchaseDate: fields[5] as DateTime,
      pharmacy: fields[6] as String?,
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationPurchase obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicationId)
      ..writeByte(2)
      ..write(obj.petId)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.purchaseDate)
      ..writeByte(6)
      ..write(obj.pharmacy)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationPurchaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
