import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../domain/models/protocols/reminder_config.dart';
import '../../../domain/repositories/protocols/reminder_config_repository.dart';
import '../../local/hive_manager.dart';

part 'reminder_config_repository_impl.g.dart';

/// Implementation of ReminderConfigRepository using Hive
class ReminderConfigRepositoryImpl implements ReminderConfigRepository {
  final Box<ReminderConfig> box;
  final logger = Logger();

  ReminderConfigRepositoryImpl({required this.box});

  @override
  Future<List<ReminderConfig>> getAll() async {
    try {
      final configs = box.values.toList();
      // Sort by creation date, newest first
      configs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i(
          "🔍 DEBUG: Retrieved ${configs.length} reminder configurations from Hive");
      return configs;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get all reminder configurations: $e");
      rethrow;
    }
  }

  @override
  Future<ReminderConfig?> getById(String id) async {
    try {
      final config = box.get(id);
      if (config != null) {
        logger.i(
            "🔍 DEBUG: Found reminder config for eventType '${config.eventType}' with ID $id");
      } else {
        logger.w("⚠️ DEBUG: No reminder configuration found with ID $id");
      }
      return config;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get reminder configuration by ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReminderConfig>> getByPetId(String petId) async {
    try {
      final configs =
          box.values.where((config) => config.petId == petId).toList();
      // Sort by event type alphabetically
      configs.sort((a, b) => a.eventType.compareTo(b.eventType));
      logger.i(
          "🔍 DEBUG: Retrieved ${configs.length} reminder configurations for pet $petId");
      return configs;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get reminder configurations for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReminderConfig>> getEnabledByPetId(String petId) async {
    try {
      final configs = box.values
          .where((config) => config.petId == petId && config.isEnabled)
          .toList();
      // Sort by event type alphabetically
      configs.sort((a, b) => a.eventType.compareTo(b.eventType));
      logger.i(
          "🔍 DEBUG: Retrieved ${configs.length} enabled reminder configurations for pet $petId");
      return configs;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get enabled reminder configurations for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReminderConfig>> getDisabledByPetId(String petId) async {
    try {
      final configs = box.values
          .where((config) => config.petId == petId && !config.isEnabled)
          .toList();
      // Sort by event type alphabetically
      configs.sort((a, b) => a.eventType.compareTo(b.eventType));
      logger.i(
          "🔍 DEBUG: Retrieved ${configs.length} disabled reminder configurations for pet $petId");
      return configs;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get disabled reminder configurations for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReminderConfig>> getByEventType(String eventType) async {
    try {
      final configs = box.values
          .where((config) => config.eventType == eventType)
          .toList();
      // Sort by creation date, newest first
      configs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i(
          "🔍 DEBUG: Retrieved ${configs.length} reminder configurations for eventType '$eventType'");
      return configs;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get reminder configurations for eventType '$eventType': $e");
      rethrow;
    }
  }

  @override
  Future<List<ReminderConfig>> getByPetIdAndEventType(
      String petId, String eventType) async {
    try {
      final configs = box.values
          .where((config) =>
              config.petId == petId && config.eventType == eventType)
          .toList();
      // Sort by creation date, newest first
      configs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i(
          "🔍 DEBUG: Retrieved ${configs.length} reminder configurations for pet $petId and eventType '$eventType'");
      return configs;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get reminder configurations for pet $petId and eventType '$eventType': $e");
      rethrow;
    }
  }

  @override
  Future<void> save(ReminderConfig config) async {
    try {
      await box.put(config.id, config);
      logger.i(
          "✅ DEBUG: Saved reminder config for eventType '${config.eventType}' with ID ${config.id} (${config.reminderDays.length} reminder days)");
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to save reminder config for eventType '${config.eventType}': $e");
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final config = box.get(id);
      await box.delete(id);
      logger.i(
          "✅ DEBUG: Deleted reminder configuration with ID $id${config != null ? " (eventType: '${config.eventType}')" : ""}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete reminder configuration with ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      final count = box.length;
      await box.clear();
      logger.i(
          "✅ DEBUG: Deleted all reminder configurations (removed $count configs)");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete all reminder configurations: $e");
      rethrow;
    }
  }
}

@riverpod
ReminderConfigRepository reminderConfigRepository(
    ReminderConfigRepositoryRef ref) {
  return ReminderConfigRepositoryImpl(
    box: HiveManager.instance.reminderConfigBox,
  );
}
