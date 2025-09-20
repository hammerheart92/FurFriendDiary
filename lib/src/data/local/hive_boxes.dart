import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/pet_profile.dart';
import '../../domain/models/feeding_entry.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/walk.dart';
import 'hive_manager.dart';

class HiveBoxes {
  static const String petProfileBox = 'pet_profiles';
  static const String feedingBox = 'feedings';
  static const String medicationBox = 'medications';
  static const String appointmentBox = 'appointments';
  static const String walkBox = 'walks';
  static const String settingsBox = 'settings';

  static Box<PetProfile> getPetProfiles() {
    try {
      return HiveManager.instance.petProfileBox;
    } catch (e) {
      print("🚨 ERROR: getPetProfiles() failed: $e");
      rethrow;
    }
  }
  
  static Box<FeedingEntry> getFeedings() {
    try {
      return HiveManager.instance.feedingBox;
    } catch (e) {
      print("🚨 ERROR: getFeedings() failed: $e");
      rethrow;
    }
  }
  
  static Box<MedicationEntry> getMedications() {
    try {
      return HiveManager.instance.medicationBox;
    } catch (e) {
      print("🚨 ERROR: getMedications() failed: $e");
      rethrow;
    }
  }
  
  static Box<AppointmentEntry> getAppointments() {
    try {
      return HiveManager.instance.appointmentBox;
    } catch (e) {
      print("🚨 ERROR: getAppointments() failed: $e");
      rethrow;
    }
  }
  
  static Box<Walk> getWalks() {
    try {
      return HiveManager.instance.walkBox;
    } catch (e) {
      print("🚨 ERROR: getWalks() failed: $e");
      rethrow;
    }
  }
  
  static Box<dynamic> getSettings() {
    try {
      return HiveManager.instance.settingsBox;
    } catch (e) {
      print("🚨 ERROR: getSettings() failed: $e");
      rethrow;
    }
  }
  
  static Box<dynamic> getAppPrefs() {
    try {
      return HiveManager.instance.appPrefsBox;
    } catch (e) {
      print("🚨 ERROR: getAppPrefs() failed: $e");
      rethrow;
    }
  }
}
