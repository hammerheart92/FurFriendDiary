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
    return box.values
        .where((appointment) => appointment.petId == petId)
        .toList();
  }

  @override
  Stream<List<AppointmentEntry>> getAppointmentsByPetIdStream(String petId) {
    return Stream<List<AppointmentEntry>>.multi((controller) {
      final box = HiveBoxes.getAppointments();

      // Emit initial state
      final initialAppointments = box.values
          .where((appointment) => appointment.petId == petId)
          .toList();
      controller.add(initialAppointments);

      // Listen to changes
      final subscription = box.watch().listen((_) {
        final appointments = box.values
            .where((appointment) => appointment.petId == petId)
            .toList();
        controller.add(appointments);
      });

      // Cleanup
      controller.onCancel = () => subscription.cancel();
    });
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
  Future<List<AppointmentEntry>> getAppointmentsByDateRange(
      String petId, DateTime start, DateTime end) async {
    final box = HiveBoxes.getAppointments();
    return box.values
        .where((appointment) =>
            appointment.petId == petId &&
            appointment.appointmentDate.isAfter(start) &&
            appointment.appointmentDate.isBefore(end))
        .toList();
  }
}

@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  return AppointmentRepositoryImpl();
}
