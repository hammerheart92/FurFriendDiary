import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/feeding_entry.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/report_entry.dart';
import '../../data/repositories/feeding_repository_impl.dart';
import '../../data/repositories/medication_repository_impl.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';

part 'care_data_provider.g.dart';

// Feeding Providers
@riverpod
class FeedingProvider extends _$FeedingProvider {
  @override
  Future<List<FeedingEntry>> build() async {
    final repository = ref.watch(feedingRepositoryProvider);
    return await repository.getAllFeedings();
  }

  Future<void> addFeeding(FeedingEntry feeding) async {
    final repository = ref.read(feedingRepositoryProvider);
    await repository.addFeeding(feeding);
    ref.invalidateSelf();
  }

  Future<void> updateFeeding(FeedingEntry feeding) async {
    final repository = ref.read(feedingRepositoryProvider);
    await repository.updateFeeding(feeding);
    ref.invalidateSelf();
  }

  Future<void> deleteFeeding(String id) async {
    final repository = ref.read(feedingRepositoryProvider);
    await repository.deleteFeeding(id);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<FeedingEntry>> feedingsByPetId(
    FeedingsByPetIdRef ref, String petId) async {
  final repository = ref.watch(feedingRepositoryProvider);
  return await repository.getFeedingsByPetId(petId);
}

@riverpod
Future<List<FeedingEntry>> feedingsByDateRange(FeedingsByDateRangeRef ref,
    String petId, DateTime start, DateTime end) async {
  final repository = ref.watch(feedingRepositoryProvider);
  return await repository.getFeedingsByDateRange(petId, start, end);
}

// Medication Providers
@riverpod
class MedicationProvider extends _$MedicationProvider {
  @override
  Future<List<MedicationEntry>> build() async {
    final repository = ref.watch(medicationRepositoryProvider);
    return await repository.getAllMedications();
  }

  Future<void> addMedication(MedicationEntry medication) async {
    final repository = ref.read(medicationRepositoryProvider);
    await repository.addMedication(medication);
    ref.invalidateSelf();
  }

  Future<void> updateMedication(MedicationEntry medication) async {
    final repository = ref.read(medicationRepositoryProvider);
    await repository.updateMedication(medication);
    ref.invalidateSelf();
  }

  Future<void> deleteMedication(String id) async {
    final repository = ref.read(medicationRepositoryProvider);
    await repository.deleteMedication(id);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<MedicationEntry>> medicationsByPetId(
    MedicationsByPetIdRef ref, String petId) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return await repository.getMedicationsByPetId(petId);
}

@riverpod
Future<List<MedicationEntry>> activeMedicationsByPetId(
    ActiveMedicationsByPetIdRef ref, String petId) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return await repository.getActiveMedicationsByPetId(petId);
}

@riverpod
Future<List<MedicationEntry>> inactiveMedicationsByPetId(
    InactiveMedicationsByPetIdRef ref, String petId) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return await repository.getInactiveMedicationsByPetId(petId);
}

// Appointment Providers
@riverpod
class AppointmentProvider extends _$AppointmentProvider {
  @override
  Future<List<AppointmentEntry>> build() async {
    final repository = ref.watch(appointmentRepositoryProvider);
    return await repository.getAllAppointments();
  }

  Future<void> addAppointment(AppointmentEntry appointment) async {
    final repository = ref.read(appointmentRepositoryProvider);
    await repository.addAppointment(appointment);
    ref.invalidateSelf();
  }

  Future<void> updateAppointment(AppointmentEntry appointment) async {
    final repository = ref.read(appointmentRepositoryProvider);
    await repository.updateAppointment(appointment);
    ref.invalidateSelf();
  }

  Future<void> deleteAppointment(String id) async {
    final repository = ref.read(appointmentRepositoryProvider);
    await repository.deleteAppointment(id);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<AppointmentEntry>> appointmentsByPetId(
    AppointmentsByPetIdRef ref, String petId) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return await repository.getAppointmentsByPetId(petId);
}

@riverpod
Future<List<AppointmentEntry>> appointmentsByDateRange(
    AppointmentsByDateRangeRef ref,
    String petId,
    DateTime start,
    DateTime end) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return await repository.getAppointmentsByDateRange(petId, start, end);
}

// Report Providers
@riverpod
class ReportProvider extends _$ReportProvider {
  @override
  Future<List<ReportEntry>> build() async {
    final repository = ref.watch(reportRepositoryProvider);
    return await repository.getAllReports();
  }

  Future<void> addReport(ReportEntry report) async {
    final repository = ref.read(reportRepositoryProvider);
    await repository.addReport(report);
    ref.invalidateSelf();
  }

  Future<void> updateReport(ReportEntry report) async {
    final repository = ref.read(reportRepositoryProvider);
    await repository.updateReport(report);
    ref.invalidateSelf();
  }

  Future<void> deleteReport(String id) async {
    final repository = ref.read(reportRepositoryProvider);
    await repository.deleteReport(id);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<ReportEntry>> reportsByPetId(
    ReportsByPetIdRef ref, String petId) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.getReportsByPetId(petId);
}

@riverpod
Future<List<ReportEntry>> reportsByDateRange(ReportsByDateRangeRef ref,
    String petId, DateTime start, DateTime end) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.getReportsByDateRange(petId, start, end);
}

@riverpod
Future<List<ReportEntry>> reportsByType(
    ReportsByTypeRef ref, String petId, String reportType) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.getReportsByType(petId, reportType);
}
