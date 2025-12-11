import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/pet_owner_tier.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../local/hive_boxes.dart';

part 'user_profile_repository_impl.g.dart';

/// Implementation of UserProfileRepository using Hive app_prefs box.
///
/// Stores the user profile with encryption (using existing app_prefs box).
class UserProfileRepositoryImpl implements UserProfileRepository {
  static const String _profileKey = 'current_user_profile';
  final _logger = Logger();

  @override
  Future<UserProfile?> getUserProfile() async {
    try {
      final box = HiveBoxes.getAppPrefs();
      final profile = box.get(_profileKey) as UserProfile?;
      return profile;
    } catch (e) {
      _logger.e('Error getting user profile: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final box = HiveBoxes.getAppPrefs();
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      await box.put(_profileKey, updatedProfile);
      await box.flush();
    } catch (e) {
      _logger.e('Error saving user profile: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfile?> updateUserProfile({
    String? name,
    String? email,
    String? profilePicturePath,
  }) async {
    try {
      final currentProfile = await getUserProfile();
      if (currentProfile == null) return null;

      final updatedProfile = currentProfile.copyWith(
        name: name,
        email: email,
        profilePicturePath: profilePicturePath,
      );

      await saveUserProfile(updatedProfile);
      return updatedProfile;
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      return null;
    }
  }

  @override
  Future<void> deleteUserProfile() async {
    try {
      final box = HiveBoxes.getAppPrefs();
      await box.delete(_profileKey);
      await box.flush();
    } catch (e) {
      _logger.e('Error deleting user profile: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasUserProfile() async {
    final profile = await getUserProfile();
    return profile != null;
  }

  @override
  Future<bool> linkPetToUser(String petId) async {
    try {
      final profile = await getUserProfile();
      if (profile == null) return false;

      // Check if pet is already linked
      if (profile.petIds.contains(petId)) return true;

      // Add pet to the list
      final updatedPetIds = List<String>.from(profile.petIds)..add(petId);
      final updatedProfile = profile.copyWith(petIds: updatedPetIds);
      await saveUserProfile(updatedProfile);
      return true;
    } catch (e) {
      _logger.e('Error linking pet to user: $e');
      return false;
    }
  }

  @override
  Future<bool> unlinkPetFromUser(String petId) async {
    try {
      final profile = await getUserProfile();
      if (profile == null) return false;

      // Remove pet from the list
      final updatedPetIds = List<String>.from(profile.petIds)..remove(petId);
      final updatedProfile = profile.copyWith(petIds: updatedPetIds);
      await saveUserProfile(updatedProfile);
      return true;
    } catch (e) {
      _logger.e('Error unlinking pet from user: $e');
      return false;
    }
  }

  @override
  Future<bool> canAddMorePets() async {
    final profile = await getUserProfile();
    if (profile == null) {
      // No profile yet - user can create first pet (will auto-create profile)
      return true;
    }
    return profile.canAddPet();
  }

  @override
  Future<int> getPetCount() async {
    final profile = await getUserProfile();
    return profile?.petIds.length ?? 0;
  }

  /// Create a default user profile for first-time users.
  Future<UserProfile> createDefaultProfile({
    required String name,
    String? email,
  }) async {
    final profile = UserProfile(
      name: name,
      email: email,
      tier: PetOwnerTier.free,
      hasCompletedOnboarding: false,
    );
    await saveUserProfile(profile);
    return profile;
  }

  /// Upgrade user to premium tier.
  Future<UserProfile?> upgradeToPremium({
    required DateTime expiryDate,
  }) async {
    final profile = await getUserProfile();
    if (profile == null) return null;

    final updatedProfile = profile.copyWith(
      tier: PetOwnerTier.premium,
      premiumExpiryDate: expiryDate,
    );
    await saveUserProfile(updatedProfile);
    return updatedProfile;
  }

  /// Upgrade user to lifetime tier.
  Future<UserProfile?> upgradeToLifetime() async {
    final profile = await getUserProfile();
    if (profile == null) return null;

    final updatedProfile = profile.copyWithNullExpiry(
      tier: PetOwnerTier.lifetime,
    );
    await saveUserProfile(updatedProfile);
    return updatedProfile;
  }

  /// Downgrade user to free tier (e.g., subscription expired).
  Future<UserProfile?> downgradeToFree() async {
    final profile = await getUserProfile();
    if (profile == null) return null;

    final updatedProfile = profile.copyWithNullExpiry(
      tier: PetOwnerTier.free,
    );
    await saveUserProfile(updatedProfile);
    return updatedProfile;
  }
}

/// Riverpod provider for UserProfileRepository
@riverpod
UserProfileRepository userProfileRepository(UserProfileRepositoryRef ref) {
  return UserProfileRepositoryImpl();
}
