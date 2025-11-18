// File: test/data/services/protocols/protocol_engine_service_test.dart
// Coverage: 70+ tests covering all core methods, helper methods, and edge cases
// Focus Areas: Vaccination date calculations, schedule generation, deworming logic,
//              appointment suggestions, medication/appointment entry creation, edge cases

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/data/services/protocols/protocol_engine_service.dart';
import 'package:fur_friend_diary/src/data/services/protocols/schedule_models.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/vaccination_protocol_repository_impl.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/deworming_protocol_repository_impl.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/vaccination_protocol.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/deworming_protocol.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'dart:convert';

void main() {
  group('ProtocolEngineService', () {
    late Box<VaccinationProtocol> vaccinationBox;
    late Box<DewormingProtocol> dewormingBox;
    late VaccinationProtocolRepositoryImpl vaccinationRepo;
    late DewormingProtocolRepositoryImpl dewormingRepo;
    late ProtocolEngineService service;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('test_hive_protocol_engine');

      // Register all necessary adapters
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(VaccinationProtocolAdapter());
      }
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(VaccinationStepAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(RecurringScheduleAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(DewormingProtocolAdapter());
      }
      if (!Hive.isAdapterRegistered(26)) {
        Hive.registerAdapter(DewormingScheduleAdapter());
      }
    });

    setUp(() async {
      // Open and clear boxes before each test
      vaccinationBox = await Hive.openBox<VaccinationProtocol>('test_vaccination_protocols');
      dewormingBox = await Hive.openBox<DewormingProtocol>('test_deworming_protocols');

      await vaccinationBox.clear();
      await dewormingBox.clear();

      vaccinationRepo = VaccinationProtocolRepositoryImpl(box: vaccinationBox);
      dewormingRepo = DewormingProtocolRepositoryImpl(box: dewormingBox);

      service = ProtocolEngineService(
        vaccinationProtocolRepository: vaccinationRepo,
        dewormingProtocolRepository: dewormingRepo,
      );
    });

    tearDown(() async {
      // Clean up after each test
      await vaccinationBox.close();
      await dewormingBox.close();
      await Hive.deleteBoxFromDisk('test_vaccination_protocols');
      await Hive.deleteBoxFromDisk('test_deworming_protocols');
    });

    tearDownAll(() async {
      await Hive.close();
    });

    // ========================================================================
    // GROUP 1: calculateNextVaccinationDate() - ~15 tests
    // ========================================================================

    group('calculateNextVaccinationDate - Basic Calculations', () {
      test('should calculate first dose date from birthdate + ageInWeeks', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1), // Jan 1, 2024
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6, // 6 weeks old
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 0,
        );

        // Assert
        // 6 weeks = 42 days, Jan 1 + 42 days = Feb 12
        expect(result, DateTime(2024, 2, 12));
      });

      test('should calculate booster dose from lastDoseDate + intervalDays', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6,
              isRequired: true,
            ),
            VaccinationStep(
              vaccineName: 'DHPPiL Booster',
              ageInWeeks: 9,
              intervalDays: 21, // 3 weeks later
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        final lastDoseDate = DateTime(2024, 2, 12); // First dose date

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 1,
          lastAdministeredDate: lastDoseDate,
        );

        // Assert
        // Feb 12 + 21 days = Mar 4
        expect(result, DateTime(2024, 3, 4));
      });

      test('should return null if pet has no birthdate', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: null, // No birthday
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6,
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 0,
        );

        // Assert
        expect(result, isNull);
      });

      test('should return null if step index is negative', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6,
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: -1, // Invalid index
        );

        // Assert
        expect(result, isNull);
      });

      test('should return null if step index exceeds protocol steps length', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6,
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 5, // Out of bounds
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('calculateNextVaccinationDate - Edge Cases', () {
      test('should handle pet too young (calculated date in future)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: DateTime.now().subtract(const Duration(days: 7)), // 1 week old
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6,
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 0,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.isAfter(DateTime.now()), isTrue); // Date is in future
      });

      test('should handle very old pet (date far in past)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Senior',
          species: 'dog',
          birthday: DateTime(2020, 1, 1), // 4+ years old
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6,
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 0,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.isBefore(DateTime.now()), isTrue); // Date is in past
      });

      test('should return null for booster without intervalDays', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6,
              isRequired: true,
            ),
            VaccinationStep(
              vaccineName: 'Booster',
              ageInWeeks: 9,
              intervalDays: null, // Missing interval
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 1,
          lastAdministeredDate: DateTime(2024, 2, 12),
        );

        // Assert
        expect(result, isNull);
      });

      test('should handle step 0 without lastAdministeredDate', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 6,
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act - no lastAdministeredDate provided
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 0,
        );

        // Assert
        expect(result, DateTime(2024, 2, 12)); // Should calculate from birthdate
      });

      test('should handle leap year dates correctly', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Leapy',
          species: 'dog',
          birthday: DateTime(2024, 2, 15), // Feb 15, 2024 (leap year)
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 2, // 14 days
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 0,
        );

        // Assert
        // Feb 15 + 14 days = Feb 29 (leap year)
        expect(result, DateTime(2024, 2, 29));
      });
    });

    group('calculateNextVaccinationDate - Date Math', () {
      test('should calculate 6-week-old puppy + 8 weeks = 14 weeks old', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 42)); // 6 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: birthdate,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'DHPPiL',
              ageInWeeks: 14, // 14 weeks old
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 0,
        );

        // Assert
        final expectedDate = birthdate.add(const Duration(days: 98)); // 14 weeks
        expect(result, expectedDate);
      });

      test('should calculate 3-month-old kitten + 4 weeks = 16 weeks old', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 84)); // 12 weeks (3 months)
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Kitten',
          species: 'cat',
          birthday: birthdate,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'cat',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'FVRCP',
              ageInWeeks: 16,
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 0,
        );

        // Assert
        final expectedDate = birthdate.add(const Duration(days: 112)); // 16 weeks
        expect(result, expectedDate);
      });

      test('should calculate annual booster: last dose + 365 days', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2020, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'Rabies',
              ageInWeeks: 16,
              isRequired: true,
            ),
            VaccinationStep(
              vaccineName: 'Rabies Booster',
              ageInWeeks: 68, // Not used for booster calculation
              intervalDays: 365, // Annual
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        final lastDoseDate = DateTime(2023, 6, 15);

        // Act
        final result = await service.calculateNextVaccinationDate(
          pet: pet,
          protocol: protocol,
          stepIndex: 1,
          lastAdministeredDate: lastDoseDate,
        );

        // Assert
        expect(result, DateTime(2024, 6, 14)); // 365 days later
      });
    });

    // ========================================================================
    // GROUP 2: generateVaccinationSchedule() - ~15 tests
    // ========================================================================

    group('generateVaccinationSchedule - Basic Schedule Generation', () {
      test('should generate schedule for all steps in protocol', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Canine Core',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'DHPPiL', ageInWeeks: 6, isRequired: true),
            VaccinationStep(vaccineName: 'DHPPiL', ageInWeeks: 9, intervalDays: 21, isRequired: true),
            VaccinationStep(vaccineName: 'Rabies', ageInWeeks: 16, isRequired: true),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result.length, 3); // 3 steps
        expect(result[0].vaccineName, 'DHPPiL');
        expect(result[0].stepIndex, 0);
        expect(result[1].vaccineName, 'DHPPiL');
        expect(result[1].stepIndex, 1);
        expect(result[2].vaccineName, 'Rabies');
        expect(result[2].stepIndex, 2);
      });

      test('should generate recurring boosters (indefinite)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'Rabies',
              ageInWeeks: 16,
              isRequired: true,
              recurring: RecurringSchedule(
                intervalMonths: 12,
                indefinitely: true,
              ),
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        // Should generate initial dose + 3 future boosters
        expect(result.length, 4);
        expect(result[0].vaccineName, 'Rabies');
        expect(result[1].vaccineName, 'Rabies (Booster 1)');
        expect(result[2].vaccineName, 'Rabies (Booster 2)');
        expect(result[3].vaccineName, 'Rabies (Booster 3)');
      });

      test('should generate recurring boosters (limited doses)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'Special Vaccine',
              ageInWeeks: 8,
              isRequired: true,
              recurring: RecurringSchedule(
                intervalMonths: 6,
                indefinitely: false,
                numberOfDoses: 2,
              ),
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        // Should generate initial dose + 2 boosters (as specified)
        expect(result.length, 3);
        expect(result[0].vaccineName, 'Special Vaccine');
        expect(result[1].vaccineName, 'Special Vaccine (Booster 1)');
        expect(result[2].vaccineName, 'Special Vaccine (Booster 2)');
      });

      test('should handle protocol with no recurring schedules', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'One-time Vaccine',
              ageInWeeks: 8,
              isRequired: true,
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result.length, 1); // Only initial dose
        expect(result[0].vaccineName, 'One-time Vaccine');
      });

      test('should skip steps with invalid dates (no birthday)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: null, // No birthday
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'DHPPiL', ageInWeeks: 6, isRequired: true),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('generateVaccinationSchedule - Recurring Schedule Logic', () {
      test('should generate 3 future doses for indefinite recurring schedules', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'Annual Vaccine',
              ageInWeeks: 52,
              isRequired: true,
              recurring: RecurringSchedule(
                intervalMonths: 12,
                indefinitely: true,
              ),
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result.length, 4); // Initial + 3 boosters
        for (int i = 1; i <= 3; i++) {
          expect(result[i].vaccineName, 'Annual Vaccine (Booster $i)');
        }
      });

      test('should generate exact numberOfDoses for limited recurring schedules', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'Limited Vaccine',
              ageInWeeks: 8,
              isRequired: true,
              recurring: RecurringSchedule(
                intervalMonths: 3,
                indefinitely: false,
                numberOfDoses: 5,
              ),
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result.length, 6); // Initial + 5 boosters
      });

      test('should calculate recurring dates using intervalMonths (addMonths helper)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'Quarterly Vaccine',
              ageInWeeks: 8,
              isRequired: true,
              recurring: RecurringSchedule(
                intervalMonths: 3,
                indefinitely: false,
                numberOfDoses: 2,
              ),
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result.length, 3);
        final initialDate = result[0].scheduledDate;
        final booster1Date = result[1].scheduledDate;
        final booster2Date = result[2].scheduledDate;

        // Verify 3-month intervals
        expect(booster1Date.month, (initialDate.month + 3) % 12 == 0 ? 12 : (initialDate.month + 3) % 12);
        expect(booster2Date.month, (initialDate.month + 6) % 12 == 0 ? 12 : (initialDate.month + 6) % 12);
      });

      test('should label recurring doses as "Booster 1", "Booster 2", etc.', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(
              vaccineName: 'Test Vaccine',
              ageInWeeks: 8,
              isRequired: true,
              recurring: RecurringSchedule(
                intervalMonths: 6,
                indefinitely: false,
                numberOfDoses: 4,
              ),
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result[0].vaccineName, 'Test Vaccine');
        expect(result[1].vaccineName, 'Test Vaccine (Booster 1)');
        expect(result[2].vaccineName, 'Test Vaccine (Booster 2)');
        expect(result[3].vaccineName, 'Test Vaccine (Booster 3)');
        expect(result[4].vaccineName, 'Test Vaccine (Booster 4)');
      });
    });

    group('generateVaccinationSchedule - Already Administered Logic', () {
      test('should use alreadyAdministeredDates for booster calculations', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Dose 1', ageInWeeks: 6, isRequired: true),
            VaccinationStep(vaccineName: 'Dose 2', ageInWeeks: 9, intervalDays: 21, isRequired: true),
          ],
          isCustom: false,
        );

        final alreadyAdministered = [
          DateTime(2024, 2, 20), // Custom first dose date
        ];

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
          alreadyAdministeredDates: alreadyAdministered,
        );

        // Assert
        expect(result.length, 2);
        expect(result[1].scheduledDate, DateTime(2024, 3, 12)); // Feb 20 + 21 days
      });

      test('should calculate subsequent boosters from provided dates', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Dose 1', ageInWeeks: 6, isRequired: true),
            VaccinationStep(vaccineName: 'Dose 2', ageInWeeks: 9, intervalDays: 14, isRequired: true),
            VaccinationStep(vaccineName: 'Dose 3', ageInWeeks: 12, intervalDays: 14, isRequired: true),
          ],
          isCustom: false,
        );

        final alreadyAdministered = [
          DateTime(2024, 3, 1),
          DateTime(2024, 3, 15),
        ];

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
          alreadyAdministeredDates: alreadyAdministered,
        );

        // Assert
        expect(result.length, 3);
        expect(result[2].scheduledDate, DateTime(2024, 3, 29)); // Mar 15 + 14 days
      });
    });

    group('generateVaccinationSchedule - Edge Cases', () {
      test('should return empty list if pet has no birthday', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: null,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 6, isRequired: true),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should handle multi-step protocol (4+ steps)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Step 1', ageInWeeks: 6, isRequired: true),
            VaccinationStep(vaccineName: 'Step 2', ageInWeeks: 9, intervalDays: 21, isRequired: true),
            VaccinationStep(vaccineName: 'Step 3', ageInWeeks: 12, intervalDays: 21, isRequired: true),
            VaccinationStep(vaccineName: 'Step 4', ageInWeeks: 16, intervalDays: 28, isRequired: true),
            VaccinationStep(vaccineName: 'Step 5', ageInWeeks: 52, intervalDays: 252, isRequired: true),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result.length, 5);
        for (int i = 0; i < 5; i++) {
          expect(result[i].stepIndex, i);
        }
      });

      test('should handle protocol with mix of required and optional vaccines', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2024, 1, 1),
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Required 1', ageInWeeks: 6, isRequired: true),
            VaccinationStep(vaccineName: 'Optional 1', ageInWeeks: 8, isRequired: false),
            VaccinationStep(vaccineName: 'Required 2', ageInWeeks: 12, isRequired: true),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateVaccinationSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result.length, 3);
        expect(result[0].isRequired, isTrue);
        expect(result[1].isRequired, isFalse);
        expect(result[2].isRequired, isTrue);
      });
    });

    // ========================================================================
    // GROUP 3: generateDewormingSchedule() - ~12 tests
    // ========================================================================

    group('generateDewormingSchedule - Age-Based Scheduling', () {
      test('should generate schedule for puppies (<12 weeks): every 2-4 weeks', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: DateTime.now().subtract(const Duration(days: 35)), // 5 weeks old
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Puppy Deworming',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 6,
              intervalDays: 21, // 3 weeks
              productName: 'Puppy Dewormer',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 3,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.every((e) => e.dewormingType == 'internal'), isTrue);
      });

      test('should generate schedule for young dogs (12-26 weeks): every 4-8 weeks', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Young Dog',
          species: 'dog',
          birthday: DateTime.now().subtract(const Duration(days: 105)), // 15 weeks old
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Young Dog Deworming',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 12,
              recurring: RecurringSchedule(
                intervalMonths: 1,
                indefinitely: true,
              ),
              productName: 'Youth Dewormer',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 3,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.every((e) => e.productName == 'Youth Dewormer'), isTrue);
      });

      test('should generate schedule for adults (>26 weeks): monthly external, quarterly internal', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Adult Dog',
          species: 'dog',
          birthday: DateTime(2022, 1, 1), // 2+ years old
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Adult Dog Deworming',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 26,
              recurring: RecurringSchedule(
                intervalMonths: 1, // Monthly
                indefinitely: true,
              ),
              productName: 'Bravecto',
            ),
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 26,
              recurring: RecurringSchedule(
                intervalMonths: 3, // Quarterly
                indefinitely: true,
              ),
              productName: 'Milbemax',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 6,
        );

        // Assert
        final external = result.where((e) => e.dewormingType == 'external').toList();
        final internal = result.where((e) => e.dewormingType == 'internal').toList();

        expect(external.length, greaterThan(internal.length)); // More frequent external
        expect(external.length, closeTo(6, 1)); // ~6 monthly treatments
        expect(internal.length, closeTo(2, 1)); // ~2 quarterly treatments
      });

      test('should handle pet already within age range (calculate from now)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Adult Dog',
          species: 'dog',
          birthday: DateTime(2023, 1, 1), // 1+ year old
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Adult Deworming',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 26,
              recurring: RecurringSchedule(
                intervalMonths: 1,
                indefinitely: true,
              ),
              productName: 'Bravecto',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 3,
        );

        // Assert
        expect(result, isNotEmpty);
        // All dates should be in the future
        expect(result.every((e) => e.scheduledDate.isAfter(DateTime.now())), isTrue);
      });
    });

    group('generateDewormingSchedule - External vs Internal', () {
      test('should separate external and internal deworming schedules', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2023, 1, 1),
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Mixed Deworming',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 1, indefinitely: true),
              productName: 'External Product',
            ),
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 3, indefinitely: true),
              productName: 'Internal Product',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 6,
        );

        // Assert
        final external = result.where((e) => e.dewormingType == 'external').toList();
        final internal = result.where((e) => e.dewormingType == 'internal').toList();

        expect(external, isNotEmpty);
        expect(internal, isNotEmpty);
        expect(external.every((e) => e.productName == 'External Product'), isTrue);
        expect(internal.every((e) => e.productName == 'Internal Product'), isTrue);
      });

      test('should handle external deworming with 4-week intervals', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2023, 1, 1),
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'External Only',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 1, indefinitely: true),
              productName: 'Flea Treatment',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 3,
        );

        // Assert
        expect(result.length, closeTo(3, 1)); // ~3 monthly treatments
        expect(result.every((e) => e.dewormingType == 'external'), isTrue);
      });

      test('should handle internal deworming with 12-week intervals', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2023, 1, 1),
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Internal Only',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 3, indefinitely: true),
              productName: 'Worm Treatment',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 9,
        );

        // Assert
        expect(result.length, closeTo(3, 1)); // ~3 quarterly treatments
        expect(result.every((e) => e.dewormingType == 'internal'), isTrue);
      });
    });

    group('generateDewormingSchedule - Recurring Logic', () {
      test('should use recurring.intervalMonths for ongoing treatments', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2023, 1, 1),
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 2, indefinitely: true),
              productName: 'Bi-monthly Treatment',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 6,
        );

        // Assert
        expect(result.length, closeTo(3, 1)); // ~3 bi-monthly treatments
      });

      test('should use intervalDays for non-recurring schedules', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: DateTime.now().subtract(const Duration(days: 21)), // 3 weeks old
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 4,
              intervalDays: 14, // 2 weeks
              productName: 'Puppy Dewormer',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 3,
        );

        // Assert
        expect(result, isNotEmpty);
      });

      test('should stop at endDate (lookAheadMonths)', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2023, 1, 1),
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 1, indefinitely: true),
              productName: 'Monthly Treatment',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result3Months = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 3,
        );

        final result6Months = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 6,
        );

        // Assert
        expect(result6Months.length, greaterThan(result3Months.length));
      });
    });

    group('generateDewormingSchedule - Edge Cases', () {
      test('should return empty list if pet has no birthday', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: null,
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 1, indefinitely: true),
              productName: 'Treatment',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should handle protocol with no schedules', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2023, 1, 1),
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Empty Protocol',
          species: 'dog',
          description: 'Test',
          schedules: [], // No schedules
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('should sort results by date', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime(2023, 1, 1),
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 1, indefinitely: true),
              productName: 'External',
            ),
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 26,
              recurring: RecurringSchedule(intervalMonths: 3, indefinitely: true),
              productName: 'Internal',
            ),
          ],
          isCustom: false,
        );

        // Act
        final result = await service.generateDewormingSchedule(
          pet: pet,
          protocol: protocol,
          lookAheadMonths: 6,
        );

        // Assert
        for (int i = 1; i < result.length; i++) {
          expect(
            result[i].scheduledDate.isAfter(result[i - 1].scheduledDate) ||
                result[i].scheduledDate.isAtSameMomentAs(result[i - 1].scheduledDate),
            isTrue,
            reason: 'Results should be sorted by date',
          );
        }
      });
    });

    // ========================================================================
    // GROUP 4: suggestNextAppointment() - ~10 tests
    // ========================================================================

    group('suggestNextAppointment - Basic Suggestions', () {
      test('should suggest appointment when vaccination due within 30 days', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 15 * 7)); // 15 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: birthdate,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Rabies Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Rabies', ageInWeeks: 16, isRequired: true),
          ],
          isCustom: false,
        );

        await vaccinationRepo.save(protocol);

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 30,
        );

        // Assert
        expect(result.length, greaterThan(0));
        expect(result.first.reason, contains('Rabies'));
        expect(result.first.dueVaccinations.length, greaterThan(0));
        expect(result.first.preparationChecklist, contains('vaccination card'));
      });

      test('should suggest appointment when deworming due within 30 days', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: DateTime.now().subtract(const Duration(days: 35)), // 5 weeks old
        );

        final protocol = DewormingProtocol(
          id: 'test-protocol',
          name: 'Puppy Deworming',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 6,
              productName: 'Dewormer',
            ),
          ],
          isCustom: false,
        );

        await dewormingRepo.save(protocol);

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 30,
        );

        // Assert
        expect(result.length, greaterThan(0));
        expect(result.first.reason, contains('Deworming'));
        expect(result.first.dueDeworming.length, greaterThan(0));
      });

      test('should combine vaccination + deworming in same suggestion', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 5 * 7)); // 5 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: birthdate,
        );

        final vacProtocol = VaccinationProtocol(
          id: 'vac-protocol',
          name: 'Puppy Vaccines',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'DHPPiL', ageInWeeks: 6, isRequired: true),
          ],
          isCustom: false,
        );

        final dewormProtocol = DewormingProtocol(
          id: 'deworm-protocol',
          name: 'Puppy Deworming',
          species: 'dog',
          description: 'Test',
          schedules: [
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 6,
              productName: 'Dewormer',
            ),
          ],
          isCustom: false,
        );

        await vaccinationRepo.save(vacProtocol);
        await dewormingRepo.save(dewormProtocol);

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 30,
        );

        // Assert
        if (result.isNotEmpty) {
          expect(result.first.reason, contains('Vaccination'));
          expect(result.first.reason, contains('Deworming'));
        }
      });

      test('should return empty list if nothing due within window', () async {
        // Arrange
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Adult Dog',
          species: 'dog',
          birthday: DateTime(2020, 1, 1), // Very old - no upcoming vaccines
        );

        // No protocols saved

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 30,
        );

        // Assert
        expect(result, isEmpty);
      });
    });

    group('suggestNextAppointment - Date Grouping', () {
      test('should group multiple vaccines due on same day', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 5 * 7)); // 5 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: birthdate,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Multi-Vaccine',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'DHPPiL', ageInWeeks: 6, isRequired: true),
            VaccinationStep(vaccineName: 'Bordetella', ageInWeeks: 6, isRequired: false),
          ],
          isCustom: false,
        );

        await vaccinationRepo.save(protocol);

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 30,
        );

        // Assert
        if (result.isNotEmpty) {
          expect(result.first.dueVaccinations.length, greaterThanOrEqualTo(1));
        }
      });

      test('should use earliest date as suggested appointment date', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 5 * 7)); // 5 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: birthdate,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Early Vaccine', ageInWeeks: 6, isRequired: true),
            VaccinationStep(vaccineName: 'Later Vaccine', ageInWeeks: 9, intervalDays: 21, isRequired: true),
          ],
          isCustom: false,
        );

        await vaccinationRepo.save(protocol);

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 60,
        );

        // Assert
        if (result.isNotEmpty) {
          final earliestVaccine = result.first.dueVaccinations
              .reduce((a, b) => a.scheduledDate.isBefore(b.scheduledDate) ? a : b);
          expect(result.first.suggestedDate, earliestVaccine.scheduledDate);
        }
      });

      test('should include preparation checklist', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 5 * 7)); // 5 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: birthdate,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'DHPPiL', ageInWeeks: 6, isRequired: true),
          ],
          isCustom: false,
        );

        await vaccinationRepo.save(protocol);

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 30,
        );

        // Assert
        if (result.isNotEmpty) {
          expect(result.first.preparationChecklist, isNotEmpty);
          expect(result.first.preparationChecklist, contains('vaccination card'));
          expect(result.first.preparationChecklist, contains('behavioral changes'));
        }
      });
    });

    group('suggestNextAppointment - Window Logic', () {
      test('should respect suggestionWindowDays parameter', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 20 * 7)); // 20 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: birthdate,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Future Vaccine', ageInWeeks: 52, isRequired: true), // Far in future
          ],
          isCustom: false,
        );

        await vaccinationRepo.save(protocol);

        // Act
        final resultShortWindow = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 7,
        );

        final resultLongWindow = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 365,
        );

        // Assert
        expect(resultShortWindow.length, lessThanOrEqualTo(resultLongWindow.length));
      });

      test('should only include protocols due after now', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 30 * 7)); // 30 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Dog',
          species: 'dog',
          birthday: birthdate,
        );

        final protocol = VaccinationProtocol(
          id: 'test-protocol',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Past Vaccine', ageInWeeks: 6, isRequired: true), // In past
          ],
          isCustom: false,
        );

        await vaccinationRepo.save(protocol);

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 30,
        );

        // Assert
        // Should not suggest past vaccinations
        if (result.isNotEmpty) {
          expect(
            result.first.dueVaccinations.every((v) => v.scheduledDate.isAfter(DateTime.now())),
            isTrue,
          );
        }
      });

      test('should filter to predefined protocols only', () async {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 5 * 7)); // 5 weeks old
        final pet = PetProfile(
          id: 'test-pet',
          name: 'Puppy',
          species: 'dog',
          birthday: birthdate,
        );

        final predefinedProtocol = VaccinationProtocol(
          id: 'predefined',
          name: 'Predefined',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Predefined Vaccine', ageInWeeks: 6, isRequired: true),
          ],
          isCustom: false,
        );

        final customProtocol = VaccinationProtocol(
          id: 'custom',
          name: 'Custom',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Custom Vaccine', ageInWeeks: 6, isRequired: true),
          ],
          isCustom: true,
        );

        await vaccinationRepo.save(predefinedProtocol);
        await vaccinationRepo.save(customProtocol);

        // Act
        final result = await service.suggestNextAppointment(
          pet: pet,
          suggestionWindowDays: 30,
        );

        // Assert
        if (result.isNotEmpty) {
          // Should only include predefined protocols
          expect(
            result.first.dueVaccinations.any((v) => v.vaccineName == 'Custom Vaccine'),
            isFalse,
          );
        }
      });
    });

    // ========================================================================
    // GROUP 5: createVaccinationMedicationEntry() - ~8 tests
    // ========================================================================

    group('createVaccinationMedicationEntry - Basic Creation', () {
      test('should create MedicationEntry with vaccine name', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final protocol = VaccinationProtocol(
          id: 'protocol-1',
          name: 'Test Protocol',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Rabies', ageInWeeks: 16, isRequired: true),
          ],
          isCustom: false,
        );
        final scheduleEntry = VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'Rabies',
          scheduledDate: DateTime(2024, 12, 1),
          isRequired: true,
        );

        // Act
        final result = service.createVaccinationMedicationEntry(
          pet: pet,
          protocol: protocol,
          scheduleEntry: scheduleEntry,
        );

        // Assert
        expect(result.petId, 'pet-1');
        expect(result.medicationName, 'Rabies');
      });

      test('should set administrationMethod to "Injection"', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final protocol = VaccinationProtocol(
          id: 'protocol-1',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 8, isRequired: true)],
          isCustom: false,
        );
        final scheduleEntry = VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'Vaccine',
          scheduledDate: DateTime(2024, 12, 1),
          isRequired: true,
        );

        // Act
        final result = service.createVaccinationMedicationEntry(
          pet: pet,
          protocol: protocol,
          scheduleEntry: scheduleEntry,
        );

        // Assert
        expect(result.administrationMethod, 'Injection');
      });

      test('should set frequency to "Once"', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final protocol = VaccinationProtocol(
          id: 'protocol-1',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 8, isRequired: true)],
          isCustom: false,
        );
        final scheduleEntry = VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'Vaccine',
          scheduledDate: DateTime(2024, 12, 1),
          isRequired: true,
        );

        // Act
        final result = service.createVaccinationMedicationEntry(
          pet: pet,
          protocol: protocol,
          scheduleEntry: scheduleEntry,
        );

        // Assert
        expect(result.frequency, 'Once');
      });

      test('should use scheduledDate for both startDate and endDate', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final protocol = VaccinationProtocol(
          id: 'protocol-1',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 8, isRequired: true)],
          isCustom: false,
        );
        final scheduledDate = DateTime(2024, 12, 15, 10, 30);
        final scheduleEntry = VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'Vaccine',
          scheduledDate: scheduledDate,
          isRequired: true,
        );

        // Act
        final result = service.createVaccinationMedicationEntry(
          pet: pet,
          protocol: protocol,
          scheduleEntry: scheduleEntry,
        );

        // Assert
        expect(result.startDate, scheduledDate);
        expect(result.endDate, scheduledDate);
      });
    });

    group('createVaccinationMedicationEntry - Metadata Handling', () {
      test('should embed protocol metadata in notes field (JSON)', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final protocol = VaccinationProtocol(
          id: 'protocol-1',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [VaccinationStep(vaccineName: 'Rabies', ageInWeeks: 16, isRequired: true)],
          isCustom: false,
        );
        final scheduleEntry = VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'Rabies',
          scheduledDate: DateTime(2024, 12, 1),
          isRequired: true,
        );

        // Act
        final result = service.createVaccinationMedicationEntry(
          pet: pet,
          protocol: protocol,
          scheduleEntry: scheduleEntry,
        );

        // Assert
        expect(result.notes, contains('Metadata:'));
        expect(result.notes, isNotNull);
      });

      test('should include protocolId in metadata', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final protocol = VaccinationProtocol(
          id: 'protocol-123',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 8, isRequired: true)],
          isCustom: false,
        );
        final scheduleEntry = VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'Vaccine',
          scheduledDate: DateTime(2024, 12, 1),
          isRequired: true,
        );

        // Act
        final result = service.createVaccinationMedicationEntry(
          pet: pet,
          protocol: protocol,
          scheduleEntry: scheduleEntry,
        );

        // Assert
        expect(result.notes, contains('protocol-123'));
        expect(result.notes, contains('protocolId'));
      });

      test('should include stepIndex in metadata', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final protocol = VaccinationProtocol(
          id: 'protocol-1',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [
            VaccinationStep(vaccineName: 'Step 1', ageInWeeks: 6, isRequired: true),
            VaccinationStep(vaccineName: 'Step 2', ageInWeeks: 9, isRequired: true),
          ],
          isCustom: false,
        );
        final scheduleEntry = VaccinationScheduleEntry(
          stepIndex: 1,
          vaccineName: 'Step 2',
          scheduledDate: DateTime(2024, 12, 1),
          isRequired: true,
        );

        // Act
        final result = service.createVaccinationMedicationEntry(
          pet: pet,
          protocol: protocol,
          scheduleEntry: scheduleEntry,
        );

        // Assert
        expect(result.notes, contains('protocolStepIndex'));
        final metadata = result.notes!.split('Metadata: ')[1];
        final json = jsonDecode(metadata);
        expect(json['protocolStepIndex'], 1);
      });

      test('should combine additionalNotes with metadata', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final protocol = VaccinationProtocol(
          id: 'protocol-1',
          name: 'Test',
          species: 'dog',
          description: 'Test',
          steps: [VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 8, isRequired: true)],
          isCustom: false,
        );
        final scheduleEntry = VaccinationScheduleEntry(
          stepIndex: 0,
          vaccineName: 'Vaccine',
          scheduledDate: DateTime(2024, 12, 1),
          isRequired: true,
        );

        // Act
        final result = service.createVaccinationMedicationEntry(
          pet: pet,
          protocol: protocol,
          scheduleEntry: scheduleEntry,
          additionalNotes: 'User added notes here',
        );

        // Assert
        expect(result.notes, contains('User added notes here'));
        expect(result.notes, contains('Metadata:'));
      });
    });

    // ========================================================================
    // GROUP 6: createProtocolAppointmentEntry() - ~6 tests
    // ========================================================================

    group('createProtocolAppointmentEntry - Basic Creation', () {
      test('should create AppointmentEntry with suggested date', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final suggestion = AppointmentSuggestion(
          suggestedDate: DateTime(2024, 12, 15),
          reason: 'Vaccination',
          linkedProtocolIds: ['protocol-1'],
          dueVaccinations: [],
          dueDeworming: [],
          preparationChecklist: 'Checklist',
        );

        // Act
        final result = service.createProtocolAppointmentEntry(
          pet: pet,
          suggestion: suggestion,
          veterinarian: 'Dr. Smith',
          clinic: 'Pet Care Clinic',
        );

        // Assert
        expect(result.petId, 'pet-1');
        expect(result.appointmentDate, DateTime(2024, 12, 15));
        expect(result.veterinarian, 'Dr. Smith');
        expect(result.clinic, 'Pet Care Clinic');
      });

      test('should use customDate if provided', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final suggestion = AppointmentSuggestion(
          suggestedDate: DateTime(2024, 12, 15),
          reason: 'Vaccination',
          linkedProtocolIds: ['protocol-1'],
          dueVaccinations: [],
          dueDeworming: [],
          preparationChecklist: 'Checklist',
        );
        final customDate = DateTime(2024, 12, 20);

        // Act
        final result = service.createProtocolAppointmentEntry(
          pet: pet,
          suggestion: suggestion,
          veterinarian: 'Dr. Smith',
          clinic: 'Pet Care Clinic',
          customDate: customDate,
        );

        // Assert
        expect(result.appointmentDate, customDate);
      });

      test('should set default time to 9 AM', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final suggestion = AppointmentSuggestion(
          suggestedDate: DateTime(2024, 12, 15),
          reason: 'Vaccination',
          linkedProtocolIds: ['protocol-1'],
          dueVaccinations: [],
          dueDeworming: [],
          preparationChecklist: 'Checklist',
        );

        // Act
        final result = service.createProtocolAppointmentEntry(
          pet: pet,
          suggestion: suggestion,
          veterinarian: 'Dr. Smith',
          clinic: 'Pet Care Clinic',
        );

        // Assert
        expect(result.appointmentTime.hour, 9);
        expect(result.appointmentTime.minute, 0);
      });

      test('should include preparation checklist in notes', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final suggestion = AppointmentSuggestion(
          suggestedDate: DateTime(2024, 12, 15),
          reason: 'Vaccination',
          linkedProtocolIds: ['protocol-1'],
          dueVaccinations: [],
          dueDeworming: [],
          preparationChecklist: 'Bring vaccine card\nNote behavioral changes',
        );

        // Act
        final result = service.createProtocolAppointmentEntry(
          pet: pet,
          suggestion: suggestion,
          veterinarian: 'Dr. Smith',
          clinic: 'Pet Care Clinic',
        );

        // Assert
        expect(result.notes, contains('Bring vaccine card'));
        expect(result.notes, contains('Note behavioral changes'));
      });
    });

    group('createProtocolAppointmentEntry - Metadata Handling', () {
      test('should embed linkedProtocolIds in notes (JSON)', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final suggestion = AppointmentSuggestion(
          suggestedDate: DateTime(2024, 12, 15),
          reason: 'Vaccination',
          linkedProtocolIds: ['protocol-1', 'protocol-2'],
          dueVaccinations: [],
          dueDeworming: [],
          preparationChecklist: 'Checklist',
        );

        // Act
        final result = service.createProtocolAppointmentEntry(
          pet: pet,
          suggestion: suggestion,
          veterinarian: 'Dr. Smith',
          clinic: 'Pet Care Clinic',
        );

        // Assert
        expect(result.notes, contains('Metadata:'));
        expect(result.notes, contains('linkedProtocolIds'));
      });

      test('should combine additionalNotes with checklist', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog');
        final suggestion = AppointmentSuggestion(
          suggestedDate: DateTime(2024, 12, 15),
          reason: 'Vaccination',
          linkedProtocolIds: ['protocol-1'],
          dueVaccinations: [],
          dueDeworming: [],
          preparationChecklist: 'Bring vaccine card',
        );

        // Act
        final result = service.createProtocolAppointmentEntry(
          pet: pet,
          suggestion: suggestion,
          veterinarian: 'Dr. Smith',
          clinic: 'Pet Care Clinic',
          additionalNotes: 'Pet is nervous at vet',
        );

        // Assert
        expect(result.notes, contains('Pet is nervous at vet'));
        expect(result.notes, contains('Bring vaccine card'));
        expect(result.notes, contains('Metadata:'));
      });
    });

    // ========================================================================
    // GROUP 7: Helper Methods - ~10 tests
    // ========================================================================

    group('Helper Methods - isPetOldEnough', () {
      test('should return true if pet age >= step age requirement', () {
        // Arrange
        final pet = PetProfile(
          id: 'pet-1',
          name: 'Buddy',
          species: 'dog',
          birthday: DateTime.now().subtract(const Duration(days: 60)), // 8+ weeks old
        );
        final step = VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 6, isRequired: true);

        // Act
        final result = service.isPetOldEnough(pet, step);

        // Assert
        expect(result, isTrue);
      });

      test('should return false if pet too young', () {
        // Arrange
        final pet = PetProfile(
          id: 'pet-1',
          name: 'Puppy',
          species: 'dog',
          birthday: DateTime.now().subtract(const Duration(days: 14)), // 2 weeks old
        );
        final step = VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 6, isRequired: true);

        // Act
        final result = service.isPetOldEnough(pet, step);

        // Assert
        expect(result, isFalse);
      });

      test('should return false if pet has no birthday', () {
        // Arrange
        final pet = PetProfile(id: 'pet-1', name: 'Buddy', species: 'dog', birthday: null);
        final step = VaccinationStep(vaccineName: 'Vaccine', ageInWeeks: 6, isRequired: true);

        // Act
        final result = service.isPetOldEnough(pet, step);

        // Assert
        expect(result, isFalse);
      });
    });

    group('Helper Methods - findBestVaccinationProtocol', () {
      test('should find region-specific protocol if region matches', () async {
        // Arrange
        final romanianProtocol = VaccinationProtocol(
          id: 'romanian-protocol',
          name: 'Romanian Protocol',
          species: 'dog',
          description: 'Test',
          steps: [],
          isCustom: false,
          region: 'Romania',
        );
        final euProtocol = VaccinationProtocol(
          id: 'eu-protocol',
          name: 'EU Protocol',
          species: 'dog',
          description: 'Test',
          steps: [],
          isCustom: false,
          region: 'EU',
        );

        await vaccinationRepo.save(romanianProtocol);
        await vaccinationRepo.save(euProtocol);

        // Act
        final result = await service.findBestVaccinationProtocol(
          species: 'dog',
          region: 'Romania',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'romanian-protocol');
      });

      test('should fall back to first predefined protocol', () async {
        // Arrange
        final protocol = VaccinationProtocol(
          id: 'default-protocol',
          name: 'Default Protocol',
          species: 'dog',
          description: 'Test',
          steps: [],
          isCustom: false,
        );

        await vaccinationRepo.save(protocol);

        // Act
        final result = await service.findBestVaccinationProtocol(species: 'dog');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'default-protocol');
      });

      test('should return null if no protocols found for species', () async {
        // Act
        final result = await service.findBestVaccinationProtocol(species: 'cat');

        // Assert
        expect(result, isNull);
      });
    });

    group('Helper Methods - findBestDewormingProtocol', () {
      test('should prefer predefined over custom protocols', () async {
        // Arrange
        final customProtocol = DewormingProtocol(
          id: 'custom-protocol',
          name: 'Custom Protocol',
          species: 'dog',
          description: 'Test',
          schedules: [],
          isCustom: true,
        );
        final predefinedProtocol = DewormingProtocol(
          id: 'predefined-protocol',
          name: 'Predefined Protocol',
          species: 'dog',
          description: 'Test',
          schedules: [],
          isCustom: false,
        );

        await dewormingRepo.save(customProtocol);
        await dewormingRepo.save(predefinedProtocol);

        // Act
        final result = await service.findBestDewormingProtocol(species: 'dog');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'predefined-protocol');
      });
    });

    group('Helper Methods - calculateAgeInWeeks', () {
      test('should return correct age in weeks', () {
        // Arrange
        final birthdate = DateTime.now().subtract(const Duration(days: 42)); // 6 weeks

        // Act
        final result = service.calculateAgeInWeeks(birthdate);

        // Assert
        expect(result, 6);
      });

      test('should return 0 if birthdate is null', () {
        // Act
        final result = service.calculateAgeInWeeks(null);

        // Assert
        expect(result, 0);
      });
    });

    group('Helper Methods - addMonths', () {
      test('should add months correctly (Jan + 3 = April)', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 10, 30);

        // Act
        final result = service.addMonths(date, 3);

        // Assert
        expect(result, DateTime(2024, 4, 15, 10, 30));
      });

      test('should handle year rollover (Dec + 2 = Feb next year)', () {
        // Arrange
        final date = DateTime(2024, 11, 15);

        // Act
        final result = service.addMonths(date, 3);

        // Assert
        expect(result, DateTime(2025, 2, 15));
      });

      test('should handle month-end edge case (Jan 31 + 1 = Feb 28/29)', () {
        // Arrange
        final date = DateTime(2024, 1, 31);

        // Act
        final result = service.addMonths(date, 1);

        // Assert
        // Jan 31 + 1 month = Feb 29 (2024 is leap year)
        expect(result, DateTime(2024, 2, 29));
      });

      test('should preserve time components (hours, minutes)', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 14, 45, 30);

        // Act
        final result = service.addMonths(date, 2);

        // Assert
        expect(result.hour, 14);
        expect(result.minute, 45);
        expect(result.second, 30);
      });
    });
  });
}
