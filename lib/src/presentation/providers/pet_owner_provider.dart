import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/user_profile.dart';
import '../../domain/models/pet_owner_tier.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../data/repositories/user_profile_repository_impl.dart';

part 'pet_owner_provider.g.dart';

/// Provider for managing the current user's profile (pet owner).
///
/// Handles:
/// - Profile CRUD operations
/// - Tier management (FREE/PREMIUM/LIFETIME)
/// - Pet linking/unlinking
/// - Pet limit enforcement
@riverpod
class PetOwner extends _$PetOwner {
  UserProfileRepository get _repository =>
      ref.read(userProfileRepositoryProvider);

  @override
  Future<UserProfile?> build() async {
    final profile = await _repository.getUserProfile();
    return profile;
  }

  /// Create a new user profile.
  /// Used during initial onboarding or when migrating existing users.
  Future<void> createProfile({
    required String name,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = UserProfile(
        name: name,
        email: email,
        tier: PetOwnerTier.free,
        hasCompletedOnboarding: false,
      );
      await _repository.saveUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update the user profile.
  Future<void> updateProfile({
    String? name,
    String? email,
    String? profilePicturePath,
  }) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    try {
      final updatedProfile = currentProfile.copyWith(
        name: name,
        email: email,
        profilePicturePath: profilePicturePath,
      );
      await _repository.saveUserProfile(updatedProfile);
      state = AsyncValue.data(updatedProfile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Link a pet to the current user.
  Future<bool> linkPet(String petId) async {
    final currentProfile = state.value;
    if (currentProfile == null) return false;

    // Check pet limit before linking
    if (!currentProfile.canAddPet()) {
      return false;
    }

    try {
      final success = await _repository.linkPetToUser(petId);
      if (success) {
        // Refresh state
        ref.invalidateSelf();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Unlink a pet from the current user.
  Future<bool> unlinkPet(String petId) async {
    try {
      final success = await _repository.unlinkPetFromUser(petId);
      if (success) {
        ref.invalidateSelf();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Complete onboarding for the user.
  Future<void> completeOnboarding() async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    try {
      final updatedProfile = currentProfile.copyWith(
        hasCompletedOnboarding: true,
      );
      await _repository.saveUserProfile(updatedProfile);
      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      // Ignore errors for onboarding flag
    }
  }

  /// Refresh the user profile from storage.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Provider that returns true if the user can add more pets.
/// Based on the user's tier and current pet count.
@riverpod
bool canAddMorePets(CanAddMorePetsRef ref) {
  final profileAsync = ref.watch(petOwnerProvider);
  return profileAsync.when(
    data: (profile) => profile?.canAddPet() ?? true,
    loading: () => false, // Don't allow adding while loading
    error: (_, __) => false, // Don't allow adding on error
  );
}

/// Provider that returns the current pet count for the user.
@riverpod
int currentPetCount(CurrentPetCountRef ref) {
  final profileAsync = ref.watch(petOwnerProvider);
  return profileAsync.when(
    data: (profile) => profile?.petIds.length ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// Provider that returns the user's current tier.
@riverpod
PetOwnerTier currentTier(CurrentTierRef ref) {
  final profileAsync = ref.watch(petOwnerProvider);
  return profileAsync.when(
    data: (profile) => profile?.effectiveTier ?? PetOwnerTier.free,
    loading: () => PetOwnerTier.free,
    error: (_, __) => PetOwnerTier.free,
  );
}

/// Provider that returns true if the user has premium features.
@riverpod
bool hasPremiumFeatures(HasPremiumFeaturesRef ref) {
  final tier = ref.watch(currentTierProvider);
  return tier.isPremium;
}

/// Provider that returns the pet limit for the current tier.
/// Returns -1 for unlimited.
@riverpod
int petLimit(PetLimitRef ref) {
  final tier = ref.watch(currentTierProvider);
  return tier.petLimit;
}

/// Provider that returns the number of remaining pet slots.
/// Returns -1 for unlimited.
@riverpod
int remainingPetSlots(RemainingPetSlotsRef ref) {
  final profileAsync = ref.watch(petOwnerProvider);
  return profileAsync.when(
    data: (profile) => profile?.remainingPetSlots ?? 1,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
