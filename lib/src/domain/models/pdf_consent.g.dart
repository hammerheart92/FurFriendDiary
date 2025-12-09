// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_consent.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfConsentAdapter extends TypeAdapter<PdfConsent> {
  @override
  final int typeId = 32;

  @override
  PdfConsent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfConsent(
      id: fields[0] as String?,
      consentGiven: fields[1] as bool,
      timestamp: fields[2] as DateTime,
      consentType: fields[3] as String,
      dontAskAgain: fields[4] as bool,
      policyVersion: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PdfConsent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.consentGiven)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.consentType)
      ..writeByte(4)
      ..write(obj.dontAskAgain)
      ..writeByte(5)
      ..write(obj.policyVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfConsentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdfConsent _$PdfConsentFromJson(Map<String, dynamic> json) => PdfConsent(
      id: json['id'] as String?,
      consentGiven: json['consentGiven'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      consentType: json['consentType'] as String? ?? 'pdf_export',
      dontAskAgain: json['dontAskAgain'] as bool? ?? true,
      policyVersion: json['policyVersion'] as String?,
    );

Map<String, dynamic> _$PdfConsentToJson(PdfConsent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'consentGiven': instance.consentGiven,
      'timestamp': instance.timestamp.toIso8601String(),
      'consentType': instance.consentType,
      'dontAskAgain': instance.dontAskAgain,
      'policyVersion': instance.policyVersion,
    };
