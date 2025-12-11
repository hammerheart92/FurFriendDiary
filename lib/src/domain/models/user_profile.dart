import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'pet_owner_tier.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 8)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? profilePicturePath;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  bool hasCompletedOnboarding;

  /// The subscription tier for this user.
  /// Determines feature access and pet limits.
  @HiveField(7)
  PetOwnerTier tier;

  /// Expiry date for premium subscription.
  /// Null for free tier or lifetime purchases.
  @HiveField(8)
  DateTime? premiumExpiryDate;

  /// List of pet IDs owned by this user.
  /// Used to link pets to their owner.
  @HiveField(9)
  List<String> petIds;

  UserProfile({
    String? id,
    required this.name,
    this.email,
    this.profilePicturePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.hasCompletedOnboarding = false,
    this.tier = PetOwnerTier.free,
    this.premiumExpiryDate,
    List<String>? petIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        petIds = petIds ?? [];

  /// Returns true if the user can add more pets based on their tier and current pet count.
  bool canAddPet() {
    if (tier.hasUnlimitedPets) return true;
    return petIds.length < tier.petLimit;
  }

  /// Returns the number of remaining pet slots.
  /// Returns -1 for unlimited.
  int get remainingPetSlots {
    if (tier.hasUnlimitedPets) return -1;
    return tier.petLimit - petIds.length;
  }

  /// Returns true if the premium subscription has expired.
  /// Returns false for free tier or lifetime purchases.
  bool get isPremiumExpired {
    if (tier == PetOwnerTier.free || tier == PetOwnerTier.lifetime) {
      return false;
    }
    if (premiumExpiryDate == null) return true;
    return DateTime.now().isAfter(premiumExpiryDate!);
  }

  /// Returns the effective tier, accounting for expired subscriptions.
  PetOwnerTier get effectiveTier {
    if (isPremiumExpired && tier == PetOwnerTier.premium) {
      return PetOwnerTier.free;
    }
    return tier;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'profilePicturePath': profilePicturePath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'tier': tier.name,
        'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
        'petIds': petIds,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profilePicturePath: json['profilePicturePath'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
        tier: json['tier'] != null
            ? PetOwnerTier.values.byName(json['tier'])
            : PetOwnerTier.free,
        premiumExpiryDate: json['premiumExpiryDate'] != null
            ? DateTime.parse(json['premiumExpiryDate'])
            : null,
        petIds: json['petIds'] != null
            ? List<String>.from(json['petIds'])
            : [],
      );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicturePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasCompletedOnboarding,
    PetOwnerTier? tier,
    DateTime? premiumExpiryDate,
    List<String>? petIds,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      tier: tier ?? this.tier,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      petIds: petIds ?? List<String>.from(this.petIds),
    );
  }

  /// Creates a copy with the premiumExpiryDate explicitly set to null.
  /// Used when upgrading to lifetime or downgrading to free.
  UserProfile copyWithNullExpiry({
    String? id,
    String? name,
    String? email,
    String? profilePicturePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasCompletedOnboarding,
    PetOwnerTier? tier,
    List<String>? petIds,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      tier: tier ?? this.tier,
      premiumExpiryDate: null,
      petIds: petIds ?? List<String>.from(this.petIds),
    );
  }
}
