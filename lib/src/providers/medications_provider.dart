import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/medication_entry.dart';
import '../domain/models/time_of_day_model.dart';
import '../domain/repositories/medication_repository.dart';
import '../data/repositories/medication_repository_impl.dart';

const _uuid = Uuid();

// Repository provider with proper interface typing for better testability
final medicationsRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepositoryImpl();
});

// Medications state provider
final medicationsProvider = StateNotifierProvider<MedicationsNotifier, AsyncValue<List<MedicationEntry>>>((ref) {
  final repository = ref.watch(medicationsRepositoryProvider);
  return MedicationsNotifier(repository);
});

// Active medications provider for a specific pet
final activeMedicationsProvider = Provider.family<List<MedicationEntry>, String>((ref, petId) {
  final medicationsAsync = ref.watch(medicationsProvider);
  return medicationsAsync.when(
    data: (medications) {
      return medications.where((medication) => medication.petId == petId && medication.isActive).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// All medications provider for a specific pet
final petMedicationsProvider = Provider.family<List<MedicationEntry>, String>((ref, petId) {
  final medicationsAsync = ref.watch(medicationsProvider);
  return medicationsAsync.when(
    data: (medications) {
      return medications.where((medication) => medication.petId == petId).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Medications due today provider
final todaysMedicationsProvider = Provider.family<List<MedicationEntry>, String>((ref, petId) {
  final medicationsAsync = ref.watch(medicationsProvider);
  return medicationsAsync.when(
    data: (medications) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return medications
          .where((medication) => 
              medication.petId == petId &&
              medication.isActive &&
              medication.administrationTimes.isNotEmpty)
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class MedicationsNotifier extends StateNotifier<AsyncValue<List<MedicationEntry>>> {
  final logger = Logger();
  final MedicationRepository _repository;

  MedicationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final medications = await _repository.getAllMedications();
      state = AsyncValue.data(medications);
      logger.i("✅ DEBUG: Loaded ${medications.length} medications in provider");
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR: Failed to load medications in provider: $error");
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Add a new medication
  Future<void> addMedication({
    required String petId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required DateTime startDate,
    DateTime? endDate,
    required String administrationMethod,
    String? notes,
    List<TimeOfDayModel>? administrationTimes,
  }) async {
    try {
      final medication = MedicationEntry(
        id: _uuid.v4(),
        petId: petId,
        medicationName: medicationName,
        dosage: dosage,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        administrationMethod: administrationMethod,
        notes: notes,
        administrationTimes: administrationTimes ?? [],
      );

      await _repository.addMedication(medication);
      await _loadMedications(); // Reload to get updated list
      logger.i("✅ DEBUG: Added medication '${medication.medicationName}' for pet $petId");
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR: Failed to add medication: $error");
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Update an existing medication
  Future<void> updateMedication(MedicationEntry updatedMedication) async {
    try {
      await _repository.updateMedication(updatedMedication);
      await _loadMedications(); // Reload to get updated list
      logger.i("✅ DEBUG: Updated medication '${updatedMedication.medicationName}'");
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR: Failed to update medication: $error");
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Delete a medication
  Future<void> deleteMedication(String medicationId) async {
    try {
      await _repository.deleteMedication(medicationId);
      await _loadMedications(); // Reload to get updated list
      logger.i("✅ DEBUG: Deleted medication with ID $medicationId");
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR: Failed to delete medication: $error");
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Toggle medication active status
  Future<void> toggleMedicationStatus(String medicationId) async {
    try {
      final currentMedications = state.value ?? [];
      final medicationIndex = currentMedications.indexWhere((m) => m.id == medicationId);
      
      if (medicationIndex == -1) {
        throw Exception('Medication not found');
      }

      final medication = currentMedications[medicationIndex];
      final updatedMedication = medication.copyWith(isActive: !medication.isActive);
      
      await _repository.updateMedication(updatedMedication);
      await _loadMedications(); // Reload to get updated list
      logger.i("✅ DEBUG: Toggled medication status for '${medication.medicationName}' to ${updatedMedication.isActive ? 'active' : 'inactive'}");
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR: Failed to toggle medication status: $error");
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Get medications for a specific pet
  Future<List<MedicationEntry>> getMedicationsForPet(String petId) async {
    try {
      return await _repository.getMedicationsByPetId(petId);
    } catch (error) {
      logger.e("🚨 ERROR: Failed to get medications for pet $petId: $error");
      return [];
    }
  }

  // Get active medications for a specific pet
  Future<List<MedicationEntry>> getActiveMedicationsForPet(String petId) async {
    try {
      return await _repository.getActiveMedicationsByPetId(petId);
    } catch (error) {
      logger.e("🚨 ERROR: Failed to get active medications for pet $petId: $error");
      return [];
    }
  }

  // Refresh medications list
  Future<void> refresh() async {
    await _loadMedications();
  }
}
