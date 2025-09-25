import '../models/feeding_entry.dart';

abstract class FeedingRepository {
  Future<List<FeedingEntry>> getAllFeedings();
  Future<List<FeedingEntry>> getFeedingsByPetId(String petId);
  Future<void> addFeeding(FeedingEntry feeding);
  Future<void> updateFeeding(FeedingEntry feeding);
  Future<void> deleteFeeding(String id);
  Future<FeedingEntry?> getFeedingById(String id);
  Future<List<FeedingEntry>> getFeedingsByDateRange(String petId, DateTime start, DateTime end);
}
