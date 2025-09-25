import
'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/time_of_day_model.dart';
import '../../domain/repositories/medication_repository.dart';
import '../local/hive_boxes.dart';


part 'medication_repository_impl.g.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final logger = Logger();
  static bool _migrationRun = false;

  Future<void> _runMigrationIfNeeded() async {
    if (_migrationRun) return;

    try {
      final box = HiveBoxes.getMedications();

      // Check if we have any medications that need migration
      final needsMigration = box.values.any((medication) {
        try {
          // Try to access administrationTimes - if this throws, we need migration
          final _ = medication.administrationTimes;
          return false;
        } catch (e) {
          return true;
        }
      });

      if (needsMigration) {
        logger.i("🔧 DEBUG: Running medication migration for TimeOfDayModel");

        // For now, clear the box since this is a breaking change
        // In a production app, you would migrate the data properly
        await box.clear();
        logger.i("✅ DEBUG: Medication box cleared due to schema change");
      }

      _migrationRun = true;
    } catch (e) {
      logger.e("🚨 ERROR: Migration failed: $e");
      // Clear the box as fallback
      try {
        final box = HiveBoxes.getMedications();
        await box.clear();
        logger.i("✅ DEBUG: Medication box cleared as migration fallback");
        _migrationRun = true;
      } catch (clearError) {
        logger.e("🚨 ERROR: Failed to clear medication box: $clearError");
      }
    }
  }
  @override
  Future<List<MedicationEntry>> getAllMedications() async {
    await _runMigrationIfNeeded();
    try {
      final box = HiveBoxes.getMedications();
      final medications = box.values.toList();
      // Sort by creation date, newest first
      medications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i("🔍 DEBUG: Retrieved ${medications.length} medications from Hive");
      return medications;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get all medications: $e");
      rethrow;
    }
  }

  @override
  Future<List<MedicationEntry>> getMedicationsByPetId(String petId) async {
    await _runMigrationIfNeeded();
    try {
      final box = HiveBoxes.getMedications();
      final medications = box.values
          .where((medication) => medication.petId == petId)
          .toList();
      // Sort by creation date, newest first
      medications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i("🔍 DEBUG: Retrieved ${medications.length} medications for pet $petId");
      return medications;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get medications for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<MedicationEntry>> getActiveMedicationsByPetId(String petId) async {
    try {
      final box = HiveBoxes.getMedications();
      final medications = box.values
          .where((medication) => medication.petId == petId && medication.isActive)
          .toList();
      // Sort by creation date, newest first
      medications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i("🔍 DEBUG: Retrieved ${medications.length} active medications for pet $petId");
      return medications;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get active medications for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<MedicationEntry>> getInactiveMedicationsByPetId(String petId) async {
    try {
      final box = HiveBoxes.getMedications();
      final medications = box.values
          .where((medication) => medication.petId == petId && !medication.isActive)
          .toList();
      // Sort by creation date, newest first
      medications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i("🔍 DEBUG: Retrieved ${medications.length} inactive medications for pet $petId");
      return medications;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get inactive medications for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<void> addMedication(MedicationEntry medication) async {
    try {
      final box = HiveBoxes.getMedications();
      await box.put(medication.id, medication);
      logger.i("✅ DEBUG: Added medication '${medication.medicationName}' with ID ${medication.id}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to add medication '${medication.medicationName}': $e");
      rethrow;
    }
  }

  @override
  Future<void> updateMedication(MedicationEntry medication) async {
    try {
      final box = HiveBoxes.getMedications();
      await box.put(medication.id, medication);
      logger.i("✅ DEBUG: Updated medication '${medication.medicationName}' with ID ${medication.id}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to update medication '${medication.medicationName}': $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteMedication(String id) async {
    try {
      final box = HiveBoxes.getMedications();
      final medication = box.get(id);
      await box.delete(id);
      logger.i("✅ DEBUG: Deleted medication with ID $id${medication != null ? " ('${medication.medicationName}')" : ""}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete medication with ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<MedicationEntry?> getMedicationById(String id) async {
    try {
      final box = HiveBoxes.getMedications();
      final medication = box.get(id);
      if (medication != null) {
        logger.i("🔍 DEBUG: Found medication '${medication.medicationName}' with ID $id");
      } else {
        logger.w("⚠️ DEBUG: No medication found with ID $id");
      }
      return medication;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get medication by ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<List<MedicationEntry>> getMedicationsByDateRange(String petId, DateTime start, DateTime end) async {
    try {
      final box = HiveBoxes.getMedications();
      final medications = box.values
          .where((medication) =>
              medication.petId == petId &&
              medication.startDate.isAfter(start) &&
              medication.startDate.isBefore(end))
          .toList();
      // Sort by start date, newest first
      medications.sort((a, b) => b.startDate.compareTo(a.startDate));
      logger.i("🔍 DEBUG: Retrieved ${medications.length} medications for pet $petId in date range");
      return medications;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get medications by date range for pet $petId: $e");
      rethrow;
    }
  }
}

@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  return MedicationRepositoryImpl();
}
