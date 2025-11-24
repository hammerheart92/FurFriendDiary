import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/reminder.dart';
import '../../../domain/models/protocols/reminder_config.dart';
import '../../../domain/repositories/protocols/reminder_config_repository.dart';
import '../../repositories/protocols/reminder_config_repository_impl.dart';
import '../notification_service.dart';
import 'schedule_models.dart';
import '../../../domain/models/appointment_entry.dart';
import '../../../domain/models/medication_entry.dart';

part 'reminder_scheduler_service.g.dart';

/// Enhanced notification scheduling service using ReminderConfig settings
///
/// ReminderSchedulerService provides smart, configurable reminder scheduling
/// for pet care events. It:
/// - Supports multiple reminder offsets per event (e.g., 1 day, 7 days before)
/// - Integrates with ReminderConfig for per-pet, per-event-type customization
/// - Handles vaccination, deworming, appointment, and medication reminders
/// - Smart date filtering (skips past dates, deduplicates)
/// - Unique notification ID generation for precise cancellation
///
/// **Usage Example:**
/// ```dart
/// final service = ref.watch(reminderSchedulerServiceProvider);
///
/// // Schedule vaccination reminders
/// final schedule = await protocolEngine.generateVaccinationSchedule(...);
/// final reminderIds = await service.scheduleVaccinationReminders(
///   petId: 'pet-123',
///   vaccinations: schedule,
/// );
///
/// // Cancel reminders when rescheduling
/// await service.cancelReminders(
///   petId: 'pet-123',
///   eventType: 'vaccination',
///   eventId: 'vacc-456',
/// );
/// ```
class ReminderSchedulerService {
  final NotificationService notificationService;
  final ReminderConfigRepository reminderConfigRepository;
  final Logger logger;

  // Default reminder offsets (days before event) when no ReminderConfig exists
  static const Map<String, List<int>> defaultReminderDays = {
    'vaccination': [1, 7], // 1 day and 1 week before
    'deworming': [1, 7], // 1 day and 1 week before
    'appointment': [1, 7], // 1 day and 1 week before
    'medication': [0], // On the day only (medication has its own scheduling)
  };

  // Default reminder time of day (9:00 AM)
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;

  ReminderSchedulerService({
    required this.notificationService,
    required this.reminderConfigRepository,
    Logger? logger,
  }) : logger = logger ?? Logger();

  // ============================================================================
  // CORE METHOD 1: Schedule Protocol Reminders (Generic)
  // ============================================================================

  /// Schedule reminders for a generic protocol event
  ///
  /// **Algorithm:**
  /// 1. Fetch ReminderConfig for petId + eventType
  /// 2. If not found or disabled, use defaults or skip
  /// 3. Calculate reminder dates using calculateReminderDates()
  /// 4. Create Reminder objects with unique IDs
  /// 5. Schedule via NotificationService
  ///
  /// **Parameters:**
  /// - `petId`: ID of the pet
  /// - `eventType`: 'vaccination', 'deworming', 'appointment', 'medication'
  /// - `eventId`: Unique ID of the event (for cancellation later)
  /// - `eventDate`: When the event is scheduled
  /// - `eventTitle`: Display title for notification
  /// - `eventDescription`: Optional description
  ///
  /// **Returns:**
  /// - `List<String>` of scheduled reminder IDs
  ///
  /// **Example:**
  /// ```dart
  /// final reminderIds = await service.scheduleProtocolReminders(
  ///   petId: 'pet-123',
  ///   eventType: 'vaccination',
  ///   eventId: 'vacc-456',
  ///   eventDate: DateTime(2025, 12, 15),
  ///   eventTitle: 'Rabies Vaccination',
  ///   eventDescription: 'Annual booster at City Vet',
  /// );
  /// // Returns: ['rem-001', 'rem-002'] (for 1-day and 7-day reminders)
  /// ```
  Future<List<String>> scheduleProtocolReminders({
    required String petId,
    required String eventType,
    required String eventId,
    required DateTime eventDate,
    required String eventTitle,
    String? eventDescription,
  }) async {
    logger.i(
        'Scheduling protocol reminders: petId=$petId, eventType=$eventType, eventId=$eventId, eventDate=$eventDate');

    // Validate event date is not in past
    if (eventDate.isBefore(DateTime.now())) {
      logger.w('Event date in past: $eventDate. Cannot schedule reminders.');
      return [];
    }

    // Validate event type
    if (!defaultReminderDays.containsKey(eventType)) {
      logger.e('Invalid event type: $eventType');
      return [];
    }

    // Fetch ReminderConfig for this pet and event type
    final configs = await reminderConfigRepository.getByPetIdAndEventType(
        petId, eventType);
    final config = configs.isNotEmpty ? configs.first : null;

    // Determine reminder offsets
    List<int> reminderOffsets;
    if (config == null) {
      logger.w(
          'No ReminderConfig for pet=$petId, eventType=$eventType. Using defaults.');
      reminderOffsets = defaultReminderDays[eventType] ?? [1];
    } else if (!config.isEnabled) {
      logger.i(
          'ReminderConfig disabled for pet=$petId, eventType=$eventType. Skipping.');
      return [];
    } else {
      reminderOffsets = config.reminderDays;
    }

    // Calculate reminder dates
    final reminderDates = calculateReminderDates(
      eventDate: eventDate,
      reminderDays: reminderOffsets,
    );

    if (reminderDates.isEmpty) {
      logger.w('No valid reminder dates after filtering past dates.');
      return [];
    }

    // Schedule each reminder
    final scheduledIds = <String>[];
    for (final entry in reminderDates.entries) {
      try {
        final offsetDays = entry.key;
        final reminderDate = entry.value;

        // Generate unique reminder ID
        final reminderId =
            generateReminderId(petId, eventType, eventId, offsetDays);

        // Format notification content
        final content = formatNotificationContent(
          eventType: eventType,
          eventTitle: eventTitle,
          eventDate: eventDate,
          eventDescription: eventDescription,
          offsetDays: offsetDays,
        );

        // Create Reminder object
        final reminder = Reminder(
          id: reminderId,
          petId: petId,
          type: _mapEventTypeToReminderType(eventType),
          title: content['title']!,
          description: content['body']!,
          scheduledTime: reminderDate,
          frequency: ReminderFrequency.once,
          linkedEntityId: eventId,
        );

        // Schedule via NotificationService
        await notificationService.scheduleReminder(reminder);
        scheduledIds.add(reminderId);

        logger.d(
            'Scheduled reminder: id=$reminderId, date=$reminderDate, offset=${offsetDays}d');
      } catch (e, stackTrace) {
        logger.e('Failed to schedule reminder for offset=${entry.key}: $e');
        logger.e('Stack trace: $stackTrace');
        // Continue with next reminder instead of failing completely
      }
    }

    logger.i(
        'Successfully scheduled ${scheduledIds.length}/${reminderDates.length} reminders for event $eventId');
    return scheduledIds;
  }

  // ============================================================================
  // CORE METHOD 2: Schedule Vaccination Reminders
  // ============================================================================

  /// Schedule reminders for vaccination schedule entries
  ///
  /// **Algorithm:**
  /// 1. Fetch ReminderConfig for vaccination events
  /// 2. For each VaccinationScheduleEntry:
  ///    - Generate unique event ID from stepIndex + vaccineName
  ///    - Call scheduleProtocolReminders() with 'vaccination' eventType
  /// 3. Return all scheduled reminder IDs
  ///
  /// **Parameters:**
  /// - `petId`: ID of the pet
  /// - `vaccinations`: List of VaccinationScheduleEntry from ProtocolEngineService
  ///
  /// **Returns:**
  /// - `Map<int, List<String>>` mapping stepIndex to reminder IDs
  ///
  /// **Example:**
  /// ```dart
  /// final schedule = await protocolEngine.generateVaccinationSchedule(...);
  /// final reminderMap = await reminderScheduler.scheduleVaccinationReminders(
  ///   petId: 'pet-123',
  ///   vaccinations: schedule,
  /// );
  /// // Returns: {0: ['rem-001', 'rem-002'], 1: ['rem-003', 'rem-004']}
  /// ```
  Future<Map<int, List<String>>> scheduleVaccinationReminders({
    required String petId,
    required List<VaccinationScheduleEntry> vaccinations,
  }) async {
    logger.i(
        'Scheduling vaccination reminders: petId=$petId, count=${vaccinations.length}');

    final scheduledReminders = <int, List<String>>{};

    for (final entry in vaccinations) {
      // Skip past vaccination dates
      if (entry.scheduledDate.isBefore(DateTime.now())) {
        logger.d(
            'Skipping past vaccination: ${entry.vaccineName} on ${entry.scheduledDate}');
        continue;
      }

      // Generate unique event ID
      final eventId =
          'vacc_${entry.stepIndex}_${entry.vaccineName.replaceAll(' ', '_')}';

      // Construct title and description
      final title = '${entry.vaccineName} Vaccination';
      final description = entry.notes ??
          'Step ${entry.stepIndex + 1}${entry.isRequired ? ' (Required)' : ''}';

      // Schedule reminders for this vaccination
      final reminderIds = await scheduleProtocolReminders(
        petId: petId,
        eventType: 'vaccination',
        eventId: eventId,
        eventDate: entry.scheduledDate,
        eventTitle: title,
        eventDescription: description,
      );

      scheduledReminders[entry.stepIndex] = reminderIds;
      logger.d(
          'Scheduled ${reminderIds.length} reminders for vaccination step ${entry.stepIndex}');
    }

    logger.i(
        'Successfully scheduled reminders for ${scheduledReminders.length} vaccinations');
    return scheduledReminders;
  }

  // ============================================================================
  // CORE METHOD 3: Schedule Deworming Reminders
  // ============================================================================

  /// Schedule reminders for deworming schedule entries
  ///
  /// **Algorithm:**
  /// 1. Fetch ReminderConfig for deworming events
  /// 2. For each DewormingScheduleEntry:
  ///    - Generate unique event ID from scheduledDate + dewormingType
  ///    - Call scheduleProtocolReminders() with 'deworming' eventType
  /// 3. Return all scheduled reminder IDs
  ///
  /// **Parameters:**
  /// - `petId`: ID of the pet
  /// - `dewormingSchedule`: List of DewormingScheduleEntry from ProtocolEngineService
  ///
  /// **Returns:**
  /// - `List<String>` of all scheduled reminder IDs
  ///
  /// **Example:**
  /// ```dart
  /// final schedule = await protocolEngine.generateDewormingSchedule(...);
  /// final reminderIds = await reminderScheduler.scheduleDewormingReminders(
  ///   petId: 'pet-123',
  ///   dewormingSchedule: schedule,
  /// );
  /// // Returns: ['rem-005', 'rem-006', 'rem-007', 'rem-008']
  /// ```
  Future<List<String>> scheduleDewormingReminders({
    required String petId,
    required List<DewormingScheduleEntry> dewormingSchedule,
  }) async {
    logger.i(
        'Scheduling deworming reminders: petId=$petId, count=${dewormingSchedule.length}');

    final allReminderIds = <String>[];

    for (final entry in dewormingSchedule) {
      // Skip past deworming dates
      if (entry.scheduledDate.isBefore(DateTime.now())) {
        logger.d(
            'Skipping past deworming: ${entry.dewormingType} on ${entry.scheduledDate}');
        continue;
      }

      // Generate unique event ID
      final eventId =
          'deworm_${entry.dewormingType}_${entry.scheduledDate.millisecondsSinceEpoch}';

      // Construct title and description
      final title =
          '${_capitalize(entry.dewormingType)} Deworming Treatment';
      final description = entry.productName != null
          ? 'Product: ${entry.productName}'
          : (entry.notes ?? 'Scheduled deworming treatment');

      // Schedule reminders for this deworming
      final reminderIds = await scheduleProtocolReminders(
        petId: petId,
        eventType: 'deworming',
        eventId: eventId,
        eventDate: entry.scheduledDate,
        eventTitle: title,
        eventDescription: description,
      );

      allReminderIds.addAll(reminderIds);
      logger.d(
          'Scheduled ${reminderIds.length} reminders for ${entry.dewormingType} deworming');
    }

    logger.i(
        'Successfully scheduled ${allReminderIds.length} total deworming reminders');
    return allReminderIds;
  }

  // ============================================================================
  // CORE METHOD 4: Schedule Appointment Reminders
  // ============================================================================

  /// Schedule reminders for an appointment
  ///
  /// **Algorithm:**
  /// 1. Fetch ReminderConfig for appointment events
  /// 2. Extract appointment date/time from AppointmentEntry
  /// 3. Call scheduleProtocolReminders() with 'appointment' eventType
  /// 4. Return scheduled reminder IDs
  ///
  /// **Parameters:**
  /// - `appointment`: AppointmentEntry object
  ///
  /// **Returns:**
  /// - `List<String>` of scheduled reminder IDs
  ///
  /// **Example:**
  /// ```dart
  /// final appointment = AppointmentEntry(
  ///   petId: 'pet-123',
  ///   veterinarian: 'Dr. Smith',
  ///   clinic: 'City Vet',
  ///   appointmentDate: DateTime(2025, 12, 15),
  ///   appointmentTime: DateTime(2025, 12, 15, 14, 30),
  ///   reason: 'Annual checkup',
  /// );
  /// final reminderIds = await reminderScheduler.scheduleAppointmentReminders(
  ///   appointment: appointment,
  /// );
  /// // Returns: ['rem-009', 'rem-010']
  /// ```
  Future<List<String>> scheduleAppointmentReminders({
    required AppointmentEntry appointment,
  }) async {
    logger.i(
        'Scheduling appointment reminders: appointmentId=${appointment.id}');

    // Use appointmentTime which contains both date and time
    final eventDate = appointment.appointmentTime;

    // Validate appointment is not in past
    if (eventDate.isBefore(DateTime.now())) {
      logger.w('Appointment in past: $eventDate. Cannot schedule reminders.');
      return [];
    }

    // Construct title and description
    final title = '${appointment.reason} at ${appointment.clinic}';
    final description = 'Veterinarian: ${appointment.veterinarian}';

    // Schedule reminders
    final reminderIds = await scheduleProtocolReminders(
      petId: appointment.petId,
      eventType: 'appointment',
      eventId: appointment.id,
      eventDate: eventDate,
      eventTitle: title,
      eventDescription: description,
    );

    logger.i(
        'Successfully scheduled ${reminderIds.length} reminders for appointment ${appointment.id}');
    return reminderIds;
  }

  // ============================================================================
  // CORE METHOD 5: Cancel Reminders
  // ============================================================================

  /// Cancel reminders for a specific event
  ///
  /// **Algorithm:**
  /// 1. Option A: Cancel by reminder IDs (if provided)
  /// 2. Option B: Cancel by event pattern (petId + eventType + eventId)
  /// 3. Generate reminder IDs matching pattern
  /// 4. Cancel each via NotificationService
  ///
  /// **Parameters:**
  /// - `reminderIds`: Optional list of specific reminder IDs to cancel
  /// - `petId`: Optional pet ID for pattern-based cancellation
  /// - `eventType`: Optional event type for pattern-based cancellation
  /// - `eventId`: Optional event ID for pattern-based cancellation
  ///
  /// **Returns:**
  /// - `int` count of reminders cancelled
  ///
  /// **Example:**
  /// ```dart
  /// // Cancel by specific IDs
  /// await service.cancelReminders(reminderIds: ['rem-001', 'rem-002']);
  ///
  /// // Cancel by pattern (all vaccination reminders for event 'vacc-456')
  /// await service.cancelReminders(
  ///   petId: 'pet-123',
  ///   eventType: 'vaccination',
  ///   eventId: 'vacc-456',
  /// );
  /// ```
  Future<int> cancelReminders({
    List<String>? reminderIds,
    String? petId,
    String? eventType,
    String? eventId,
  }) async {
    logger.i('Cancelling reminders...');

    // Validate inputs
    if (reminderIds == null &&
        (petId == null || eventType == null || eventId == null)) {
      logger.e(
          'Invalid parameters: Must provide either reminderIds or (petId + eventType + eventId)');
      return 0;
    }

    int cancelledCount = 0;

    // Option A: Cancel by specific IDs
    if (reminderIds != null && reminderIds.isNotEmpty) {
      for (final reminderId in reminderIds) {
        try {
          await notificationService.cancelReminder(reminderId);
          cancelledCount++;
          logger.d('Cancelled reminder: $reminderId');
        } catch (e) {
          logger.e('Failed to cancel reminder $reminderId: $e');
        }
      }
    }

    // Option B: Cancel by pattern
    if (petId != null && eventType != null && eventId != null) {
      // Fetch ReminderConfig to get possible offsets
      final configs =
          await reminderConfigRepository.getByPetIdAndEventType(petId, eventType);
      final config = configs.isNotEmpty ? configs.first : null;

      List<int> possibleOffsets = config?.reminderDays ??
          defaultReminderDays[eventType] ??
          [0, 1, 7, 14, 30]; // Extended list for thoroughness

      // Generate and cancel all possible reminder IDs
      for (final offset in possibleOffsets) {
        final reminderId = generateReminderId(petId, eventType, eventId, offset);
        try {
          await notificationService.cancelReminder(reminderId);
          cancelledCount++;
          logger.d('Cancelled reminder by pattern: $reminderId');
        } catch (e) {
          // Silent fail - reminder may not exist
          logger.d(
              'Reminder not found (expected if not scheduled): $reminderId');
        }
      }
    }

    logger.i('Successfully cancelled $cancelledCount reminders');
    return cancelledCount;
  }

  // ============================================================================
  // HELPER METHOD 1: Calculate Reminder Dates
  // ============================================================================

  /// Calculate reminder dates from event date and offset days
  ///
  /// **Algorithm:**
  /// 1. For each offset in reminderDays:
  ///    - Calculate: eventDate - offset days
  ///    - Set time to default (9:00 AM)
  ///    - Skip if date is in past
  /// 2. Remove duplicates (via Map structure)
  /// 3. Sort by date (earliest first)
  ///
  /// **Parameters:**
  /// - `eventDate`: When the event is scheduled
  /// - `reminderDays`: List of days before event (e.g., [1, 7, 14])
  /// - `reminderTime`: Optional specific time (default 9:00 AM)
  ///
  /// **Returns:**
  /// - `Map<int, DateTime>` mapping offset days to calculated reminder dates
  ///
  /// **Example:**
  /// ```dart
  /// final eventDate = DateTime(2025, 12, 15, 14, 30); // Dec 15 at 2:30 PM
  /// final dates = service.calculateReminderDates(
  ///   eventDate: eventDate,
  ///   reminderDays: [1, 7, 14],
  /// );
  /// // Returns: {
  /// //   1: DateTime(2025, 12, 14, 9, 0),   // 1 day before at 9 AM
  /// //   7: DateTime(2025, 12, 8, 9, 0),    // 7 days before at 9 AM
  /// //   14: DateTime(2025, 12, 1, 9, 0),   // 14 days before at 9 AM
  /// // }
  /// ```
  Map<int, DateTime> calculateReminderDates({
    required DateTime eventDate,
    required List<int> reminderDays,
  }) {
    final reminderDates = <int, DateTime>{};
    final now = DateTime.now();

    for (final offsetDays in reminderDays) {
      // Calculate reminder date
      final reminderDate = eventDate.subtract(Duration(days: offsetDays));

      // Set time to 9:00 AM (default)
      final reminderDateTime = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        defaultReminderHour,
        defaultReminderMinute,
      );

      // Skip if reminder date is in past
      if (reminderDateTime.isBefore(now)) {
        logger.d(
            'Reminder date in past (offset=$offsetDays days): $reminderDateTime. Skipping.');
        continue;
      }

      reminderDates[offsetDays] = reminderDateTime;
    }

    logger.d(
        'Calculated ${reminderDates.length} valid reminder dates from ${reminderDays.length} offsets');
    return reminderDates;
  }

  // ============================================================================
  // HELPER METHOD 2: Generate Reminder ID
  // ============================================================================

  /// Generate unique reminder ID for notification cancellation
  ///
  /// **Format:** `{petId}_{eventType}_{eventId}_{offsetDays}`
  ///
  /// **Example:**
  /// ```dart
  /// final id = generateReminderId('pet-123', 'vaccination', 'vacc-456', 7);
  /// // Returns: 'pet-123_vaccination_vacc-456_7'
  /// ```
  String generateReminderId(
    String petId,
    String eventType,
    String eventId,
    int offsetDays,
  ) {
    return '${petId}_${eventType}_${eventId}_$offsetDays';
  }

  // ============================================================================
  // HELPER METHOD 3: Format Notification Content
  // ============================================================================

  /// Format notification title and body based on event type
  ///
  /// **Parameters:**
  /// - `eventType`: Type of event (vaccination, deworming, appointment, medication)
  /// - `eventTitle`: Title of the event
  /// - `eventDate`: When the event is scheduled
  /// - `eventDescription`: Optional description
  /// - `offsetDays`: Optional days until event (calculated if not provided)
  ///
  /// **Returns:**
  /// - `Map<String, String>` with 'title' and 'body' keys
  Map<String, String> formatNotificationContent({
    required String eventType,
    required String eventTitle,
    required DateTime eventDate,
    String? eventDescription,
    int? offsetDays,
  }) {
    String title;
    String body;

    final daysUntilEvent =
        offsetDays ?? eventDate.difference(DateTime.now()).inDays;
    final dateStr = DateFormat('MMM d, y').format(eventDate);

    switch (eventType) {
      case 'vaccination':
        title = '💉 $eventTitle Due Soon';
        if (daysUntilEvent == 0) {
          body = 'Scheduled for today!';
        } else if (daysUntilEvent == 1) {
          body = 'Tomorrow - $dateStr';
        } else {
          body = 'In $daysUntilEvent days - $dateStr';
        }
        if (eventDescription != null && eventDescription.isNotEmpty) {
          body += '\n$eventDescription';
        }
        break;

      case 'deworming':
        title = '$eventTitle Due Soon';
        if (daysUntilEvent == 0) {
          body = 'Scheduled for today!';
        } else if (daysUntilEvent == 1) {
          body = 'Tomorrow - $dateStr';
        } else {
          body = 'Scheduled for $dateStr';
        }
        if (eventDescription != null && eventDescription.isNotEmpty) {
          body += '\n$eventDescription';
        }
        break;

      case 'appointment':
        title = '📅 Appointment: $eventTitle';
        if (daysUntilEvent == 0) {
          body = 'Today! ${eventDescription ?? ""}';
        } else if (daysUntilEvent == 1) {
          body = 'Tomorrow - ${eventDescription ?? ""}';
        } else {
          body = '$dateStr - ${eventDescription ?? ""}';
        }
        break;

      case 'medication':
        title = '💊 Medication: $eventTitle';
        body = eventDescription ?? 'Time to administer medication';
        break;

      default:
        title = eventTitle;
        body = eventDescription ?? '';
    }

    return {'title': title, 'body': body};
  }

  // ============================================================================
  // HELPER METHOD 4: Map Event Type to ReminderType
  // ============================================================================

  /// Map event type string to ReminderType enum
  ReminderType _mapEventTypeToReminderType(String eventType) {
    switch (eventType) {
      case 'vaccination':
        return ReminderType.medication; // Vaccinations are medical procedures
      case 'deworming':
        return ReminderType.medication; // Deworming treatments are medications
      case 'appointment':
        return ReminderType.appointment;
      case 'medication':
        return ReminderType.medication;
      default:
        return ReminderType.appointment; // Default to appointment for unknown types
    }
  }

  // ============================================================================
  // HELPER METHOD 5: Capitalize First Letter
  // ============================================================================

  /// Capitalize first letter of a string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

/// Riverpod provider for ReminderSchedulerService
@riverpod
ReminderSchedulerService reminderSchedulerService(
  ReminderSchedulerServiceRef ref,
) {
  return ReminderSchedulerService(
    notificationService: NotificationService(),
    reminderConfigRepository: ref.watch(reminderConfigRepositoryProvider),
  );
}
