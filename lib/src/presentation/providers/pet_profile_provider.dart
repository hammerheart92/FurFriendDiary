import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/data/repositories/pet_profile_repository.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';

// Repository provider
final petProfileRepositoryProvider = Provider<PetProfileRepository>((ref) {
  return PetProfileRepository();
});

// All pet profiles state provider
final petProfilesProvider =
    StateNotifierProvider<PetProfilesNotifier, AsyncValue<List<PetProfile>>>(
        (ref) {
  final repository = ref.watch(petProfileRepositoryProvider);
  return PetProfilesNotifier(repository);
});

// Current active pet profile provider
final currentPetProfileProvider = Provider<PetProfile?>((ref) {
  final logger = Logger();
  final profilesAsync = ref.watch(petProfilesProvider);
  return profilesAsync.when(
    data: (profiles) {
      logger.d("🐾 DEBUG: currentPetProfileProvider - received ${profiles.length} profiles");
      final active = profiles.where((p) => p.isActive);
      logger.d("🐾 DEBUG: currentPetProfileProvider - ${active.length} active profiles found");
      if (active.isEmpty && profiles.isNotEmpty) {
        logger.w("⚠️ WARNING: No active pet but ${profiles.length} pets exist!");
      }
      return active.isNotEmpty ? active.first : null;
    },
    loading: () {
      logger.d("🐾 DEBUG: currentPetProfileProvider - still loading");
      return null;
    },
    error: (e, __) {
      logger.e("🐾 ERROR: currentPetProfileProvider - $e");
      return null;
    },
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
      logger.d("🔍 DEBUG: PetProfilesNotifier._initialize() starting");
      await _repository.init();
      logger.d("🔍 DEBUG: Repository initialized successfully");
      await load();
      logger.d("🔍 DEBUG: PetProfilesNotifier._initialize() completed");
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR in PetProfileProvider._initialize: $error");
      logger.e("🚨 Stack trace: $stackTrace");
      // Initialize with empty state if there's an error
      state = AsyncValue.data([]);
    }
  }

  Future<void> load() async {
    try {
      logger.d("📥 DEBUG: PetProfilesNotifier.load() starting");
      final profiles = _repository.getAll();
      logger.d("📥 DEBUG: Repository returned ${profiles.length} profiles");

      for (var profile in profiles) {
        logger.d("📥 DEBUG: - ${profile.name}: gender=[REDACTED], isActive=${profile.isActive}");
      }

      if (profiles.isEmpty) {
        logger.w("⚠️ WARNING: Repository returned empty profile list");
      }

      state = AsyncValue.data(profiles);
      logger.d("📥 DEBUG: State updated with ${profiles.length} profiles");
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR in PetProfileProvider.load: $error");
      logger.e("🚨 Stack trace: $stackTrace");
      // Return empty list if there's an error instead of crashing
      state = AsyncValue.data([]);
    }
  }

  Future<void> createOrUpdate(PetProfile profile) async {
    logger.d(
        "🔍 DEBUG: PetProfilesNotifier.createOrUpdate called with profile: ${profile.name}");
    logger.d("🔍 DEBUG: Profile photoPath being saved: ${profile.photoPath}");

    try {
      final existing = _repository.getAll();
      final idx = existing.indexWhere((p) => p.id == profile.id);
      logger.d(
          "🔍 DEBUG: Existing profiles count: ${existing.length}, profile index: $idx");

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
      final savedProfile = allProfiles.firstWhere((p) => p.id == profile.id,
          orElse: () => profile);
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
