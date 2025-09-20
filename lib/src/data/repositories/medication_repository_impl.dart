import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/repositories/medication_repository.dart';
import '../local/hive_boxes.dart';

part 'medication_repository_impl.g.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  @override
  Future<List<MedicationEntry>> getAllMedications() async {
    final box = HiveBoxes.getMedications();
    return box.values.toList();
  }

  @override
  Future<List<MedicationEntry>> getMedicationsByPetId(String petId) async {
    final box = HiveBoxes.getMedications();
    return box.values.where((medication) => medication.petId == petId).toList();
  }

  @override
  Future<void> addMedication(MedicationEntry medication) async {
    final box = HiveBoxes.getMedications();
    await box.put(medication.id, medication);
  }

  @override
  Future<void> updateMedication(MedicationEntry medication) async {
    final box = HiveBoxes.getMedications();
    await box.put(medication.id, medication);
  }

  @override
  Future<void> deleteMedication(String id) async {
    final box = HiveBoxes.getMedications();
    await box.delete(id);
  }

  @override
  Future<MedicationEntry?> getMedicationById(String id) async {
    final box = HiveBoxes.getMedications();
    return box.get(id);
  }

  @override
  Future<List<MedicationEntry>> getUpcomingMedications(String petId) async {
    final box = HiveBoxes.getMedications();
    final now = DateTime.now();
    return box.values
        .where((medication) => 
            medication.petId == petId &&
            !medication.isCompleted &&
            (medication.nextDose?.isAfter(now) ?? false))
        .toList();
  }

  @override
  Future<List<MedicationEntry>> getOverdueMedications(String petId) async {
    final box = HiveBoxes.getMedications();
    final now = DateTime.now();
    return box.values
        .where((medication) => 
            medication.petId == petId &&
            !medication.isCompleted &&
            (medication.nextDose?.isBefore(now) ?? false))
        .toList();
  }
}

@riverpod
MedicationRepository medicationRepository(MedicationRepositoryRef ref) {
  return MedicationRepositoryImpl();
}
