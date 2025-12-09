import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../domain/models/protocols/treatment_plan.dart';
import '../../../domain/repositories/protocols/treatment_plan_repository.dart';
import '../../local/hive_manager.dart';

part 'treatment_plan_repository_impl.g.dart';

/// Implementation of TreatmentPlanRepository using Hive
class TreatmentPlanRepositoryImpl implements TreatmentPlanRepository {
  final Box<TreatmentPlan> box;
  final logger = Logger();

  TreatmentPlanRepositoryImpl({required this.box});

  @override
  Future<List<TreatmentPlan>> getAll() async {
    try {
      final plans = box.values.toList();
      // Sort by creation date, newest first
      plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i("🔍 DEBUG: Retrieved ${plans.length} treatment plans from Hive");
      return plans;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get all treatment plans: $e");
      rethrow;
    }
  }

  @override
  Future<TreatmentPlan?> getById(String id) async {
    try {
      final plan = box.get(id);
      if (plan != null) {
        logger.i("🔍 DEBUG: Found treatment plan '${plan.name}' with ID $id");
      } else {
        logger.w("⚠️ DEBUG: No treatment plan found with ID $id");
      }
      return plan;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get treatment plan by ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<List<TreatmentPlan>> getByPetId(String petId) async {
    try {
      final plans = box.values.where((plan) => plan.petId == petId).toList();
      // Sort by start date, newest first
      plans.sort((a, b) => b.startDate.compareTo(a.startDate));
      logger.i(
          "🔍 DEBUG: Retrieved ${plans.length} treatment plans for pet $petId");
      return plans;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get treatment plans for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<TreatmentPlan>> getActiveByPetId(String petId) async {
    try {
      final plans = box.values
          .where((plan) => plan.petId == petId && plan.isActive)
          .toList();
      // Sort by start date, newest first
      plans.sort((a, b) => b.startDate.compareTo(a.startDate));
      logger.i(
          "🔍 DEBUG: Retrieved ${plans.length} active treatment plans for pet $petId");
      return plans;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get active treatment plans for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<TreatmentPlan>> getInactiveByPetId(String petId) async {
    try {
      final plans = box.values
          .where((plan) => plan.petId == petId && !plan.isActive)
          .toList();
      // Sort by start date, newest first
      plans.sort((a, b) => b.startDate.compareTo(a.startDate));
      logger.i(
          "🔍 DEBUG: Retrieved ${plans.length} inactive treatment plans for pet $petId");
      return plans;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get inactive treatment plans for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<TreatmentPlan>> getIncompleteByPetId(String petId) async {
    try {
      final plans = box.values
          .where((plan) =>
              plan.petId == petId &&
              plan.isActive &&
              plan.completionPercentage < 100.0)
          .toList();
      // Sort by start date, newest first
      plans.sort((a, b) => b.startDate.compareTo(a.startDate));
      logger.i(
          "🔍 DEBUG: Retrieved ${plans.length} incomplete treatment plans for pet $petId");
      return plans;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get incomplete treatment plans for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<void> save(TreatmentPlan plan) async {
    try {
      await box.put(plan.id, plan);
      logger.i(
          "✅ DEBUG: Saved treatment plan '${plan.name}' with ID ${plan.id} (${plan.tasks.length} tasks)");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to save treatment plan '${plan.name}': $e");
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final plan = box.get(id);
      await box.delete(id);
      logger.i(
          "✅ DEBUG: Deleted treatment plan with ID $id${plan != null ? " ('${plan.name}')" : ""}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete treatment plan with ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      final count = box.length;
      await box.clear();
      logger.i("✅ DEBUG: Deleted all treatment plans (removed $count plans)");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete all treatment plans: $e");
      rethrow;
    }
  }
}

@riverpod
TreatmentPlanRepository treatmentPlanRepository(
    TreatmentPlanRepositoryRef ref) {
  return TreatmentPlanRepositoryImpl(
    box: HiveManager.instance.treatmentPlanBox,
  );
}
