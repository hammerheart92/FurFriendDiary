import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../local/hive_boxes.dart';

part 'appointment_repository_impl.g.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  @override
  Future<List<AppointmentEntry>> getAllAppointments() async {
    final box = HiveBoxes.getAppointments();
    return box.values.toList();
  }

  @override
  Future<List<AppointmentEntry>> getAppointmentsByPetId(String petId) async {
    final box = HiveBoxes.getAppointments();
    return box.values.where((appointment) => appointment.petId == petId).toList();
  }

  @override
  Future<void> addAppointment(AppointmentEntry appointment) async {
    final box = HiveBoxes.getAppointments();
    await box.put(appointment.id, appointment);
  }

  @override
  Future<void> updateAppointment(AppointmentEntry appointment) async {
    final box = HiveBoxes.getAppointments();
    await box.put(appointment.id, appointment);
  }

  @override
  Future<void> deleteAppointment(String id) async {
    final box = HiveBoxes.getAppointments();
    await box.delete(id);
  }

  @override
  Future<AppointmentEntry?> getAppointmentById(String id) async {
    final box = HiveBoxes.getAppointments();
    return box.get(id);
  }

  @override
  Future<List<AppointmentEntry>> getUpcomingAppointments(String petId) async {
    final box = HiveBoxes.getAppointments();
    final now = DateTime.now();
    return box.values
        .where((appointment) => 
            appointment.petId == petId &&
            !appointment.isCompleted &&
            appointment.dateTime.isAfter(now))
        .toList();
  }

  @override
  Future<List<AppointmentEntry>> getCompletedAppointments(String petId) async {
    final box = HiveBoxes.getAppointments();
    return box.values
        .where((appointment) => 
            appointment.petId == petId &&
            appointment.isCompleted)
        .toList();
  }
}

@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  return AppointmentRepositoryImpl();
}
