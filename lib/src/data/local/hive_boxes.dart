import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../../domain/models/pet_profile.dart';
import '../../domain/models/feeding_entry.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/report_entry.dart';
import '../../domain/models/walk.dart';
import '../../domain/models/vaccination_event.dart';
import 'hive_manager.dart';

class HiveBoxes {
  static final logger = Logger();
  static const String petProfileBox = 'pet_profiles';
  static const String feedingBox = 'feedings';
  static const String medicationBox = 'medications';
  static const String appointmentBox = 'appointments';
  static const String reportBox = 'reports';
  static const String walkBox = 'walks';
  static const String settingsBox = 'settings';

  static Box<PetProfile> getPetProfiles() {
    try {
      return HiveManager.instance.petProfileBox;
    } catch (e) {
      logger.e("🚨 ERROR: getPetProfiles() failed: $e");
      rethrow;
    }
  }

  static Box<FeedingEntry> getFeedings() {
    try {
      return HiveManager.instance.feedingBox;
    } catch (e) {
      logger.e("🚨 ERROR: getFeedings() failed: $e");
      rethrow;
    }
  }

  static Box<MedicationEntry> getMedications() {
    try {
      return HiveManager.instance.medicationBox;
    } catch (e) {
      logger.e("🚨 ERROR: getMedications() failed: $e");
      rethrow;
    }
  }

  static Box<AppointmentEntry> getAppointments() {
    try {
      return HiveManager.instance.appointmentBox;
    } catch (e) {
      logger.e("🚨 ERROR: getAppointments() failed: $e");
      rethrow;
    }
  }

  static Box<ReportEntry> getReports() {
    try {
      return HiveManager.instance.reportBox;
    } catch (e) {
      logger.e("🚨 ERROR: getReports() failed: $e");
      rethrow;
    }
  }

  static Box<Walk> getWalks() {
    try {
      return HiveManager.instance.walkBox;
    } catch (e) {
      logger.e("🚨 ERROR: getWalks() failed: $e");
      rethrow;
    }
  }

  static Box<dynamic> getSettings() {
    try {
      return HiveManager.instance.settingsBox;
    } catch (e) {
      logger.e("🚨 ERROR: getSettings() failed: $e");
      rethrow;
    }
  }

  static Box<dynamic> getAppPrefs() {
    try {
      return HiveManager.instance.appPrefsBox;
    } catch (e) {
      logger.e("🚨 ERROR: getAppPrefs() failed: $e");
      rethrow;
    }
  }

  static Box<VaccinationEvent> getVaccinationEvents() {
    try {
      return HiveManager.instance.vaccinationEventBox;
    } catch (e) {
      logger.e("🚨 ERROR: getVaccinationEvents() failed: $e");
      rethrow;
    }
  }
}
