import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/repositories/medication_repository.dart';
import '../local/hive_boxes.dart';

part 'medication_repository_impl.g.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  @override
  Future<List<MedicationEntry>> getAllMedications() async {
    try {
      final box = HiveBoxes.getMedications();
      final medications = box.values.toList();
      // Sort by creation date, newest first
      medications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print("🔍 DEBUG: Retrieved ${medications.length} medications from Hive");
      return medications;
    } catch (e) {
      print("🚨 ERROR: Failed to get all medications: $e");
      rethrow;
    }
  }

  @override
  Future<List<MedicationEntry>> getMedicationsByPetId(String petId) async {
    try {
      final box = HiveBoxes.getMedications();
      final medications = box.values
          .where((medication) => medication.petId == petId)
          .toList();
      // Sort by creation date, newest first
      medications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print("🔍 DEBUG: Retrieved ${medications.length} medications for pet $petId");
      return medications;
    } catch (e) {
      print("🚨 ERROR: Failed to get medications for pet $petId: $e");
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
      print("🔍 DEBUG: Retrieved ${medications.length} active medications for pet $petId");
      return medications;
    } catch (e) {
      print("🚨 ERROR: Failed to get active medications for pet $petId: $e");
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
      print("🔍 DEBUG: Retrieved ${medications.length} inactive medications for pet $petId");
      return medications;
    } catch (e) {
      print("🚨 ERROR: Failed to get inactive medications for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<void> addMedication(MedicationEntry medication) async {
    try {
      final box = HiveBoxes.getMedications();
      await box.put(medication.id, medication);
      print("✅ DEBUG: Added medication '${medication.medicationName}' with ID ${medication.id}");
    } catch (e) {
      print("🚨 ERROR: Failed to add medication '${medication.medicationName}': $e");
      rethrow;
    }
  }

  @override
  Future<void> updateMedication(MedicationEntry medication) async {
    try {
      final box = HiveBoxes.getMedications();
      await box.put(medication.id, medication);
      print("✅ DEBUG: Updated medication '${medication.medicationName}' with ID ${medication.id}");
    } catch (e) {
      print("🚨 ERROR: Failed to update medication '${medication.medicationName}': $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteMedication(String id) async {
    try {
      final box = HiveBoxes.getMedications();
      final medication = box.get(id);
      await box.delete(id);
      print("✅ DEBUG: Deleted medication with ID $id${medication != null ? " ('${medication.medicationName}')" : ""}");
    } catch (e) {
      print("🚨 ERROR: Failed to delete medication with ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<MedicationEntry?> getMedicationById(String id) async {
    try {
      final box = HiveBoxes.getMedications();
      final medication = box.get(id);
      if (medication != null) {
        print("🔍 DEBUG: Found medication '${medication.medicationName}' with ID $id");
      } else {
        print("⚠️ DEBUG: No medication found with ID $id");
      }
      return medication;
    } catch (e) {
      print("🚨 ERROR: Failed to get medication by ID $id: $e");
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
      print("🔍 DEBUG: Retrieved ${medications.length} medications for pet $petId in date range");
      return medications;
    } catch (e) {
      print("🚨 ERROR: Failed to get medications by date range for pet $petId: $e");
      rethrow;
    }
  }
}

@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  return MedicationRepositoryImpl();
}
