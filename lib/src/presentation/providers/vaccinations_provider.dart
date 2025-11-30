import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/vaccination_event.dart';
import '../../data/repositories/vaccination_repository_impl.dart';
import '../../data/services/vaccination_service.dart';

part 'vaccinations_provider.g.dart';

// ============================================================================
// Main Vaccination Provider (AsyncNotifier for CRUD operations)
// ============================================================================

@riverpod
class VaccinationProvider extends _$VaccinationProvider {
  @override
  Future<List<VaccinationEvent>> build() async {
    final repository = ref.watch(vaccinationRepositoryProvider);
    return await repository.getAllVaccinations();
  }

  Future<void> addVaccination(VaccinationEvent vaccination) async {
    final repository = ref.read(vaccinationRepositoryProvider);
    await repository.addVaccination(vaccination);
    ref.invalidateSelf();
  }

  Future<void> updateVaccination(VaccinationEvent vaccination) async {
    final repository = ref.read(vaccinationRepositoryProvider);
    await repository.updateVaccination(vaccination);
    ref.invalidateSelf();
  }

  Future<void> deleteVaccination(String id) async {
    final repository = ref.read(vaccinationRepositoryProvider);
    await repository.deleteVaccination(id);
    ref.invalidateSelf();
  }

  /// Mark a vaccination as completed with details
  Future<void> markAsCompleted({
    required String vaccinationId,
    required DateTime completedDate,
    String? veterinarianName,
    String? clinicName,
    String? batchNumber,
    String? notes,
    List<String>? certificatePhotoUrls,
  }) async {
    final service = ref.read(vaccinationServiceProvider);
    await service.markVaccinationAsCompleted(
      vaccinationId: vaccinationId,
      completedDate: completedDate,
      veterinarianName: veterinarianName,
      clinicName: clinicName,
      batchNumber: batchNumber,
      notes: notes,
      certificatePhotoUrls: certificatePhotoUrls,
    );
    ref.invalidateSelf();
  }

  /// Schedule a booster vaccination
  Future<VaccinationEvent> scheduleBooster({
    required String vaccinationId,
    required DateTime nextBoosterDate,
    String? notes,
  }) async {
    final service = ref.read(vaccinationServiceProvider);
    final booster = await service.scheduleNextBooster(
      vaccinationId: vaccinationId,
      nextBoosterDate: nextBoosterDate,
      notes: notes,
    );
    ref.invalidateSelf();
    return booster;
  }
}

// ============================================================================
// Family Providers (per-pet queries)
// ============================================================================

/// Get all vaccinations for a specific pet
@riverpod
Future<List<VaccinationEvent>> vaccinationsByPetId(
  VaccinationsByPetIdRef ref,
  String petId,
) async {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return await repository.getVaccinationsByPetId(petId);
}

/// Get upcoming vaccinations for a specific pet (due today or in the future)
@riverpod
Future<List<VaccinationEvent>> upcomingVaccinationsByPetId(
  UpcomingVaccinationsByPetIdRef ref,
  String petId,
) async {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return await repository.getUpcomingVaccinations(petId);
}

/// Get overdue vaccinations for a specific pet (past due date)
@riverpod
Future<List<VaccinationEvent>> overdueVaccinationsByPetId(
  OverdueVaccinationsByPetIdRef ref,
  String petId,
) async {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return await repository.getOverdueVaccinations(petId);
}

/// Get vaccinations within a date range for a specific pet
@riverpod
Future<List<VaccinationEvent>> vaccinationsByDateRange(
  VaccinationsByDateRangeRef ref,
  String petId,
  DateTime start,
  DateTime end,
) async {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return await repository.getVaccinationsByDateRange(petId, start, end);
}

/// Get vaccinations linked to a specific protocol
@riverpod
Future<List<VaccinationEvent>> vaccinationsByProtocolId(
  VaccinationsByProtocolIdRef ref,
  String protocolId,
) async {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return await repository.getVaccinationsByProtocolId(protocolId);
}

/// Get the most recent vaccination of a specific type for a pet
@riverpod
Future<VaccinationEvent?> lastVaccinationByType(
  LastVaccinationByTypeRef ref,
  String petId,
  String vaccineType,
) async {
  final repository = ref.watch(vaccinationRepositoryProvider);
  return await repository.getLastVaccinationByType(petId, vaccineType);
}

// ============================================================================
// Summary Provider
// ============================================================================

/// Get vaccination summary statistics for a pet
@riverpod
Future<VaccinationSummary> vaccinationSummary(
  VaccinationSummaryRef ref,
  String petId,
) async {
  final service = ref.watch(vaccinationServiceProvider);
  return await service.getVaccinationSummaryForPet(petId);
}

// ============================================================================
// Utility Providers
// ============================================================================

/// Check if a specific vaccine type is due for a pet
@riverpod
Future<bool> isVaccineDue(
  IsVaccineDueRef ref,
  String petId,
  String vaccineType,
) async {
  final service = ref.watch(vaccinationServiceProvider);
  return await service.isVaccineDue(petId, vaccineType);
}

/// Get all vaccine types that have been administered to a pet
@riverpod
Future<List<String>> vaccineTypesForPet(
  VaccineTypesForPetRef ref,
  String petId,
) async {
  final service = ref.watch(vaccinationServiceProvider);
  return await service.getVaccineTypesForPet(petId);
}
