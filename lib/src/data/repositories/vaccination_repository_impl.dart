import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../domain/models/vaccination_event.dart';
import '../../domain/repositories/vaccination_repository.dart';
import '../local/hive_boxes.dart';

part 'vaccination_repository_impl.g.dart';

class VaccinationRepositoryImpl implements VaccinationRepository {
  final logger = Logger();

  @override
  Future<List<VaccinationEvent>> getAllVaccinations() async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      final vaccinations = box.values.toList();
      // Sort by administered date, newest first
      vaccinations
          .sort((a, b) => b.administeredDate.compareTo(a.administeredDate));
      logger.i(
          "🔍 DEBUG: Retrieved ${vaccinations.length} vaccination events from Hive");
      return vaccinations;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get all vaccinations: $e");
      rethrow;
    }
  }

  @override
  Future<List<VaccinationEvent>> getVaccinationsByPetId(String petId) async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      final vaccinations =
          box.values.where((event) => event.petId == petId).toList();
      // Sort by administered date, newest first
      vaccinations
          .sort((a, b) => b.administeredDate.compareTo(a.administeredDate));
      logger.i(
          "🔍 DEBUG: Retrieved ${vaccinations.length} vaccinations for pet $petId");
      return vaccinations;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get vaccinations for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<VaccinationEvent?> getVaccinationById(String id) async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      final vaccination = box.get(id);
      if (vaccination != null) {
        logger.i(
            "🔍 DEBUG: Found vaccination '${vaccination.vaccineType}' with ID $id");
      } else {
        logger.w("⚠️ DEBUG: No vaccination found with ID $id");
      }
      return vaccination;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get vaccination by ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<void> addVaccination(VaccinationEvent event) async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      await box.put(event.id, event);
      logger.i(
          "✅ DEBUG: Added vaccination '${event.vaccineType}' with ID ${event.id}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to add vaccination '${event.vaccineType}': $e");
      rethrow;
    }
  }

  @override
  Future<void> updateVaccination(VaccinationEvent event) async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      await box.put(event.id, event);
      logger.i(
          "✅ DEBUG: Updated vaccination '${event.vaccineType}' with ID ${event.id}");
    } catch (e) {
      logger
          .e("🚨 ERROR: Failed to update vaccination '${event.vaccineType}': $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteVaccination(String id) async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      final vaccination = box.get(id);
      await box.delete(id);
      logger.i(
          "✅ DEBUG: Deleted vaccination with ID $id${vaccination != null ? " ('${vaccination.vaccineType}')" : ""}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete vaccination with ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<List<VaccinationEvent>> getVaccinationsByDateRange(
    String petId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      final vaccinations = box.values
          .where((event) =>
              event.petId == petId &&
              (event.administeredDate.isAtSameMomentAs(start) ||
                  event.administeredDate.isAfter(start)) &&
              (event.administeredDate.isAtSameMomentAs(end) ||
                  event.administeredDate.isBefore(end)))
          .toList();
      // Sort by administered date, newest first
      vaccinations
          .sort((a, b) => b.administeredDate.compareTo(a.administeredDate));
      logger.i(
          "🔍 DEBUG: Retrieved ${vaccinations.length} vaccinations for pet $petId in date range");
      return vaccinations;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get vaccinations by date range for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<VaccinationEvent>> getUpcomingVaccinations(String petId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final box = HiveBoxes.getVaccinationEvents();
      final vaccinations = box.values
          .where((event) =>
              event.petId == petId &&
              event.nextDueDate != null &&
              (event.nextDueDate!.isAtSameMomentAs(today) ||
                  event.nextDueDate!.isAfter(today)))
          .toList();
      // Sort by next due date, soonest first
      vaccinations.sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
      logger.i(
          "🔍 DEBUG: Retrieved ${vaccinations.length} upcoming vaccinations for pet $petId");
      return vaccinations;
    } catch (e) {
      logger
          .e("🚨 ERROR: Failed to get upcoming vaccinations for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<VaccinationEvent>> getOverdueVaccinations(String petId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final box = HiveBoxes.getVaccinationEvents();
      final vaccinations = box.values
          .where((event) =>
              event.petId == petId &&
              event.nextDueDate != null &&
              event.nextDueDate!.isBefore(today))
          .toList();
      // Sort by next due date, most overdue first
      vaccinations.sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
      logger.i(
          "🔍 DEBUG: Retrieved ${vaccinations.length} overdue vaccinations for pet $petId");
      return vaccinations;
    } catch (e) {
      logger
          .e("🚨 ERROR: Failed to get overdue vaccinations for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<VaccinationEvent>> getVaccinationsByProtocolId(
      String protocolId) async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      final vaccinations = box.values
          .where((event) => event.protocolId == protocolId)
          .toList();
      // Sort by protocol step index, then by administered date
      vaccinations.sort((a, b) {
        final stepCompare =
            (a.protocolStepIndex ?? 0).compareTo(b.protocolStepIndex ?? 0);
        if (stepCompare != 0) return stepCompare;
        return a.administeredDate.compareTo(b.administeredDate);
      });
      logger.i(
          "🔍 DEBUG: Retrieved ${vaccinations.length} vaccinations for protocol $protocolId");
      return vaccinations;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get vaccinations for protocol $protocolId: $e");
      rethrow;
    }
  }

  @override
  Future<VaccinationEvent?> getLastVaccinationByType(
    String petId,
    String vaccineType,
  ) async {
    try {
      final box = HiveBoxes.getVaccinationEvents();
      final vaccinations = box.values
          .where((event) =>
              event.petId == petId &&
              event.vaccineType.toLowerCase() == vaccineType.toLowerCase())
          .toList();

      if (vaccinations.isEmpty) {
        logger.i(
            "⚠️ DEBUG: No vaccinations of type '$vaccineType' found for pet $petId");
        return null;
      }

      // Sort by administered date, newest first
      vaccinations
          .sort((a, b) => b.administeredDate.compareTo(a.administeredDate));
      final lastVaccination = vaccinations.first;
      logger.i(
          "🔍 DEBUG: Found last '$vaccineType' vaccination for pet $petId on ${lastVaccination.administeredDate}");
      return lastVaccination;
    } catch (e) {
      logger.e(
          "🚨 ERROR: Failed to get last vaccination by type for pet $petId: $e");
      rethrow;
    }
  }
}

@riverpod
VaccinationRepository vaccinationRepository(VaccinationRepositoryRef ref) {
  return VaccinationRepositoryImpl();
}
