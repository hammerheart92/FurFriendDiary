import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/data/repositories/pet_profile_repository.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';

// Repository provider
final petProfileRepositoryProvider = Provider<PetProfileRepository>((ref) {
  return PetProfileRepository();
});

// All pet profiles state provider
final petProfilesProvider = StateNotifierProvider<PetProfilesNotifier, AsyncValue<List<PetProfile>>>((ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return PetProfilesNotifier(repository);
});

// Current active pet profile provider
final currentPetProfileProvider = Provider<PetProfile?>((ref) {
  final profilesAsync = ref.watch(petProfilesProvider);
  return profilesAsync.when(
    data: (profiles) {
      final active = profiles.where((p) => p.isActive);
      return active.isNotEmpty ? active.first : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Setup completion status provider (async-safe)
final hasCompletedSetupProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(petProfileRepositoryProvider);
  await repository.init(); // no-op if already initialized
  return repository.hasCompletedSetup();
});

class PetProfilesNotifier extends StateNotifier<AsyncValue<List<PetProfile>>> {
  final logger = Logger();
  final PetProfileRepository _repository;
  PetProfilesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _repository.init();
      await load();
    } catch (error) {
      logger.e("🚨 ERROR in PetProfileProvider._initialize: $error");
      // Initialize with empty state if there's an error
      state = AsyncValue.data([]);
    }
  }

  Future<void> load() async {
    try {
      logger.d("📥 DEBUG: Loading profiles from Hive");
      final profiles = _repository.getAll();
      logger.d("📥 DEBUG: Loaded ${profiles.length} profiles");

      for (var profile in profiles) {
        logger.d("📥 DEBUG: - ${profile.name}: photoPath = ${profile.photoPath}");
      }

      state = AsyncValue.data(profiles);
    } catch (error) {
      logger.e("🚨 ERROR in PetProfileProvider.load: $error");
      // Return empty list if there's an error instead of crashing
      state = AsyncValue.data([]);
    }
  }

  Future<void> createOrUpdate(PetProfile profile) async {
    logger.d("🔍 DEBUG: PetProfilesNotifier.createOrUpdate called with profile: ${profile.name}");
    logger.d("🔍 DEBUG: Profile photoPath being saved: ${profile.photoPath}");

    try {
      final existing = _repository.getAll();
      final idx = existing.indexWhere((p) => p.id == profile.id);
      logger.d("🔍 DEBUG: Existing profiles count: ${existing.length}, profile index: $idx");

      if (idx >= 0) {
        logger.d("🔍 DEBUG: Updating existing profile");
        await _repository.update(profile);
        logger.d("🔍 DEBUG: Profile updated in repository");
      } else {
        logger.d("🔍 DEBUG: Adding new profile");
        await _repository.add(profile);
        logger.d("🔍 DEBUG: Profile added to repository");
      }

      // Verify the save
      final allProfiles = _repository.getAll();
      final savedProfile = allProfiles.firstWhere((p) => p.id == profile.id, orElse: () => profile);
      logger.d("🗂️ DEBUG: Verifying saved profile from Hive:");
      logger.d("🗂️ DEBUG: - Name: ${savedProfile.name}");
      logger.d("🗂️ DEBUG: - photoPath: ${savedProfile.photoPath}");

      logger.d("🔍 DEBUG: Profile operation completed, reloading state");
      await load();
      logger.d("🔍 DEBUG: State reloaded successfully");

    } catch (error, stackTrace) {
      logger.e("🚨 ERROR: Failed in createOrUpdate: $error");
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _repository.delete(id);
      await load();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setActive(String id) async {
    try {
      await _repository.setActive(id);
      await load();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async => load();
}

