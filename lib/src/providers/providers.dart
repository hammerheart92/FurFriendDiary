import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/walks_repository.dart';
import '../domain/models/walk.dart';

// Repository provider
final walksRepositoryProvider = Provider<WalksRepository>((ref) {
  return WalksRepository();
});

// Walks state provider
final walksProvider = StateNotifierProvider<WalksNotifier, AsyncValue<List<Walk>>>((ref) {
  final repository = ref.watch(walksRepositoryProvider);
  return WalksNotifier(repository);
});

// Active walk provider for a specific pet
final activeWalkProvider = Provider.family<Walk?, String>((ref, petId) {
  final walksAsync = ref.watch(walksProvider);
  return walksAsync.when(
    data: (walks) {
      final filtered = walks.where((walk) => walk.petId == petId && walk.isActive);
      return filtered.isNotEmpty ? filtered.first : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Today's walks provider
final todaysWalksProvider = Provider<List<Walk>>((ref) {
  final walksAsync = ref.watch(walksProvider);
  return walksAsync.when(
    data: (walks) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      return walks
          .where((walk) => 
              walk.startTime.isAfter(startOfDay) && 
              walk.startTime.isBefore(endOfDay))
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Walk statistics provider
final walkStatsProvider = Provider.family<Map<String, dynamic>, String>((ref, petId) {
  final repository = ref.watch(walksRepositoryProvider);
  return repository.getWalkStats(petId);
});

class WalksNotifier extends StateNotifier<AsyncValue<List<Walk>>> {
  final WalksRepository _repository;
  final Uuid _uuid = const Uuid();

  WalksNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _repository.initialize();
      _loadWalks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _loadWalks() {
    try {
      final walks = _repository.getAllWalks();
      state = AsyncValue.data(walks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Start a new walk
  Future<void> startWalk({
    required String petId,
    WalkType walkType = WalkType.regular,
  }) async {
    try {
      // Check if there's already an active walk for this pet
      final activeWalk = _repository.getActiveWalk(petId);
      if (activeWalk != null) {
        throw Exception('There is already an active walk for this pet');
      }

      final walk = Walk(
        id: _uuid.v4(),
        petId: petId,
        startTime: DateTime.now(),
        walkType: walkType,
        createdAt: DateTime.now(),
      );

      await _repository.startWalk(walk);
      _loadWalks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // End a walk
  Future<void> endWalk({
    required String walkId,
    double? distance,
    String? notes,
  }) async {
    try {
      await _repository.endWalk(walkId, distance: distance, notes: notes);
      _loadWalks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Update walk details
  Future<void> updateWalk(Walk updatedWalk) async {
    try {
      await _repository.updateWalk(updatedWalk);
      _loadWalks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Delete a walk
  Future<void> deleteWalk(String walkId) async {
    try {
      await _repository.deleteWalk(walkId);
      _loadWalks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Refresh walks
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _loadWalks();
  }
}