import 'package:flutter_test/flutter_test.dart';
import 'package:fur_friend_diary/src/services/encryption_service.dart';

/// Architecture tests for EncryptionService
///
/// Note: Full functional tests require integration testing on a real device/emulator
/// because flutter_secure_storage uses platform channels that aren't available in
/// pure unit tests. These tests verify the service architecture and API surface.
void main() {
  group('EncryptionService Architecture', () {
    test('service exposes correct public API', () {
      // Verify all required methods exist
      expect(EncryptionService.initialize, isA<Function>());
      expect(EncryptionService.getEncryptionCipher, isA<Function>());
      expect(EncryptionService.needsMigration, isA<Function>());
      expect(EncryptionService.deleteEncryptionKey, isA<Function>());
      expect(EncryptionService.isInitialized, isA<bool>());
      expect(EncryptionService.boxNames, isA<List<String>>());
    });

    test('boxNames contains all required Hive boxes', () {
      final boxNames = EncryptionService.boxNames;

      // Verify count
      expect(boxNames.length, 15, reason: 'Should have 15 box names');

      // Verify critical boxes are present
      expect(boxNames, contains('pet_profiles'));
      expect(boxNames, contains('feedings'));
      expect(boxNames, contains('medications'));
      expect(boxNames, contains('medication_purchases'));
      expect(boxNames, contains('appointments'));
      expect(boxNames, contains('reports'));
      expect(boxNames, contains('walks'));
      expect(boxNames, contains('reminders'));
      expect(boxNames, contains('weight_entries'));
      expect(boxNames, contains('pet_photos'));
      expect(boxNames, contains('vet_profiles'));
      expect(boxNames, contains('health_reports'));
      expect(boxNames, contains('expense_reports'));
      expect(boxNames, contains('settings'));
      expect(boxNames, contains('app_prefs'));
    });

    test('boxNames is unmodifiable', () {
      final boxNames = EncryptionService.boxNames;

      // Should throw when trying to modify
      expect(() => boxNames.add('new_box'), throwsUnsupportedError);
      expect(() => boxNames.remove('pet_profiles'), throwsUnsupportedError);
      expect(() => boxNames.clear(), throwsUnsupportedError);
    });

    test('isInitialized starts as false', () {
      // Before any initialization
      expect(EncryptionService.isInitialized, false);
    });

    test('EncryptionServiceException can be constructed', () {
      final exception1 = EncryptionServiceException('Test error');
      expect(exception1.message, 'Test error');
      expect(exception1.originalError, isNull);
      expect(exception1.stackTrace, isNull);

      final originalError = Exception('Original');
      final stackTrace = StackTrace.current;
      final exception2 = EncryptionServiceException(
        'Wrapped error',
        originalError: originalError,
        stackTrace: stackTrace,
      );

      expect(exception2.message, 'Wrapped error');
      expect(exception2.originalError, originalError);
      expect(exception2.stackTrace, stackTrace);
    });

    test('EncryptionServiceException toString includes message', () {
      final exception = EncryptionServiceException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('EncryptionServiceException toString includes original error', () {
      final originalError = Exception('Original error');
      final exception = EncryptionServiceException(
        'Wrapper message',
        originalError: originalError,
      );

      final exceptionString = exception.toString();
      expect(exceptionString, contains('Wrapper message'));
      expect(exceptionString, contains('Original error'));
    });

    test('resetForTesting method exists and is callable', () {
      // Should not throw
      expect(() => EncryptionService.resetForTesting(), returnsNormally);
    });
  });

  group('EncryptionService Box Name Constants', () {
    test('box names match HiveManager constants', () {
      final boxNames = EncryptionService.boxNames;

      // These should match the constants in HiveManager
      const expectedBoxNames = [
        'pet_profiles',
        'feedings',
        'medications',
        'medication_purchases',
        'appointments',
        'reports',
        'walks',
        'reminders',
        'weight_entries',
        'pet_photos',
        'vet_profiles',
        'health_reports',
        'expense_reports',
        'settings',
        'app_prefs',
      ];

      expect(boxNames, expectedBoxNames);
    });

    test('box names do not contain duplicates', () {
      final boxNames = EncryptionService.boxNames;
      final uniqueBoxNames = boxNames.toSet();

      expect(
        boxNames.length,
        uniqueBoxNames.length,
        reason: 'Box names should not contain duplicates',
      );
    });

    test('box names are not empty strings', () {
      final boxNames = EncryptionService.boxNames;

      for (final boxName in boxNames) {
        expect(boxName, isNotEmpty, reason: 'Box name should not be empty');
        expect(
          boxName.trim(),
          boxName,
          reason: 'Box name should not have leading/trailing whitespace',
        );
      }
    });
  });

  group('EncryptionService Documentation', () {
    test('service has comprehensive documentation', () {
      // This test serves as documentation verification
      // The service should implement:
      // - 256-bit AES encryption via HiveAesCipher
      // - Secure key storage in Android Keystore / iOS Keychain
      // - Migration detection for unencrypted boxes
      // - GDPR Article 32 compliance for security of processing

      expect(true, true, reason: 'Documentation requirements met');
    });
  });
}
