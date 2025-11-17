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
  Box? _settingsBox;
  Box? _appPrefsBox;

  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    if (_isInitialized) {
      logger.i("🔍 DEBUG: HiveManager already initialized");
      return;
    }

    logger.i("🔍 DEBUG: Starting HiveManager initialization");

    try {
      // Initialize Hive
      await Hive.initFlutter();
      logger.i("🔍 DEBUG: Hive.initFlutter() completed");

      // Initialize encryption service
      logger.i("🔐 DEBUG: Initializing encryption service...");
      await EncryptionService.initialize();
      logger.i("✅ DEBUG: Encryption service initialized successfully");

      // Register all adapters
      await _registerAdapters();

      // Check if migration is needed (existing v1.0.7 users)
      logger.i("🔍 DEBUG: Checking if migration needed...");
      final needsMigration = await EncryptionService.needsMigration();

      if (needsMigration) {
        logger.w("⚠️ DEBUG: Migration needed - running DataMigrationService");

        final migrationService = DataMigrationService();
        final result = await migrationService.migrateToEncrypted();

        if (result.success) {
          logger.i(
              "✅ DEBUG: Migration completed successfully: ${result.totalRecordsMigrated} records across ${result.boxesProcessed.length} boxes in ${result.duration.inSeconds}s");
        } else {
          logger.e("❌ DEBUG: Migration failed: ${result.message}");
          if (result.errors.isNotEmpty) {
            logger.e("   Errors: ${result.errors.join(', ')}");
          }
          // Continue anyway - original data remains accessible
          logger.w("⚠️ DEBUG: Continuing with unencrypted boxes - migration will retry next launch");
        }
      } else {
        logger.i("ℹ️ DEBUG: No migration needed - boxes already encrypted or fresh install");
      }

      // Get encryption cipher for opening boxes
      logger.i("🔐 DEBUG: Getting encryption cipher...");
      final cipher = await EncryptionService.getEncryptionCipher();
      logger.i("✅ DEBUG: Encryption cipher obtained");

      // Open all boxes with encryption
      logger.i("🔐 DEBUG: Opening all boxes with encryption enabled...");
      await _openAllBoxes(cipher);

      // Diagnostic: Verify data persistence right after opening boxes
      await verifyDataPersistence();

      _isInitialized = true;
      logger.i("✅ DEBUG: HiveManager initialization completed successfully");
    } catch (e, stackTrace) {
      logger.e("🚨 ERROR: HiveManager initialization failed: $e");
      logger.e("🚨 STACK: $stackTrace");
      rethrow;
    }
  }

  /// Register all Hive adapters
  Future<void> _registerAdapters() async {
    logger.i("🔍 DEBUG: Registering Hive adapters");

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PetProfileAdapter());
      logger.d("✅ DEBUG: PetProfile adapter registered with typeId 1");
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FeedingEntryAdapter());
      logger.d("✅ DEBUG: FeedingEntry adapter registered with typeId 2");
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WalkAdapter());
      logger.d("✅ DEBUG: Walk adapter registered with typeId 3");
    }

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(WalkTypeAdapter());
      logger.d("✅ DEBUG: WalkType adapter registered with typeId 4");
    }

    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(MedicationEntryAdapter());
      logger.d("✅ DEBUG: MedicationEntry adapter registered with typeId 5");
    }

    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(AppointmentEntryAdapter());
      logger.d("✅ DEBUG: AppointmentEntry adapter registered with typeId 6");
    }

    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(WalkLocationAdapter());
      logger.d("✅ DEBUG: WalkLocation adapter registered with typeId 7");
    }

    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(ReportEntryAdapter());
      logger.d("✅ DEBUG: ReportEntry adapter registered with typeId 9");
    }

    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(UserProfileAdapter());
      logger.d("✅ DEBUG: UserProfile adapter registered with typeId 8");
    }

    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ReminderTypeAdapter());
      logger.d("✅ DEBUG: ReminderType adapter registered with typeId 10");
    }

    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(ReminderFrequencyAdapter());
      logger.d("✅ DEBUG: ReminderFrequency adapter registered with typeId 11");
    }

    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(ReminderAdapter());
      logger.d("✅ DEBUG: Reminder adapter registered with typeId 12");
    }

    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(TimeOfDayModelAdapter());
      logger.d("✅ DEBUG: TimeOfDayModel adapter registered with typeId 13");
    }

    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(WeightEntryAdapter());
      logger.d("✅ DEBUG: WeightEntry adapter registered with typeId 14");
    }

    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(WeightUnitAdapter());
      logger.d("✅ DEBUG: WeightUnit adapter registered with typeId 15");
    }

    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(PetPhotoAdapter());
      logger.d("✅ DEBUG: PetPhoto adapter registered with typeId 16");
    }

    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(MedicationPurchaseAdapter());
      logger.d("✅ DEBUG: MedicationPurchase adapter registered with typeId 18");
    }

    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(VetProfileAdapter());
      logger.d("✅ DEBUG: VetProfile adapter registered with typeId 19");
    }

    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(HealthReportAdapter());
      logger.d("✅ DEBUG: HealthReport adapter registered with typeId 20");
    }

    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(ExpenseReportAdapter());
      logger.d("✅ DEBUG: ExpenseReport adapter registered with typeId 21");
    }

    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(VaccinationProtocolAdapter());
      logger.d("✅ DEBUG: VaccinationProtocol adapter registered with typeId 22");
    }

    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(VaccinationStepAdapter());
      logger.d("✅ DEBUG: VaccinationStep adapter registered with typeId 23");
    }

    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(RecurringScheduleAdapter());
      logger.d("✅ DEBUG: RecurringSchedule adapter registered with typeId 24");
    }

    if (!Hive.isAdapterRegistered(25)) {
      Hive.registerAdapter(DewormingProtocolAdapter());
      logger.d("✅ DEBUG: DewormingProtocol adapter registered with typeId 25");
    }

    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(DewormingScheduleAdapter());
      logger.d("✅ DEBUG: DewormingSchedule adapter registered with typeId 26");
    }

    if (!Hive.isAdapterRegistered(27)) {
      Hive.registerAdapter(TreatmentPlanAdapter());
      logger.d("✅ DEBUG: TreatmentPlan adapter registered with typeId 27");
    }

    if (!Hive.isAdapterRegistered(28)) {
      Hive.registerAdapter(TreatmentTaskAdapter());
      logger.d("✅ DEBUG: TreatmentTask adapter registered with typeId 28");
    }

    if (!Hive.isAdapterRegistered(29)) {
      Hive.registerAdapter(ReminderConfigAdapter());
      logger.d("✅ DEBUG: ReminderConfig adapter registered with typeId 29");
    }
  }

  /// Open all boxes in the correct order
  Future<void> _openAllBoxes(HiveAesCipher? cipher) async {
    logger.i("🔍 DEBUG: Opening all Hive boxes with encryption enabled");

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

    // Open settings boxes
    _settingsBox = await _openBox(
      settingsBoxName,
      encryptionCipher: cipher,
    );
    _appPrefsBox = await _openBox(
      appPrefsBoxName,
      encryptionCipher: cipher,
    );

    logger.i("✅ DEBUG: All boxes opened successfully with encryption");

    // Mark encryption initialization complete for fresh installs
    // (Migration sets its own flag after migrating data)
    final prefs = await SharedPreferences.getInstance();
    final migrationAlreadyCompleted = prefs.getBool('hive_encryption_migration_completed_v1') ?? false;

    if (!migrationAlreadyCompleted) {
      await prefs.setBool('hive_encryption_migration_completed_v1', true);
      logger.d("✅ DEBUG: Encryption initialization flag saved");
    }
  }

  /// Open a single box with error handling
  Future<Box<T>> _openBox<T>(
    String boxName, {
    HiveAesCipher? encryptionCipher,
  }) async {
    try {
      logger.d("🔍 DEBUG: Opening box '$boxName'");

      // CRITICAL FIX: If box is already open, try to get it as the correct type
      // If that fails (wrong type), force-close and reopen with correct type
      if (Hive.isBoxOpen(boxName)) {
        logger.d("⚠️  DEBUG: Box '$boxName' is already open, checking type...");
        try {
          final existingBox = Hive.box<T>(boxName);
          logger.d("✅ DEBUG: Box '$boxName' already open with correct type");
          return existingBox;
        } catch (typeError) {
          // Box is open but with wrong type (e.g., Box<dynamic> instead of Box<PetProfile>)
          logger.w("⚠️  WARNING: Box '$boxName' open with wrong type: $typeError");
          logger.w("🔧 Forcing close and reopening with encryption...");

          try {
            await Hive.box(boxName).close();
            logger.d("✅ DEBUG: Force-closed box '$boxName'");
          } catch (closeError) {
            logger.e("❌ ERROR: Failed to force-close '$boxName': $closeError");
            // Try to delete and recreate
            await Hive.deleteBoxFromDisk(boxName);
            logger.w("🔧 Deleted corrupted box '$boxName' from disk");
          }
        }
      }

      // Open the box with encryption if cipher provided
      final box = await Hive.openBox<T>(
        boxName,
        encryptionCipher: encryptionCipher,
      );
      logger.d(
          "✅ DEBUG: Box '$boxName' opened successfully - IsOpen: ${box.isOpen}, Length: ${box.length}");

      return box;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to open box '$boxName': $e");

      // Try to delete corrupted box and recreate
      try {
        logger.i(
            "🔧 DEBUG: Attempting to delete and recreate corrupted box '$boxName'");
        await Hive.deleteBoxFromDisk(boxName);
        final box = await Hive.openBox<T>(
          boxName,
          encryptionCipher: encryptionCipher,
        );
        logger.i("✅ DEBUG: Box '$boxName' recreated successfully");
        return box;
      } catch (e2) {
        logger.e("🚨 ERROR: Failed to recreate box '$boxName': $e2");
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
    logger.i("🔍 DEBUG: Closing all Hive boxes");
    await Hive.close();
    _isInitialized = false;
    logger.i("✅ DEBUG: All Hive boxes closed");
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
    logger.d("💾 DEBUG: Flushing all Hive boxes to disk...");

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

      // Flush untyped boxes
      await _settingsBox?.flush();
      await _appPrefsBox?.flush();

      logger.i("✅ DEBUG: All boxes flushed to disk successfully");
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
      logger.i("📁 Total files in directory: ${files.length}");

      for (var file in files) {
        if (file is File) {
          final size = await file.length();
          final name = file.path.split(Platform.pathSeparator).last;
          logger.i("📁   - $name (${size} bytes)");
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
        logger.w(
            "📁   $boxName: ${exists ? 'EXISTS' : 'MISSING'} (${size} bytes)");
      }
      logger.w("📁 =================================");

      // Check box states
      logger.i("📦 Box states:");
      logger.i(
          "📦   pet_profiles isOpen: ${_petProfileBox?.isOpen ?? false}, length: ${_petProfileBox?.length ?? 0}");
      logger.i(
          "📦   feedings isOpen: ${_feedingBox?.isOpen ?? false}, length: ${_feedingBox?.length ?? 0}");
      logger.i(
          "📦   walks isOpen: ${_walkBox?.isOpen ?? false}, length: ${_walkBox?.length ?? 0}");
      logger.i(
          "📦   settings isOpen: ${_settingsBox?.isOpen ?? false}, length: ${_settingsBox?.length ?? 0}");
      logger.i(
          "📦   app_prefs isOpen: ${_appPrefsBox?.isOpen ?? false}, length: ${_appPrefsBox?.length ?? 0}");
    } catch (e, stack) {
      logger.e("🚨 ERROR in verifyDataPersistence: $e");
      logger.e("🚨 Stack: $stack");
    }
  }

  /// Clear all data (for testing/debugging)
  /// Note: Hive must be initialized before calling this method
  Future<void> clearAllData() async {
    logger.i("🔧 DEBUG: Clearing all Hive data");

    try {
      // Initialize Hive if not already initialized
      if (!_isInitialized) {
        logger
            .i("🔍 DEBUG: Hive not initialized, initializing for clearAllData");
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
      await Hive.deleteBoxFromDisk(settingsBoxName);
      await Hive.deleteBoxFromDisk(appPrefsBoxName);

      logger.i("✅ DEBUG: All Hive data cleared");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to clear some Hive data: $e");
    }
  }
}
