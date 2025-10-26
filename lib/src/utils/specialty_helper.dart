import '../../../l10n/app_localizations.dart';

/// Helper class for translating veterinarian specialties
class SpecialtyHelper {
  /// Translates a specialty from English storage value to localized display text
  static String getLocalizedSpecialty(
    String? specialty,
    AppLocalizations l10n,
  ) {
    if (specialty == null || specialty.isEmpty) {
      return '';
    }

    // Map English specialty values to localized strings
    switch (specialty) {
      case 'General Practice':
        return l10n.generalPractice;
      case 'Emergency Medicine':
        return l10n.emergencyMedicine;
      case 'Cardiology':
        return l10n.cardiology;
      case 'Dermatology':
        return l10n.dermatology;
      case 'Surgery':
        return l10n.surgery;
      case 'Orthopedics':
        return l10n.orthopedics;
      case 'Oncology':
        return l10n.oncology;
      case 'Ophthalmology':
        return l10n.ophthalmology;
      case 'Statistics':
        return l10n.statistics;
      case 'Custom':
        return l10n.custom;
      default:
        // Return the original value if not found in mappings
        // This handles custom specialties or unknown values
        return specialty;
    }
  }
}
