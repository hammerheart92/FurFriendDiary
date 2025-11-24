import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../domain/models/protocols/vaccination_protocol.dart';
import '../../../domain/repositories/protocols/vaccination_protocol_repository.dart';
import '../../local/hive_manager.dart';

part 'vaccination_protocol_repository_impl.g.dart';

/// Implementation of VaccinationProtocolRepository using Hive
class VaccinationProtocolRepositoryImpl
    implements VaccinationProtocolRepository {
  final Box<VaccinationProtocol> box;
  final logger = Logger();

  VaccinationProtocolRepositoryImpl({required this.box});

  @override
  Future<List<VaccinationProtocol>> getAll() async {
    try {
      final protocols = box.values.toList();
      // Sort by name alphabetically
      protocols.sort((a, b) => a.name.compareTo(b.name));
      logger.i(
          "🔍 DEBUG: Retrieved ${protocols.length} vaccination protocols from Hive");
      return protocols;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get all vaccination protocols: $e");
      rethrow;
    }
  }

  @override
  Future<VaccinationProtocol?> getById(String id) async {
    try {
      final protocol = box.get(id);
      if (protocol != null) {
        logger.i("🔍 DEBUG: Found vaccination protocol '${protocol.name}' with ID $id");
      } else {
        logger.w("⚠️ DEBUG: No vaccination protocol found with ID $id");
      }
      return protocol;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get vaccination protocol by ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<List<VaccinationProtocol>> getBySpecies(String species) async {
    try {
      // CRITICAL FIX: Case-insensitive comparison
      // JSON has "dog"/"cat" (lowercase), but UI may pass "Dog"/"Cat" (capitalized)
      final speciesLower = species.toLowerCase();
      final protocols = box.values
          .where((protocol) => protocol.species.toLowerCase() == speciesLower)
          .toList();

      // Sort by name alphabetically
      protocols.sort((a, b) => a.name.compareTo(b.name));
      return protocols;
    } catch (e) {
      logger.e(
          "ERROR: Failed to get vaccination protocols for species '$species': $e");
      rethrow;
    }
  }

  @override
  Future<List<VaccinationProtocol>> getPredefined() async {
    try {
      final protocols =
          box.values.where((protocol) => !protocol.isCustom).toList();
      // Sort by species first, then by name
      protocols.sort((a, b) {
        final speciesCompare = a.species.compareTo(b.species);
        if (speciesCompare != 0) return speciesCompare;
        return a.name.compareTo(b.name);
      });
      logger.i(
          "🔍 DEBUG: Retrieved ${protocols.length} predefined vaccination protocols");
      return protocols;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get predefined vaccination protocols: $e");
      rethrow;
    }
  }

  @override
  Future<List<VaccinationProtocol>> getCustom() async {
    try {
      final protocols =
          box.values.where((protocol) => protocol.isCustom).toList();
      // Sort by creation date, newest first
      protocols.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i(
          "🔍 DEBUG: Retrieved ${protocols.length} custom vaccination protocols");
      return protocols;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get custom vaccination protocols: $e");
      rethrow;
    }
  }

  @override
  Future<void> save(VaccinationProtocol protocol) async {
    try {
      await box.put(protocol.id, protocol);
      logger.i(
          "✅ DEBUG: Saved vaccination protocol '${protocol.name}' with ID ${protocol.id}");
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to save vaccination protocol '${protocol.name}': $e");
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final protocol = box.get(id);
      await box.delete(id);
      logger.i(
          "✅ DEBUG: Deleted vaccination protocol with ID $id${protocol != null ? " ('${protocol.name}')" : ""}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete vaccination protocol with ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      final count = box.length;
      await box.clear();
      logger.i(
          "✅ DEBUG: Deleted all vaccination protocols (removed $count protocols)");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete all vaccination protocols: $e");
      rethrow;
    }
  }
}

@riverpod
VaccinationProtocolRepository vaccinationProtocolRepository(
    VaccinationProtocolRepositoryRef ref) {
  return VaccinationProtocolRepositoryImpl(
    box: HiveManager.instance.vaccinationProtocolBox,
  );
}
