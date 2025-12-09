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
      final active = profiles.where((p) => p.isActive);
      return active.isNotEmpty ? active.first : null;
    },
    loading: () {
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
      await _repository.init();
      await load();
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR in PetProfileProvider._initialize: $error");
      logger.e("🚨 Stack trace: $stackTrace");
      // Initialize with empty state if there's an error
      state = AsyncValue.data([]);
    }
  }

  Future<void> load() async {
    try {
      final profiles = _repository.getAll();

      if (profiles.isEmpty) {
        logger.w("⚠️ WARNING: Repository returned empty profile list");
      }

      state = AsyncValue.data(profiles);
    } catch (error, stackTrace) {
      logger.e("🚨 ERROR in PetProfileProvider.load: $error");
      logger.e("🚨 Stack trace: $stackTrace");
      // Return empty list if there's an error instead of crashing
      state = AsyncValue.data([]);
    }
  }

  Future<void> createOrUpdate(PetProfile profile) async {
    try {
      final existing = _repository.getAll();
      final idx = existing.indexWhere((p) => p.id == profile.id);

      if (idx >= 0) {
        await _repository.update(profile);
      } else {
        await _repository.add(profile);
      }

      await load();
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
