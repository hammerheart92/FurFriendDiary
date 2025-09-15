// lib/src/providers/user_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/src/models/user_profile.dart';
import 'package:fur_friend_diary/src/services/profile_picture_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _loadProfile();
  }

  final ProfilePictureService _profilePictureService = ProfilePictureService();
  late Box<UserProfile> _box;

  Future<void> _loadProfile() async {
    _box = await Hive.openBox<UserProfile>('user_profile');
    final profile = _box.get('current_user');
    state = profile;
  }

  Future<void> updateDisplayName(String displayName) async {
    if (state == null) return;
    
    final updatedProfile = UserProfile(
      id: state!.id,
      displayName: displayName,
      photoPath: state!.photoPath,
    );
    
    await _box.put('current_user', updatedProfile);
    state = updatedProfile;
  }

  Future<void> updateProfilePicture(String? photoPath) async {
    if (state == null) return;

    // Delete old profile picture if it exists
    if (state!.photoPath != null && state!.photoPath != photoPath) {
      await _profilePictureService.deleteProfilePicture(state!.photoPath);
    }

    final updatedProfile = UserProfile(
      id: state!.id,
      displayName: state!.displayName,
      photoPath: photoPath,
    );
    
    await _box.put('current_user', updatedProfile);
    state = updatedProfile;
  }

  Future<void> createProfile(String displayName, {String? photoPath}) async {
    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: displayName,
      photoPath: photoPath,
    );
    
    await _box.put('current_user', profile);
    state = profile;
  }

  Future<void> deleteProfilePicture() async {
    if (state?.photoPath != null) {
      await _profilePictureService.deleteProfilePicture(state!.photoPath);
      await updateProfilePicture(null);
    }
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});