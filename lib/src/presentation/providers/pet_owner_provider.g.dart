// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_owner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$canAddMorePetsHash() => r'555b3f7604f28ab8edf42cdde6ab5f5d8092ac4b';

/// Provider that returns true if the user can add more pets.
/// Based on the user's tier and current pet count.
///
/// Copied from [canAddMorePets].
@ProviderFor(canAddMorePets)
final canAddMorePetsProvider = AutoDisposeProvider<bool>.internal(
  canAddMorePets,
  name: r'canAddMorePetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canAddMorePetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CanAddMorePetsRef = AutoDisposeProviderRef<bool>;
String _$currentPetCountHash() => r'8b6cecb6180e6d538c56c22234ba6a4e7bc9ddf1';

/// Provider that returns the current pet count for the user.
///
/// Copied from [currentPetCount].
@ProviderFor(currentPetCount)
final currentPetCountProvider = AutoDisposeProvider<int>.internal(
  currentPetCount,
  name: r'currentPetCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPetCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentPetCountRef = AutoDisposeProviderRef<int>;
String _$currentTierHash() => r'4b21d14267211a8416a45ff604b3d935706aa223';

/// Provider that returns the user's current tier.
///
/// Copied from [currentTier].
@ProviderFor(currentTier)
final currentTierProvider = AutoDisposeProvider<PetOwnerTier>.internal(
  currentTier,
  name: r'currentTierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentTierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentTierRef = AutoDisposeProviderRef<PetOwnerTier>;
String _$hasPremiumFeaturesHash() =>
    r'5f0455cb4a04c0650c4d622ee327a44471a29658';

/// Provider that returns true if the user has premium features.
///
/// Copied from [hasPremiumFeatures].
@ProviderFor(hasPremiumFeatures)
final hasPremiumFeaturesProvider = AutoDisposeProvider<bool>.internal(
  hasPremiumFeatures,
  name: r'hasPremiumFeaturesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasPremiumFeaturesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasPremiumFeaturesRef = AutoDisposeProviderRef<bool>;
String _$petLimitHash() => r'c120f3f67bf5c4a8b495e710ef3e5d129bc3df2b';

/// Provider that returns the pet limit for the current tier.
/// Returns -1 for unlimited.
///
/// Copied from [petLimit].
@ProviderFor(petLimit)
final petLimitProvider = AutoDisposeProvider<int>.internal(
  petLimit,
  name: r'petLimitProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$petLimitHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PetLimitRef = AutoDisposeProviderRef<int>;
String _$remainingPetSlotsHash() => r'893bce1cdbd4b49f987f87b1199c61e958d276f7';

/// Provider that returns the number of remaining pet slots.
/// Returns -1 for unlimited.
///
/// Copied from [remainingPetSlots].
@ProviderFor(remainingPetSlots)
final remainingPetSlotsProvider = AutoDisposeProvider<int>.internal(
  remainingPetSlots,
  name: r'remainingPetSlotsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$remainingPetSlotsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RemainingPetSlotsRef = AutoDisposeProviderRef<int>;
String _$petOwnerHash() => r'8c306124c7fadf7549fe4d0674d8691fc5c1f57f';

/// Provider for managing the current user's profile (pet owner).
///
/// Handles:
/// - Profile CRUD operations
/// - Tier management (FREE/PREMIUM/LIFETIME)
/// - Pet linking/unlinking
/// - Pet limit enforcement
///
/// Copied from [PetOwner].
@ProviderFor(PetOwner)
final petOwnerProvider =
    AutoDisposeAsyncNotifierProvider<PetOwner, UserProfile?>.internal(
  PetOwner.new,
  name: r'petOwnerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$petOwnerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PetOwner = AutoDisposeAsyncNotifier<UserProfile?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
