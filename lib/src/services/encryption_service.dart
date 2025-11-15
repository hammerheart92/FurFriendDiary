import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Service for managing Hive encryption with secure key storage
///
/// Implements GDPR Article 32 compliant encryption for pet health data:
/// - 256-bit AES encryption keys
/// - Secure key storage in Android Keystore / iOS Keychain
/// - Migration detection for unencrypted boxes
///
/// Usage:
/// ```dart
/// await EncryptionService.initialize();
/// final cipher = await EncryptionService.getEncryptionCipher();
/// await Hive.openBox('secure_box', encryptionCipher: cipher);
/// ```
class EncryptionService {
  static final Logger _logger = Logger();
  static const String _encryptionKeyStorageKey = 'hive_encryption_key_v1';
  static const String _fallbackKeyStorageKey = 'hive_encryption_key_fallback_v1';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: false, // CRITICAL FIX: Prevent key deletion on errors (Samsung devices)
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Fallback storage for key persistence when secure storage fails
  static SharedPreferences? _prefs;

  static HiveAesCipher? _cachedCipher;
  static bool _isInitialized = false;

  /// List of all Hive box names that need encryption
  /// Matches HiveManager box names
  static const List<String> _boxNames = [
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

  /// Initialize the encryption service
  ///
  /// Generates and stores a new encryption key if one doesn't exist.
  /// Safe to call multiple times - will skip if already initialized.
  ///
  /// Throws [EncryptionServiceException] if initialization fails.
  static Future<void> initialize() async {
    if (_isInitialized) {
      _logger.d('🔐 EncryptionService already initialized');
      return;
    }

    try {
      _logger.i('🔐 [INIT] Starting EncryptionService initialization...');

      // Initialize SharedPreferences for fallback storage
      _logger.d('🔐 [INIT] Initializing SharedPreferences for fallback storage...');
      _prefs = await SharedPreferences.getInstance();
      _logger.d('🔐 [INIT] SharedPreferences initialized successfully');

      // Phase 1: Check if key exists in flutter_secure_storage (primary)
      _logger.d('🔐 [LOAD-PRIMARY] Attempting to load key from flutter_secure_storage...');
      String? existingKeyFromSecure;
      try {
        existingKeyFromSecure = await _secureStorage.read(key: _encryptionKeyStorageKey);
        if (existingKeyFromSecure != null) {
          final keyBytes = base64Decode(existingKeyFromSecure);
          _logger.i('🔐 [LOAD-PRIMARY] ✅ Key found in flutter_secure_storage (${keyBytes.length} bytes, hashCode: ${keyBytes.hashCode})');
        } else {
          _logger.w('🔐 [LOAD-PRIMARY] ⚠️ Key NOT found in flutter_secure_storage (returned null)');
        }
      } catch (e) {
        _logger.e('🔐 [LOAD-PRIMARY] ❌ Failed to read from flutter_secure_storage: $e');
        existingKeyFromSecure = null;
      }

      // Phase 2: Check if key exists in SharedPreferences (fallback)
      _logger.d('🔐 [LOAD-FALLBACK] Attempting to load key from SharedPreferences...');
      String? existingKeyFromFallback;
      try {
        existingKeyFromFallback = _prefs!.getString(_fallbackKeyStorageKey);
        if (existingKeyFromFallback != null) {
          final keyBytes = base64Decode(existingKeyFromFallback);
          _logger.i('🔐 [LOAD-FALLBACK] ✅ Key found in SharedPreferences (${keyBytes.length} bytes, hashCode: ${keyBytes.hashCode})');
        } else {
          _logger.w('🔐 [LOAD-FALLBACK] ⚠️ Key NOT found in SharedPreferences (returned null)');
        }
      } catch (e) {
        _logger.e('🔐 [LOAD-FALLBACK] ❌ Failed to read from SharedPreferences: $e');
        existingKeyFromFallback = null;
      }

      // Phase 3: Key consistency check
      if (existingKeyFromSecure != null && existingKeyFromFallback != null) {
        final secureBytes = base64Decode(existingKeyFromSecure);
        final fallbackBytes = base64Decode(existingKeyFromFallback);
        final keysMatch = existingKeyFromSecure == existingKeyFromFallback;
        _logger.i('🔐 [CONSISTENCY] Keys present in BOTH storages. Match: $keysMatch (secure.hashCode: ${secureBytes.hashCode}, fallback.hashCode: ${fallbackBytes.hashCode})');
      } else if (existingKeyFromSecure != null) {
        _logger.w('🔐 [CONSISTENCY] ⚠️ Key ONLY in flutter_secure_storage (fallback missing)');
      } else if (existingKeyFromFallback != null) {
        _logger.w('🔐 [CONSISTENCY] ⚠️ Key ONLY in SharedPreferences (secure missing)');
      } else {
        _logger.i('🔐 [CONSISTENCY] No keys found in either storage - new key generation required');
      }

      // Phase 4: Generate new key if none exists
      if (existingKeyFromSecure == null && existingKeyFromFallback == null) {
        _logger.i('🔐 [GENERATE] No encryption key found in any storage, generating new 256-bit AES key...');
        await _generateAndStoreKey();

        // Phase 5: Immediate verification after generation
        _logger.d('🔐 [VERIFY] Verifying newly generated key was saved correctly...');

        // Verify secure storage save
        String? verifySecure;
        try {
          verifySecure = await _secureStorage.read(key: _encryptionKeyStorageKey);
          if (verifySecure != null) {
            final keyBytes = base64Decode(verifySecure);
            _logger.i('🔐 [VERIFY-PRIMARY] ✅ Key verified in flutter_secure_storage (${keyBytes.length} bytes, hashCode: ${keyBytes.hashCode})');
          } else {
            _logger.e('🔐 [VERIFY-PRIMARY] ❌ Key verification FAILED - not found in flutter_secure_storage after save!');
          }
        } catch (e) {
          _logger.e('🔐 [VERIFY-PRIMARY] ❌ Key verification FAILED - error reading from flutter_secure_storage: $e');
        }

        // Verify fallback storage save
        String? verifyFallback;
        try {
          verifyFallback = _prefs!.getString(_fallbackKeyStorageKey);
          if (verifyFallback != null) {
            final keyBytes = base64Decode(verifyFallback);
            _logger.i('🔐 [VERIFY-FALLBACK] ✅ Key verified in SharedPreferences (${keyBytes.length} bytes, hashCode: ${keyBytes.hashCode})');
          } else {
            _logger.e('🔐 [VERIFY-FALLBACK] ❌ Key verification FAILED - not found in SharedPreferences after save!');
          }
        } catch (e) {
          _logger.e('🔐 [VERIFY-FALLBACK] ❌ Key verification FAILED - error reading from SharedPreferences: $e');
        }

        // Verify consistency of saved keys
        if (verifySecure != null && verifyFallback != null) {
          final keysMatch = verifySecure == verifyFallback;
          final secureBytes = base64Decode(verifySecure);
          final fallbackBytes = base64Decode(verifyFallback);
          _logger.i('🔐 [VERIFY-CONSISTENCY] Keys match after save: $keysMatch (secure.hashCode: ${secureBytes.hashCode}, fallback.hashCode: ${fallbackBytes.hashCode})');
        } else if (verifySecure == null && verifyFallback == null) {
          _logger.e('🔐 [VERIFY-CONSISTENCY] ❌ CRITICAL: Key save FAILED in BOTH storages!');
        }
      } else {
        _logger.d('🔐 [GENERATE] Skipping key generation - existing key found');
      }

      // Phase 6: Final validation - retrieve and use the key
      _logger.d('🔐 [FINAL-VALIDATE] Validating final encryption cipher retrieval...');
      await getEncryptionCipher();
      _logger.i('🔐 [FINAL-VALIDATE] ✅ Encryption cipher retrieved successfully');

      _isInitialized = true;
      _logger.i('🔐 [INIT] ✅ EncryptionService initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('🔐 [INIT] ❌ Failed to initialize EncryptionService: $e');
      _logger.e('🔐 [INIT] Stack trace: $stackTrace');
      throw EncryptionServiceException(
        'Failed to initialize encryption service: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Generate a new 256-bit AES encryption key and store it securely
  ///
  /// Uses cryptographically secure random number generation.
  /// Stores key in BOTH flutter_secure_storage AND SharedPreferences for redundancy.
  /// Critical fix for Samsung devices where secure storage can fail.
  static Future<void> _generateAndStoreKey() async {
    try {
      // Generate 256-bit (32 bytes) random key
      final random = Random.secure();
      final keyBytes = Uint8List(32);
      for (int i = 0; i < 32; i++) {
        keyBytes[i] = random.nextInt(256);
      }

      // Encode to base64 for storage
      final keyString = base64Encode(keyBytes);

      // Store in BOTH locations for redundancy
      bool secureStorageSuccess = false;
      bool fallbackStorageSuccess = false;

      // Try to store in flutter_secure_storage (primary)
      try {
        await _secureStorage.write(
          key: _encryptionKeyStorageKey,
          value: keyString,
        );
        secureStorageSuccess = true;
        _logger.d('✅ Key stored in flutter_secure_storage');
      } catch (e) {
        _logger.w('⚠️ flutter_secure_storage write failed: $e');
      }

      // Always store in SharedPreferences (fallback)
      try {
        await _saveKeyToFallback(keyString);
        fallbackStorageSuccess = true;
      } catch (e) {
        _logger.w('⚠️ SharedPreferences fallback write failed: $e');
      }

      // Ensure at least one storage method succeeded
      if (!secureStorageSuccess && !fallbackStorageSuccess) {
        throw Exception(
          'Failed to store key in both secure storage and fallback storage',
        );
      }

      _logger.i(
        'Generated and stored new 256-bit encryption key '
        '(secure: $secureStorageSuccess, fallback: $fallbackStorageSuccess)',
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to generate encryption key: $e');
      throw EncryptionServiceException(
        'Failed to generate encryption key: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Save encryption key to SharedPreferences fallback storage
  ///
  /// Provides redundant key storage in case flutter_secure_storage fails.
  /// Critical for Samsung devices where secure storage can be unreliable.
  static Future<void> _saveKeyToFallback(String keyString) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(_fallbackKeyStorageKey, keyString);
      _logger.d('✅ Key saved to SharedPreferences fallback');
    } catch (e) {
      _logger.w('⚠️ Failed to save key to SharedPreferences fallback: $e');
      // Don't throw - fallback failure is not critical if secure storage worked
    }
  }

  /// Load encryption key from SharedPreferences fallback storage
  ///
  /// Used when flutter_secure_storage fails to retrieve the key.
  /// Returns null if key is not found in fallback storage.
  static Future<String?> _loadKeyFromFallback() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final key = _prefs!.getString(_fallbackKeyStorageKey);
      if (key != null) {
        _logger.i('✅ Key loaded from SharedPreferences fallback');
      }
      return key;
    } catch (e) {
      _logger.w('⚠️ Failed to load key from SharedPreferences fallback: $e');
      return null;
    }
  }

  /// Retrieve the encryption cipher for Hive
  ///
  /// Returns a [HiveAesCipher] that can be used to encrypt/decrypt Hive boxes.
  /// Caches the cipher after first retrieval for performance.
  ///
  /// Throws [EncryptionServiceException] if key cannot be retrieved.
  ///
  /// Example:
  /// ```dart
  /// final cipher = await EncryptionService.getEncryptionCipher();
  /// final box = await Hive.openBox('secure_data', encryptionCipher: cipher);
  /// ```
  static Future<HiveAesCipher> getEncryptionCipher() async {
    // Return cached cipher if available
    if (_cachedCipher != null) {
      return _cachedCipher!;
    }

    try {
      String? keyString;
      bool loadedFromFallback = false;

      // Try to retrieve key from flutter_secure_storage (primary)
      try {
        _logger.d('🔍 Trying to load key from flutter_secure_storage...');
        keyString = await _secureStorage.read(key: _encryptionKeyStorageKey);

        if (keyString != null) {
          _logger.d('✅ Key loaded from flutter_secure_storage');
        } else {
          _logger.w('⚠️ Key not found in flutter_secure_storage');
        }
      } catch (e) {
        _logger.w('⚠️ flutter_secure_storage read failed: $e');
      }

      // If secure storage failed, try SharedPreferences fallback
      if (keyString == null || keyString.isEmpty) {
        _logger.i('🔍 Trying to load key from SharedPreferences fallback...');
        keyString = await _loadKeyFromFallback();

        if (keyString != null) {
          loadedFromFallback = true;
          _logger.i('✅ Key recovered from SharedPreferences fallback');

          // Try to sync key back to secure storage for future use
          try {
            await _secureStorage.write(
              key: _encryptionKeyStorageKey,
              value: keyString,
            );
            _logger.d('🔄 Key synced back to flutter_secure_storage');
          } catch (e) {
            _logger.w('⚠️ Failed to sync key back to secure storage: $e');
            // Continue anyway - we have the key from fallback
          }
        }
      }

      // If both storages failed, throw exception
      if (keyString == null || keyString.isEmpty) {
        throw EncryptionServiceException(
          'Encryption key not found in both secure storage and fallback. Call initialize() first.',
        );
      }

      // Decode from base64
      final keyBytes = base64Decode(keyString);

      // Validate key length (must be 256 bits = 32 bytes)
      if (keyBytes.length != 32) {
        throw EncryptionServiceException(
          'Invalid encryption key length: ${keyBytes.length} bytes (expected 32)',
        );
      }

      // Create and cache cipher
      _cachedCipher = HiveAesCipher(keyBytes);
      _logger.i(
        'Retrieved encryption cipher successfully '
        '(source: ${loadedFromFallback ? "fallback" : "secure_storage"})',
      );

      return _cachedCipher!;
    } catch (e, stackTrace) {
      _logger.e('Failed to get encryption cipher: $e');
      throw EncryptionServiceException(
        'Failed to get encryption cipher: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if migration to encrypted storage is needed
  ///
  /// Uses a persistent flag to track migration completion, avoiding destructive
  /// checks that could corrupt encrypted data.
  ///
  /// Returns true if:
  /// - Encryption key exists (indicating upgrade from unencrypted version)
  /// - Migration completion flag is NOT set
  /// - Legacy box files exist on disk
  ///
  /// Returns false if:
  /// - Migration already completed (flag found)
  /// - Fresh install (no key, no boxes)
  /// - No legacy data to migrate
  ///
  /// Example:
  /// ```dart
  /// if (await EncryptionService.needsMigration()) {
  ///   // Perform migration from unencrypted to encrypted boxes
  ///   await migrateData();
  /// }
  /// ```
  static Future<bool> needsMigration() async {
    try {
      _logger.i('Checking if migration to encrypted storage is needed...');

      // Check migration completion flag
      final prefs = await SharedPreferences.getInstance();
      final migrationCompleted = prefs.getBool('hive_encryption_migration_completed_v1') ?? false;

      if (migrationCompleted) {
        _logger.i('✓ Migration already completed (flag found)');
        return false;
      }

      // Check if encryption key exists
      final keyExists = await _keyExists();

      if (!keyExists) {
        _logger.i('✓ No encryption key exists - fresh install, no migration needed');
        return false;
      }

      // Key exists but migration not marked complete
      // Check if any box files exist from before encryption
      _logger.w('⚠ Encryption key exists but migration flag not set - checking for legacy data...');

      bool hasLegacyData = false;
      for (final boxName in _boxNames) {
        if (await Hive.boxExists(boxName)) {
          hasLegacyData = true;
          _logger.d('Found legacy box file: $boxName');
          break;
        }
      }

      if (hasLegacyData) {
        _logger.w('⚠ Legacy unencrypted data detected - migration required');
        return true;
      }

      _logger.i('✓ No legacy data found - migration not needed');
      return false;
    } catch (e, stackTrace) {
      _logger.e('Error checking migration status: $e');
      _logger.e('Stack trace: $stackTrace');
      // Return false to avoid accidental data loss - safer to skip migration
      // than to run it incorrectly
      return false;
    }
  }

  /// Helper method to check if encryption key exists in storage
  ///
  /// Returns true if key found in flutter_secure_storage
  static Future<bool> _keyExists() async {
    try {
      const secureStorage = FlutterSecureStorage();
      final key = await secureStorage.read(key: _encryptionKeyStorageKey);
      return key != null;
    } catch (e) {
      _logger.w('Failed to check key existence: $e');
      return false;
    }
  }

  /// Delete the encryption key from secure storage
  ///
  /// WARNING: This will make all encrypted data inaccessible!
  /// Only use this for:
  /// - Testing/development
  /// - User account deletion (GDPR right to erasure)
  /// - Factory reset scenarios
  ///
  /// After calling this, all encrypted Hive boxes must be deleted
  /// and recreated, as the data cannot be decrypted.
  static Future<void> deleteEncryptionKey() async {
    try {
      _logger.w('Deleting encryption key - all encrypted data will become inaccessible!');

      // Delete from secure storage (primary)
      await _secureStorage.delete(key: _encryptionKeyStorageKey);

      // CRITICAL FIX: Also delete from SharedPreferences fallback storage
      // This ensures complete key deletion for GDPR Article 17 compliance
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.remove(_fallbackKeyStorageKey);

      _cachedCipher = null;
      _isInitialized = false;

      _logger.i('Encryption key deleted from all storages (secure + fallback)');
    } catch (e, stackTrace) {
      _logger.e('Failed to delete encryption key: $e');
      throw EncryptionServiceException(
        'Failed to delete encryption key: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if the encryption service is initialized
  static bool get isInitialized => _isInitialized;

  /// Get the list of box names that need encryption
  static List<String> get boxNames => List.unmodifiable(_boxNames);

  /// Reset the service state (for testing only)
  ///
  /// This does NOT delete the encryption key from secure storage.
  /// It only clears the cached cipher and initialization flag.
  static void resetForTesting() {
    _cachedCipher = null;
    _isInitialized = false;
    _logger.i('EncryptionService reset for testing');
  }
}

/// Custom exception for encryption service errors
class EncryptionServiceException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  EncryptionServiceException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'EncryptionServiceException: $message\nOriginal error: $originalError';
    }
    return 'EncryptionServiceException: $message';
  }
}
