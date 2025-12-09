import '../models/pdf_consent.dart';

/// Repository interface for PDF export consent management
abstract class PdfConsentRepository {
  /// Get current consent record (returns null if never set)
  Future<PdfConsent?> getConsent();

  /// Save or update consent record
  Future<void> saveConsent(PdfConsent consent);

  /// Delete consent record (for testing/reset purposes)
  Future<void> deleteConsent();

  /// Check if consent exists and is granted
  /// Returns false if no consent record exists or if explicitly declined
  Future<bool> hasGrantedConsent();

  /// Check if user has made any consent decision (granted or declined with "don't ask again")
  /// Returns true if consent record exists with dontAskAgain=true
  Future<bool> hasConsentDecision();
}
