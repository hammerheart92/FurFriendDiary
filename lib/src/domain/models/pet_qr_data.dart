import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'pet_qr_data.g.dart';

/// Data model for pet information encoded in QR codes.
/// Privacy-conscious: excludes sensitive medical data.
@JsonSerializable()
class PetQrData {
  final String name;
  final String species;
  final String? breed;
  final int? ageYears;
  final String generatedAt;

  PetQrData({
    required this.name,
    required this.species,
    this.breed,
    this.ageYears,
    String? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now().toIso8601String();

  factory PetQrData.fromJson(Map<String, dynamic> json) =>
      _$PetQrDataFromJson(json);

  Map<String, dynamic> toJson() => _$PetQrDataToJson(this);

  String toJsonString() => jsonEncode(toJson());

  static PetQrData? fromJsonString(String jsonString) {
    try {
      return PetQrData.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }
}
