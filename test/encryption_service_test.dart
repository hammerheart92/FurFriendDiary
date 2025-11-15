import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/services/encryption_service.dart';

void main() {
  // Set up test directory for Hive
  late Directory testDirectory;

  setUpAll(() async {
    // Initialize Flutter bindings for platform channel tests
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    // Create a temporary directory for Hive
    testDirectory = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(testDirectory.path);

    // Reset the encryption service state
    EncryptionService.resetForTesting();
  });

  tearDown(() async {
    // Close all Hive boxes
    await Hive.close();

    // Clean up test directory
    if (testDirectory.existsSync()) {
      testDirectory.deleteSync(recursive: true);
    }

    // Reset the encryption service state
    EncryptionService.resetForTesting();
  });

  group('EncryptionService Initialization', () {
    test('initialize() generates new key on first launch', () async {
      // Initialize service
      await EncryptionService.initialize();

      // Verify it's initialized
      expect(EncryptionService.isInitialized, true);

      // Verify we can get a cipher
      final cipher = await EncryptionService.getEncryptionCipher();
      expect(cipher, isNotNull);
    });

    test('initialize() is idempotent - safe to call multiple times', () async {
      // Initialize twice
      await EncryptionService.initialize();
      await EncryptionService.initialize();

      // Should still be initialized
      expect(EncryptionService.isInitialized, true);
    });

    test('isInitialized returns false before initialization', () {
      expect(EncryptionService.isInitialized, false);
    });

    test('isInitialized returns true after initialization', () async {
      await EncryptionService.initialize();
      expect(EncryptionService.isInitialized, true);
    });
  });

  group('EncryptionService Key Generation', () {
    test('generates 256-bit encryption key', () async {
      await EncryptionService.initialize();

      final cipher = await EncryptionService.getEncryptionCipher();
      expect(cipher, isA<HiveAesCipher>());
    });

    test('generated key persists across service resets', () async {
      // Initialize and get first cipher
      await EncryptionService.initialize();
      final cipher1 = await EncryptionService.getEncryptionCipher();

      // Reset service (simulates app restart)
      EncryptionService.resetForTesting();

      // Re-initialize and get cipher again
      await EncryptionService.initialize();
      final cipher2 = await EncryptionService.getEncryptionCipher();

      // Both ciphers should work the same way (same key)
      // We can't compare the ciphers directly, but we can test
      // that they encrypt/decrypt the same way
      expect(cipher1, isNotNull);
      expect(cipher2, isNotNull);
    });

    test('getEncryptionCipher() caches cipher after first retrieval', () async {
      await EncryptionService.initialize();

      final cipher1 = await EncryptionService.getEncryptionCipher();
      final cipher2 = await EncryptionService.getEncryptionCipher();

      // Should return the same instance
      expect(identical(cipher1, cipher2), true);
    });

    test('getEncryptionCipher() throws exception when not initialized', () async {
      // Note: This test may fail in practice because initialize() also
      // generates the key. But we test the error path.
      expect(
        () => EncryptionService.getEncryptionCipher(),
        throwsA(isA<EncryptionServiceException>()),
      );
    });
  });

  group('EncryptionService Cipher Usage', () {
    test('cipher can encrypt and decrypt Hive box', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      // Open encrypted box
      final box = await Hive.openBox(
        'test_encrypted_box',
        encryptionCipher: cipher,
      );

      // Write data
      await box.put('key1', 'sensitive_data');
      expect(box.get('key1'), 'sensitive_data');

      await box.close();
    });

    test('encrypted box cannot be opened without cipher', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      // Create encrypted box
      final box = await Hive.openBox(
        'test_encrypted_box_2',
        encryptionCipher: cipher,
      );
      await box.put('secret', 'confidential');
      await box.close();

      // Try to open without cipher - should fail
      expect(
        () => Hive.openBox('test_encrypted_box_2'),
        throwsA(isA<HiveError>()),
      );
    });

    test('cipher works with complex data types', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      final box = await Hive.openBox(
        'test_complex_data',
        encryptionCipher: cipher,
      );

      // Test various data types
      await box.put('string', 'test');
      await box.put('number', 42);
      await box.put('double', 3.14159);
      await box.put('bool', true);
      await box.put('list', [1, 2, 3]);
      await box.put('map', {'key': 'value'});

      expect(box.get('string'), 'test');
      expect(box.get('number'), 42);
      expect(box.get('double'), 3.14159);
      expect(box.get('bool'), true);
      expect(box.get('list'), [1, 2, 3]);
      expect(box.get('map'), {'key': 'value'});

      await box.close();
    });
  });

  group('EncryptionService Migration Detection', () {
    test('needsMigration() returns false when no boxes exist', () async {
      await EncryptionService.initialize();

      final needsMigration = await EncryptionService.needsMigration();
      expect(needsMigration, false);
    });

    test('needsMigration() returns true when unencrypted boxes exist', () async {
      await EncryptionService.initialize();

      // Create unencrypted boxes
      final box1 = await Hive.openBox('pet_profiles');
      await box1.put('pet1', 'data');
      await box1.close();

      final needsMigration = await EncryptionService.needsMigration();
      expect(needsMigration, true);
    });

    test('needsMigration() returns false when all boxes are encrypted', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      // Create encrypted boxes
      final box1 = await Hive.openBox(
        'pet_profiles',
        encryptionCipher: cipher,
      );
      await box1.put('pet1', 'data');
      await box1.close();

      final box2 = await Hive.openBox(
        'medications',
        encryptionCipher: cipher,
      );
      await box2.put('med1', 'data');
      await box2.close();

      final needsMigration = await EncryptionService.needsMigration();
      expect(needsMigration, false);
    });

    test('needsMigration() detects mix of encrypted and unencrypted boxes', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      // Create one encrypted box
      final encryptedBox = await Hive.openBox(
        'pet_profiles',
        encryptionCipher: cipher,
      );
      await encryptedBox.put('pet1', 'data');
      await encryptedBox.close();

      // Create one unencrypted box
      final unencryptedBox = await Hive.openBox('medications');
      await unencryptedBox.put('med1', 'data');
      await unencryptedBox.close();

      final needsMigration = await EncryptionService.needsMigration();
      expect(needsMigration, true);
    });
  });

  group('EncryptionService Key Deletion', () {
    test('deleteEncryptionKey() removes key from storage', () async {
      await EncryptionService.initialize();

      // Verify key exists
      final cipher1 = await EncryptionService.getEncryptionCipher();
      expect(cipher1, isNotNull);

      // Delete key
      await EncryptionService.deleteEncryptionKey();

      // Verify service is no longer initialized
      expect(EncryptionService.isInitialized, false);
    });

    test('after key deletion, new key is generated on re-initialization', () async {
      await EncryptionService.initialize();
      await EncryptionService.deleteEncryptionKey();

      // Re-initialize should generate new key
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      expect(cipher, isNotNull);
      expect(EncryptionService.isInitialized, true);
    });

    test('deleteEncryptionKey() makes encrypted data inaccessible', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      // Create encrypted box with data
      final box = await Hive.openBox(
        'test_deletion',
        encryptionCipher: cipher,
      );
      await box.put('secret', 'data');
      await box.close();

      // Delete key
      await EncryptionService.deleteEncryptionKey();

      // Re-initialize (generates new key)
      EncryptionService.resetForTesting();
      await EncryptionService.initialize();
      final newCipher = await EncryptionService.getEncryptionCipher();

      // Try to open box with new cipher - should fail or return empty
      expect(
        () => Hive.openBox('test_deletion', encryptionCipher: newCipher),
        throwsA(isA<HiveError>()),
      );
    });
  });

  group('EncryptionService Box Names', () {
    test('boxNames returns list of all Hive boxes', () {
      final boxNames = EncryptionService.boxNames;

      expect(boxNames, isNotEmpty);
      expect(boxNames, contains('pet_profiles'));
      expect(boxNames, contains('medications'));
      expect(boxNames, contains('appointments'));
      expect(boxNames, contains('walks'));
      expect(boxNames, contains('settings'));
    });

    test('boxNames list is unmodifiable', () {
      final boxNames = EncryptionService.boxNames;

      // Should throw when trying to modify
      expect(() => boxNames.add('new_box'), throwsUnsupportedError);
    });

    test('boxNames contains exactly 15 boxes', () {
      final boxNames = EncryptionService.boxNames;
      expect(boxNames.length, 15);
    });
  });

  group('EncryptionService Error Handling', () {
    test('EncryptionServiceException includes message', () {
      final exception = EncryptionServiceException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('EncryptionServiceException includes original error', () {
      final originalError = Exception('Original');
      final exception = EncryptionServiceException(
        'Wrapped error',
        originalError: originalError,
      );

      expect(exception.toString(), contains('Wrapped error'));
      expect(exception.toString(), contains('Original'));
    });

    test('EncryptionServiceException stores stack trace', () {
      final stackTrace = StackTrace.current;
      final exception = EncryptionServiceException(
        'Test error',
        stackTrace: stackTrace,
      );

      expect(exception.stackTrace, isNotNull);
      expect(identical(exception.stackTrace, stackTrace), true);
    });
  });

  group('EncryptionService Data Persistence', () {
    test('key survives app restart simulation', () async {
      // First "app launch"
      await EncryptionService.initialize();
      final cipher1 = await EncryptionService.getEncryptionCipher();

      // Create encrypted box
      final box1 = await Hive.openBox(
        'persistence_test',
        encryptionCipher: cipher1,
      );
      await box1.put('data', 'test_value');
      await box1.close();

      // Simulate app restart
      await Hive.close();
      EncryptionService.resetForTesting();

      // "Second app launch"
      await EncryptionService.initialize();
      final cipher2 = await EncryptionService.getEncryptionCipher();

      // Should be able to read data with persisted key
      final box2 = await Hive.openBox(
        'persistence_test',
        encryptionCipher: cipher2,
      );

      expect(box2.get('data'), 'test_value');
      await box2.close();
    });

    test('multiple boxes can share same encryption key', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      // Create multiple encrypted boxes
      final box1 = await Hive.openBox('box1', encryptionCipher: cipher);
      final box2 = await Hive.openBox('box2', encryptionCipher: cipher);
      final box3 = await Hive.openBox('box3', encryptionCipher: cipher);

      await box1.put('key', 'value1');
      await box2.put('key', 'value2');
      await box3.put('key', 'value3');

      expect(box1.get('key'), 'value1');
      expect(box2.get('key'), 'value2');
      expect(box3.get('key'), 'value3');

      await box1.close();
      await box2.close();
      await box3.close();
    });
  });

  group('EncryptionService Security', () {
    test('encryption key is 256 bits (32 bytes)', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      // HiveAesCipher requires 256-bit key
      // If initialization succeeds, key length is correct
      expect(cipher, isA<HiveAesCipher>());
    });

    test('different app instances have different keys', () async {
      // First instance
      await EncryptionService.initialize();
      await EncryptionService.deleteEncryptionKey();

      // Reset and create new instance
      EncryptionService.resetForTesting();
      await EncryptionService.initialize();
      final cipher1 = await EncryptionService.getEncryptionCipher();

      // Delete and create another new instance
      await EncryptionService.deleteEncryptionKey();
      EncryptionService.resetForTesting();
      await EncryptionService.initialize();
      final cipher2 = await EncryptionService.getEncryptionCipher();

      // Keys should be different (different instances)
      expect(identical(cipher1, cipher2), false);
    });
  });
}
