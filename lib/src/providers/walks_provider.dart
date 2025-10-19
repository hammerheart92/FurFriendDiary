import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/walk.dart';
import '../services/box_repository.dart';

const _uuid = Uuid();

class WalksNotifier extends StateNotifier<AsyncValue<List<Walk>>> {
  final BoxRepository _repo;

  WalksNotifier(this._repo) : super(const AsyncValue.loading()) {
    _loadWalks();
  }

  Future<void> _loadWalks() async {
    try {
      final walksJson = await _repo.listAll();
      final walks = walksJson.map((json) => Walk.fromJson(json)).toList();
      walks.sort((a, b) => b.startTime.compareTo(a.startTime));
      state = AsyncValue.data(walks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startWalk(
      {required String petId, WalkType walkType = WalkType.regular}) async {
    final currentWalks = state.value ?? [];
    if (currentWalks.any((w) => w.petId == petId && w.isActive)) {
      throw Exception('A walk is already in progress for this pet.');
    }

    final walk = Walk(
      id: _uuid.v4(),
      petId: petId,
      start: DateTime.now(),
      durationMinutes: 0,
      walkType: walkType,
      isActive: true,
    );

    await _repo.put(walk.id, walk.toJson());
    state = AsyncValue.data([walk, ...currentWalks]);
  }

  Future<void> endWalk(
      {required String walkId, double? distance, String? notes}) async {
    final currentWalks = state.value ?? [];
    final walkIndex = currentWalks.indexWhere((w) => w.id == walkId);

    if (walkIndex == -1) {
      throw Exception('Walk not found.');
    }

    final walk = currentWalks[walkIndex];
    final updatedWalk = walk.copyWith(
      endTime: DateTime.now(),
      distance: distance,
      notes: notes,
    );

    await _repo.put(walk.id, updatedWalk.toJson());

    final updatedList = List<Walk>.from(currentWalks);
    updatedList[walkIndex] = updatedWalk;

    state = AsyncValue.data(updatedList);
  }

  Future<void> deleteWalk(String walkId) async {
    await _repo.delete(walkId);
    final currentWalks = state.value ?? [];
    state = AsyncValue.data(currentWalks.where((w) => w.id != walkId).toList());
  }
}

final walksRepoProvider =
    Provider<BoxRepository>((ref) => BoxRepository('walks'));

final walksProvider =
    StateNotifierProvider<WalksNotifier, AsyncValue<List<Walk>>>((ref) {
  return WalksNotifier(ref.watch(walksRepoProvider));
});

final activeWalkProvider = Provider.family<Walk?, String>((ref, petId) {
  final walks = ref.watch(walksProvider).value;
  if (walks == null) return null;

  try {
    return walks.firstWhere((w) => w.petId == petId && w.isActive);
  } catch (e) {
    return null; // No active walk found
  }
});

final walkDurationProvider =
    StreamProvider.family<Duration, DateTime>((ref, startTime) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return DateTime.now().difference(startTime);
  });
});

final walkStatsProvider =
    Provider.family<Map<String, dynamic>, String>((ref, petId) {
  final walksAsync = ref.watch(walksProvider);

  return walksAsync.when(
    data: (walks) {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      final recentWalks = walks
          .where((w) =>
              w.petId == petId &&
              w.isComplete &&
              w.startTime.isAfter(oneWeekAgo))
          .toList();

      if (recentWalks.isEmpty) {
        return {
          'totalWalks': 0,
          'totalDuration': Duration.zero,
          'totalDistance': 0.0,
          'averageWalkDuration': Duration.zero,
          'averageDistance': 0.0,
        };
      }

      final totalDuration = recentWalks.fold<Duration>(
        Duration.zero,
        (prev, walk) => prev + (walk.actualDuration ?? Duration.zero),
      );

      final totalDistance = recentWalks.fold<double>(
        0.0,
        (prev, walk) => prev + (walk.distance ?? 0.0),
      );

      return {
        'totalWalks': recentWalks.length,
        'totalDuration': totalDuration,
        'totalDistance': totalDistance,
        'averageWalkDuration': totalDuration.inMinutes > 0
            ? Duration(minutes: totalDuration.inMinutes ~/ recentWalks.length)
            : Duration.zero,
        'averageDistance':
            totalDistance > 0 ? totalDistance / recentWalks.length : 0.0,
      };
    },
    loading: () => {
      'totalWalks': 0,
      'totalDuration': Duration.zero,
      'totalDistance': 0.0,
      'averageWalkDuration': Duration.zero,
      'averageDistance': 0.0,
    },
    error: (err, stack) => throw err,
  );
});
