// Unit test to verify vaccination dose date fix
// This test ensures medications created with vaccination protocols
// use the CURRENT dose date (startDate), not the NEXT dose date (endDate)

import 'package:flutter_test/flutter_test.dart';
import 'package:fur_friend_diary/src/domain/models/medication_entry.dart';
import 'package:fur_friend_diary/src/presentation/models/upcoming_care_event.dart';

void main() {
  group('Vaccination Dose Date Fix', () {
    test('MedicationEvent should use startDate as scheduledDate', () {
      // Simulate a vaccination medication entry
      // User sets Start Date: Nov 23, 2025 (current dose being logged)
      // System calculates Next Dose: Dec 21, 2025 (informational only)
      final currentDoseDate = DateTime(2025, 11, 23);

      final medication = MedicationEntry(
        petId: 'test-pet-id',
        medicationName: 'DHPPiL',
        dosage: 'Standard vaccine dose',
        frequency: 'frequencyOnceDaily',
        startDate: currentDoseDate, // Current dose being logged (Nov 23)
        endDate: currentDoseDate,   // Single dose, same day (Nov 23)
        administrationMethod: 'administrationMethodInjection',
        notes: 'Metadata: {"isVaccination":true,"protocolId":"canine_core","protocolStepIndex":0}',
      );

      // Create MedicationEvent from the medication entry
      final event = MedicationEvent(medication);

      // Verify: The scheduled date should be the CURRENT dose date (Nov 23)
      // NOT the next dose date (Dec 21)
      expect(event.scheduledDate, equals(currentDoseDate));
      expect(event.scheduledDate.month, equals(11));
      expect(event.scheduledDate.day, equals(23));
    });

    test('MedicationEvent should use startDate even when endDate is different', () {
      // Edge case: Even if endDate differs from startDate,
      // the scheduled date should still be startDate for display purposes
      final startDate = DateTime(2025, 11, 23);
      final endDate = DateTime(2025, 12, 21);

      final medication = MedicationEntry(
        petId: 'test-pet-id',
        medicationName: 'Test Medication',
        dosage: '1 pill',
        frequency: 'frequencyOnceDaily',
        startDate: startDate,
        endDate: endDate,
        administrationMethod: 'administrationMethodOral',
      );

      final event = MedicationEvent(medication);

      // Should use startDate, not endDate
      expect(event.scheduledDate, equals(startDate));
      expect(event.scheduledDate, isNot(equals(endDate)));
    });

    test('MedicationEntry preserves both startDate and endDate correctly', () {
      // Verify the medication entry itself stores both dates correctly
      final currentDoseDate = DateTime(2025, 11, 23);

      final medication = MedicationEntry(
        petId: 'test-pet-id',
        medicationName: 'DHPPiL',
        dosage: 'Standard vaccine dose',
        frequency: 'frequencyOnceDaily',
        startDate: currentDoseDate,
        endDate: currentDoseDate, // Single dose
        administrationMethod: 'administrationMethodInjection',
      );

      // Verify both fields are stored correctly
      expect(medication.startDate, equals(currentDoseDate));
      expect(medication.endDate, equals(currentDoseDate));
      expect(medication.startDate.day, equals(23));
      expect(medication.endDate!.day, equals(23));
    });

    test('MedicationEvent correctly identifies vaccinations from metadata', () {
      // Verify that vaccination detection works correctly
      final medication = MedicationEntry(
        petId: 'test-pet-id',
        medicationName: 'DHPPiL',
        dosage: 'Standard vaccine dose',
        frequency: 'frequencyOnceDaily',
        startDate: DateTime(2025, 11, 23),
        administrationMethod: 'administrationMethodInjection',
        notes: 'Metadata: {"isVaccination":true,"protocolId":"canine_core","protocolStepIndex":0}',
      );

      final event = MedicationEvent(medication);

      // Should be recognized as a vaccination
      expect(event.isVaccination, isTrue);
      expect(event.eventType, equals('medication'));
      expect(event.icon, equals('💊'));
    });

    test('Regular medication (non-vaccination) still uses startDate', () {
      // Verify that regular medications also use startDate
      final medication = MedicationEntry(
        petId: 'test-pet-id',
        medicationName: 'Antibiotics',
        dosage: '1 pill',
        frequency: 'frequencyTwiceDaily',
        startDate: DateTime(2025, 11, 23),
        endDate: DateTime(2025, 12, 3), // 10-day course
        administrationMethod: 'administrationMethodOral',
      );

      final event = MedicationEvent(medication);

      // Should use startDate (when medication starts)
      expect(event.scheduledDate, equals(medication.startDate));
      expect(event.scheduledDate.day, equals(23));
      expect(event.isVaccination, isFalse);
    });
  });
}
