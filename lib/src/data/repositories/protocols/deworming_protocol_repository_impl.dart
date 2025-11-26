import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../domain/models/protocols/deworming_protocol.dart';
import '../../../domain/repositories/protocols/deworming_protocol_repository.dart';
import '../../local/hive_manager.dart';

part 'deworming_protocol_repository_impl.g.dart';

/// Implementation of DewormingProtocolRepository using Hive
class DewormingProtocolRepositoryImpl implements DewormingProtocolRepository {
  final Box<DewormingProtocol> box;
  final logger = Logger();

  DewormingProtocolRepositoryImpl({required this.box});

  @override
  Future<List<DewormingProtocol>> getAll() async {
    try {
      final protocols = box.values.toList();
      // Sort by name alphabetically
      protocols.sort((a, b) => a.name.compareTo(b.name));
      logger.i(
          "🔍 DEBUG: Retrieved ${protocols.length} deworming protocols from Hive");
      return protocols;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get all deworming protocols: $e");
      rethrow;
    }
  }

  @override
  Future<DewormingProtocol?> getById(String id) async {
    try {
      final protocol = box.get(id);
      if (protocol != null) {
        logger.i(
            "🔍 DEBUG: Found deworming protocol '${protocol.name}' with ID $id");
      } else {
        logger.w("⚠️ DEBUG: No deworming protocol found with ID $id");
      }
      return protocol;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get deworming protocol by ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<List<DewormingProtocol>> getBySpecies(String species) async {
    try {
      final protocols =
          box.values.where((protocol) => protocol.species.toLowerCase() == species.toLowerCase()).toList();
      // Sort by name alphabetically
      protocols.sort((a, b) => a.name.compareTo(b.name));
      logger.i(
          "🔍 DEBUG: Retrieved ${protocols.length} deworming protocols for species '$species'");
      return protocols;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get deworming protocols for species '$species': $e");
      rethrow;
    }
  }

  @override
  Future<List<DewormingProtocol>> getPredefined() async {
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
          "🔍 DEBUG: Retrieved ${protocols.length} predefined deworming protocols");
      return protocols;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get predefined deworming protocols: $e");
      rethrow;
    }
  }

  @override
  Future<List<DewormingProtocol>> getCustom() async {
    try {
      final protocols =
          box.values.where((protocol) => protocol.isCustom).toList();
      // Sort by creation date, newest first
      protocols.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i(
          "🔍 DEBUG: Retrieved ${protocols.length} custom deworming protocols");
      return protocols;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get custom deworming protocols: $e");
      rethrow;
    }
  }

  @override
  Future<void> save(DewormingProtocol protocol) async {
    try {
      await box.put(protocol.id, protocol);
      logger.i(
          "✅ DEBUG: Saved deworming protocol '${protocol.name}' with ID ${protocol.id}");
    } catch (e) {
      logger
          .e("🚨 ERROR: Failed to save deworming protocol '${protocol.name}': $e");
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final protocol = box.get(id);
      await box.delete(id);
      logger.i(
          "✅ DEBUG: Deleted deworming protocol with ID $id${protocol != null ? " ('${protocol.name}')" : ""}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete deworming protocol with ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      final count = box.length;
      await box.clear();
      logger.i(
          "✅ DEBUG: Deleted all deworming protocols (removed $count protocols)");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete all deworming protocols: $e");
      rethrow;
    }
  }
}

@riverpod
DewormingProtocolRepository dewormingProtocolRepository(
    DewormingProtocolRepositoryRef ref) {
  return DewormingProtocolRepositoryImpl(
    box: HiveManager.instance.dewormingProtocolBox,
  );
}
