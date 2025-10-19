import '../models/medication_entry.dart';

abstract class MedicationRepository {
  Future<List<MedicationEntry>> getAllMedications();
  Future<List<MedicationEntry>> getMedicationsByPetId(String petId);
  Future<List<MedicationEntry>> getActiveMedicationsByPetId(String petId);
  Future<List<MedicationEntry>> getInactiveMedicationsByPetId(String petId);
  Future<void> addMedication(MedicationEntry medication);
  Future<void> updateMedication(MedicationEntry medication);
  Future<void> deleteMedication(String id);
  Future<MedicationEntry?> getMedicationById(String id);
  Future<List<MedicationEntry>> getMedicationsByDateRange(
      String petId, DateTime start, DateTime end);

  // Inventory management methods
  Future<void> updateStock(String medicationId, int newQuantity);
  Future<void> addStock(String medicationId, int quantity);
  Future<void> recordDosageGiven(String medicationId, int dosageUnits);
  List<MedicationEntry> getLowStockMedications(String petId);
  int? getDaysUntilEmpty(MedicationEntry medication);
}
