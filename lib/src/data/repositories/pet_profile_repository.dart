import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import '../local/hive_boxes.dart';

class PetProfileRepository {
  final logger = Logger();
  static const String _settingsBoxName = 'app_prefs';
  
  Box<PetProfile>? _profileBox;
  Box? _settingsBox;

  Box<PetProfile> get _profiles => _profileBox ?? HiveBoxes.getPetProfiles();
  Box get _settings => _settingsBox ?? HiveBoxes.getAppPrefs();

  // Initialize boxes - called from InitService
  Future<void> init() async {
    logger.i("🔍 DEBUG: PetProfileRepository.init() called");
    
    try {
      // Use HiveBoxes to get already opened boxes
      _profileBox = HiveBoxes.getPetProfiles();
      logger.i("🔍 DEBUG: Got pet profiles box successfully");
      
      _settingsBox = HiveBoxes.getAppPrefs();
      logger.i("🔍 DEBUG: Got app prefs box successfully");
      
      logger.i("🔍 DEBUG: PetProfileRepository initialization completed");
    } catch (e) {
      logger.e("🚨 ERROR: PetProfileRepository.init() failed: $e");
      rethrow;
    }
  }

  // Get all profiles
  List<PetProfile> getAll() {
    try {
      return _profiles.values.toList();
    } catch (e) {
      logger.e("🚨 ERROR in getAll: $e");
      return [];
    }
  }

  // Get active profiles only
  List<PetProfile> getActive() {
    try {
      return _profiles.values.where((p) => p.isActive).toList();
    } catch (e) {
      logger.e("🚨 ERROR in getActive: $e");
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
        }
      }
      
      // Activate the selected profile
      final targetProfile = _profiles.get(id);
      if (targetProfile != null) {
        final updated = targetProfile.copyWith(isActive: true);
        await _profiles.put(id, updated);
        await _settings.put('hasCompletedSetup', true);
      }
    } catch (e) {
      logger.e("🚨 ERROR in setActive: $e");
      rethrow;
    }
  }

  // Add new profile
  Future<void> add(PetProfile profile) async {
    logger.i("🔍 DEBUG: PetProfileRepository.add() called for: ${profile.name}");
    
    try {
      logger.d("🔍 DEBUG: Attempting to get pet_profiles box");
      final box = _profiles; // This will call HiveBoxes.getPetProfiles() with defensive checks
      
      logger.d("🔍 DEBUG: Box retrieved successfully. IsOpen: ${box.isOpen}");
      logger.d("🔍 DEBUG: Current box length: ${box.length}");
      
      // If this is the first profile, make it active
      final isFirstProfile = box.isEmpty;
      logger.d("🔍 DEBUG: Is first profile: $isFirstProfile");
      
      final profileToSave = isFirstProfile 
          ? profile.copyWith(isActive: true) 
          : profile;
      
      logger.d("🔍 DEBUG: About to save profile with ID: ${profile.id}");
      logger.d("🔍 DEBUG: Profile to save - Name: ${profileToSave.name}, Active: ${profileToSave.isActive}");
      
      await box.put(profile.id, profileToSave);
      
      logger.i("🔍 DEBUG: Profile saved successfully!");
      logger.d("🔍 DEBUG: Box now contains ${box.length} profiles");
      
      // Verify the save
      final savedProfile = box.get(profile.id);
      logger.d("🔍 DEBUG: Verification - saved profile: ${savedProfile?.name}");
      
      if (isFirstProfile) {
        await _settings.put('hasCompletedSetup', true);
        logger.i("🔍 DEBUG: Setup completion flag set to true");
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
  }

  // Delete profile
  Future<void> delete(String id) async {
    try {
      final profile = _profiles.get(id);
      if (profile == null) return;
      
      await _profiles.delete(id);
      
      // If we deleted the active profile, activate another one if available
      if (profile.isActive && _profiles.isNotEmpty) {
        final firstProfile = _profiles.values.first;
        await setActive(firstProfile.id);
      } else if (_profiles.isEmpty) {
        // No profiles left, mark setup as incomplete
        await _settings.put('hasCompletedSetup', false);
      }
    } catch (e) {
      logger.e("🚨 ERROR in delete: $e");
      rethrow;
    }
  }

  // Get current active profile
  PetProfile? getCurrentProfile() {
    try {
      return _profiles.values.firstWhere((p) => p.isActive);
    } catch (e) {
      // No active profile found, return first available
      return _profiles.isNotEmpty ? _profiles.values.first : null;
    }
  }

  // Check if setup has been completed
  bool hasCompletedSetup() {
    return _settings.get('hasCompletedSetup', defaultValue: false);
  }
}
