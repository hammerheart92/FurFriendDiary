import '../models/medication_entry.dart';

abstract class MedicationRepository {
  Future<List<MedicationEntry>> getAllMedications();
  Future<List<MedicationEntry>> getMedicationsByPetId(String petId);
  Future<void> addMedication(MedicationEntry medication);
  Future<void> updateMedication(MedicationEntry medication);
  Future<void> deleteMedication(String id);
  Future<MedicationEntry?> getMedicationById(String id);
  Future<List<MedicationEntry>> getUpcomingMedications(String petId);
  Future<List<MedicationEntry>> getOverdueMedications(String petId);
}
