/// Translations for vaccine type display names
///
/// **IMPORTANT**: All vaccine types are STORED in English in the database.
/// This class ONLY provides display translations for the UI layer.
///
/// **Usage Pattern**:
/// ```dart
/// // When saving to database
/// final vaccinationType = 'Rabies'; // Always English
/// await repository.save(vaccination.copyWith(vaccineType: vaccinationType));
///
/// // When displaying in UI
/// final locale = Localizations.localeOf(context).languageCode;
/// final displayName = VaccineTypeTranslations.getDisplayName('Rabies', locale);
/// Text(displayName); // Shows "Rabie" in Romanian, "Rabies" in English
/// ```
///
/// **Medical Terms**:
/// Medical abbreviations (FVRCP, DHPPiL, FeLV) remain unchanged in all locales
/// as they are internationally recognized veterinary standards.
class VaccineTypeTranslations {
  /// Romanian translations for vaccine type names
  ///
  /// Maps English vaccine type (database value) to Romanian display name
  static const Map<String, String> ro = {
    // Dogs: Core vaccines
    'Rabies': 'Rabie',
    'DHPPiL': 'DHPPiL', // Medical abbreviation, keep as-is
    'Bordetella': 'Bordetella', // Medical term, keep as-is

    // Dogs: Non-core vaccines
    'Lyme': 'Lyme', // Disease name (proper noun), keep as-is
    'Leptospirosis': 'Leptospiroză',
    'Canine Influenza': 'Gripă Canină',

    // Cats: Core vaccines
    'FVRCP': 'FVRCP', // Medical abbreviation, keep as-is
    'FeLV': 'FeLV', // Medical abbreviation, keep as-is

    // Cats: Non-core vaccines
    'Feline Leukemia': 'Leucemie Felină',
    'FIV': 'FIV', // Medical abbreviation, keep as-is

    // Other common vaccines
    'Bordetella bronchiseptica': 'Bordetella bronchiseptica', // Scientific name
  };

  /// Get display name for vaccine type based on current locale
  ///
  /// **Parameters**:
  /// - `vaccineType`: The vaccine type as stored in database (always English)
  /// - `localeCode`: The locale code (e.g., 'en', 'ro')
  ///
  /// **Returns**: Localized display name, or original English name if no translation exists
  ///
  /// **Example**:
  /// ```dart
  /// VaccineTypeTranslations.getDisplayName('Rabies', 'ro') // Returns 'Rabie'
  /// VaccineTypeTranslations.getDisplayName('Rabies', 'en') // Returns 'Rabies'
  /// VaccineTypeTranslations.getDisplayName('FVRCP', 'ro')  // Returns 'FVRCP' (unchanged)
  /// ```
  static String getDisplayName(String vaccineType, String localeCode) {
    if (localeCode == 'ro' && ro.containsKey(vaccineType)) {
      return ro[vaccineType]!;
    }
    return vaccineType; // Default to stored value (English)
  }

  /// Get all available vaccine types in English (for storage)
  ///
  /// **Use this** when populating dropdown menus to ensure consistent database values
  static List<String> getAllVaccineTypes() {
    return ro.keys.toList();
  }

  /// Check if a vaccine type has a Romanian translation
  static bool hasRomanianTranslation(String vaccineType) {
    return ro.containsKey(vaccineType) && ro[vaccineType] != vaccineType;
  }
}
