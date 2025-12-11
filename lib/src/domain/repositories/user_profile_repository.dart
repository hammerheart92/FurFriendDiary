import '../models/user_profile.dart';

/// Repository interface for user profile (pet owner) management.
///
/// Handles storage and retrieval of the current user's profile,
/// including tier management and pet linking.
abstract class UserProfileRepository {
  /// Get the current user's profile.
  /// Returns null if no profile exists yet.
  Future<UserProfile?> getUserProfile();

  /// Save or update the user's profile.
  /// Creates a new profile if none exists, otherwise updates existing.
  Future<void> saveUserProfile(UserProfile profile);

  /// Update specific fields of the user's profile.
  /// Returns the updated profile.
  Future<UserProfile?> updateUserProfile({
    String? name,
    String? email,
    String? profilePicturePath,
  });

  /// Delete the user's profile (for testing/reset purposes).
  Future<void> deleteUserProfile();

  /// Check if a user profile exists.
  Future<bool> hasUserProfile();

  /// Link a pet to the current user.
  /// Adds the pet ID to the user's petIds list.
  /// Returns false if user profile doesn't exist.
  Future<bool> linkPetToUser(String petId);

  /// Unlink a pet from the current user.
  /// Removes the pet ID from the user's petIds list.
  Future<bool> unlinkPetFromUser(String petId);

  /// Check if the current user can add more pets.
  /// Based on tier limits and current pet count.
  Future<bool> canAddMorePets();

  /// Get the count of pets linked to the current user.
  Future<int> getPetCount();
}
