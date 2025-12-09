import '../../domain/models/appointment_entry.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/vaccination_event.dart' as domain;
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
    // Note: This description is locale-aware. The UI layer can optionally
    // replace static words like "Dose" and "Required" with localized strings,
    // but notesRo provides Romanian translations for protocol-specific notes.
    final parts = <String>[];
    parts
        .add('Dose ${entry.stepIndex + 1}'); // Will use l10n.doseNumber() in UI

    // Use notesRo if available (Romanian), otherwise fall back to notes (English)
    // The UI layer should check locale and provide notesRo when appropriate
    if (entry.notes != null && entry.notes!.isNotEmpty) {
      parts.add(entry.notes!);
    }

    if (entry.isRequired) {
      parts.add('Required'); // Will use l10n.requiredVaccine in UI
    }
    return parts.isEmpty
        ? 'Vaccination'
        : parts.join(' - '); // Will use l10n.vaccination in UI
  }

  /// Get localized description based on locale
  /// Use this method from UI layer to get properly localized description
  String getLocalizedDescription(String localeCode) {
    final isRomanian = localeCode == 'ro';
    final parts = <String>[];

    // Localized dose label
    final doseLabel = isRomanian
        ? 'Doza ${entry.stepIndex + 1}'
        : 'Dose ${entry.stepIndex + 1}';
    parts.add(doseLabel);

    // Use Romanian notes if locale is Romanian, otherwise use English
    final notes =
        isRomanian && entry.notesRo != null && entry.notesRo!.isNotEmpty
            ? entry.notesRo!
            : entry.notes;

    if (notes != null && notes.isNotEmpty) {
      parts.add(notes);
    }

    if (entry.isRequired) {
      // Localized required label
      final requiredLabel = isRomanian ? 'Obligatoriu' : 'Required';
      parts.add(requiredLabel);
    }

    final defaultLabel = isRomanian ? 'Vaccinare' : 'Vaccination';
    final result = parts.isEmpty ? defaultLabel : parts.join(' - ');
    return result;
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

/// Vaccination record event from actual repository records
///
/// Unlike VaccinationEvent (protocol schedules), this represents actual
/// vaccination records stored in the repository with a nextDueDate.
/// This allows navigation to specific vaccination detail screens.
class VaccinationRecordEvent extends UpcomingCareEvent {
  final domain.VaccinationEvent record;

  VaccinationRecordEvent(this.record);

  @override
  DateTime get scheduledDate => record.nextDueDate ?? record.administeredDate;

  @override
  String get title => record.vaccineType;

  @override
  String get description {
    final parts = <String>[];
    if (record.veterinarianName != null &&
        record.veterinarianName!.isNotEmpty) {
      parts.add('Dr. ${record.veterinarianName}');
    }
    if (record.clinicName != null && record.clinicName!.isNotEmpty) {
      parts.add(record.clinicName!);
    }
    if (record.notes != null && record.notes!.isNotEmpty) {
      parts.add(record.notes!);
    }
    return parts.isEmpty ? 'Vaccination' : parts.join(' - ');
  }

  /// Get localized description based on locale
  /// Use this method from UI layer to get properly localized description
  String getLocalizedDescription(String localeCode) {
    final parts = <String>[];

    // Add veterinarian name if available
    if (record.veterinarianName != null &&
        record.veterinarianName!.isNotEmpty) {
      parts.add('Dr. ${record.veterinarianName}');
    }

    // Add clinic name if available
    if (record.clinicName != null && record.clinicName!.isNotEmpty) {
      parts.add(record.clinicName!);
    }

    // Use Romanian notes if locale is Romanian and notesRo is available
    final notes = localeCode == 'ro' &&
            record.notesRo != null &&
            record.notesRo!.isNotEmpty
        ? record.notesRo!
        : record.notes;

    if (notes != null && notes.isNotEmpty) {
      parts.add(notes);
    }

    final defaultLabel = localeCode == 'ro' ? 'Vaccinare' : 'Vaccination';
    final result = parts.isEmpty ? defaultLabel : parts.join(' - ');
    return result;
  }

  @override
  String get icon => '💉';

  @override
  String get eventType => 'vaccination_record';

  /// The unique ID for navigation to detail screen
  String get id => record.id;

  /// Whether this vaccination is overdue
  bool get isOverdue {
    if (record.nextDueDate == null) return false;
    return record.nextDueDate!.isBefore(DateTime.now());
  }

  /// Whether this is coming up soon (within 7 days)
  bool get isUpcomingSoon {
    if (record.nextDueDate == null) return false;
    final now = DateTime.now();
    final diff = record.nextDueDate!.difference(now).inDays;
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
  String get title =>
      'Deworming Treatment'; // Placeholder - UI layer should use l10n.dewormingTreatment

  @override
  String get description {
    // Note: dewormingType and notes are displayed as-is from JSON
    // For locale-aware display, the UI layer should check locale and use
    // appropriate translations from protocol JSON (descriptionRo field)
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
    return parts.isEmpty
        ? 'Veterinary Appointment'
        : parts.join(' - '); // Will use l10n.veterinaryAppointment in UI
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
    return parts.isEmpty
        ? 'Medication'
        : parts.join(' - '); // Will use l10n.medication in UI
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
