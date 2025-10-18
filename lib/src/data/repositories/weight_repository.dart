import 'package:hive/hive.dart';
import 'package:fur_friend_diary/src/domain/models/weight_entry.dart';

class WeightRepository {
  final Box<WeightEntry> _box;

  WeightRepository(this._box);

  /// Get all weight entries for a specific pet
  List<WeightEntry> getWeightEntriesForPet(String petId) {
    return _box.values
        .where((entry) => entry.petId == petId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  /// Get weight entries as a stream for real-time updates
  Stream<List<WeightEntry>> getWeightEntriesStream(String petId) {
    return _box.watch().map((_) => getWeightEntriesForPet(petId));
  }

  /// Add a new weight entry
  Future<void> addWeightEntry(WeightEntry entry) async {
    await _box.put(entry.id, entry);
  }

  /// Update an existing weight entry
  Future<void> updateWeightEntry(WeightEntry entry) async {
    await _box.put(entry.id, entry);
  }

  /// Delete a weight entry by ID
  Future<void> deleteWeightEntry(String id) async {
    await _box.delete(id);
  }

  /// Get the latest (most recent) weight entry for a pet
  WeightEntry? getLatestWeight(String petId) {
    final entries = getWeightEntriesForPet(petId);
    return entries.isNotEmpty ? entries.first : null;
  }

  /// Get weight change between the first and last entry
  /// Returns null if there are fewer than 2 entries
  double? getWeightChange(String petId) {
    final entries = getWeightEntriesForPet(petId);
    if (entries.length < 2) return null;
    
    final latest = entries.first.weight;
    final earliest = entries.last.weight;
    return latest - earliest;
  }

  /// Get all weight entries across all pets
  List<WeightEntry> getAllEntries() {
    return _box.values.toList();
  }

  /// Delete all weight entries for a specific pet
  Future<void> deleteEntriesForPet(String petId) async {
    final entries = getWeightEntriesForPet(petId);
    for (final entry in entries) {
      await _box.delete(entry.id);
    }
  }
}

