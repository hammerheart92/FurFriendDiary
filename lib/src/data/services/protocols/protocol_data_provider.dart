import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/protocols/vaccination_protocol.dart';
import '../../../domain/models/protocols/deworming_protocol.dart';

part 'protocol_data_provider.g.dart';

/// Service for loading and caching protocol data from JSON assets
///
/// ProtocolDataProvider loads vaccination and deworming protocols from JSON files
/// in assets/protocols/ directory. The service caches loaded protocols in memory
/// to avoid repeated asset loading and JSON parsing on subsequent calls.
///
/// Features:
/// - Load vaccination protocols from JSON (assets/protocols/vaccination_protocols.json)
/// - Load deworming protocols from JSON (assets/protocols/deworming_protocols.json)
/// - In-memory caching for performance
/// - Force reload capability
/// - Comprehensive error handling
/// - Logger integration
///
/// Usage:
/// ```dart
/// final protocolProvider = ref.read(protocolDataProviderProvider);
/// final vaccinationProtocols = await protocolProvider.loadVaccinationProtocols();
/// final dewormingProtocols = await protocolProvider.loadDewormingProtocols();
/// ```
class ProtocolDataProvider {
  final Logger logger;

  // Asset paths
  static const String _vaccinationProtocolsPath =
      'assets/protocols/vaccination_protocols.json';
  static const String _dewormingProtocolsPath =
      'assets/protocols/deworming_protocols.json';

  // In-memory caches
  List<VaccinationProtocol>? _vaccinationProtocolsCache;
  List<DewormingProtocol>? _dewormingProtocolsCache;

  ProtocolDataProvider({
    Logger? logger,
  }) : logger = logger ?? Logger();

  // ============================================================================
  // CORE METHOD 1: Load Vaccination Protocols
  // ============================================================================

  /// Load vaccination protocols from JSON asset
  ///
  /// This method loads the vaccination_protocols.json file from assets,
  /// parses it into VaccinationProtocol objects, and caches the results
  /// in memory. Subsequent calls return the cached data without reloading.
  ///
  /// Returns:
  /// - List<VaccinationProtocol>: Loaded protocols (or cached if already loaded)
  /// - Empty list on error (graceful degradation)
  ///
  /// Example:
  /// ```dart
  /// final protocols = await provider.loadVaccinationProtocols();
  /// print('Loaded ${protocols.length} vaccination protocols');
  /// ```
  Future<List<VaccinationProtocol>> loadVaccinationProtocols() async {
    // Return cached data if available
    if (_vaccinationProtocolsCache != null) {
      logger.d(
          '🔍 DEBUG: Returning cached vaccination protocols (${_vaccinationProtocolsCache!.length} protocols)');
      return _vaccinationProtocolsCache!;
    }

    try {
      logger.i('📥 Loading vaccination protocols from assets...');

      // Load JSON string from assets
      final jsonString = await rootBundle.loadString(_vaccinationProtocolsPath);
      logger.d(
          '✅ Loaded vaccination protocols JSON (${jsonString.length} characters)');

      // Parse JSON
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      logger.d('✅ Parsed JSON array with ${jsonList.length} items');

      // Convert to VaccinationProtocol objects
      final protocols = jsonList
          .map((json) =>
              VaccinationProtocol.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the results
      _vaccinationProtocolsCache = protocols;

      logger.i(
          '✅ Successfully loaded ${protocols.length} vaccination protocols from assets');

      // Log protocol details
      for (final protocol in protocols) {
        logger.d(
            '  📋 ${protocol.name} (${protocol.species}) - ${protocol.steps.length} steps');
      }

      return protocols;
    } catch (e, stackTrace) {
      logger.e(
          '🚨 ERROR: Failed to load vaccination protocols from assets: $e\n$stackTrace');
      // Return empty list on error (graceful degradation)
      return [];
    }
  }

  // ============================================================================
  // CORE METHOD 2: Load Deworming Protocols
  // ============================================================================

  /// Load deworming protocols from JSON asset
  ///
  /// This method loads the deworming_protocols.json file from assets,
  /// parses it into DewormingProtocol objects, and caches the results
  /// in memory. Subsequent calls return the cached data without reloading.
  ///
  /// Returns:
  /// - List<DewormingProtocol>: Loaded protocols (or cached if already loaded)
  /// - Empty list on error (graceful degradation)
  ///
  /// Example:
  /// ```dart
  /// final protocols = await provider.loadDewormingProtocols();
  /// print('Loaded ${protocols.length} deworming protocols');
  /// ```
  Future<List<DewormingProtocol>> loadDewormingProtocols() async {
    // Return cached data if available
    if (_dewormingProtocolsCache != null) {
      logger.d(
          '🔍 DEBUG: Returning cached deworming protocols (${_dewormingProtocolsCache!.length} protocols)');
      return _dewormingProtocolsCache!;
    }

    try {
      logger.i('📥 Loading deworming protocols from assets...');

      // Load JSON string from assets
      final jsonString = await rootBundle.loadString(_dewormingProtocolsPath);
      logger.d(
          '✅ Loaded deworming protocols JSON (${jsonString.length} characters)');

      // Parse JSON
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      logger.d('✅ Parsed JSON array with ${jsonList.length} items');

      // Convert to DewormingProtocol objects
      final protocols = jsonList
          .map((json) =>
              DewormingProtocol.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the results
      _dewormingProtocolsCache = protocols;

      logger.i(
          '✅ Successfully loaded ${protocols.length} deworming protocols from assets');

      // Log protocol details
      for (final protocol in protocols) {
        logger.d(
            '  📋 ${protocol.name} (${protocol.species}) - ${protocol.schedules.length} schedules');
      }

      return protocols;
    } catch (e, stackTrace) {
      logger.e(
          '🚨 ERROR: Failed to load deworming protocols from assets: $e\n$stackTrace');
      // Return empty list on error (graceful degradation)
      return [];
    }
  }

  // ============================================================================
  // CORE METHOD 3: Get Cached Protocols
  // ============================================================================

  /// Get cached protocols without loading from assets
  ///
  /// This method returns the currently cached protocol data without triggering
  /// a load operation. Returns empty lists if protocols have not been loaded yet.
  ///
  /// Returns:
  /// - Map with keys 'vaccination' and 'deworming'
  /// - Empty lists for any protocols not yet loaded
  ///
  /// Example:
  /// ```dart
  /// final cached = provider.getCachedProtocols();
  /// print('Cached vaccination protocols: ${cached['vaccination']!.length}');
  /// print('Cached deworming protocols: ${cached['deworming']!.length}');
  /// ```
  Map<String, List<dynamic>> getCachedProtocols() {
    logger.d('🔍 DEBUG: Getting cached protocols');

    return {
      'vaccination': _vaccinationProtocolsCache ?? [],
      'deworming': _dewormingProtocolsCache ?? [],
    };
  }

  // ============================================================================
  // CORE METHOD 4: Force Reload Protocols
  // ============================================================================

  /// Force reload all protocols from assets
  ///
  /// This method clears the in-memory cache and reloads all protocols from
  /// JSON assets. Useful when protocol data may have been updated or when
  /// you want to ensure fresh data.
  ///
  /// Returns:
  /// - Future<void> that completes when both protocol types are reloaded
  ///
  /// Example:
  /// ```dart
  /// await provider.reloadProtocols();
  /// print('All protocols reloaded from assets');
  /// ```
  Future<void> reloadProtocols() async {
    logger.i('🔄 Force reloading all protocols from assets...');

    // Clear caches
    _vaccinationProtocolsCache = null;
    _dewormingProtocolsCache = null;
    logger.d('✅ Cleared protocol caches');

    // Reload from assets
    await loadVaccinationProtocols();
    await loadDewormingProtocols();

    logger.i('✅ Successfully reloaded all protocols from assets');
  }

  // ============================================================================
  // HELPER METHOD: Get Protocol Count
  // ============================================================================

  /// Get count of cached protocols
  ///
  /// Returns a map with counts for each protocol type.
  /// Useful for debugging and status displays.
  ///
  /// Returns:
  /// - Map with keys 'vaccination' and 'deworming'
  ///
  /// Example:
  /// ```dart
  /// final counts = provider.getProtocolCounts();
  /// print('Vaccination protocols: ${counts['vaccination']}');
  /// print('Deworming protocols: ${counts['deworming']}');
  /// ```
  Map<String, int> getProtocolCounts() {
    return {
      'vaccination': _vaccinationProtocolsCache?.length ?? 0,
      'deworming': _dewormingProtocolsCache?.length ?? 0,
    };
  }
}

// ============================================================================
// RIVERPOD PROVIDER
// ============================================================================

/// Riverpod provider for ProtocolDataProvider
///
/// Usage:
/// ```dart
/// final protocolProvider = ref.read(protocolDataProviderProvider);
/// final protocols = await protocolProvider.loadVaccinationProtocols();
/// ```
@riverpod
ProtocolDataProvider protocolDataProvider(ProtocolDataProviderRef ref) {
  return ProtocolDataProvider();
}
