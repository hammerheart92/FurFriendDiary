import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pdf_consent.g.dart';

/// Represents user consent for PDF export operations (GDPR Article 6(1)(a))
///
/// This model stores the user's consent decision for generating PDF health reports
/// containing sensitive pet health data. Consent is global (applies to all pets).
@HiveType(typeId: 32)
@JsonSerializable()
class PdfConsent extends HiveObject {
  /// Fixed ID for singleton pattern - always "pdf_export_consent"
  @HiveField(0)
  final String id;

  /// Whether consent has been granted
  @HiveField(1)
  final bool consentGiven;

  /// Timestamp when consent was granted or revoked
  @HiveField(2)
  final DateTime timestamp;

  /// Type of consent - always "pdf_export" for this use case
  @HiveField(3)
  final String consentType;

  /// Whether user checked "Don't ask again"
  /// If false and consentGiven is false, show dialog again
  @HiveField(4)
  final bool dontAskAgain;

  /// Version of privacy policy/terms at time of consent
  /// Can be used for re-consent if policies change
  @HiveField(5)
  final String? policyVersion;

  PdfConsent({
    String? id,
    required this.consentGiven,
    required this.timestamp,
    this.consentType = 'pdf_export',
    this.dontAskAgain = true,
    this.policyVersion,
  }) : id = id ?? 'pdf_export_consent';

  /// Factory for granting consent
  factory PdfConsent.granted(
      {bool dontAskAgain = true, String? policyVersion}) {
    return PdfConsent(
      consentGiven: true,
      timestamp: DateTime.now(),
      dontAskAgain: dontAskAgain,
      policyVersion: policyVersion,
    );
  }

  /// Factory for declining consent
  factory PdfConsent.declined({bool dontAskAgain = true}) {
    return PdfConsent(
      consentGiven: false,
      timestamp: DateTime.now(),
      dontAskAgain: dontAskAgain,
    );
  }

  /// Copy with method for updates
  PdfConsent copyWith({
    bool? consentGiven,
    DateTime? timestamp,
    String? consentType,
    bool? dontAskAgain,
    String? policyVersion,
  }) {
    return PdfConsent(
      id: id,
      consentGiven: consentGiven ?? this.consentGiven,
      timestamp: timestamp ?? this.timestamp,
      consentType: consentType ?? this.consentType,
      dontAskAgain: dontAskAgain ?? this.dontAskAgain,
      policyVersion: policyVersion ?? this.policyVersion,
    );
  }

  /// JSON serialization
  factory PdfConsent.fromJson(Map<String, dynamic> json) =>
      _$PdfConsentFromJson(json);
  Map<String, dynamic> toJson() => _$PdfConsentToJson(this);
}
