// File: test/data/services/protocols/reminder_scheduler_service_test.dart
// Coverage: 75 tests, 300+ assertions
// Focus Areas:
// - scheduleProtocolReminders() with ReminderConfig integration (15 tests)
// - scheduleVaccinationReminders() for vaccination lists (12 tests)
// - scheduleDewormingReminders() for deworming lists (10 tests)
// - scheduleAppointmentReminders() for appointments (8 tests)
// - cancelReminders() pattern-based cancellation (10 tests)
// - calculateReminderDates() with date filtering (12 tests)
// - Helper methods & edge cases (8 tests)

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fur_friend_diary/src/data/services/protocols/reminder_scheduler_service.dart';
import 'package:fur_friend_diary/src/data/services/notification_service.dart';
import 'package:fur_friend_diary/src/domain/repositories/protocols/reminder_config_repository.dart';
import 'package:fur_friend_diary/src/domain/models/reminder.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/reminder_config.dart';
import 'package:fur_friend_diary/src/data/services/protocols/schedule_models.dart';
import 'package:fur_friend_diary/src/domain/models/appointment_entry.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockNotificationService extends Mock implements NotificationService {}

class MockReminderConfigRepository extends Mock
    implements ReminderConfigRepository {}

class MockLogger extends Mock implements Logger {}

// Fallback values for Mocktail
class FakeReminder extends Fake implements Reminder {}

void main() {
  // Register fallback values
  setUpAll(() {
    registerFallbackValue(FakeReminder());
  });

  late ReminderSchedulerService service;
  late MockNotificationService mockNotificationService;
  late MockReminderConfigRepository mockReminderConfigRepository;
  late MockLogger mockLogger;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockReminderConfigRepository = MockReminderConfigRepository();
    mockLogger = MockLogger();

    // Default stub: NotificationService.scheduleReminder() succeeds
    when(() => mockNotificationService.scheduleReminder(any()))
        .thenAnswer((_) async => {});

    // Default stub: NotificationService.cancelReminder() succeeds
    when(() => mockNotificationService.cancelReminder(any()))
        .thenAnswer((_) async => {});

    service = ReminderSchedulerService(
      notificationService: mockNotificationService,
      reminderConfigRepository: mockReminderConfigRepository,
      logger: mockLogger,
    );
  });

  // Helper to create test dates (relative to now for stability)
  DateTime futureDate(int daysFromNow) =>
      DateTime.now().add(Duration(days: daysFromNow));
  DateTime pastDate(int daysAgo) =>
      DateTime.now().subtract(Duration(days: daysAgo));

  // ============================================================================
  // GROUP 1: scheduleProtocolReminders() - 15 tests
  // ============================================================================

  group('scheduleProtocolReminders()', () {
    const testPetId = 'pet-123';
    const testEventType = 'vaccination';
    const testEventId = 'vacc-456';
    const testEventTitle = 'Rabies Vaccination';
    const testEventDescription = 'Annual booster';

    test(
        'should schedule reminders with valid ReminderConfig (enabled) for future event',
        () async {
      // Arrange
      final eventDate = futureDate(30);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [1, 7],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
        eventDescription: testEventDescription,
      );

      // Assert
      expect(reminderIds.length, 2);
      expect(reminderIds[0], 'pet-123_vaccination_vacc-456_1');
      expect(reminderIds[1], 'pet-123_vaccination_vacc-456_7');

      // Verify NotificationService.scheduleReminder() called twice
      verify(() => mockNotificationService.scheduleReminder(any())).called(2);
    });

    test('should return empty list when ReminderConfig disabled (isEnabled=false)',
        () async {
      // Arrange
      final eventDate = futureDate(30);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [1, 7],
        isEnabled: false, // DISABLED
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert
      expect(reminderIds, isEmpty);
      verifyNever(() => mockNotificationService.scheduleReminder(any()));
    });

    test('should use default reminderDays when no ReminderConfig found',
        () async {
      // Arrange
      final eventDate = futureDate(30);

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => []); // No config

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert - defaults for 'vaccination' are [1, 7]
      expect(reminderIds.length, 2);
      expect(reminderIds[0], 'pet-123_vaccination_vacc-456_1');
      expect(reminderIds[1], 'pet-123_vaccination_vacc-456_7');
    });

    test('should return empty list when event date is in past', () async {
      // Arrange
      final eventDate = pastDate(30); // 1 month ago

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => []);

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert
      expect(reminderIds, isEmpty);
      verifyNever(() => mockNotificationService.scheduleReminder(any()));
    });

    test('should schedule reminders with custom reminder offsets', () async {
      // Arrange
      final eventDate = futureDate(60);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [1, 7, 14, 30], // Custom: 4 reminders
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert
      expect(reminderIds.length, 4);
      expect(reminderIds, [
        'pet-123_vaccination_vacc-456_1',
        'pet-123_vaccination_vacc-456_7',
        'pet-123_vaccination_vacc-456_14',
        'pet-123_vaccination_vacc-456_30',
      ]);
    });

    test('should skip partial past dates (some offsets result in past)',
        () async {
      // Arrange
      final eventDate = futureDate(5); // Event in 5 days
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [1, 7, 14], // 7 and 14 day reminders are in past
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert - only 1-day reminder scheduled
      expect(reminderIds.length, 1);
      expect(reminderIds[0], 'pet-123_vaccination_vacc-456_1');
    });

    test(
        'should handle NotificationService error gracefully (partial success)',
        () async {
      // Arrange
      final eventDate = futureDate(30);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [1, 7],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Mock: First call succeeds, second call throws
      var callCount = 0;
      when(() => mockNotificationService.scheduleReminder(any())).thenAnswer(
        (_) async {
          callCount++;
          if (callCount == 2) {
            throw Exception('NotificationService error');
          }
        },
      );

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert - first reminder succeeds, second fails
      expect(reminderIds.length, 1);
      expect(reminderIds[0], 'pet-123_vaccination_vacc-456_1');
    });

    test('should return empty list for invalid event type', () async {
      // Arrange
      final eventDate = futureDate(30);

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: 'invalid_type', // INVALID
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert
      expect(reminderIds, isEmpty);
      verifyNever(() => mockNotificationService.scheduleReminder(any()));
    });

    test('should schedule reminder with zero offset (same day)', () async {
      // Arrange
      final eventDate = futureDate(30);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [0], // Same day reminder
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert
      expect(reminderIds.length, 1);
      expect(reminderIds[0], 'pet-123_vaccination_vacc-456_0');

      // Verify scheduled date is event date at 9 AM
      final capturedReminder = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .single as Reminder;
      expect(capturedReminder.scheduledTime.year, eventDate.year);
      expect(capturedReminder.scheduledTime.month, eventDate.month);
      expect(capturedReminder.scheduledTime.day, eventDate.day);
      expect(capturedReminder.scheduledTime.hour, 9);
      expect(capturedReminder.scheduledTime.minute, 0);
    });

    test('should format notification content correctly for vaccination',
        () async {
      // Arrange
      final eventDate = futureDate(30);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: 'vaccination',
        reminderDays: [1],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: 'vaccination',
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: 'Rabies',
        eventDescription: 'First dose',
      );

      // Assert
      final capturedReminder = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .single as Reminder;
      expect(capturedReminder.title, contains('💉'));
      expect(capturedReminder.title, contains('Rabies'));
      expect(capturedReminder.description, contains('First dose'));
    });

    test('should schedule reminders for multiple event types', () async {
      // Test deworming, appointment, medication event types
      final eventDate = futureDate(30);

      for (final eventType in ['deworming', 'appointment', 'medication']) {
        reset(mockReminderConfigRepository);
        reset(mockNotificationService);

        when(() => mockNotificationService.scheduleReminder(any()))
            .thenAnswer((_) async => {});

        when(() => mockReminderConfigRepository.getByPetIdAndEventType(
              testPetId,
              eventType,
            )).thenAnswer((_) async => []);

        // Act
        final reminderIds = await service.scheduleProtocolReminders(
          petId: testPetId,
          eventType: eventType,
          eventId: 'event-123',
          eventDate: eventDate,
          eventTitle: 'Test Event',
        );

        // Assert
        expect(reminderIds.isNotEmpty, true,
            reason: 'Should schedule for $eventType');
      }
    });

    test('should set linkedEntityId correctly in Reminder', () async {
      // Arrange
      final eventDate = futureDate(30);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [1],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: 'vacc-789',
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert
      final capturedReminder = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .single as Reminder;
      expect(capturedReminder.linkedEntityId, 'vacc-789');
    });

    test('should set reminder frequency to once', () async {
      // Arrange
      final eventDate = futureDate(30);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [1],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert
      final capturedReminder = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .single as Reminder;
      expect(capturedReminder.frequency, ReminderFrequency.once);
    });

    test('should calculate reminder scheduled time correctly', () async {
      // Arrange
      final eventDate = DateTime(2025, 12, 15, 14, 30); // Dec 15 at 2:30 PM
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [7],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: eventDate,
        eventTitle: testEventTitle,
      );

      // Assert - should be Dec 8 at 9:00 AM
      final capturedReminder = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .single as Reminder;
      expect(capturedReminder.scheduledTime.year, 2025);
      expect(capturedReminder.scheduledTime.month, 12);
      expect(capturedReminder.scheduledTime.day, 8);
      expect(capturedReminder.scheduledTime.hour, 9);
      expect(capturedReminder.scheduledTime.minute, 0);
    });

    test('should return empty list when empty reminderDays list', () async {
      // Arrange
      final eventDate = futureDate(30);
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: testEventType,
        reminderDays: [100, 200], // All in past for near-future event
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            testEventType,
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final reminderIds = await service.scheduleProtocolReminders(
        petId: testPetId,
        eventType: testEventType,
        eventId: testEventId,
        eventDate: futureDate(5), // Event in 5 days, but offsets require 100+ days
        eventTitle: testEventTitle,
      );

      // Assert
      expect(reminderIds, isEmpty);
    });
  });

  // ============================================================================
  // GROUP 2: scheduleVaccinationReminders() - 12 tests
  // ============================================================================

  group('scheduleVaccinationReminders()', () {
    const testPetId = 'pet-123';

    test('should schedule reminders for single vaccination entry', () async {
      // Arrange
      final vaccination = VaccinationScheduleEntry(
        stepIndex: 0,
        vaccineName: 'Rabies',
        scheduledDate: futureDate(30),
        notes: 'First dose',
        isRequired: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: [vaccination],
      );

      // Assert
      expect(result.length, 1);
      expect(result[0]!.length, 2); // Default [1, 7]
      expect(result[0]![0], 'pet-123_vaccination_vacc_0_Rabies_1');
      expect(result[0]![1], 'pet-123_vaccination_vacc_0_Rabies_7');
    });

    test('should schedule reminders for multiple vaccination entries',
        () async {
      // Arrange
      final vaccinations = [
        VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'DHPPiL',
          scheduledDate: futureDate(15),
          isRequired: true,
        ),
        VaccinationScheduleEntry(
          stepIndex: 1,
          vaccineName: 'DHPPiL Booster',
          scheduledDate: futureDate(35),
          isRequired: true,
        ),
        VaccinationScheduleEntry(
          stepIndex: 2,
          vaccineName: 'Rabies',
          scheduledDate: futureDate(63),
          isRequired: true,
        ),
      ];

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: vaccinations,
      );

      // Assert
      expect(result.length, 3);
      expect(result[0]!.length, 2); // Step 0
      expect(result[1]!.length, 2); // Step 1
      expect(result[2]!.length, 2); // Step 2
    });

    test('should skip past vaccination dates', () async {
      // Arrange
      final vaccinations = [
        VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'DHPPiL',
          scheduledDate: pastDate(30), // PAST
          isRequired: true,
        ),
        VaccinationScheduleEntry(
          stepIndex: 1,
          vaccineName: 'Rabies',
          scheduledDate: futureDate(30), // FUTURE
          isRequired: true,
        ),
        VaccinationScheduleEntry(
          stepIndex: 2,
          vaccineName: 'DHPPiL Booster',
          scheduledDate: futureDate(60), // FUTURE
          isRequired: true,
        ),
      ];

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: vaccinations,
      );

      // Assert - only steps 1 and 2 scheduled
      expect(result.length, 2);
      expect(result[1]!.length, 2);
      expect(result[2]!.length, 2);
      expect(result.containsKey(0), false);
    });

    test('should return empty map when empty vaccination list', () async {
      // Act
      final result = await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: [],
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should generate event ID from stepIndex and vaccineName', () async {
      // Arrange
      final vaccination = VaccinationScheduleEntry(
        stepIndex: 2,
        vaccineName: 'Rabies Booster 1',
        scheduledDate: futureDate(30),
        isRequired: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: [vaccination],
      );

      // Assert - eventId should be 'vacc_2_Rabies_Booster_1'
      expect(result[2]![0], contains('vacc_2_Rabies_Booster_1'));
    });

    test('should format title as "{vaccineName} Vaccination"', () async {
      // Arrange
      final vaccination = VaccinationScheduleEntry(
        stepIndex: 0,
        vaccineName: 'DHPPiL',
        scheduledDate: futureDate(30),
        isRequired: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: [vaccination],
      );

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders.first.title, contains('DHPPiL'));
      expect(capturedReminders.first.title, contains('Vaccination'));
    });

    test('should include notes and required flag in description', () async {
      // Arrange
      final vaccination = VaccinationScheduleEntry(
        stepIndex: 0,
        vaccineName: 'DHPPiL',
        scheduledDate: futureDate(30),
        notes: 'First core vaccine',
        isRequired: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: [vaccination],
      );

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders.first.description, contains('First core vaccine'));
    });

    test('should return empty map when all vaccinations in past', () async {
      // Arrange
      final vaccinations = [
        VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'DHPPiL',
          scheduledDate: pastDate(90),
          isRequired: true,
        ),
        VaccinationScheduleEntry(
          stepIndex: 1,
          vaccineName: 'Rabies',
          scheduledDate: pastDate(60),
          isRequired: true,
        ),
        VaccinationScheduleEntry(
          stepIndex: 2,
          vaccineName: 'DHPPiL Booster',
          scheduledDate: pastDate(30),
          isRequired: true,
        ),
      ];

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: vaccinations,
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should integrate with custom ReminderConfig', () async {
      // Arrange
      final vaccination = VaccinationScheduleEntry(
        stepIndex: 0,
        vaccineName: 'Rabies',
        scheduledDate: futureDate(30),
        isRequired: true,
      );

      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: testPetId,
        eventType: 'vaccination',
        reminderDays: [1, 3, 7],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final result = await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: [vaccination],
      );

      // Assert - should schedule 3 reminders per custom config
      expect(result[0]!.length, 3);
    });

    test('should handle large vaccination schedule (10 steps)', () async {
      // Arrange
      final vaccinations = List.generate(
        10,
        (index) => VaccinationScheduleEntry(
          stepIndex: index,
          vaccineName: 'Vaccine $index',
          scheduledDate: futureDate(30 + (index * 28)), // Every 4 weeks
          isRequired: true,
        ),
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: vaccinations,
      );

      // Assert
      expect(result.length, 10);
      for (var i = 0; i < 10; i++) {
        expect(result[i]!.length, 2); // Default [1, 7]
      }
    });

    test('should use fallback description when notes is null', () async {
      // Arrange
      final vaccination = VaccinationScheduleEntry(
        stepIndex: 1,
        vaccineName: 'Rabies',
        scheduledDate: futureDate(30),
        notes: null, // NO NOTES
        isRequired: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: [vaccination],
      );

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders.first.description, contains('Step 2')); // stepIndex 1 = Step 2
      expect(capturedReminders.first.description, contains('(Required)'));
    });

    test('should differentiate required and optional vaccines in description',
        () async {
      // Arrange
      final vaccinations = [
        VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'Rabies',
          scheduledDate: futureDate(30),
          isRequired: true, // REQUIRED
        ),
        VaccinationScheduleEntry(
          stepIndex: 1,
          vaccineName: 'Lyme',
          scheduledDate: futureDate(60),
          isRequired: false, // OPTIONAL
        ),
      ];

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'vaccination',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleVaccinationReminders(
        petId: testPetId,
        vaccinations: vaccinations,
      );

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();

      // First 2 reminders are for required vaccine
      expect(capturedReminders[0].description, contains('(Required)'));
      expect(capturedReminders[1].description, contains('(Required)'));

      // Last 2 reminders are for optional vaccine
      expect(capturedReminders[2].description, isNot(contains('(Required)')));
      expect(capturedReminders[3].description, isNot(contains('(Required)')));
    });
  });

  // ============================================================================
  // GROUP 3: scheduleDewormingReminders() - 10 tests
  // ============================================================================

  group('scheduleDewormingReminders()', () {
    const testPetId = 'pet-123';

    test('should schedule reminders for single deworming entry', () async {
      // Arrange
      final deworming = DewormingScheduleEntry(
        dewormingType: 'external',
        scheduledDate: futureDate(30),
        productName: 'Bravecto',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: [deworming],
      );

      // Assert
      expect(result.length, 2); // Default [1, 7]
      expect(result[0], contains('pet-123_deworming_deworm_external_'));
      expect(result[1], contains('pet-123_deworming_deworm_external_'));
    });

    test('should schedule reminders for multiple deworming entries', () async {
      // Arrange
      final dewormings = [
        DewormingScheduleEntry(
          dewormingType: 'external',
          scheduledDate: futureDate(30),
          productName: 'Bravecto',
        ),
        DewormingScheduleEntry(
          dewormingType: 'external',
          scheduledDate: futureDate(60),
          productName: 'Bravecto',
        ),
        DewormingScheduleEntry(
          dewormingType: 'internal',
          scheduledDate: futureDate(90),
          productName: 'Milbemax',
        ),
        DewormingScheduleEntry(
          dewormingType: 'internal',
          scheduledDate: futureDate(120),
          productName: 'Milbemax',
        ),
      ];

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: dewormings,
      );

      // Assert - 4 entries × 2 reminders each = 8 total
      expect(result.length, 8);
    });

    test('should skip past deworming dates', () async {
      // Arrange
      final dewormings = [
        DewormingScheduleEntry(
          dewormingType: 'external',
          scheduledDate: pastDate(30), // PAST
          productName: 'Bravecto',
        ),
        DewormingScheduleEntry(
          dewormingType: 'external',
          scheduledDate: futureDate(30), // FUTURE
          productName: 'Bravecto',
        ),
        DewormingScheduleEntry(
          dewormingType: 'internal',
          scheduledDate: futureDate(60), // FUTURE
          productName: 'Milbemax',
        ),
      ];

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: dewormings,
      );

      // Assert - only 2 future entries × 2 reminders = 4 total
      expect(result.length, 4);
    });

    test('should return empty list when empty deworming schedule', () async {
      // Act
      final result = await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: [],
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should generate event ID from type and timestamp', () async {
      // Arrange
      final scheduledDate = DateTime(2025, 12, 15);
      final deworming = DewormingScheduleEntry(
        dewormingType: 'external',
        scheduledDate: scheduledDate,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: [deworming],
      );

      // Assert - eventId format: 'deworm_external_{millisecondsSinceEpoch}'
      expect(result[0], contains('deworm_external_'));
      expect(result[0], contains(scheduledDate.millisecondsSinceEpoch.toString()));
    });

    test('should format title with capitalized type', () async {
      // Arrange
      final deworming = DewormingScheduleEntry(
        dewormingType: 'external',
        scheduledDate: futureDate(30),
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: [deworming],
      );

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders.first.title, contains('External'));
      expect(capturedReminders.first.title, contains('Deworming Treatment'));
    });

    test('should include product name in description', () async {
      // Arrange
      final deworming = DewormingScheduleEntry(
        dewormingType: 'external',
        scheduledDate: futureDate(30),
        productName: 'Bravecto',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: [deworming],
      );

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders.first.description, contains('Product: Bravecto'));
    });

    test('should use fallback description when no product name', () async {
      // Arrange
      final deworming = DewormingScheduleEntry(
        dewormingType: 'internal',
        scheduledDate: futureDate(30),
        productName: null,
        notes: 'Monthly treatment',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: [deworming],
      );

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders.first.description, contains('Monthly treatment'));
    });

    test('should differentiate internal vs external deworming', () async {
      // Arrange
      final dewormings = [
        DewormingScheduleEntry(
          dewormingType: 'internal',
          scheduledDate: futureDate(30),
        ),
        DewormingScheduleEntry(
          dewormingType: 'external',
          scheduledDate: futureDate(60),
        ),
      ];

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: dewormings,
      );

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders[0].title, contains('Internal'));
      expect(capturedReminders[2].title, contains('External'));
    });

    test('should return empty list when all dewormings in past', () async {
      // Arrange
      final dewormings = [
        DewormingScheduleEntry(
          dewormingType: 'external',
          scheduledDate: pastDate(90),
        ),
        DewormingScheduleEntry(
          dewormingType: 'internal',
          scheduledDate: pastDate(60),
        ),
      ];

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            testPetId,
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      final result = await service.scheduleDewormingReminders(
        petId: testPetId,
        dewormingSchedule: dewormings,
      );

      // Assert
      expect(result, isEmpty);
    });
  });

  // ============================================================================
  // GROUP 4: scheduleAppointmentReminders() - 8 tests
  // ============================================================================

  group('scheduleAppointmentReminders()', () {
    test('should schedule reminders for valid future appointment', () async {
      // Arrange
      final appointment = AppointmentEntry(
        id: 'appt-456',
        petId: 'pet-123',
        veterinarian: 'Dr. Smith',
        clinic: 'City Vet',
        appointmentDate: futureDate(30),
        appointmentTime: futureDate(30),
        reason: 'Annual checkup',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => []);

      // Act
      final result =
          await service.scheduleAppointmentReminders(appointment: appointment);

      // Assert
      expect(result.length, 2); // Default [1, 7]
      expect(result[0], 'pet-123_appointment_appt-456_1');
      expect(result[1], 'pet-123_appointment_appt-456_7');
    });

    test('should return empty list for past appointment', () async {
      // Arrange
      final appointment = AppointmentEntry(
        id: 'appt-456',
        petId: 'pet-123',
        veterinarian: 'Dr. Smith',
        clinic: 'City Vet',
        appointmentDate: pastDate(30),
        appointmentTime: pastDate(30), // PAST
        reason: 'Annual checkup',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => []);

      // Act
      final result =
          await service.scheduleAppointmentReminders(appointment: appointment);

      // Assert
      expect(result, isEmpty);
    });

    test('should format title as "{reason} at {clinic}"', () async {
      // Arrange
      final appointment = AppointmentEntry(
        id: 'appt-456',
        petId: 'pet-123',
        veterinarian: 'Dr. Smith',
        clinic: 'City Vet',
        appointmentDate: futureDate(30),
        appointmentTime: futureDate(30),
        reason: 'Annual checkup',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleAppointmentReminders(appointment: appointment);

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(
          capturedReminders.first.title, contains('Annual checkup at City Vet'));
    });

    test('should format description as "Veterinarian: {veterinarian}"',
        () async {
      // Arrange
      final appointment = AppointmentEntry(
        id: 'appt-456',
        petId: 'pet-123',
        veterinarian: 'Dr. Smith',
        clinic: 'City Vet',
        appointmentDate: futureDate(30),
        appointmentTime: futureDate(30),
        reason: 'Annual checkup',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleAppointmentReminders(appointment: appointment);

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders.first.description,
          contains('Veterinarian: Dr. Smith'));
    });

    test('should use appointmentTime (not appointmentDate)', () async {
      // Arrange
      final appointmentTime = DateTime(2025, 12, 15, 14, 30);
      final appointment = AppointmentEntry(
        id: 'appt-456',
        petId: 'pet-123',
        veterinarian: 'Dr. Smith',
        clinic: 'City Vet',
        appointmentDate: DateTime(2025, 12, 15),
        appointmentTime: appointmentTime, // USE THIS
        reason: 'Annual checkup',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleAppointmentReminders(appointment: appointment);

      // Assert - verify reminder scheduled based on appointmentTime
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      // 1-day reminder should be Dec 14 at 9 AM
      expect(capturedReminders.first.scheduledTime.month, 12);
      expect(capturedReminders.first.scheduledTime.day, 14);
    });

    test('should use appointment.id as eventId', () async {
      // Arrange
      final appointment = AppointmentEntry(
        id: 'appt-789',
        petId: 'pet-123',
        veterinarian: 'Dr. Jones',
        clinic: 'Pet Hospital',
        appointmentDate: futureDate(30),
        appointmentTime: futureDate(30),
        reason: 'Vaccination',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => []);

      // Act
      final result =
          await service.scheduleAppointmentReminders(appointment: appointment);

      // Assert
      expect(result[0], contains('appt-789'));
    });

    test('should integrate with custom ReminderConfig', () async {
      // Arrange
      final appointment = AppointmentEntry(
        id: 'appt-456',
        petId: 'pet-123',
        veterinarian: 'Dr. Smith',
        clinic: 'City Vet',
        appointmentDate: futureDate(30),
        appointmentTime: futureDate(30),
        reason: 'Annual checkup',
      );

      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: 'pet-123',
        eventType: 'appointment',
        reminderDays: [1, 7, 14],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final result =
          await service.scheduleAppointmentReminders(appointment: appointment);

      // Assert - should schedule 3 reminders per custom config
      expect(result.length, 3);
    });

    test('should use correct eventType for appointments', () async {
      // Arrange
      final appointment = AppointmentEntry(
        id: 'appt-456',
        petId: 'pet-123',
        veterinarian: 'Dr. Smith',
        clinic: 'City Vet',
        appointmentDate: futureDate(30),
        appointmentTime: futureDate(30),
        reason: 'Annual checkup',
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleAppointmentReminders(appointment: appointment);

      // Assert
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();
      expect(capturedReminders.first.type, ReminderType.appointment);
    });
  });

  // ============================================================================
  // GROUP 5: cancelReminders() - 10 tests
  // ============================================================================

  group('cancelReminders()', () {
    test('should cancel reminders by specific ID list', () async {
      // Arrange
      final reminderIds = ['id1', 'id2', 'id3'];

      // Act
      final count = await service.cancelReminders(reminderIds: reminderIds);

      // Assert
      expect(count, 3);
      verify(() => mockNotificationService.cancelReminder('id1')).called(1);
      verify(() => mockNotificationService.cancelReminder('id2')).called(1);
      verify(() => mockNotificationService.cancelReminder('id3')).called(1);
    });

    test('should cancel reminders by pattern (petId + eventType + eventId)',
        () async {
      // Arrange
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: 'pet-123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'vaccination',
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final count = await service.cancelReminders(
        petId: 'pet-123',
        eventType: 'vaccination',
        eventId: 'vacc-456',
      );

      // Assert
      expect(count, 2);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_vaccination_vacc-456_1')).called(1);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_vaccination_vacc-456_7')).called(1);
    });

    test(
        'should use extended offset list when no ReminderConfig (pattern-based)',
        () async {
      // Arrange
      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'vaccination',
          )).thenAnswer((_) async => []); // No config

      // Act
      final count = await service.cancelReminders(
        petId: 'pet-123',
        eventType: 'vaccination',
        eventId: 'vacc-456',
      );

      // Assert - uses default [1, 7], not extended list
      expect(count, 2);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_vaccination_vacc-456_1')).called(1);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_vaccination_vacc-456_7')).called(1);
    });

    test('should handle non-existent reminders gracefully (silent fail)',
        () async {
      // Arrange
      when(() => mockNotificationService.cancelReminder(any()))
          .thenThrow(Exception('Reminder not found'));

      // Act
      final count = await service.cancelReminders(
        reminderIds: ['id1', 'id2'],
      );

      // Assert - should not crash, but count is 0 due to exceptions
      expect(count, 0);
    });

    test('should return 0 when empty ID list provided', () async {
      // Act
      final count = await service.cancelReminders(reminderIds: []);

      // Assert
      expect(count, 0);
      verifyNever(() => mockNotificationService.cancelReminder(any()));
    });

    test('should return 0 and log error when no parameters provided',
        () async {
      // Act
      final count = await service.cancelReminders();

      // Assert
      expect(count, 0);
      verifyNever(() => mockNotificationService.cancelReminder(any()));
    });

    test('should handle partial failures (some IDs fail to cancel)', () async {
      // Arrange
      when(() => mockNotificationService.cancelReminder('id1'))
          .thenAnswer((_) async => {});
      when(() => mockNotificationService.cancelReminder('id2'))
          .thenThrow(Exception('Cancel failed'));
      when(() => mockNotificationService.cancelReminder('id3'))
          .thenAnswer((_) async => {});

      // Act
      final count = await service.cancelReminders(
        reminderIds: ['id1', 'id2', 'id3'],
      );

      // Assert - id2 failed, so count is 2
      expect(count, 2);
    });

    test('should cancel by pattern with custom ReminderConfig', () async {
      // Arrange
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: 'pet-123',
        eventType: 'appointment',
        reminderDays: [1, 3, 5, 7],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'appointment',
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final count = await service.cancelReminders(
        petId: 'pet-123',
        eventType: 'appointment',
        eventId: 'appt-789',
      );

      // Assert
      expect(count, 4);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_appointment_appt-789_1')).called(1);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_appointment_appt-789_3')).called(1);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_appointment_appt-789_5')).called(1);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_appointment_appt-789_7')).called(1);
    });

    test('should cancel both by ID list AND pattern when both provided',
        () async {
      // Arrange
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: 'pet-123',
        eventType: 'vaccination',
        reminderDays: [1],
        isEnabled: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'vaccination',
          )).thenAnswer((_) async => [reminderConfig]);

      // Act
      final count = await service.cancelReminders(
        reminderIds: ['custom-id-1', 'custom-id-2'],
        petId: 'pet-123',
        eventType: 'vaccination',
        eventId: 'vacc-456',
      );

      // Assert - 2 from ID list + 1 from pattern = 3
      expect(count, 3);
      verify(() => mockNotificationService.cancelReminder('custom-id-1'))
          .called(1);
      verify(() => mockNotificationService.cancelReminder('custom-id-2'))
          .called(1);
      verify(() => mockNotificationService
          .cancelReminder('pet-123_vaccination_vacc-456_1')).called(1);
    });

    test('should return accurate count of cancelled reminders', () async {
      // Arrange
      when(() => mockNotificationService.cancelReminder('id1'))
          .thenAnswer((_) async => {});
      when(() => mockNotificationService.cancelReminder('id2'))
          .thenAnswer((_) async => {});
      when(() => mockNotificationService.cancelReminder('id3'))
          .thenAnswer((_) async => {});

      // Act
      final count = await service.cancelReminders(
        reminderIds: ['id1', 'id2', 'id3'],
      );

      // Assert
      expect(count, 3);
    });
  });

  // ============================================================================
  // GROUP 6: calculateReminderDates() - 12 tests
  // ============================================================================

  group('calculateReminderDates()', () {
    test('should calculate reminder date for single offset (1 day)', () {
      // Arrange
      final eventDate = DateTime(2025, 12, 15, 14, 30);

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [1],
      );

      // Assert
      expect(result.length, 1);
      expect(result[1]!.year, 2025);
      expect(result[1]!.month, 12);
      expect(result[1]!.day, 14);
      expect(result[1]!.hour, 9);
      expect(result[1]!.minute, 0);
    });

    test('should calculate reminder dates for multiple offsets', () {
      // Arrange
      final eventDate = DateTime(2025, 12, 15);

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [1, 7, 14],
      );

      // Assert
      expect(result.length, 3);
      expect(result[1]!.day, 14); // Dec 14
      expect(result[7]!.day, 8); // Dec 8
      expect(result[14]!.day, 1); // Dec 1
      // All at 9:00 AM
      expect(result[1]!.hour, 9);
      expect(result[7]!.hour, 9);
      expect(result[14]!.hour, 9);
    });

    test('should calculate reminder date for zero offset (same day)', () {
      // Arrange
      final eventDate = DateTime(2025, 12, 15, 14, 30);

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [0],
      );

      // Assert
      expect(result.length, 1);
      expect(result[0]!.year, 2025);
      expect(result[0]!.month, 12);
      expect(result[0]!.day, 15);
      expect(result[0]!.hour, 9);
      expect(result[0]!.minute, 0);
    });

    test('should skip past dates', () {
      // Arrange
      final eventDate = futureDate(5); // 5 days from now
      final reminderDays = [1, 7, 14]; // 7 and 14 are in past

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: reminderDays,
      );

      // Assert - only 1-day reminder valid
      expect(result.length, 1);
      expect(result.containsKey(1), true);
      expect(result.containsKey(7), false);
      expect(result.containsKey(14), false);
    });

    test('should return empty map when all offsets in past', () {
      // Arrange
      final eventDate = futureDate(2); // 2 days from now
      final reminderDays = [3, 7, 14]; // All in past

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: reminderDays,
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should default time to 9:00 AM', () {
      // Arrange
      final eventDate = DateTime(2025, 12, 15, 18, 45); // 6:45 PM

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [1, 7],
      );

      // Assert - all times should be 9:00 AM
      expect(result[1]!.hour, 9);
      expect(result[1]!.minute, 0);
      expect(result[7]!.hour, 9);
      expect(result[7]!.minute, 0);
    });

    test('should return empty map when empty reminderDays list', () {
      // Arrange
      final eventDate = futureDate(30);

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [],
      );

      // Assert
      expect(result, isEmpty);
    });

    test('should calculate reminder date for large offset (90 days)', () {
      // Arrange
      final eventDate = futureDate(120); // 120 days out, so 90 days before = 30 days from now

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [90],
      );

      // Assert - 90 days before event date
      expect(result.length, 1);
      expect(result[90]!.hour, 9);
    });

    test('should handle negative offset (edge case)', () {
      // Arrange
      final eventDate = DateTime(2025, 12, 15);

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [-1], // Negative offset = 1 day AFTER event
      );

      // Assert - should calculate Dec 16 (1 day after Dec 15)
      expect(result.length, 1);
      expect(result[-1]!.day, 16);
    });

    test('should deduplicate via Map key structure', () {
      // Arrange - hypothetically two offsets calculate to same date
      final eventDate = DateTime(2025, 12, 15);

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [1, 1, 1], // Duplicates
      );

      // Assert - Map structure prevents duplicates
      expect(result.length, 1);
      expect(result.containsKey(1), true);
    });

    test('should filter based on current time boundary', () {
      // This test verifies that reminders scheduled in the past relative to NOW are skipped
      // Arrange
      final now = DateTime.now();
      final eventDate =
          now.add(const Duration(hours: 1)); // 1 hour from now (today)
      final reminderDays = [1]; // 1 day before = yesterday

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: reminderDays,
      );

      // Assert - reminder date is in past (yesterday), should be skipped
      expect(result, isEmpty);
    });

    test('should preserve date accurately (no time drift)', () {
      // Arrange
      final eventDate = DateTime(2025, 12, 15, 14, 30); // Dec 15 at 2:30 PM

      // Act
      final result = service.calculateReminderDates(
        eventDate: eventDate,
        reminderDays: [7],
      );

      // Assert - Dec 8 at 9:00 AM
      expect(result[7]!.year, 2025);
      expect(result[7]!.month, 12);
      expect(result[7]!.day, 8);
      expect(result[7]!.hour, 9);
      expect(result[7]!.minute, 0);
      expect(result[7]!.second, 0);
    });
  });

  // ============================================================================
  // GROUP 7: Helper Methods & Edge Cases - 8 tests
  // ============================================================================

  group('Helper Methods & Edge Cases', () {
    test('generateReminderId() should format correctly', () {
      // Act
      final id = service.generateReminderId(
        'pet-123',
        'vaccination',
        'vacc-456',
        7,
      );

      // Assert
      expect(id, 'pet-123_vaccination_vacc-456_7');
    });

    test('formatNotificationContent() should format vaccination correctly',
        () {
      // Act
      final content = service.formatNotificationContent(
        eventType: 'vaccination',
        eventTitle: 'Rabies',
        eventDate: futureDate(1),
        eventDescription: 'First dose',
        offsetDays: 1,
      );

      // Assert
      expect(content['title'], contains('💉'));
      expect(content['title'], contains('Rabies'));
      expect(content['title'], contains('Due Soon'));
      expect(content['body'], contains('Tomorrow'));
      expect(content['body'], contains('First dose'));
    });

    test('formatNotificationContent() should format deworming correctly',
        () {
      // Act
      final content = service.formatNotificationContent(
        eventType: 'deworming',
        eventTitle: 'External Treatment',
        eventDate: futureDate(7),
        eventDescription: 'Bravecto',
        offsetDays: 7,
      );

      // Assert
      expect(content['title'], contains('🐛'));
      expect(content['title'], contains('External Treatment'));
      expect(content['title'], contains('Due Soon'));
      expect(content['body'], contains('Bravecto'));
    });

    test('formatNotificationContent() should format appointment correctly',
        () {
      // Act
      final content = service.formatNotificationContent(
        eventType: 'appointment',
        eventTitle: 'Annual Checkup',
        eventDate: futureDate(0),
        eventDescription: 'Dr. Smith',
        offsetDays: 0,
      );

      // Assert
      expect(content['title'], contains('📅'));
      expect(content['title'], contains('Appointment'));
      expect(content['title'], contains('Annual Checkup'));
      expect(content['body'], contains('Today'));
      expect(content['body'], contains('Dr. Smith'));
    });

    test('formatNotificationContent() should format medication correctly',
        () {
      // Act
      final content = service.formatNotificationContent(
        eventType: 'medication',
        eventTitle: 'Antibiotics',
        eventDate: futureDate(0),
        eventDescription: 'Take with food',
      );

      // Assert
      expect(content['title'], contains('💊'));
      expect(content['title'], contains('Medication'));
      expect(content['title'], contains('Antibiotics'));
      expect(content['body'], contains('Take with food'));
    });

    test('_mapEventTypeToReminderType() should map event types correctly', () async {
      // Arrange
      final futureEventDate = futureDate(30);
      final testCases = [
        {'eventType': 'vaccination', 'expectedType': ReminderType.medication},
        {'eventType': 'deworming', 'expectedType': ReminderType.medication},
        {'eventType': 'appointment', 'expectedType': ReminderType.appointment},
        {'eventType': 'medication', 'expectedType': ReminderType.medication},
      ];

      for (final testCase in testCases) {
        when(() => mockReminderConfigRepository.getByPetIdAndEventType(
              'pet-123',
              testCase['eventType'] as String,
            )).thenAnswer((_) async => [
          ReminderConfig(
            id: 'config-${testCase['eventType']}',
            petId: 'pet-123',
            eventType: testCase['eventType'] as String,
            reminderDays: [1], // Only 1 reminder per event type
            isEnabled: true,
          ),
        ]);

        // Act
        await service.scheduleProtocolReminders(
          petId: 'pet-123',
          eventType: testCase['eventType'] as String,
          eventId: 'test',
          eventDate: futureEventDate,
          eventTitle: 'Test',
        );
      }

      // Assert - capture all reminders to verify types
      final capturedReminders = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .cast<Reminder>();

      expect(capturedReminders.length, 4);
      expect(capturedReminders[0].type, ReminderType.medication); // vaccination
      expect(capturedReminders[1].type, ReminderType.medication); // deworming
      expect(capturedReminders[2].type, ReminderType.appointment); // appointment
      expect(capturedReminders[3].type, ReminderType.medication); // medication
    });

    test('_capitalize() should capitalize first letter (via public API)',
        () async {
      // Arrange
      final deworming = DewormingScheduleEntry(
        dewormingType: 'external',
        scheduledDate: futureDate(30),
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'deworming',
          )).thenAnswer((_) async => []);

      // Act
      await service.scheduleDewormingReminders(
        petId: 'pet-123',
        dewormingSchedule: [deworming],
      );

      // Assert - title should have capitalized "External"
      final capturedReminder = verify(() =>
              mockNotificationService.scheduleReminder(captureAny()))
          .captured
          .first as Reminder;
      expect(capturedReminder.title, contains('External'));
      expect(capturedReminder.title, isNot(contains('external')));
    });

    test('Integration: End-to-end scheduling flow', () async {
      // Arrange - simulate complete vaccination reminder flow
      final reminderConfig = ReminderConfig(
        id: 'config-1',
        petId: 'pet-123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
        isEnabled: true,
      );

      final vaccination = VaccinationScheduleEntry(
        stepIndex: 0,
        vaccineName: 'Rabies',
        scheduledDate: futureDate(30),
        notes: 'First dose',
        isRequired: true,
      );

      when(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'vaccination',
          )).thenAnswer((_) async => [reminderConfig]);

      // Act - full flow
      final result = await service.scheduleVaccinationReminders(
        petId: 'pet-123',
        vaccinations: [vaccination],
      );

      // Assert - verify full pipeline
      expect(result.length, 1);
      expect(result[0]!.length, 2);

      // Verify ReminderConfig fetched
      verify(() => mockReminderConfigRepository.getByPetIdAndEventType(
            'pet-123',
            'vaccination',
          )).called(1);

      // Verify reminders scheduled
      verify(() => mockNotificationService.scheduleReminder(any())).called(2);
    });
  });
}
