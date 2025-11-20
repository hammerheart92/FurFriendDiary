import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/protocols/deworming_protocol.dart';
import '../../../data/repositories/protocols/deworming_protocol_repository_impl.dart';
import '../../../data/services/protocols/protocol_data_provider.dart';

part 'deworming_protocol_provider.g.dart';

// ============================================================================
// DEWORMING PROTOCOL DATA PROVIDER
// ============================================================================

/// Main deworming protocol provider - manages all protocols (predefined + custom)
///
/// This provider combines predefined protocols loaded from JSON assets with
/// custom user-created protocols stored in Hive. It automatically loads predefined
/// protocols on first build and merges them with custom protocols.
///
/// Usage:
/// ```dart
/// final protocols = await ref.read(dewormingProtocolsProvider.future);
/// ```
@riverpod
class DewormingProtocols extends _$DewormingProtocols {
  @override
  Future<List<DewormingProtocol>> build() async {
    final repository = ref.watch(dewormingProtocolRepositoryProvider);
    final protocolData = ref.watch(protocolDataProviderProvider);

    // Load predefined protocols from JSON assets
    final predefinedProtocols = await protocolData.loadDewormingProtocols();

    // Get custom protocols from Hive
    final customProtocols = await repository.getCustom();

    // Combine: predefined first (sorted by species/name), then custom (sorted by date)
    return [...predefinedProtocols, ...customProtocols];
  }

  /// Save a new custom deworming protocol
  ///
  /// Note: Only custom protocols can be saved. Predefined protocols are read-only.
  Future<void> saveProtocol(DewormingProtocol protocol) async {
    if (!protocol.isCustom) {
      throw ArgumentError(
          'Cannot save predefined protocols. Use custom protocols instead.');
    }

    final repository = ref.read(dewormingProtocolRepositoryProvider);
    await repository.save(protocol);
    ref.invalidateSelf();
  }

  /// Delete a custom deworming protocol
  ///
  /// Note: Only custom protocols can be deleted. Predefined protocols are read-only.
  Future<void> deleteProtocol(String id) async {
    final repository = ref.read(dewormingProtocolRepositoryProvider);

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
// FILTERED DEWORMING PROTOCOL PROVIDERS
// ============================================================================

/// Get deworming protocols filtered by pet species (Dog/Cat)
///
/// Returns both predefined and custom protocols for the specified species.
///
/// Usage:
/// ```dart
/// final dogProtocols = await ref.read(dewormingProtocolsBySpeciesProvider('Dog').future);
/// ```
@riverpod
Future<List<DewormingProtocol>> dewormingProtocolsBySpecies(
  DewormingProtocolsBySpeciesRef ref,
  String species,
) async {
  final repository = ref.watch(dewormingProtocolRepositoryProvider);
  return await repository.getBySpecies(species);
}

/// Get only predefined deworming protocols
///
/// These are the protocols loaded from JSON assets (deworming_protocols.json).
/// Includes ESCCAP-compliant internal and external parasite treatment schedules.
///
/// Usage:
/// ```dart
/// final predefinedProtocols = await ref.read(predefinedDewormingProtocolsProvider.future);
/// ```
@riverpod
Future<List<DewormingProtocol>> predefinedDewormingProtocols(
  PredefinedDewormingProtocolsRef ref,
) async {
  final repository = ref.watch(dewormingProtocolRepositoryProvider);
  return await repository.getPredefined();
}

/// Get only custom user-created deworming protocols
///
/// These are protocols created by the user and stored in Hive.
///
/// Usage:
/// ```dart
/// final customProtocols = await ref.read(customDewormingProtocolsProvider.future);
/// ```
@riverpod
Future<List<DewormingProtocol>> customDewormingProtocols(
  CustomDewormingProtocolsRef ref,
) async {
  final repository = ref.watch(dewormingProtocolRepositoryProvider);
  return await repository.getCustom();
}

/// Get a specific deworming protocol by ID
///
/// Returns null if protocol not found.
///
/// Usage:
/// ```dart
/// final protocol = await ref.read(dewormingProtocolByIdProvider('protocol-id').future);
/// ```
@riverpod
Future<DewormingProtocol?> dewormingProtocolById(
  DewormingProtocolByIdRef ref,
  String id,
) async {
  final repository = ref.watch(dewormingProtocolRepositoryProvider);
  return await repository.getById(id);
}
