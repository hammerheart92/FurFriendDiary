// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_owner_tier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetOwnerTierAdapter extends TypeAdapter<PetOwnerTier> {
  @override
  final int typeId = 17;

  @override
  PetOwnerTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PetOwnerTier.free;
      case 1:
        return PetOwnerTier.premium;
      case 2:
        return PetOwnerTier.lifetime;
      default:
        return PetOwnerTier.free;
    }
  }

  @override
  void write(BinaryWriter writer, PetOwnerTier obj) {
    switch (obj) {
      case PetOwnerTier.free:
        writer.writeByte(0);
        break;
      case PetOwnerTier.premium:
        writer.writeByte(1);
        break;
      case PetOwnerTier.lifetime:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetOwnerTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
