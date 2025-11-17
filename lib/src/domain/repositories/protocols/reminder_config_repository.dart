import '../../models/protocols/reminder_config.dart';

/// Repository interface for managing reminder configurations
///
/// Provides methods to retrieve, save, and delete reminder configurations.
/// Configurations define how notifications are sent for various pet care events
/// (vaccinations, deworming, appointments, medications, custom). Supports
/// filtering by pet, event type, and enabled status.
abstract class ReminderConfigRepository {
  /// Retrieve all reminder configurations
  Future<List<ReminderConfig>> getAll();

  /// Retrieve a specific reminder configuration by ID
  Future<ReminderConfig?> getById(String id);

  /// Retrieve all reminder configurations for a specific pet
  Future<List<ReminderConfig>> getByPetId(String petId);

  /// Retrieve all enabled reminder configurations for a specific pet
  /// Returns configs where isEnabled = true
  Future<List<ReminderConfig>> getEnabledByPetId(String petId);

  /// Retrieve all disabled reminder configurations for a specific pet
  /// Returns configs where isEnabled = false
  Future<List<ReminderConfig>> getDisabledByPetId(String petId);

  /// Retrieve reminder configurations by event type
  /// [eventType]: 'vaccination', 'deworming', 'appointment', 'medication', or 'custom'
  Future<List<ReminderConfig>> getByEventType(String eventType);

  /// Retrieve reminder configurations by pet and event type
  /// Useful for checking if a specific reminder type is configured for a pet
  Future<List<ReminderConfig>> getByPetIdAndEventType(
      String petId, String eventType);

  /// Save a reminder configuration (create or update)
  /// Uses the config's ID as the key
  Future<void> save(ReminderConfig config);

  /// Delete a specific reminder configuration by ID
  Future<void> delete(String id);

  /// Delete all reminder configurations
  /// Use with caution - this will remove all reminder configurations
  Future<void> deleteAll();
}
