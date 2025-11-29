/// Schedule models for protocol engine calculations
///
/// These models represent calculated schedules and suggestions that are NOT
/// persisted to Hive. They are temporary data structures used to communicate
/// schedule information from ProtocolEngineService to the presentation layer.

/// Represents a calculated vaccination schedule entry (not persisted)
///
/// This is a computed schedule item based on a VaccinationProtocol step.
/// It contains the calculated date when a vaccine should be administered.
class VaccinationScheduleEntry {
  /// Index of the step in the VaccinationProtocol.steps list
  final int stepIndex;

  /// Name of the vaccine (e.g., "DHPPiL", "Rabies")
  final String vaccineName;

  /// Calculated date when this vaccine should be administered
  final DateTime scheduledDate;

  /// Optional notes from the protocol step or calculated information
  final String? notes;

  /// Whether this vaccination is required (core) or optional (non-core)
  final bool isRequired;

  /// Helper: True if the scheduled date is in the past
  bool get isInPast => scheduledDate.isBefore(DateTime.now());

  /// Helper: True if the scheduled date is within the next 30 days
  bool get isDueSoon {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return scheduledDate.isAfter(now) && scheduledDate.isBefore(thirtyDaysFromNow);
  }

  /// Helper: True if this is an overdue vaccination
  bool get isOverdue => isInPast;

  VaccinationScheduleEntry({
    required this.stepIndex,
    required this.vaccineName,
    required this.scheduledDate,
    this.notes,
    required this.isRequired,
  });

  /// Create a copy with modified fields
  VaccinationScheduleEntry copyWith({
    int? stepIndex,
    String? vaccineName,
    DateTime? scheduledDate,
    String? notes,
    bool? isRequired,
  }) {
    return VaccinationScheduleEntry(
      stepIndex: stepIndex ?? this.stepIndex,
      vaccineName: vaccineName ?? this.vaccineName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      notes: notes ?? this.notes,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  @override
  String toString() {
    return 'VaccinationScheduleEntry('
        'stepIndex: $stepIndex, '
        'vaccineName: $vaccineName, '
        'scheduledDate: $scheduledDate, '
        'isRequired: $isRequired, '
        'isOverdue: $isOverdue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VaccinationScheduleEntry &&
        other.stepIndex == stepIndex &&
        other.vaccineName == vaccineName &&
        other.scheduledDate == scheduledDate &&
        other.notes == notes &&
        other.isRequired == isRequired;
  }

  @override
  int get hashCode {
    return stepIndex.hashCode ^
        vaccineName.hashCode ^
        scheduledDate.hashCode ^
        notes.hashCode ^
        isRequired.hashCode;
  }
}

/// Represents a calculated deworming schedule entry (not persisted)
///
/// This is a computed schedule item based on a DewormingProtocol schedule.
/// It contains the calculated date when deworming treatment should be given.
class DewormingScheduleEntry {
  /// Type of deworming treatment: 'external' (fleas/ticks) or 'internal' (worms)
  final String dewormingType;

  /// Calculated date when this treatment should be administered
  final DateTime scheduledDate;

  /// Optional product name (e.g., "Bravecto", "Milbemax")
  final String? productName;

  /// Optional notes from the protocol schedule
  final String? notes;

  /// Romanian translation of notes (optional, for localization)
  final String? notesRo;

  /// Helper: True if the scheduled date is in the past
  bool get isInPast => scheduledDate.isBefore(DateTime.now());

  /// Helper: True if the scheduled date is within the next 30 days
  bool get isDueSoon {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return scheduledDate.isAfter(now) && scheduledDate.isBefore(thirtyDaysFromNow);
  }

  /// Helper: True if this is an overdue treatment
  bool get isOverdue => isInPast;

  DewormingScheduleEntry({
    required this.dewormingType,
    required this.scheduledDate,
    this.productName,
    this.notes,
    this.notesRo,
  });

  /// Create a copy with modified fields
  DewormingScheduleEntry copyWith({
    String? dewormingType,
    DateTime? scheduledDate,
    String? productName,
    String? notes,
    String? notesRo,
  }) {
    return DewormingScheduleEntry(
      dewormingType: dewormingType ?? this.dewormingType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      productName: productName ?? this.productName,
      notes: notes ?? this.notes,
      notesRo: notesRo ?? this.notesRo,
    );
  }

  @override
  String toString() {
    return 'DewormingScheduleEntry('
        'dewormingType: $dewormingType, '
        'scheduledDate: $scheduledDate, '
        'productName: $productName, '
        'isOverdue: $isOverdue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DewormingScheduleEntry &&
        other.dewormingType == dewormingType &&
        other.scheduledDate == scheduledDate &&
        other.productName == productName &&
        other.notes == notes &&
        other.notesRo == notesRo;
  }

  @override
  int get hashCode {
    return dewormingType.hashCode ^
        scheduledDate.hashCode ^
        productName.hashCode ^
        notes.hashCode ^
        notesRo.hashCode;
  }
}

/// Represents a suggested appointment based on upcoming protocols (not persisted)
///
/// This is a computed suggestion that combines multiple due protocols
/// (vaccinations, deworming) into a single recommended vet appointment.
class AppointmentSuggestion {
  /// Suggested date for the appointment (typically the earliest due protocol date)
  final DateTime suggestedDate;

  /// Human-readable reason for the appointment
  /// Example: "Rabies vaccination + Annual checkup"
  final String reason;

  /// List of protocol IDs that are linked to this suggestion
  final List<String> linkedProtocolIds;

  /// Vaccinations that are due around this date
  final List<VaccinationScheduleEntry> dueVaccinations;

  /// Deworming treatments that are due around this date
  final List<DewormingScheduleEntry> dueDeworming;

  /// Preparation checklist for the appointment
  /// Example: "Bring vaccine card\n• Fast pet 12h\n• Note behavioral changes"
  final String preparationChecklist;

  /// Helper: Total number of protocols combined in this suggestion
  int get totalProtocols => dueVaccinations.length + dueDeworming.length;

  /// Helper: True if any vaccination is overdue
  bool get hasOverdueVaccinations =>
      dueVaccinations.any((v) => v.isOverdue);

  /// Helper: True if any deworming is overdue
  bool get hasOverdueDeworming => dueDeworming.any((d) => d.isOverdue);

  AppointmentSuggestion({
    required this.suggestedDate,
    required this.reason,
    required this.linkedProtocolIds,
    required this.dueVaccinations,
    required this.dueDeworming,
    required this.preparationChecklist,
  });

  /// Create a copy with modified fields
  AppointmentSuggestion copyWith({
    DateTime? suggestedDate,
    String? reason,
    List<String>? linkedProtocolIds,
    List<VaccinationScheduleEntry>? dueVaccinations,
    List<DewormingScheduleEntry>? dueDeworming,
    String? preparationChecklist,
  }) {
    return AppointmentSuggestion(
      suggestedDate: suggestedDate ?? this.suggestedDate,
      reason: reason ?? this.reason,
      linkedProtocolIds: linkedProtocolIds ?? this.linkedProtocolIds,
      dueVaccinations: dueVaccinations ?? this.dueVaccinations,
      dueDeworming: dueDeworming ?? this.dueDeworming,
      preparationChecklist: preparationChecklist ?? this.preparationChecklist,
    );
  }

  @override
  String toString() {
    return 'AppointmentSuggestion('
        'suggestedDate: $suggestedDate, '
        'reason: $reason, '
        'totalProtocols: $totalProtocols, '
        'hasOverdueVaccinations: $hasOverdueVaccinations, '
        'hasOverdueDeworming: $hasOverdueDeworming)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppointmentSuggestion &&
        other.suggestedDate == suggestedDate &&
        other.reason == reason &&
        other.preparationChecklist == preparationChecklist;
    // Note: Not comparing lists for equality to keep == simple
  }

  @override
  int get hashCode {
    return suggestedDate.hashCode ^
        reason.hashCode ^
        preparationChecklist.hashCode;
  }
}
