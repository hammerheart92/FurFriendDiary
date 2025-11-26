import '../../domain/models/appointment_entry.dart';
import '../../domain/models/medication_entry.dart';
import '../../data/services/protocols/schedule_models.dart';

/// Sealed class hierarchy for type-safe upcoming care events
///
/// This provides a unified interface for displaying different types of care events
/// (vaccinations, deworming, appointments, medications) in the UI.
sealed class UpcomingCareEvent {
  DateTime get scheduledDate;
  String get title;
  String get description;
  String get icon;
  String get eventType;

  /// Sort events by scheduled date
  int compareTo(UpcomingCareEvent other) {
    return scheduledDate.compareTo(other.scheduledDate);
  }
}

/// Vaccination event from a protocol schedule
class VaccinationEvent extends UpcomingCareEvent {
  final VaccinationScheduleEntry entry;

  VaccinationEvent(this.entry);

  @override
  DateTime get scheduledDate => entry.scheduledDate;

  @override
  String get title => entry.vaccineName;

  @override
  String get description {
    final parts = <String>[];
    parts.add('Dose ${entry.stepIndex + 1}');
    if (entry.notes != null && entry.notes!.isNotEmpty) {
      parts.add(entry.notes!);
    }
    if (entry.isRequired) {
      parts.add('Required');
    }
    return parts.isEmpty ? 'Vaccination' : parts.join(' - ');
  }

  @override
  String get icon => '💉';

  @override
  String get eventType => 'vaccination';

  /// Whether this is an overdue vaccination
  bool get isOverdue => scheduledDate.isBefore(DateTime.now());

  /// Whether this is coming up soon (within 7 days)
  bool get isUpcomingSoon {
    final now = DateTime.now();
    final diff = scheduledDate.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }
}

/// Deworming event from a protocol schedule
class DewormingEvent extends UpcomingCareEvent {
  final DewormingScheduleEntry entry;

  DewormingEvent(this.entry);

  @override
  DateTime get scheduledDate => entry.scheduledDate;

  @override
  String get title => 'Deworming Treatment';

  @override
  String get description {
    final parts = <String>[entry.dewormingType];
    if (entry.productName != null && entry.productName!.isNotEmpty) {
      parts.add(entry.productName!);
    }
    if (entry.notes != null && entry.notes!.isNotEmpty) {
      parts.add(entry.notes!);
    }
    return parts.join(' - ');
  }

  @override
  String get icon => '🐛';

  @override
  String get eventType => 'deworming';

  /// Whether this is an overdue treatment
  bool get isOverdue => scheduledDate.isBefore(DateTime.now());

  /// Whether this is coming up soon (within 7 days)
  bool get isUpcomingSoon {
    final now = DateTime.now();
    final diff = scheduledDate.difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }
}

/// Appointment event from existing appointments
class AppointmentEvent extends UpcomingCareEvent {
  final AppointmentEntry entry;

  AppointmentEvent(this.entry);

  @override
  DateTime get scheduledDate => entry.appointmentDate;

  @override
  String get title => entry.reason;

  @override
  String get description {
    final parts = <String>[];
    if (entry.veterinarian.isNotEmpty) {
      parts.add('Dr. ${entry.veterinarian}');
    }
    if (entry.clinic.isNotEmpty) {
      parts.add(entry.clinic);
    }
    if (entry.notes != null && entry.notes!.isNotEmpty) {
      parts.add(entry.notes!);
    }
    return parts.isEmpty ? 'Veterinary Appointment' : parts.join(' - ');
  }

  @override
  String get icon => '📅';

  @override
  String get eventType => 'appointment';

  /// Whether this appointment is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  /// Whether this is coming up soon (within 3 days)
  bool get isUpcomingSoon {
    final now = DateTime.now();
    final diff = scheduledDate.difference(now).inDays;
    return diff >= 0 && diff <= 3;
  }
}

/// Medication event from medication schedules
class MedicationEvent extends UpcomingCareEvent {
  final MedicationEntry entry;

  MedicationEvent(this.entry);

  @override
  DateTime get scheduledDate {
    // For medications, always use startDate as the primary scheduled date
    // This represents when the medication starts, not when it ends
    // For single-dose medications (like vaccinations), startDate is the dose date
    return entry.startDate;
  }

  @override
  String get title => entry.medicationName;

  @override
  String get description {
    final parts = <String>[];
    if (entry.dosage.isNotEmpty) {
      parts.add(entry.dosage);
    }
    if (entry.frequency.isNotEmpty) {
      parts.add(entry.frequency);
    }
    return parts.isEmpty ? 'Medication' : parts.join(' - ');
  }

  @override
  String get icon => '💊';

  @override
  String get eventType => 'medication';

  /// Medications are never "overdue" - they're either active, completed, or upcoming
  /// This prevents the confusing "Overdue by X days" display for ongoing treatments
  bool get isOverdue {
    return false;
  }

  /// Whether this medication ends soon (within 3 days)
  bool get isUpcomingSoon {
    if (entry.endDate == null) return false;
    final now = DateTime.now();
    final diff = entry.endDate!.difference(now).inDays;
    return diff >= 0 && diff <= 3;
  }

  /// Whether this is a vaccination (protocol-linked medication)
  bool get isVaccination {
    // Check if notes contain protocol metadata (Week 2 temporary solution)
    return entry.notes?.contains('"protocolId"') ?? false;
  }
}
