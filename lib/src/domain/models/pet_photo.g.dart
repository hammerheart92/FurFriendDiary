// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetPhotoAdapter extends TypeAdapter<PetPhoto> {
  @override
  final int typeId = 16;

  @override
  PetPhoto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetPhoto(
      id: fields[0] as String?,
      petId: fields[1] as String,
      filePath: fields[2] as String,
      thumbnailPath: fields[3] as String,
      caption: fields[4] as String?,
      dateTaken: fields[5] as DateTime,
      createdAt: fields[6] as DateTime?,
      fileSize: fields[7] as int,
      medicationId: fields[8] as String?,
      appointmentId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PetPhoto obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.petId)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.thumbnailPath)
      ..writeByte(4)
      ..write(obj.caption)
      ..writeByte(5)
      ..write(obj.dateTaken)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.fileSize)
      ..writeByte(8)
      ..write(obj.medicationId)
      ..writeByte(9)
      ..write(obj.appointmentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetPhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
