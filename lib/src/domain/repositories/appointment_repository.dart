import '../models/appointment_entry.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntry>> getAllAppointments();
  Future<List<AppointmentEntry>> getAppointmentsByPetId(String petId);
  Future<void> addAppointment(AppointmentEntry appointment);
  Future<void> updateAppointment(AppointmentEntry appointment);
  Future<void> deleteAppointment(String id);
  Future<AppointmentEntry?> getAppointmentById(String id);
  Future<List<AppointmentEntry>> getAppointmentsByDateRange(String petId, DateTime start, DateTime end);
}
