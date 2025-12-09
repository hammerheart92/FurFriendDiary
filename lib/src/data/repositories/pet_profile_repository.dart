import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import '../local/hive_boxes.dart';
import '../local/hive_manager.dart';

class PetProfileRepository {
  final logger = Logger();
  static const String _settingsBoxName = 'app_prefs';

  Box<PetProfile>? _profileBox;
  Box? _settingsBox;

  Box<PetProfile> get _profiles => _profileBox ?? HiveBoxes.getPetProfiles();
  Box get _settings => _settingsBox ?? HiveBoxes.getAppPrefs();

  // Initialize boxes - called from InitService
  Future<void> init() async {
    try {
      // Use HiveBoxes to get already opened boxes
      _profileBox = HiveBoxes.getPetProfiles();
      _settingsBox = HiveBoxes.getAppPrefs();
    } catch (e) {
      logger.e("🚨 ERROR: PetProfileRepository.init() failed: $e");
      rethrow;
    }
  }

  // Get all profiles
  List<PetProfile> getAll() {
    try {
      final pets = _profiles.values.toList();
      return pets;
    } catch (e, stackTrace) {
      logger.e("🚨 ERROR in getAll: $e");
      logger.e("🚨 Stack trace: $stackTrace");
      return [];
    }
  }

  // Get active profiles only
  List<PetProfile> getActive() {
    try {
      final active = _profiles.values.where((p) => p.isActive).toList();
      return active;
    } catch (e, stackTrace) {
      logger.e("🚨 ERROR in getActive: $e");
      logger.e("🚨 Stack trace: $stackTrace");
      return [];
    }
  }

  // Set a profile as active (ensures only one active at a time)
  Future<void> setActive(String id) async {
    try {
      // Deactivate all profiles first
      for (final profile in _profiles.values) {
        if (profile.isActive) {
          final updated = profile.copyWith(isActive: false);
          await _profiles.put(profile.id, updated);
          await _profiles.flush(); // CRITICAL FIX: Flush to disk immediately
        }
      }

      // Activate the selected profile
      final targetProfile = _profiles.get(id);
      if (targetProfile != null) {
        final updated = targetProfile.copyWith(isActive: true);
        await _profiles.put(id, updated);
        await _profiles.flush(); // CRITICAL FIX: Flush to disk immediately
        await _settings.put('hasCompletedSetup', true);
        await _settings.flush(); // CRITICAL FIX: Flush to disk immediately
      }
    } catch (e) {
      logger.e("🚨 ERROR in setActive: $e");
      rethrow;
    }
  }

  // Add new profile
  Future<void> add(PetProfile profile) async {
    try {
      final box =
          _profiles; // This will call HiveBoxes.getPetProfiles() with defensive checks

      // If this is the first profile, make it active
      final isFirstProfile = box.isEmpty;

      final profileToSave =
          isFirstProfile ? profile.copyWith(isActive: true) : profile;

      await box.put(profile.id, profileToSave);
      await box.flush(); // CRITICAL FIX: Flush to disk immediately

      // DIAGNOSTIC: Verify data persistence right after saving
      await HiveManager.instance.verifyDataPersistence();

      if (isFirstProfile) {
        await _settings.put('hasCompletedSetup', true);
        await _settings.flush(); // CRITICAL FIX: Flush to disk immediately
      }
    } catch (e) {
      logger.e("🚨 ERROR: addPetProfile failed: $e");
      logger.e("🚨 ERROR: Error type: ${e.runtimeType}");
      rethrow;
    }
  }

  // Update existing profile
  Future<void> update(PetProfile profile) async {
    final updated = profile.copyWith(updatedAt: DateTime.now());
    await _profiles.put(profile.id, updated);
    await _profiles.flush(); // CRITICAL FIX: Flush to disk immediately
  }

  // Delete profile
  Future<void> delete(String id) async {
    try {
      final profile = _profiles.get(id);
      if (profile == null) return;

      await _profiles.delete(id);
      await _profiles.flush(); // CRITICAL FIX: Flush to disk immediately

      // If we deleted the active profile, activate another one if available
      if (profile.isActive && _profiles.isNotEmpty) {
        final firstProfile = _profiles.values.first;
        await setActive(firstProfile.id);
      } else if (_profiles.isEmpty) {
        // No profiles left, mark setup as incomplete
        await _settings.put('hasCompletedSetup', false);
        await _settings.flush(); // CRITICAL FIX: Flush to disk immediately
      }
    } catch (e) {
      logger.e("🚨 ERROR in delete: $e");
      rethrow;
    }
  }

  // Get current active profile
  PetProfile? getCurrentProfile() {
    try {
      final active = _profiles.values.firstWhere((p) => p.isActive);
      return active;
    } catch (e) {
      // No active profile found, return first available
      if (_profiles.isNotEmpty) {
        final first = _profiles.values.first;
        return first;
      }
      return null;
    }
  }

  // Check if setup has been completed
  bool hasCompletedSetup() {
    return _settings.get('hasCompletedSetup', defaultValue: false);
  }
}
