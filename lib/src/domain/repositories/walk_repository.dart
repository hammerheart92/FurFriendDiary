import 'package:hive_flutter/hive_flutter.dart';
import '../models/walk.dart';

abstract class WalkRepository {
  Future<void> startWalk(Walk walk);
  Future<void> updateWalk(Walk walk);
  Future<void> endWalk(String walkId, {double? distance, String? notes});
  List<Walk> getAllWalks();
  List<Walk> getWalksForPet(String petId);
  Stream<List<Walk>> getWalksForPetStream(String petId);
  Walk? getActiveWalk(String petId);
  List<Walk> getWalksByDateRange(DateTime start, DateTime end);
  List<Walk> getTodaysWalks();
  Map<String, dynamic> getWalkStats(String petId, {int days = 7});
  Future<void> deleteWalk(String walkId);
  Stream<BoxEvent> watchWalks();
  Future<void> dispose();
  Future<void> migrateDefaultPetIdWalks(String actualPetId);
}
