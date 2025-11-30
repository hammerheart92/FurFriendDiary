import '../models/vaccination_event.dart';

/// Repository interface for managing vaccination events
abstract class VaccinationRepository {
  /// Get all vaccination events across all pets
  Future<List<VaccinationEvent>> getAllVaccinations();

  /// Get all vaccination events for a specific pet
  Future<List<VaccinationEvent>> getVaccinationsByPetId(String petId);

  /// Get a specific vaccination event by its ID
  Future<VaccinationEvent?> getVaccinationById(String id);

  /// Add a new vaccination event
  Future<void> addVaccination(VaccinationEvent event);

  /// Update an existing vaccination event
  Future<void> updateVaccination(VaccinationEvent event);

  /// Delete a vaccination event by its ID
  Future<void> deleteVaccination(String id);

  /// Get vaccination events within a date range for a specific pet
  Future<List<VaccinationEvent>> getVaccinationsByDateRange(
    String petId,
    DateTime start,
    DateTime end,
  );

  /// Get upcoming vaccinations (due date in the future) for a specific pet
  Future<List<VaccinationEvent>> getUpcomingVaccinations(String petId);

  /// Get overdue vaccinations (due date in the past) for a specific pet
  Future<List<VaccinationEvent>> getOverdueVaccinations(String petId);

  /// Get vaccinations linked to a specific protocol
  Future<List<VaccinationEvent>> getVaccinationsByProtocolId(String protocolId);

  /// Get the most recent vaccination of a specific type for a pet
  Future<VaccinationEvent?> getLastVaccinationByType(
    String petId,
    String vaccineType,
  );
}
