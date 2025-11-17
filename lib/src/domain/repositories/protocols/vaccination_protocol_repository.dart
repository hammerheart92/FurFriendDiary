import '../../models/protocols/vaccination_protocol.dart';

/// Repository interface for managing vaccination protocols
///
/// Provides methods to retrieve, save, and delete vaccination protocols.
/// Protocols can be predefined (standard veterinary schedules) or custom
/// (user-created). Supports filtering by species and protocol type.
abstract class VaccinationProtocolRepository {
  /// Retrieve all vaccination protocols
  Future<List<VaccinationProtocol>> getAll();

  /// Retrieve a specific protocol by ID
  Future<VaccinationProtocol?> getById(String id);

  /// Retrieve all protocols for a specific species
  /// [species]: 'dog', 'cat', or 'other'
  Future<List<VaccinationProtocol>> getBySpecies(String species);

  /// Retrieve all predefined (built-in) protocols
  /// Returns protocols where isCustom = false
  Future<List<VaccinationProtocol>> getPredefined();

  /// Retrieve all custom (user-created) protocols
  /// Returns protocols where isCustom = true
  Future<List<VaccinationProtocol>> getCustom();

  /// Save a vaccination protocol (create or update)
  /// Uses the protocol's ID as the key
  Future<void> save(VaccinationProtocol protocol);

  /// Delete a specific protocol by ID
  Future<void> delete(String id);

  /// Delete all vaccination protocols
  /// Use with caution - this will remove all protocols including predefined ones
  Future<void> deleteAll();
}
