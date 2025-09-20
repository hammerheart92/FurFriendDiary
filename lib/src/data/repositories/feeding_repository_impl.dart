import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/feeding_entry.dart';
import '../../domain/repositories/feeding_repository.dart';
import '../local/hive_boxes.dart';

part 'feeding_repository_impl.g.dart';

class FeedingRepositoryImpl implements FeedingRepository {
  @override
  Future<List<FeedingEntry>> getAllFeedings() async {
    final box = HiveBoxes.getFeedings();
    return box.values.toList();
  }

  @override
  Future<List<FeedingEntry>> getFeedingsByPetId(String petId) async {
    final box = HiveBoxes.getFeedings();
    return box.values.where((feeding) => feeding.petId == petId).toList();
  }

  @override
  Future<void> addFeeding(FeedingEntry feeding) async {
    final box = HiveBoxes.getFeedings();
    await box.put(feeding.id, feeding);
  }

  @override
  Future<void> updateFeeding(FeedingEntry feeding) async {
    final box = HiveBoxes.getFeedings();
    await box.put(feeding.id, feeding);
  }

  @override
  Future<void> deleteFeeding(String id) async {
    final box = HiveBoxes.getFeedings();
    await box.delete(id);
  }

  @override
  Future<FeedingEntry?> getFeedingById(String id) async {
    final box = HiveBoxes.getFeedings();
    return box.get(id);
  }

  @override
  Future<List<FeedingEntry>> getFeedingsByDateRange(String petId, DateTime start, DateTime end) async {
    final box = HiveBoxes.getFeedings();
    return box.values
        .where((feeding) => 
            feeding.petId == petId &&
            feeding.dateTime.isAfter(start) &&
            feeding.dateTime.isBefore(end))
        .toList();
  }
}

@riverpod
FeedingRepository feedingRepository(FeedingRepositoryRef ref) {
  return FeedingRepositoryImpl();
}
