import '../models/appointment_entry.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntry>> getAllAppointments();
  Future<List<AppointmentEntry>> getAppointmentsByPetId(String petId);
  Future<void> addAppointment(AppointmentEntry appointment);
  Future<void> updateAppointment(AppointmentEntry appointment);
  Future<void> deleteAppointment(String id);
  Future<AppointmentEntry?> getAppointmentById(String id);
  Future<List<AppointmentEntry>> getUpcomingAppointments(String petId);
  Future<List<AppointmentEntry>> getCompletedAppointments(String petId);
}
