import 'package:hive/hive.dart';

part 'pet_owner_tier.g.dart';

/// Represents the subscription tier for a pet owner.
///
/// Tier determines feature access and pet limits:
/// - [free]: Limited to 1 pet, basic features
/// - [premium]: Unlimited pets, premium features (subscription)
/// - [lifetime]: Unlimited pets, premium features (one-time purchase)
@HiveType(typeId: 17)
enum PetOwnerTier {
  @HiveField(0)
  free,

  @HiveField(1)
  premium,

  @HiveField(2)
  lifetime,
}

/// Extension methods for [PetOwnerTier] to provide helper functionality.
extension PetOwnerTierExtension on PetOwnerTier {
  /// Returns the maximum number of pets allowed for this tier.
  /// Returns -1 for unlimited pets.
  int get petLimit {
    switch (this) {
      case PetOwnerTier.free:
        return 1;
      case PetOwnerTier.premium:
      case PetOwnerTier.lifetime:
        return -1; // Unlimited
    }
  }

  /// Returns true if this tier allows adding more pets (unlimited).
  bool get hasUnlimitedPets => petLimit == -1;

  /// Returns true if this tier grants premium features.
  bool get isPremium {
    switch (this) {
      case PetOwnerTier.free:
        return false;
      case PetOwnerTier.premium:
      case PetOwnerTier.lifetime:
        return true;
    }
  }

  /// Returns true if this tier is a subscription (can expire).
  bool get isSubscription => this == PetOwnerTier.premium;

  /// Returns true if this tier is a lifetime purchase (never expires).
  bool get isLifetime => this == PetOwnerTier.lifetime;

  /// Returns a display name for this tier.
  String get displayName {
    switch (this) {
      case PetOwnerTier.free:
        return 'Free';
      case PetOwnerTier.premium:
        return 'Premium';
      case PetOwnerTier.lifetime:
        return 'Lifetime';
    }
  }
}
