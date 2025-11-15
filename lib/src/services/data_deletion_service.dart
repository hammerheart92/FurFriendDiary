import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/hive_manager.dart';
import 'encryption_service.dart';

/// GDPR Article 17 compliant complete data deletion service
///
/// This service implements the "Right to Erasure" by permanently deleting:
/// - All Hive boxes (pet profiles, health records, appointments, etc.)
/// - All photo files and thumbnails
/// - Encryption keys from secure storage AND fallback storage
/// - SharedPreferences flags and settings
/// - Cache directories
///
/// Usage:
/// ```dart
/// final deletionService = DataDeletionService();
/// final success = await deletionService.deleteAllUserData();
/// if (success) {
///   // Navigate to setup screen
/// }
/// ```
class DataDeletionService {
  final Logger _logger = Logger();

  /// Delete ALL user data permanently (GDPR Article 17 compliance)
  ///
  /// This implements the "Right to Erasure" by deleting:
  /// - All Hive boxes (pet profiles, health records, appointments, etc.)
  /// - All photo files and thumbnails
  /// - Encryption keys from secure storage AND fallback storage
  /// - SharedPreferences flags and settings
  /// - Cache directories
  ///
  /// Returns true if deletion succeeded, false otherwise
  ///
  /// Example:
  /// ```dart
  /// final deletionService = DataDeletionService();
  /// final success = await deletionService.deleteAllUserData();
  /// if (success) {
  ///   context.go('/setup'); // Navigate to setup after deletion
  /// }
  /// ```
  Future<bool> deleteAllUserData() async {
    try {
      _logger.w('🗑️ Starting complete user data deletion (GDPR Article 17)');

      // Step 1: Delete all Hive boxes
      _logger.i('Step 1/5: Deleting Hive boxes...');
      await _deleteAllHiveBoxes();
      _logger.i('✅ Hive boxes deleted');

      // Step 2: Delete all photo files
      _logger.i('Step 2/5: Deleting photo files...');
      await _deleteAllPhotoFiles();
      _logger.i('✅ Photo files deleted');

      // Step 3: Delete encryption keys (primary AND fallback)
      _logger.i('Step 3/5: Deleting encryption keys...');
      await _deleteEncryptionKeys();
      _logger.i('✅ Encryption keys deleted');

      // Step 4: Clear SharedPreferences
      _logger.i('Step 4/5: Clearing SharedPreferences...');
      await _clearSharedPreferences();
      _logger.i('✅ SharedPreferences cleared');

      // Step 5: Clear cache directories
      _logger.i('Step 5/5: Clearing cache directories...');
      await _clearCacheDirectories();
      _logger.i('✅ Cache cleared');

      _logger.w('🗑️ ✅ Complete data deletion finished successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.e('🗑️ ❌ Data deletion failed: $e');
      _logger.e('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Delete all Hive boxes from disk
  Future<void> _deleteAllHiveBoxes() async {
    try {
      final hiveManager = HiveManager.instance;
      await hiveManager.clearAllData();
      _logger.d('All Hive boxes deleted via HiveManager');
    } catch (e) {
      _logger.e('Error deleting Hive boxes: $e');
      rethrow;
    }
  }

  /// Delete all photo files from all pet directories
  ///
  /// Photos are stored in: {ApplicationDocumentsDirectory}/photos/{petId}/
  /// This includes both full-resolution images and thumbnails
  Future<void> _deleteAllPhotoFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosRootDir = Directory('${appDir.path}/photos');

      if (await photosRootDir.exists()) {
        _logger.d('Deleting photos directory: ${photosRootDir.path}');
        await photosRootDir.delete(recursive: true);
        _logger.i('Deleted photos directory: ${photosRootDir.path}');
      } else {
        _logger.d('Photos directory does not exist, skipping');
      }
    } catch (e) {
      _logger.e('Error deleting photo files: $e');
      rethrow;
    }
  }

  /// Delete encryption keys from BOTH secure storage AND SharedPreferences fallback
  ///
  /// This calls EncryptionService.deleteEncryptionKey() which now deletes:
  /// - Primary key from FlutterSecureStorage (Android Keystore / iOS Keychain)
  /// - Fallback key from SharedPreferences
  Future<void> _deleteEncryptionKeys() async {
    try {
      await EncryptionService.deleteEncryptionKey();
      _logger.i('Encryption keys deleted from all storages');
    } catch (e) {
      _logger.e('Error deleting encryption keys: $e');
      rethrow;
    }
  }

  /// Clear all SharedPreferences data
  ///
  /// This removes ALL persistent flags and settings including:
  /// - hive_encryption_migration_completed_v1
  /// - hasCompletedSetup
  /// - theme_mode, language_code, notifications_enabled
  /// - Any other app preferences
  ///
  /// Note: This is the most thorough approach for GDPR compliance
  Future<void> _clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear ALL preferences (most thorough approach for GDPR)
      await prefs.clear();

      _logger.i('All SharedPreferences cleared');
    } catch (e) {
      _logger.e('Error clearing SharedPreferences: $e');
      rethrow;
    }
  }

  /// Clear all cache directories
  ///
  /// This deletes temporary files from:
  /// - getTemporaryDirectory() - Image picker temp files, PDF exports, etc.
  ///
  /// Note: Cache cleanup is best-effort - we continue even if some files fail
  Future<void> _clearCacheDirectories() async {
    try {
      final tempDir = await getTemporaryDirectory();

      if (await tempDir.exists()) {
        // Delete all files in temp directory
        final entities = tempDir.listSync();
        int deletedCount = 0;
        int failedCount = 0;

        for (final entity in entities) {
          try {
            await entity.delete(recursive: true);
            deletedCount++;
            _logger.d('Deleted cache: ${entity.path}');
          } catch (e) {
            failedCount++;
            _logger.w('Failed to delete cache item ${entity.path}: $e');
            // Continue with other files - cache cleanup is best-effort
          }
        }

        _logger.i('Cache cleanup: $deletedCount deleted, $failedCount failed');
      } else {
        _logger.d('Temp directory does not exist, skipping cache cleanup');
      }
    } catch (e) {
      _logger.e('Error clearing cache: $e');
      // Don't rethrow - cache cleanup is best-effort and shouldn't block deletion
    }
  }
}
