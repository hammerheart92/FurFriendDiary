import '../../models/protocols/deworming_protocol.dart';

/// Repository interface for managing deworming protocols
///
/// Provides methods to retrieve, save, and delete deworming protocols.
/// Protocols can be predefined (standard veterinary schedules) or custom
/// (user-created). Supports filtering by species and protocol type.
abstract class DewormingProtocolRepository {
  /// Retrieve all deworming protocols
  Future<List<DewormingProtocol>> getAll();

  /// Retrieve a specific protocol by ID
  Future<DewormingProtocol?> getById(String id);

  /// Retrieve all protocols for a specific species
  /// [species]: 'dog', 'cat', or 'other'
  Future<List<DewormingProtocol>> getBySpecies(String species);

  /// Retrieve all predefined (built-in) protocols
  /// Returns protocols where isCustom = false
  Future<List<DewormingProtocol>> getPredefined();

  /// Retrieve all custom (user-created) protocols
  /// Returns protocols where isCustom = true
  Future<List<DewormingProtocol>> getCustom();

  /// Save a deworming protocol (create or update)
  /// Uses the protocol's ID as the key
  Future<void> save(DewormingProtocol protocol);

  /// Delete a specific protocol by ID
  Future<void> delete(String id);

  /// Delete all deworming protocols
  /// Use with caution - this will remove all protocols including predefined ones
  Future<void> deleteAll();
}
