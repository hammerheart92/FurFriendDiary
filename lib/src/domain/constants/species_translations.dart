// File: lib/src/domain/constants/species_translations.dart
// Purpose: Provides translation mappings for pet species

/// Translation helper for pet species names
///
/// Maps English species names to their Romanian equivalents and provides
/// a method to get the localized display name based on locale.
class SpeciesTranslations {
  /// Map of English species names to Romanian translations
  static const Map<String, String> _romanianTranslations = {
    'dog': 'Câine',
    'cat': 'Pisică',
    'bird': 'Pasăre',
    'rabbit': 'Iepure',
    'hamster': 'Hamster',
    'guinea pig': 'Porc de Guineea',
    'fish': 'Pește',
    'turtle': 'Broască țestoasă',
    'lizard': 'Șopârlă',
    'snake': 'Șarpe',
    'ferret': 'Dihor',
    'horse': 'Cal',
    'other': 'Altele',
  };

  /// Map of English species names to capitalized English display names
  static const Map<String, String> _englishDisplayNames = {
    'dog': 'Dog',
    'cat': 'Cat',
    'bird': 'Bird',
    'rabbit': 'Rabbit',
    'hamster': 'Hamster',
    'guinea pig': 'Guinea Pig',
    'fish': 'Fish',
    'turtle': 'Turtle',
    'lizard': 'Lizard',
    'snake': 'Snake',
    'ferret': 'Ferret',
    'horse': 'Horse',
    'other': 'Other',
  };

  /// Get the localized display name for a species
  ///
  /// [species] - The species identifier (e.g., "dog", "cat")
  /// [localeCode] - The locale code (e.g., "en", "ro")
  ///
  /// Returns the translated species name, or the original species if not found.
  static String getDisplayName(String species, String localeCode) {
    final normalizedSpecies = species.toLowerCase().trim();

    if (localeCode == 'ro') {
      return _romanianTranslations[normalizedSpecies] ??
          _capitalizeFirst(species);
    }

    // English or fallback
    return _englishDisplayNames[normalizedSpecies] ?? _capitalizeFirst(species);
  }

  /// Capitalize the first letter of a string
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Get all available species in the given locale
  static List<String> getAllSpecies(String localeCode) {
    if (localeCode == 'ro') {
      return _romanianTranslations.values.toList();
    }
    return _englishDisplayNames.values.toList();
  }

  /// Check if a species is supported
  static bool isSupported(String species) {
    final normalizedSpecies = species.toLowerCase().trim();
    return _englishDisplayNames.containsKey(normalizedSpecies);
  }
}
