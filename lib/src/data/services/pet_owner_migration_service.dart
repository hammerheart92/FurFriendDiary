import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/pet_owner_tier.dart';
import '../local/hive_boxes.dart';
import '../repositories/pet_profile_repository.dart';

final _logger = Logger();

/// One-time migration service to create UserProfile for existing users.
///
/// This migration runs once on app startup for users upgrading to v1.3.3.
/// It creates a default UserProfile and links all existing pets to it.
///
/// Migration steps:
/// 1. Check if migration has already run (SharedPreferences flag)
/// 2. If not migrated:
///    - Create default UserProfile with FREE tier
///    - Get all existing pets from pet_profiles box
///    - Link each pet to the user profile
///    - Set migration flag
///
/// Rollback strategy:
/// - If migration fails at any step:
///   - Delete created UserProfile (if any)
///   - Don't set migration flag
///   - Allow retry on next app start
class PetOwnerMigrationService {
  static const String _migrationKey = 'pet_owner_migration_v1_3_3';
  static const String _profileKey = 'current_user_profile';

  /// Run migration if not already completed.
  /// Safe to call multiple times - will only run once.
  /// Returns true if migration succeeded or was already done.
  static Future<bool> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRun = prefs.getBool(_migrationKey) ?? false;

    if (hasRun) {
      _logger.i('[PET_OWNER_MIGRATION] Already migrated, skipping');
      return true;
    }

    _logger.i('[PET_OWNER_MIGRATION] Starting migration...');

    try {
      final result = await _performMigration();
      if (result) {
        await prefs.setBool(_migrationKey, true);
        _logger.i('[PET_OWNER_MIGRATION] Completed successfully!');
      }
      return result;
    } catch (e, stackTrace) {
      _logger.e('[PET_OWNER_MIGRATION] Failed: $e',
          error: e, stackTrace: stackTrace);
      // Don't mark as complete if migration fails
      // Will retry on next app launch
      return false;
    }
  }

  /// Perform the actual migration.
  /// Returns true if successful, false otherwise.
  static Future<bool> _performMigration() async {
    UserProfile? createdProfile;

    try {
      final appPrefsBox = HiveBoxes.getAppPrefs();

      // Step 1: Check if UserProfile already exists (shouldn't, but be safe)
      final existingProfile = appPrefsBox.get(_profileKey) as UserProfile?;
      if (existingProfile != null) {
        _logger.i('[PET_OWNER_MIGRATION] UserProfile already exists, '
            'checking pet links...');
        // Profile exists - just ensure pets are linked
        return await _linkExistingPets(existingProfile);
      }

      // Step 2: Get all existing pets
      final petRepository = PetProfileRepository();
      final allPets = petRepository.getAll();
      _logger.d('[PET_OWNER_MIGRATION] Found ${allPets.length} existing pets');

      // Step 3: Create pet ID list
      final petIds = allPets.map((pet) => pet.id).toList();

      // Step 4: Create default UserProfile with linked pets
      createdProfile = UserProfile(
        name: 'Pet Owner', // Default name, user can update later
        tier: PetOwnerTier.free,
        hasCompletedOnboarding: allPets.isNotEmpty, // If they have pets, they've onboarded
        petIds: petIds,
      );

      // Step 5: Save the profile
      await appPrefsBox.put(_profileKey, createdProfile);
      await appPrefsBox.flush();

      _logger.i('[PET_OWNER_MIGRATION] Created UserProfile with '
          '${petIds.length} linked pets');

      // Step 6: Verify save was successful
      final savedProfile = appPrefsBox.get(_profileKey) as UserProfile?;
      if (savedProfile == null) {
        throw Exception('Failed to verify saved UserProfile');
      }

      return true;
    } catch (e) {
      _logger.e('[PET_OWNER_MIGRATION] Error during migration: $e');

      // Rollback: Delete the profile if it was created
      if (createdProfile != null) {
        try {
          final appPrefsBox = HiveBoxes.getAppPrefs();
          await appPrefsBox.delete(_profileKey);
          await appPrefsBox.flush();
          _logger.i('[PET_OWNER_MIGRATION] Rolled back - deleted profile');
        } catch (rollbackError) {
          _logger.e('[PET_OWNER_MIGRATION] Rollback failed: $rollbackError');
        }
      }

      return false;
    }
  }

  /// Link existing pets to an existing profile.
  /// Used when profile exists but pets might not be linked.
  static Future<bool> _linkExistingPets(UserProfile profile) async {
    try {
      final petRepository = PetProfileRepository();
      final allPets = petRepository.getAll();
      final existingPetIds = Set<String>.from(profile.petIds);

      // Find pets not yet linked
      final newPetIds = <String>[];
      for (final pet in allPets) {
        if (!existingPetIds.contains(pet.id)) {
          newPetIds.add(pet.id);
        }
      }

      if (newPetIds.isEmpty) {
        _logger.i('[PET_OWNER_MIGRATION] All pets already linked');
        return true;
      }

      // Add new pet IDs
      final updatedPetIds = List<String>.from(profile.petIds)..addAll(newPetIds);
      final updatedProfile = profile.copyWith(
        petIds: updatedPetIds,
        updatedAt: DateTime.now(),
      );

      // Save updated profile
      final appPrefsBox = HiveBoxes.getAppPrefs();
      await appPrefsBox.put(_profileKey, updatedProfile);
      await appPrefsBox.flush();

      _logger.i('[PET_OWNER_MIGRATION] Linked ${newPetIds.length} additional pets');
      return true;
    } catch (e) {
      _logger.e('[PET_OWNER_MIGRATION] Failed to link existing pets: $e');
      return false;
    }
  }

  /// Check if migration has been completed.
  static Future<bool> hasMigrated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationKey) ?? false;
  }

  /// Force re-run migration (for testing/development only).
  /// Call this to reset the migration flag and allow it to run again.
  /// WARNING: This does NOT delete the UserProfile, only resets the flag.
  static Future<void> resetMigration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationKey);
    _logger.i('[PET_OWNER_MIGRATION] Reset flag - will run on next launch');
  }

  /// Force re-run migration with profile cleanup (for testing only).
  /// WARNING: This DELETES the UserProfile and resets the flag.
  /// Use with extreme caution - intended for development/testing only.
  static Future<void> resetMigrationWithCleanup() async {
    try {
      // Delete the profile
      final appPrefsBox = HiveBoxes.getAppPrefs();
      await appPrefsBox.delete(_profileKey);
      await appPrefsBox.flush();
      _logger.i('[PET_OWNER_MIGRATION] Deleted UserProfile');
    } catch (e) {
      _logger.e('[PET_OWNER_MIGRATION] Failed to delete profile: $e');
    }

    // Reset the flag
    await resetMigration();
  }
}
