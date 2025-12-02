import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/protocols/vaccination_protocol.dart';
import '../../../data/repositories/protocols/vaccination_protocol_repository_impl.dart';
import '../../../data/services/protocols/protocol_data_provider.dart';

part 'vaccination_protocol_provider.g.dart';

// ============================================================================
// VACCINATION PROTOCOL DATA PROVIDER
// ============================================================================

/// Main vaccination protocol provider - manages all protocols (predefined + custom)
///
/// This provider combines predefined protocols loaded from JSON assets with
/// custom user-created protocols stored in Hive. It automatically loads predefined
/// protocols on first build and merges them with custom protocols.
///
/// Usage:
/// ```dart
/// final protocols = await ref.read(vaccinationProtocolsProvider.future);
/// ```
@riverpod
class VaccinationProtocols extends _$VaccinationProtocols {
  @override
  Future<List<VaccinationProtocol>> build() async {
    final repository = ref.watch(vaccinationProtocolRepositoryProvider);
    final protocolData = ref.watch(protocolDataProviderProvider);

    // Load predefined protocols from JSON assets (always has latest translations)
    final predefinedProtocols = await protocolData.loadVaccinationProtocols();

    // CRITICAL FIX v1.2.0: Always update predefined protocols in Hive from JSON
    // This ensures notesRo and other localization fields are synced from JSON
    // Old approach only saved when Hive was empty - now we always sync
    if (predefinedProtocols.isNotEmpty) {
      for (final protocol in predefinedProtocols) {
        await repository.save(protocol);
      }
      print('🔄 [PROTOCOLS] Synced ${predefinedProtocols.length} predefined protocols from JSON to Hive');
    }

    // Get custom protocols from Hive
    final customProtocols = await repository.getCustom();

    // Combine: predefined first (sorted by species/name), then custom (sorted by date)
    final combined = [...predefinedProtocols, ...customProtocols];
    return combined;
  }

  /// Save a new custom vaccination protocol
  ///
  /// Note: Only custom protocols can be saved. Predefined protocols are read-only.
  Future<void> saveProtocol(VaccinationProtocol protocol) async {
    if (!protocol.isCustom) {
      throw ArgumentError(
          'Cannot save predefined protocols. Use custom protocols instead.');
    }

    final repository = ref.read(vaccinationProtocolRepositoryProvider);
    await repository.save(protocol);
    ref.invalidateSelf();
  }

  /// Delete a custom vaccination protocol
  ///
  /// Note: Only custom protocols can be deleted. Predefined protocols are read-only.
  Future<void> deleteProtocol(String id) async {
    final repository = ref.read(vaccinationProtocolRepositoryProvider);

    // Verify it's a custom protocol before deleting
    final protocol = await repository.getById(id);
    if (protocol != null && !protocol.isCustom) {
      throw ArgumentError(
          'Cannot delete predefined protocols. Only custom protocols can be deleted.');
    }

    await repository.delete(id);
    ref.invalidateSelf();
  }

  /// Force reload predefined protocols from JSON assets
  ///
  /// Useful for refreshing protocol data after app updates or manual changes.
  Future<void> reloadPredefinedProtocols() async {
    final protocolData = ref.read(protocolDataProviderProvider);
    await protocolData.reloadProtocols();
    ref.invalidateSelf();
  }
}

// ============================================================================
// FILTERED VACCINATION PROTOCOL PROVIDERS
// ============================================================================

/// Get vaccination protocols filtered by pet species (Dog/Cat)
///
/// Returns both predefined and custom protocols for the specified species.
///
/// Usage:
/// ```dart
/// final dogProtocols = await ref.read(vaccinationProtocolsBySpeciesProvider('Dog').future);
/// ```
@riverpod
Future<List<VaccinationProtocol>> vaccinationProtocolsBySpecies(
  VaccinationProtocolsBySpeciesRef ref,
  String species,
) async {
  // CRITICAL FIX: Watch main provider to ensure JSON is loaded and saved to Hive
  final allProtocols = await ref.watch(vaccinationProtocolsProvider.future);

  // Filter by species (case-insensitive)
  final speciesLower = species.toLowerCase();
  final result = allProtocols
      .where((p) => p.species.toLowerCase() == speciesLower)
      .toList();

  return result;
}

/// Get only predefined vaccination protocols
///
/// These are the protocols loaded from JSON assets (vaccination_protocols.json).
/// Includes WSAVA-compliant core and extended vaccination schedules.
///
/// Usage:
/// ```dart
/// final predefinedProtocols = await ref.read(predefinedVaccinationProtocolsProvider.future);
/// ```
@riverpod
Future<List<VaccinationProtocol>> predefinedVaccinationProtocols(
  PredefinedVaccinationProtocolsRef ref,
) async {
  final repository = ref.watch(vaccinationProtocolRepositoryProvider);
  return await repository.getPredefined();
}

/// Get only custom user-created vaccination protocols
///
/// These are protocols created by the user and stored in Hive.
///
/// Usage:
/// ```dart
/// final customProtocols = await ref.read(customVaccinationProtocolsProvider.future);
/// ```
@riverpod
Future<List<VaccinationProtocol>> customVaccinationProtocols(
  CustomVaccinationProtocolsRef ref,
) async {
  final repository = ref.watch(vaccinationProtocolRepositoryProvider);
  return await repository.getCustom();
}

/// Get a specific vaccination protocol by ID
///
/// Returns null if protocol not found.
///
/// Usage:
/// ```dart
/// final protocol = await ref.read(vaccinationProtocolByIdProvider('protocol-id').future);
/// ```
@riverpod
Future<VaccinationProtocol?> vaccinationProtocolById(
  VaccinationProtocolByIdRef ref,
  String id,
) async {
  final repository = ref.watch(vaccinationProtocolRepositoryProvider);
  return await repository.getById(id);
}
