import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/walk.dart';

class WalksRepository {
  final Box<Walk> _box;

  WalksRepository(this._box);

  // Create a new walk
  Future<void> startWalk(Walk walk) async {
    await _box.put(walk.id, walk);
  }

  // Update existing walk (e.g., when ending a walk)
  Future<void> updateWalk(Walk walk) async {
    await _box.put(walk.id, walk);
  }

  // End a walk
  Future<void> endWalk(String walkId, {double? distance, String? notes}) async {
    final walk = _box.get(walkId);
    if (walk != null && walk.isActive) {
      final endedWalk = walk.copyWith(
        endTime: DateTime.now(),
        distance: distance ?? walk.distance,
        notes: notes ?? walk.notes,
      );
      await _box.put(walkId, endedWalk);
    }
  }

  // Get all walks
  List<Walk> getAllWalks() {
    return _box.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Get walks for a specific pet
  List<Walk> getWalksForPet(String petId) {
    return _box.values.where((walk) => walk.petId == petId).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Get active walk for a pet
  Walk? getActiveWalk(String petId) {
    return _box.values.cast<Walk?>().firstWhere(
          (walk) => walk != null && walk.petId == petId && walk.isActive,
          orElse: () => null,
        );
  }

  // Get walks within date range
  List<Walk> getWalksByDateRange(DateTime start, DateTime end) {
    return _box.values
        .where((walk) =>
            walk.startTime.isAfter(start) && walk.startTime.isBefore(end))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Get today's walks
  List<Walk> getTodaysWalks() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getWalksByDateRange(startOfDay, endOfDay);
  }

  // Get walk statistics
  Map<String, dynamic> getWalkStats(String petId, {int days = 7}) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final walks = getWalksForPet(petId)
        .where(
            (walk) => walk.startTime.isAfter(startDate) && walk.endTime != null)
        .toList();

    final totalWalks = walks.length;
    final totalDuration = walks.fold<Duration>(
      Duration.zero,
      (total, walk) => total + (walk.actualDuration ?? Duration.zero),
    );
    final totalDistance = walks.fold<double>(
      0.0,
      (total, walk) => total + (walk.distance ?? 0.0),
    );

    return {
      'totalWalks': totalWalks,
      'totalDuration': totalDuration,
      'totalDistance': totalDistance,
      'averageWalkDuration': totalWalks > 0
          ? Duration(milliseconds: totalDuration.inMilliseconds ~/ totalWalks)
          : Duration.zero,
      'averageDistance': totalWalks > 0 ? totalDistance / totalWalks : 0.0,
    };
  }

  // Delete a walk
  Future<void> deleteWalk(String walkId) async {
    await _box.delete(walkId);
  }

  // Watch walks changes
  Stream<BoxEvent> watchWalks() {
    return _box.watch();
  }

  // Cleanup - Box is managed by HiveManager, no need to close here
  Future<void> dispose() async {
    // Box lifecycle is managed by HiveManager
  }

  // Migration: Update walks with default-pet-id to use actual pet ID
  Future<void> migrateDefaultPetIdWalks(String actualPetId) async {
    final defaultWalks =
        _box.values.where((walk) => walk.petId == 'default-pet-id').toList();

    if (defaultWalks.isEmpty) return;

    print(
        'Migrating ${defaultWalks.length} walks from default-pet-id to $actualPetId');

    for (final walk in defaultWalks) {
      final updatedWalk = walk.copyWith(petId: actualPetId);
      await _box.put(walk.id, updatedWalk);
    }

    print('Migration complete!');
  }
}
