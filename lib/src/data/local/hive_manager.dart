import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/pet_profile.dart';
import '../../domain/models/feeding_entry.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/medication_purchase.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/report_entry.dart';
import '../../domain/models/walk.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/time_of_day_model.dart';
import '../../domain/models/reminder.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/models/pet_photo.dart';
import '../../domain/models/vet_profile.dart';
import '../../domain/models/health_report.dart';
import '../../domain/models/expense_report.dart';
import '../../domain/models/protocols/vaccination_protocol.dart';
import '../../domain/models/protocols/deworming_protocol.dart';
import '../../domain/models/protocols/treatment_plan.dart';
import '../../domain/models/protocols/reminder_config.dart';
import '../../domain/models/vaccination_event.dart';
import '../../domain/models/pdf_consent.dart';
import '../../domain/models/pet_owner_tier.dart';
import '../../services/encryption_service.dart';
import '../../services/data_migration_service.dart';

class HiveManager {
  final logger = Logger();
  static HiveManager? _instance;
  static HiveManager get instance => _instance ??= HiveManager._();

  HiveManager._();

  bool _isInitialized = false;

  // Box names
  static const String petProfileBoxName = 'pet_profiles';
  static const String feedingBoxName = 'feedings';
  static const String medicationBoxName = 'medications';
  static const String medicationPurchaseBoxName = 'medication_purchases';
  static const String appointmentBoxName = 'appointments';
  static const String reportBoxName = 'reports';
  static const String walkBoxName = 'walks';
  static const String reminderBoxName = 'reminders';
  static const String weightBoxName = 'weight_entries';
  static const String petPhotoBoxName = 'pet_photos';
  static const String vetProfileBoxName = 'vet_profiles';
  static const String healthReportBoxName = 'health_reports';
  static const String expenseReportBoxName = 'expense_reports';
  static const String vaccinationProtocolBoxName = 'vaccination_protocols';
  static const String dewormingProtocolBoxName = 'deworming_protocols';
  static const String treatmentPlanBoxName = 'treatment_plans';
  static const String reminderConfigBoxName = 'reminder_configs';
  static const String vaccinationEventBoxName = 'vaccination_events';
  static const String settingsBoxName = 'settings';
  static const String appPrefsBoxName = 'app_prefs';

  // Box references
  Box<PetProfile>? _petProfileBox;
  Box<FeedingEntry>? _feedingBox;
  Box<MedicationEntry>? _medicationBox;
  Box<MedicationPurchase>? _medicationPurchaseBox;
  Box<AppointmentEntry>? _appointmentBox;
  Box<ReportEntry>? _reportBox;
  Box<Walk>? _walkBox;
  Box<Reminder>? _reminderBox;
  Box<WeightEntry>? _weightBox;
  Box<PetPhoto>? _petPhotoBox;
  Box<VetProfile>? _vetProfileBox;
  Box<HealthReport>? _healthReportBox;
  Box<ExpenseReport>? _expenseReportBox;
  Box<VaccinationProtocol>? _vaccinationProtocolBox;
  Box<DewormingProtocol>? _dewormingProtocolBox;
  Box<TreatmentPlan>? _treatmentPlanBox;
  Box<ReminderConfig>? _reminderConfigBox;
  Box<VaccinationEvent>? _vaccinationEventBox;
  Box? _settingsBox;
  Box? _appPrefsBox;

  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Initialize encryption service
      await EncryptionService.initialize();

      // Register all adapters
      await _registerAdapters();

      // Check if migration is needed (existing v1.0.7 users)
      final needsMigration = await EncryptionService.needsMigration();

      if (needsMigration) {
        final migrationService = DataMigrationService();
        final result = await migrationService.migrateToEncrypted();

        if (!result.success) {
          logger.e("❌ DEBUG: Migration failed: ${result.message}");
          if (result.errors.isNotEmpty) {
            logger.e("   Errors: ${result.errors.join(', ')}");
          }
        }
      }

      // Get encryption cipher for opening boxes
      final cipher = await EncryptionService.getEncryptionCipher();

      // Open all boxes with encryption
      await _openAllBoxes(cipher);

      // Diagnostic: Verify data persistence right after opening boxes
      await verifyDataPersistence();

      _isInitialized = true;
    } catch (e, stackTrace) {
      logger.e("🚨 ERROR: HiveManager initialization failed: $e");
      logger.e("🚨 STACK: $stackTrace");
      rethrow;
    }
  }

  /// Register all Hive adapters
  Future<void> _registerAdapters() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PetProfileAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FeedingEntryAdapter());
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WalkAdapter());
    }

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(WalkTypeAdapter());
    }

    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(MedicationEntryAdapter());
    }

    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(AppointmentEntryAdapter());
    }

    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(WalkLocationAdapter());
    }

    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(ReportEntryAdapter());
    }

    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(UserProfileAdapter());
    }

    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ReminderTypeAdapter());
    }

    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(ReminderFrequencyAdapter());
    }

    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(ReminderAdapter());
    }

    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(TimeOfDayModelAdapter());
    }

    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(WeightEntryAdapter());
    }

    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(WeightUnitAdapter());
    }

    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(PetPhotoAdapter());
    }

    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(PetOwnerTierAdapter());
    }

    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(MedicationPurchaseAdapter());
    }

    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(VetProfileAdapter());
    }

    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(HealthReportAdapter());
    }

    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(ExpenseReportAdapter());
    }

    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(VaccinationProtocolAdapter());
      logger
          .d("✅ DEBUG: VaccinationProtocol adapter registered with typeId 22");
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

    if (!Hive.isAdapterRegistered(27)) {
      Hive.registerAdapter(TreatmentPlanAdapter());
    }

    if (!Hive.isAdapterRegistered(28)) {
      Hive.registerAdapter(TreatmentTaskAdapter());
    }

    if (!Hive.isAdapterRegistered(29)) {
      Hive.registerAdapter(ReminderConfigAdapter());
    }

    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(VaccinationEventAdapter());
    }

    if (!Hive.isAdapterRegistered(31)) {
      Hive.registerAdapter(PetGenderAdapter());
    }

    if (!Hive.isAdapterRegistered(32)) {
      Hive.registerAdapter(PdfConsentAdapter());
    }
  }

  /// Open all boxes in the correct order
  Future<void> _openAllBoxes(HiveAesCipher? cipher) async {
    // Open pet profiles box first (most important)
    _petProfileBox = await _openBox<PetProfile>(
      petProfileBoxName,
      encryptionCipher: cipher,
    );

    // Open walks box (second most important)
    _walkBox = await _openBox<Walk>(
      walkBoxName,
      encryptionCipher: cipher,
    );

    // Open other boxes
    _feedingBox = await _openBox<FeedingEntry>(
      feedingBoxName,
      encryptionCipher: cipher,
    );
    _medicationBox = await _openBox<MedicationEntry>(
      medicationBoxName,
      encryptionCipher: cipher,
    );
    _medicationPurchaseBox = await _openBox<MedicationPurchase>(
      medicationPurchaseBoxName,
      encryptionCipher: cipher,
    );
    _appointmentBox = await _openBox<AppointmentEntry>(
      appointmentBoxName,
      encryptionCipher: cipher,
    );
    _reportBox = await _openBox<ReportEntry>(
      reportBoxName,
      encryptionCipher: cipher,
    );
    _reminderBox = await _openBox<Reminder>(
      reminderBoxName,
      encryptionCipher: cipher,
    );
    _weightBox = await _openBox<WeightEntry>(
      weightBoxName,
      encryptionCipher: cipher,
    );
    _petPhotoBox = await _openBox<PetPhoto>(
      petPhotoBoxName,
      encryptionCipher: cipher,
    );
    _vetProfileBox = await _openBox<VetProfile>(
      vetProfileBoxName,
      encryptionCipher: cipher,
    );
    _healthReportBox = await _openBox<HealthReport>(
      healthReportBoxName,
      encryptionCipher: cipher,
    );
    _expenseReportBox = await _openBox<ExpenseReport>(
      expenseReportBoxName,
      encryptionCipher: cipher,
    );
    _vaccinationProtocolBox = await _openBox<VaccinationProtocol>(
      vaccinationProtocolBoxName,
      encryptionCipher: cipher,
    );
    _dewormingProtocolBox = await _openBox<DewormingProtocol>(
      dewormingProtocolBoxName,
      encryptionCipher: cipher,
    );
    _treatmentPlanBox = await _openBox<TreatmentPlan>(
      treatmentPlanBoxName,
      encryptionCipher: cipher,
    );
    _reminderConfigBox = await _openBox<ReminderConfig>(
      reminderConfigBoxName,
      encryptionCipher: cipher,
    );
    _vaccinationEventBox = await _openBox<VaccinationEvent>(
      vaccinationEventBoxName,
      encryptionCipher: cipher,
    );

    // Open settings boxes
    _settingsBox = await _openBox(
      settingsBoxName,
      encryptionCipher: cipher,
    );
    _appPrefsBox = await _openBox(
      appPrefsBoxName,
      encryptionCipher: cipher,
    );

    // Mark encryption initialization complete for fresh installs
    // (Migration sets its own flag after migrating data)
    final prefs = await SharedPreferences.getInstance();
    final migrationAlreadyCompleted =
        prefs.getBool('hive_encryption_migration_completed_v1') ?? false;

    if (!migrationAlreadyCompleted) {
      await prefs.setBool('hive_encryption_migration_completed_v1', true);
    }
  }

  /// Safely delete a box from disk, preventing data loss
  /// Returns true if box was deleted, false if skipped
  /// Throws HiveError if box contains data (to prevent data loss)
  Future<bool> _safeDeleteBoxFromDisk(String boxName) async {
    logger.e('╔════════════════════════════════════╗');
    logger.e('║ SAFE DELETE CHECK: $boxName');
    logger.e('╚════════════════════════════════════╝');

    try {
      logger.w("🔍 Step 1: Getting Hive storage directory...");
      // Get the Hive storage directory
      final appDir = await getApplicationDocumentsDirectory();
      final hivePath = appDir.path;
      logger.d("📁 Hive path: $hivePath");

      logger.w("🔍 Step 2: Checking if box files exist on disk...");
      // Check if box files exist
      final boxFile = File('$hivePath/$boxName.hive');
      final lockFile = File('$hivePath/$boxName.lock');

      final boxExists = await boxFile.exists();
      final lockExists = await lockFile.exists();

      logger.e("📂 Box file exists: $boxExists");
      logger.e("📂 Lock file exists: $lockExists");

      if (!boxExists && !lockExists) {
        logger.e("✅ Box '$boxName' files don't exist - NOTHING TO DELETE");
        logger.e('╚════════════════════════════════════╝');
        return true; // Nothing to delete, consider it success
      }

      if (boxExists) {
        final fileSize = await boxFile.length();
        logger.e("📂 Box file size: $fileSize bytes");
      }

      logger.w(
          "🔍 Step 3: Attempting to open as untyped box to check for data...");
      // Try to open as untyped box to check if it has data
      try {
        // If box is already open, close it first
        if (Hive.isBoxOpen(boxName)) {
          logger
              .w("⚠️  Box '$boxName' is currently OPEN - closing it first...");
          await Hive.box(boxName).close();
          logger.d("✅ Box closed successfully");
        }

        logger.w("🔓 Opening untyped box to inspect contents...");
        final untypedBox = await Hive.openBox(boxName);
        final hasData = untypedBox.isNotEmpty;
        final length = untypedBox.length;

        logger.e("━━━━━━━━━━━━━━━━━━━━━━━━");
        logger.e("📊 UNTYPED BOX OPENED:");
        logger.e("📊 Length: $length");
        logger.e("📊 Has data: $hasData");
        logger.e("📊 Keys: ${untypedBox.keys.toList()}");
        logger.e("━━━━━━━━━━━━━━━━━━━━━━━━");

        await untypedBox.close();
        logger.d("✅ Untyped box closed");

        if (hasData) {
          logger.e('╔════════════════════════════════════╗');
          logger.e("║ 🚨 DATA DETECTED - REFUSING DELETE!");
          logger.e("║ Box: $boxName");
          logger.e("║ Entries: $length");
          logger.e('╚════════════════════════════════════╝');
          throw HiveError("Box '$boxName' contains data ($length entries). "
              "Cannot delete box with data. Manual intervention required.");
        }

        // Box is empty, safe to delete
        logger.e("✅ Box '$boxName' is EMPTY - SAFE TO DELETE");
      } catch (e) {
        if (e is HiveError &&
            e.message.contains('Cannot delete box with data')) {
          rethrow; // Re-throw our data protection error
        }

        logger.e("⚠️  CAUGHT ERROR while opening untyped box: $e");
        logger.w("🔍 Falling back to file size check...");

        // Box couldn't be opened (corrupted) - check file size as fallback
        final fileSize = await boxFile.length();
        logger.e("📂 Box file size from fallback: $fileSize bytes");

        // Hive empty box is ~48 bytes, use 100 as threshold
        if (fileSize > 100) {
          logger.e('╔════════════════════════════════════╗');
          logger.e("║ 🚨 FILE SIZE INDICATES DATA!");
          logger.e("║ Box: $boxName");
          logger.e("║ Size: $fileSize bytes (threshold: 100)");
          logger.e("║ REFUSING TO DELETE");
          logger.e('╚════════════════════════════════════╝');
          throw HiveError(
              "Box '$boxName' may contain data (file size: $fileSize bytes). "
              "Cannot safely delete. Manual intervention required.");
        }
        logger.e(
            "✅ Box '$boxName' appears EMPTY based on file size ($fileSize bytes)");
      }

      logger.w("🔍 Step 4: DELETING BOX from disk...");
      logger.e("🚨 EXECUTING: Hive.deleteBoxFromDisk('$boxName')");
      // Safe to delete
      await Hive.deleteBoxFromDisk(boxName);

      logger.e('╔════════════════════════════════════╗');
      logger.e("║ ✅ BOX DELETED SUCCESSFULLY");
      logger.e("║ Box: $boxName");
      logger.e('╚════════════════════════════════════╝');
      return true;
    } catch (e) {
      if (e is HiveError) {
        logger.e('╔════════════════════════════════════╗');
        logger.e("║ 🚨 HIVE ERROR - RETHROWING");
        logger.e("║ Error: ${e.message}");
        logger.e('╚════════════════════════════════════╝');
        rethrow; // Re-throw HiveErrors (including our data protection errors)
      }
      logger.e('╔════════════════════════════════════╗');
      logger.e("║ ❌ SAFE DELETE FAILED");
      logger.e("║ Box: $boxName");
      logger.e("║ Error: $e");
      logger.e('╚════════════════════════════════════╝');
      return false;
    }
  }

  /// Open a single box with error handling
  Future<Box<T>> _openBox<T>(
    String boxName, {
    HiveAesCipher? encryptionCipher,
  }) async {
    // START BANNER
    logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');
    logger.e('🔍 ATTEMPTING TO OPEN BOX: $boxName');
    logger.e('🔍 Expected type: $T');
    logger.e('🔍 Encryption enabled: ${encryptionCipher != null}');
    logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      logger.w("🔍 DEBUG: Checking if box '$boxName' is already open...");

      // CRITICAL FIX: If box is already open, try to get it as the correct type
      // If that fails (wrong type), force-close and reopen with correct type
      if (Hive.isBoxOpen(boxName)) {
        logger.w(
            "⚠️  Box '$boxName' is ALREADY OPEN - checking type compatibility...");
        try {
          final existingBox = Hive.box<T>(boxName);
          logger.e(
              "✅ Box '$boxName' already open with CORRECT type - reusing existing box");
          logger.e("✅ Existing box length: ${existingBox.length}");
          logger.e("✅ Existing box isOpen: ${existingBox.isOpen}");
          return existingBox;
        } catch (typeError) {
          // Box is open but with wrong type (e.g., Box<dynamic> instead of Box<PetProfile>)
          logger
              .e("⚠️  CAUGHT TYPE ERROR: Box '$boxName' open with wrong type!");
          logger.e("⚠️  Type error details: $typeError");
          logger.e("🔧 FORCING CLOSE and reopening with encryption...");

          try {
            await Hive.box(boxName).close();
            logger.e("✅ Force-closed box '$boxName' successfully");
          } catch (closeError) {
            logger.e("❌ CAUGHT CLOSE ERROR: Failed to force-close '$boxName'");
            logger.e("❌ Close error details: $closeError");
            logger.e("🔧 CALLING SAFE DELETE due to close failure...");
            // Try to safely delete (only if empty or non-existent)
            await _safeDeleteBoxFromDisk(boxName);
          }
        }
      } else {
        logger.d("ℹ️  Box '$boxName' is NOT currently open - will open fresh");
      }

      logger.w(
          "🔓 ATTEMPTING Hive.openBox<$T>('$boxName', encryptionCipher: ${encryptionCipher != null})...");

      // Open the box with encryption if cipher provided
      final box = await Hive.openBox<T>(
        boxName,
        encryptionCipher: encryptionCipher,
      );

      // END BANNER - SUCCESS
      logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');
      logger.e('✅ BOX OPENED SUCCESSFULLY: $boxName');
      logger.e('✅ Type: $T');
      logger.e('✅ Length: ${box.length}');
      logger.e('✅ IsOpen: ${box.isOpen}');
      logger.e('✅ Keys: ${box.keys.toList()}');
      logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');

      return box;
    } catch (e) {
      logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');
      logger.e("🚨 CAUGHT ERROR OPENING BOX: $boxName");
      logger.e("🚨 Error type: ${e.runtimeType}");
      logger.e("🚨 Error message: $e");
      logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');

      // Try to safely delete corrupted box and recreate (only if empty)
      try {
        logger.e(
            "🔧 RECOVERY ATTEMPT: Trying to safely delete and recreate box '$boxName'");
        logger.e("🔧 CALLING SAFE DELETE from catch block...");
        await _safeDeleteBoxFromDisk(boxName);

        logger
            .w("🔓 RETRY: Attempting to open box '$boxName' after deletion...");
        final box = await Hive.openBox<T>(
          boxName,
          encryptionCipher: encryptionCipher,
        );

        logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');
        logger.e("✅ RECOVERY SUCCESS: Box '$boxName' recreated");
        logger.e('✅ Length after recovery: ${box.length}');
        logger.e('✅ IsOpen: ${box.isOpen}');
        logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');

        return box;
      } catch (e2) {
        logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');
        logger.e("🚨 RECOVERY FAILED: Could not recreate box '$boxName'");
        logger.e("🚨 Recovery error type: ${e2.runtimeType}");
        logger.e("🚨 Recovery error message: $e2");
        logger.e('━━━━━━━━━━━━━━━━━━━━━━━━');
        rethrow;
      }
    }
  }

  /// Get pet profiles box
  Box<PetProfile> get petProfileBox {
    if (_petProfileBox == null || !_petProfileBox!.isOpen) {
      throw HiveError(
          "Pet profiles box is not initialized. Call HiveManager.initialize() first.");
    }
    return _petProfileBox!;
  }

  /// Get walks box
  Box<Walk> get walkBox {
    if (_walkBox == null || !_walkBox!.isOpen) {
      throw HiveError(
          "Walks box is not initialized. Call HiveManager.initialize() first.");
    }
    return _walkBox!;
  }

  /// Get feedings box
  Box<FeedingEntry> get feedingBox {
    if (_feedingBox == null || !_feedingBox!.isOpen) {
      throw HiveError(
          "Feedings box is not initialized. Call HiveManager.initialize() first.");
    }
    return _feedingBox!;
  }

  /// Get medications box
  Box<MedicationEntry> get medicationBox {
    if (_medicationBox == null || !_medicationBox!.isOpen) {
      throw HiveError(
          "Medications box is not initialized. Call HiveManager.initialize() first.");
    }
    return _medicationBox!;
  }

  /// Get medication purchases box
  Box<MedicationPurchase> get medicationPurchaseBox {
    if (_medicationPurchaseBox == null || !_medicationPurchaseBox!.isOpen) {
      throw HiveError(
          "Medication purchases box is not initialized. Call HiveManager.initialize() first.");
    }
    return _medicationPurchaseBox!;
  }

  /// Get appointments box
  Box<AppointmentEntry> get appointmentBox {
    if (_appointmentBox == null || !_appointmentBox!.isOpen) {
      throw HiveError(
          "Appointments box is not initialized. Call HiveManager.initialize() first.");
    }
    return _appointmentBox!;
  }

  /// Get reports box
  Box<ReportEntry> get reportBox {
    if (_reportBox == null || !_reportBox!.isOpen) {
      throw HiveError(
          "Reports box is not initialized. Call HiveManager.initialize() first.");
    }
    return _reportBox!;
  }

  /// Get reminders box
  Box<Reminder> get reminderBox {
    if (_reminderBox == null || !_reminderBox!.isOpen) {
      throw HiveError(
          "Reminders box is not initialized. Call HiveManager.initialize() first.");
    }
    return _reminderBox!;
  }

  /// Get weight entries box
  Box<WeightEntry> get weightBox {
    if (_weightBox == null || !_weightBox!.isOpen) {
      throw HiveError(
          "Weight entries box is not initialized. Call HiveManager.initialize() first.");
    }
    return _weightBox!;
  }

  /// Get pet photos box
  Box<PetPhoto> get petPhotoBox {
    if (_petPhotoBox == null || !_petPhotoBox!.isOpen) {
      throw HiveError(
          "Pet photos box is not initialized. Call HiveManager.initialize() first.");
    }
    return _petPhotoBox!;
  }

  /// Get vet profiles box
  Box<VetProfile> get vetProfileBox {
    if (_vetProfileBox == null || !_vetProfileBox!.isOpen) {
      throw HiveError(
          "Vet profiles box is not initialized. Call HiveManager.initialize() first.");
    }
    return _vetProfileBox!;
  }

  /// Get health reports box
  Box<HealthReport> get healthReportBox {
    if (_healthReportBox == null || !_healthReportBox!.isOpen) {
      throw HiveError(
          "Health reports box is not initialized. Call HiveManager.initialize() first.");
    }
    return _healthReportBox!;
  }

  /// Get expense reports box
  Box<ExpenseReport> get expenseReportBox {
    if (_expenseReportBox == null || !_expenseReportBox!.isOpen) {
      throw HiveError(
          "Expense reports box is not initialized. Call HiveManager.initialize() first.");
    }
    return _expenseReportBox!;
  }

  /// Get vaccination protocols box
  Box<VaccinationProtocol> get vaccinationProtocolBox {
    if (_vaccinationProtocolBox == null || !_vaccinationProtocolBox!.isOpen) {
      throw HiveError(
          "Vaccination protocols box is not initialized. Call HiveManager.initialize() first.");
    }
    return _vaccinationProtocolBox!;
  }

  /// Get deworming protocols box
  Box<DewormingProtocol> get dewormingProtocolBox {
    if (_dewormingProtocolBox == null || !_dewormingProtocolBox!.isOpen) {
      throw HiveError(
          "Deworming protocols box is not initialized. Call HiveManager.initialize() first.");
    }
    return _dewormingProtocolBox!;
  }

  /// Get treatment plans box
  Box<TreatmentPlan> get treatmentPlanBox {
    if (_treatmentPlanBox == null || !_treatmentPlanBox!.isOpen) {
      throw HiveError(
          "Treatment plans box is not initialized. Call HiveManager.initialize() first.");
    }
    return _treatmentPlanBox!;
  }

  /// Get reminder configs box
  Box<ReminderConfig> get reminderConfigBox {
    if (_reminderConfigBox == null || !_reminderConfigBox!.isOpen) {
      throw HiveError(
          "Reminder configs box is not initialized. Call HiveManager.initialize() first.");
    }
    return _reminderConfigBox!;
  }

  /// Get vaccination events box
  Box<VaccinationEvent> get vaccinationEventBox {
    if (_vaccinationEventBox == null || !_vaccinationEventBox!.isOpen) {
      throw HiveError(
          "Vaccination events box is not initialized. Call HiveManager.initialize() first.");
    }
    return _vaccinationEventBox!;
  }

  /// Get settings box
  Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw HiveError(
          "Settings box is not initialized. Call HiveManager.initialize() first.");
    }
    return _settingsBox!;
  }

  /// Get app prefs box
  Box get appPrefsBox {
    if (_appPrefsBox == null || !_appPrefsBox!.isOpen) {
      throw HiveError(
          "App prefs box is not initialized. Call HiveManager.initialize() first.");
    }
    return _appPrefsBox!;
  }

  /// Check if HiveManager is initialized
  bool get isInitialized => _isInitialized;

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// Flush all boxes to ensure data is written to disk
  ///
  /// CRITICAL FIX for Samsung devices: Forces Hive to write buffered data
  /// to disk immediately instead of keeping it in memory cache.
  ///
  /// Should be called:
  /// - When app goes to background (paused/detached lifecycle state)
  /// - After critical data changes
  /// - Before app termination
  Future<void> flushAllBoxes() async {
    try {
      // Flush all typed boxes
      await _petProfileBox?.flush();
      await _feedingBox?.flush();
      await _medicationBox?.flush();
      await _medicationPurchaseBox?.flush();
      await _appointmentBox?.flush();
      await _reportBox?.flush();
      await _walkBox?.flush();
      await _reminderBox?.flush();
      await _weightBox?.flush();
      await _petPhotoBox?.flush();
      await _vetProfileBox?.flush();
      await _healthReportBox?.flush();
      await _expenseReportBox?.flush();
      await _vaccinationProtocolBox?.flush();
      await _dewormingProtocolBox?.flush();
      await _treatmentPlanBox?.flush();
      await _reminderConfigBox?.flush();
      await _vaccinationEventBox?.flush();

      // Flush untyped boxes
      await _settingsBox?.flush();
      await _appPrefsBox?.flush();
    } catch (e) {
      logger.e("🚨 ERROR: Failed to flush boxes: $e");
      // Don't rethrow - flushing is best-effort
    }
  }

  /// DIAGNOSTIC: Verify data persistence and file system state
  ///
  /// This method checks:
  /// - Hive storage directory location
  /// - All files in the directory
  /// - Specific box file existence and sizes
  /// - Box states (isOpen, length)
  ///
  /// Call this at critical points:
  /// 1. After opening boxes in initialize()
  /// 2. After saving data in repositories
  /// 3. Before app goes to background
  Future<void> verifyDataPersistence() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      logger.w("📁 =================================");
      logger.w("📁 DIAGNOSTIC: Hive Storage Location");
      logger.w("📁 Directory: ${dir.path}");
      logger.w("📁 =================================");

      // List ALL files in directory
      final files = dir.listSync();
      logger.d("📁 Total files in directory: ${files.length}");

      for (var file in files) {
        if (file is File) {
          final size = await file.length();
          final name = file.path.split(Platform.pathSeparator).last;
          logger.d("📁   - $name ($size bytes)");
        }
      }

      // Check specific box files
      final boxesToCheck = [
        'pet_profiles.hive',
        'feedings.hive',
        'app_prefs.hive',
        'settings.hive',
        'walks.hive',
      ];

      logger.w("📁 =================================");
      logger.w("📁 CRITICAL BOX FILE STATUS:");
      for (var boxName in boxesToCheck) {
        final boxFile = File('${dir.path}${Platform.pathSeparator}$boxName');
        final exists = await boxFile.exists();
        final size = exists ? await boxFile.length() : 0;
        logger
            .w("📁   $boxName: ${exists ? 'EXISTS' : 'MISSING'} ($size bytes)");
      }
      logger.w("📁 =================================");

      // Check box states
      logger.d("📦 Box states:");
      logger.d(
          "📦   pet_profiles isOpen: ${_petProfileBox?.isOpen ?? false}, length: ${_petProfileBox?.length ?? 0}");
      logger.d(
          "📦   feedings isOpen: ${_feedingBox?.isOpen ?? false}, length: ${_feedingBox?.length ?? 0}");
      logger.d(
          "📦   walks isOpen: ${_walkBox?.isOpen ?? false}, length: ${_walkBox?.length ?? 0}");
      logger.d(
          "📦   settings isOpen: ${_settingsBox?.isOpen ?? false}, length: ${_settingsBox?.length ?? 0}");
      logger.d(
          "📦   app_prefs isOpen: ${_appPrefsBox?.isOpen ?? false}, length: ${_appPrefsBox?.length ?? 0}");
    } catch (e, stack) {
      logger.e("🚨 ERROR in verifyDataPersistence: $e");
      logger.e("🚨 Stack: $stack");
    }
  }

  /// Clear all data (for testing/debugging)
  /// Note: Hive must be initialized before calling this method
  Future<void> clearAllData() async {
    try {
      // Initialize Hive if not already initialized
      if (!_isInitialized) {
        await Hive.initFlutter();
      }

      // Close all boxes before deleting
      if (_isInitialized) {
        await close();
      }

      await Hive.deleteBoxFromDisk(petProfileBoxName);
      await Hive.deleteBoxFromDisk(walkBoxName);
      await Hive.deleteBoxFromDisk(feedingBoxName);
      await Hive.deleteBoxFromDisk(medicationBoxName);
      await Hive.deleteBoxFromDisk(medicationPurchaseBoxName);
      await Hive.deleteBoxFromDisk(appointmentBoxName);
      await Hive.deleteBoxFromDisk(reportBoxName);
      await Hive.deleteBoxFromDisk(reminderBoxName);
      await Hive.deleteBoxFromDisk(weightBoxName);
      await Hive.deleteBoxFromDisk(petPhotoBoxName);
      await Hive.deleteBoxFromDisk(vetProfileBoxName);
      await Hive.deleteBoxFromDisk(healthReportBoxName);
      await Hive.deleteBoxFromDisk(expenseReportBoxName);
      await Hive.deleteBoxFromDisk(vaccinationProtocolBoxName);
      await Hive.deleteBoxFromDisk(dewormingProtocolBoxName);
      await Hive.deleteBoxFromDisk(treatmentPlanBoxName);
      await Hive.deleteBoxFromDisk(reminderConfigBoxName);
      await Hive.deleteBoxFromDisk(vaccinationEventBoxName);
      await Hive.deleteBoxFromDisk(settingsBoxName);
      await Hive.deleteBoxFromDisk(appPrefsBoxName);
    } catch (e) {
      logger.e("🚨 ERROR: Failed to clear some Hive data: $e");
    }
  }
}
