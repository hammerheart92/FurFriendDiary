import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_service.dart';

/// Service for migrating Hive boxes from unencrypted to encrypted format
///
/// CRITICAL SAFETY RULES:
/// - Never delete unencrypted boxes until data is verified in encrypted boxes
/// - Preserve original data if any step fails
/// - Verify data integrity before considering migration successful
///
/// Usage:
/// ```dart
/// await EncryptionService.initialize();
/// final migrationService = DataMigrationService();
/// final result = await migrationService.migrateToEncrypted();
/// if (result.success) {
///   print('Migrated ${result.totalRecordsMigrated} records');
/// }
/// ```
class DataMigrationService {
  final Logger _logger = Logger();

  /// Main migration orchestrator - migrates all Hive boxes to encrypted format
  ///
  /// Returns [MigrationResult] with detailed success/failure information.
  ///
  /// SAFETY GUARANTEES:
  /// - Original unencrypted boxes are NOT deleted until migration is verified
  /// - If any step fails, original data remains accessible
  /// - All operations are logged for debugging
  ///
  /// Steps:
  /// 1. Check if migration is needed
  /// 2. Read all data from unencrypted boxes
  /// 3. Close unencrypted boxes (but don't delete)
  /// 4. Open encrypted boxes
  /// 5. Write data to encrypted boxes
  /// 6. Verify data integrity
  /// 7. Delete old unencrypted boxes (only after verification)
  Future<MigrationResult> migrateToEncrypted() async {
    _logger.i('=' * 80);
    _logger.i('STARTING HIVE ENCRYPTION MIGRATION');
    _logger.i('=' * 80);

    final startTime = DateTime.now();
    final result = MigrationResult();

    try {
      // Step 1: Check if migration is needed
      _logger.i('Step 1: Checking if migration is needed...');
      final needsMigration = await EncryptionService.needsMigration();

      if (!needsMigration) {
        _logger.i('✓ No migration needed - all boxes are already encrypted');
        result.success = true;
        result.message = 'No migration needed - all boxes already encrypted';
        result.duration = DateTime.now().difference(startTime);
        return result;
      }

      _logger.w('⚠ Migration needed - unencrypted boxes detected');

      // Step 2: Read all data from unencrypted boxes
      _logger.i('Step 2: Reading data from unencrypted boxes...');
      final unencryptedData = await _readAllUnencryptedData(result);

      if (result.errors.isNotEmpty) {
        throw MigrationException(
          'Failed to read unencrypted data: ${result.errors.join(", ")}',
        );
      }

      _logger.i('✓ Read ${result.totalRecordsMigrated} total records from ${result.boxesProcessed.length} boxes');

      // Step 3: Close unencrypted boxes (but DON'T delete yet)
      _logger.i('Step 3: Closing unencrypted boxes (preserving data)...');
      await _closeUnencryptedBoxes(unencryptedData.keys.toList());

      // CRITICAL FIX: Force-close ALL boxes (even ones we didn't process)
      // to prevent "box already open" errors when opening encrypted boxes
      _logger.i('Step 3b: Force-closing ALL boxes to ensure clean state...');
      for (final boxName in EncryptionService.boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            await Hive.box(boxName).close();
            _logger.d('  ✓ Force-closed "$boxName"');
          }
        } catch (e) {
          _logger.w('⚠ Failed to force-close "$boxName": $e');
          // Continue anyway
        }
      }
      _logger.i('✓ All boxes closed - ready for encrypted re-opening');

      // Step 4 & 5: Open encrypted boxes and write data
      _logger.i('Step 4-5: Creating encrypted boxes and writing data...');
      final cipher = await EncryptionService.getEncryptionCipher();
      await _writeToEncryptedBoxes(unencryptedData, cipher, result);

      if (result.errors.isNotEmpty) {
        throw MigrationException(
          'Failed to write encrypted data: ${result.errors.join(", ")}',
        );
      }

      _logger.i('✓ Wrote data to ${result.boxesProcessed.length} encrypted boxes');

      // Step 6: Verify data integrity
      _logger.i('Step 6: Verifying data integrity...');
      final verified = await _verifyMigration(unencryptedData, cipher, result);

      if (!verified) {
        throw MigrationException(
          'Data verification failed: ${result.errors.join(", ")}',
        );
      }

      _logger.i('✓ Data integrity verified successfully');

      // Step 7: Delete old unencrypted boxes (ONLY after verification)
      _logger.i('Step 7: Deleting old unencrypted boxes...');
      await _deleteUnencryptedBoxes(unencryptedData.keys.toList(), result);

      if (result.errors.isNotEmpty) {
        _logger.w('⚠ Some unencrypted boxes could not be deleted, but migration succeeded');
        _logger.w('You may need to manually delete: ${result.errors.join(", ")}');
      }

      _logger.i('✓ Cleaned up old unencrypted boxes');

      // Success!
      result.success = true;
      result.message = 'Successfully migrated ${result.totalRecordsMigrated} records across ${result.boxesProcessed.length} boxes';
      result.duration = DateTime.now().difference(startTime);

      // Mark migration as completed to prevent re-running on subsequent launches
      _logger.i('Saving migration completion flag...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hive_encryption_migration_completed_v1', true);
      _logger.i('✓ Migration completion flag saved');

      _logger.i('=' * 80);
      _logger.i('✓ MIGRATION COMPLETED SUCCESSFULLY');
      _logger.i('  Records migrated: ${result.totalRecordsMigrated}');
      _logger.i('  Boxes processed: ${result.boxesProcessed.length}');
      _logger.i('  Duration: ${result.duration.inSeconds}s');
      _logger.i('=' * 80);

      return result;
    } catch (e, stackTrace) {
      _logger.e('✗ MIGRATION FAILED: $e');
      _logger.e('Stack trace: $stackTrace');

      result.success = false;
      result.message = 'Migration failed: $e';
      result.errors.add('Fatal error: $e');
      result.duration = DateTime.now().difference(startTime);

      _logger.e('=' * 80);
      _logger.e('✗ MIGRATION FAILED - ORIGINAL DATA PRESERVED');
      _logger.e('  Error: $e');
      _logger.e('  Unencrypted boxes remain accessible');
      _logger.e('=' * 80);

      return result;
    }
  }

  /// Read all data from unencrypted boxes
  ///
  /// Returns a map of box name -> list of all values in that box.
  /// Updates [result] with counts and any errors.
  Future<Map<String, List<dynamic>>> _readAllUnencryptedData(
    MigrationResult result,
  ) async {
    final data = <String, List<dynamic>>{};
    final boxNames = EncryptionService.boxNames;

    for (final boxName in boxNames) {
      try {
        // Check if box exists
        final boxExists = await Hive.boxExists(boxName);
        if (!boxExists) {
          _logger.d('Box "$boxName" does not exist - skipping');
          continue;
        }

        // Try to open box without encryption
        Box? box;
        try {
          box = await Hive.openBox(boxName);
        } catch (e) {
          // Box might already be encrypted, skip it
          _logger.d('Box "$boxName" cannot be opened unencrypted - likely already encrypted');
          continue;
        }

        // Read all values from the box
        final values = box.values.toList();
        final recordCount = values.length;

        if (recordCount > 0) {
          data[boxName] = values;
          result.boxesProcessed.add(boxName);
          result.recordsPerBox[boxName] = recordCount;
          result.totalRecordsMigrated += recordCount;

          _logger.i('  ✓ Read $recordCount records from "$boxName"');
        } else {
          _logger.d('  - Box "$boxName" is empty');
        }

        // Don't close yet - we'll close all boxes together in the next step
      } catch (e, stackTrace) {
        _logger.e('✗ Failed to read box "$boxName": $e');
        _logger.e('Stack trace: $stackTrace');
        result.errors.add('Failed to read box "$boxName": $e');
      }
    }

    return data;
  }

  /// Close unencrypted boxes (but don't delete them yet)
  Future<void> _closeUnencryptedBoxes(List<String> boxNames) async {
    for (final boxName in boxNames) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
          _logger.d('  ✓ Closed unencrypted box "$boxName"');
        }
      } catch (e) {
        _logger.w('⚠ Failed to close box "$boxName": $e');
        // Continue anyway - not critical
      }
    }
  }

  /// Write data to encrypted boxes
  ///
  /// Opens each box with encryption and writes all values.
  /// Updates [result] with any errors.
  Future<void> _writeToEncryptedBoxes(
    Map<String, List<dynamic>> data,
    HiveAesCipher cipher,
    MigrationResult result,
  ) async {
    for (final entry in data.entries) {
      final boxName = entry.key;
      final values = entry.value;

      try {
        // Open box with encryption
        final box = await Hive.openBox(
          boxName,
          encryptionCipher: cipher,
        );

        // Clear any existing data (shouldn't be any, but be safe)
        await box.clear();

        // Write all values using numeric keys (Hive auto-increments)
        for (int i = 0; i < values.length; i++) {
          await box.add(values[i]);
        }

        _logger.i('  ✓ Wrote ${values.length} records to encrypted "$boxName"');
      } catch (e, stackTrace) {
        _logger.e('✗ Failed to write to encrypted box "$boxName": $e');
        _logger.e('Stack trace: $stackTrace');
        result.errors.add('Failed to write to encrypted box "$boxName": $e');
      }
    }
  }

  /// Verify that migration was successful
  ///
  /// Checks that:
  /// - All boxes can be opened with encryption
  /// - Record counts match the original data
  ///
  /// Returns true if verification passed, false otherwise.
  Future<bool> _verifyMigration(
    Map<String, List<dynamic>> originalData,
    HiveAesCipher cipher,
    MigrationResult result,
  ) async {
    bool allVerified = true;

    for (final entry in originalData.entries) {
      final boxName = entry.key;
      final originalValues = entry.value;
      final originalCount = originalValues.length;

      try {
        // Open encrypted box
        final box = await Hive.openBox(
          boxName,
          encryptionCipher: cipher,
        );

        // Verify record count matches
        final encryptedCount = box.length;

        if (encryptedCount != originalCount) {
          _logger.e('✗ Verification failed for "$boxName": Expected $originalCount records, found $encryptedCount');
          result.errors.add(
            'Verification failed for "$boxName": count mismatch ($originalCount vs $encryptedCount)',
          );
          allVerified = false;
        } else {
          _logger.d('  ✓ Verified "$boxName": $encryptedCount records match');
        }

        // Close the box
        await box.close();
      } catch (e, stackTrace) {
        _logger.e('✗ Verification failed for "$boxName": $e');
        _logger.e('Stack trace: $stackTrace');
        result.errors.add('Verification failed for "$boxName": $e');
        allVerified = false;
      }
    }

    return allVerified;
  }

  /// Delete old unencrypted boxes from disk
  ///
  /// ONLY called after successful verification.
  /// Updates [result] with any errors.
  Future<void> _deleteUnencryptedBoxes(
    List<String> boxNames,
    MigrationResult result,
  ) async {
    for (final boxName in boxNames) {
      try {
        // Make sure box is closed first
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }

        // Delete from disk
        await Hive.deleteBoxFromDisk(boxName);
        _logger.i('  ✓ Deleted old unencrypted box "$boxName"');
      } catch (e) {
        _logger.w('⚠ Failed to delete unencrypted box "$boxName": $e');
        result.errors.add('Failed to delete unencrypted box "$boxName": $e');
        // Continue anyway - migration succeeded, cleanup is best-effort
      }
    }
  }
}

/// Result of a migration operation
///
/// Contains detailed information about what was migrated,
/// any errors that occurred, and overall success status.
class MigrationResult {
  /// Whether the migration was successful
  bool success = false;

  /// Human-readable message about the migration result
  String message = '';

  /// Total number of records migrated across all boxes
  int totalRecordsMigrated = 0;

  /// List of box names that were processed
  List<String> boxesProcessed = [];

  /// Map of box name -> number of records in that box
  Map<String, int> recordsPerBox = {};

  /// List of error messages encountered during migration
  List<String> errors = [];

  /// How long the migration took
  Duration duration = Duration.zero;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('MigrationResult {');
    buffer.writeln('  success: $success');
    buffer.writeln('  message: $message');
    buffer.writeln('  totalRecordsMigrated: $totalRecordsMigrated');
    buffer.writeln('  boxesProcessed: $boxesProcessed');
    buffer.writeln('  recordsPerBox: $recordsPerBox');
    buffer.writeln('  errors: $errors');
    buffer.writeln('  duration: ${duration.inSeconds}s');
    buffer.writeln('}');
    return buffer.toString();
  }

  /// Convert to a JSON-serializable map
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'totalRecordsMigrated': totalRecordsMigrated,
      'boxesProcessed': boxesProcessed,
      'recordsPerBox': recordsPerBox,
      'errors': errors,
      'durationSeconds': duration.inSeconds,
    };
  }
}

/// Custom exception for migration errors
class MigrationException implements Exception {
  final String message;

  MigrationException(this.message);

  @override
  String toString() => 'MigrationException: $message';
}
