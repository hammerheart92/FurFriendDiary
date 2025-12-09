import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local/hive_manager.dart';
import 'protocols/protocol_data_provider.dart';

final _logger = Logger();

/// One-time migration service to populate notesRo field for existing
/// VaccinationEvent records from vaccination_protocols.json.
///
/// This migration runs once on app startup for users upgrading from v1.1.x
/// to v1.2.0. It finds protocol-based vaccinations that are missing Romanian
/// translations and populates them from the protocol step data.
class VaccinationLocalizationMigration {
  static const String _migrationKey =
      'vaccination_localization_migration_v1_2_0';

  final ProtocolDataProvider _protocolProvider;

  VaccinationLocalizationMigration(this._protocolProvider);

  /// Run migration if not already completed.
  /// Safe to call multiple times - will only run once.
  Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRun = prefs.getBool(_migrationKey) ?? false;

    if (hasRun) {
      _logger.i('[MIGRATION] Vaccination localization already migrated');
      return;
    }

    _logger.i('[MIGRATION] Starting vaccination localization migration...');

    try {
      final migratedCount = await _migrateVaccinationNotes();
      await prefs.setBool(_migrationKey, true);
      _logger.i('[MIGRATION] Completed! Migrated $migratedCount vaccinations');
    } catch (e, stackTrace) {
      _logger.e('[MIGRATION] Failed: $e', error: e, stackTrace: stackTrace);
      // Don't mark as complete if migration fails
      // Will retry on next app launch
    }
  }

  Future<int> _migrateVaccinationNotes() async {
    int migratedCount = 0;

    final box = HiveManager.instance.vaccinationEventBox;
    final allVaccinations = box.values.toList();

    _logger
        .d('[MIGRATION] Found ${allVaccinations.length} vaccinations to check');

    // Load protocols using correct method name
    final protocols = await _protocolProvider.loadVaccinationProtocols();
    if (protocols.isEmpty) {
      _logger.w('[MIGRATION] No protocols loaded - skipping migration');
      return 0;
    }

    final protocolMap = {for (var p in protocols) p.id: p};

    for (final event in allVaccinations) {
      // Skip if already has notesRo
      if (event.notesRo != null && event.notesRo!.isNotEmpty) {
        continue;
      }

      // Skip if not protocol-based
      if (!event.isFromProtocol ||
          event.protocolId == null ||
          event.protocolStepIndex == null) {
        continue;
      }

      final protocol = protocolMap[event.protocolId];
      if (protocol == null) {
        _logger.w('[MIGRATION] Protocol not found: ${event.protocolId}');
        continue;
      }

      final stepIndex = event.protocolStepIndex!;
      if (stepIndex < 0 || stepIndex >= protocol.steps.length) {
        _logger.w('[MIGRATION] Step index out of range: $stepIndex');
        continue;
      }

      final step = protocol.steps[stepIndex];

      if (step.notesRo != null && step.notesRo!.isNotEmpty) {
        // CRITICAL: Use copyWith since notesRo is final
        final updatedEvent = event.copyWith(notesRo: step.notesRo);

        // CRITICAL: Use event.id as key (matches repository pattern)
        await box.put(event.id, updatedEvent);
        migratedCount++;
        _logger.d('[MIGRATION] Updated: ${event.vaccineType} (${event.id})');
      }
    }

    // Flush to ensure persistence (critical for Samsung devices)
    await box.flush();

    return migratedCount;
  }

  /// Force re-run migration (for testing/development only).
  /// Call this to reset the migration flag and allow it to run again.
  static Future<void> resetMigration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationKey);
    _logger.i('[MIGRATION] Reset flag - will run on next launch');
  }
}
