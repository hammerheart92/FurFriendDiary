import '../../models/protocols/treatment_plan.dart';

/// Repository interface for managing treatment plans
///
/// Provides methods to retrieve, save, and delete treatment plans.
/// Treatment plans are veterinary-prescribed care protocols containing
/// multiple tasks. Supports filtering by pet, active status, and completion.
abstract class TreatmentPlanRepository {
  /// Retrieve all treatment plans
  Future<List<TreatmentPlan>> getAll();

  /// Retrieve a specific treatment plan by ID
  Future<TreatmentPlan?> getById(String id);

  /// Retrieve all treatment plans for a specific pet
  Future<List<TreatmentPlan>> getByPetId(String petId);

  /// Retrieve all active treatment plans for a specific pet
  /// Returns plans where isActive = true
  Future<List<TreatmentPlan>> getActiveByPetId(String petId);

  /// Retrieve all inactive treatment plans for a specific pet
  /// Returns plans where isActive = false
  Future<List<TreatmentPlan>> getInactiveByPetId(String petId);

  /// Retrieve all incomplete treatment plans for a specific pet
  /// Returns active plans with incomplete tasks
  Future<List<TreatmentPlan>> getIncompleteByPetId(String petId);

  /// Save a treatment plan (create or update)
  /// Uses the plan's ID as the key
  Future<void> save(TreatmentPlan plan);

  /// Delete a specific treatment plan by ID
  Future<void> delete(String id);

  /// Delete all treatment plans
  /// Use with caution - this will remove all treatment plans
  Future<void> deleteAll();
}
