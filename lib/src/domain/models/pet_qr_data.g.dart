// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_qr_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PetQrData _$PetQrDataFromJson(Map<String, dynamic> json) => PetQrData(
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      ageYears: (json['ageYears'] as num?)?.toInt(),
      generatedAt: json['generatedAt'] as String?,
    );

Map<String, dynamic> _$PetQrDataToJson(PetQrData instance) => <String, dynamic>{
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'ageYears': instance.ageYears,
      'generatedAt': instance.generatedAt,
    };
