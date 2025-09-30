import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../../domain/models/pet_profile.dart';
import '../../domain/models/feeding_entry.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/report_entry.dart';
import '../../domain/models/walk.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/time_of_day_model.dart';

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
  static const String appointmentBoxName = 'appointments';
  static const String reportBoxName = 'reports';
  static const String walkBoxName = 'walks';
  static const String settingsBoxName = 'settings';
  static const String appPrefsBoxName = 'app_prefs';
  
  // Box references
  Box<PetProfile>? _petProfileBox;
  Box<FeedingEntry>? _feedingBox;
  Box<MedicationEntry>? _medicationBox;
  Box<AppointmentEntry>? _appointmentBox;
  Box<ReportEntry>? _reportBox;
  Box<Walk>? _walkBox;
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
      
      // Register all adapters
      await _registerAdapters();
      
      // Open all boxes in sequence
      await _openAllBoxes();
      
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
      Hive.registerAdapter(TimeOfDayModelAdapter());
      logger.d("✅ DEBUG: TimeOfDayModel adapter registered with typeId 10");
    }
  }
  
  /// Open all boxes in the correct order
  Future<void> _openAllBoxes() async {
    logger.i("🔍 DEBUG: Opening all Hive boxes");
    
    // Open pet profiles box first (most important)
    _petProfileBox = await _openBox<PetProfile>(petProfileBoxName);
    
    // Open walks box (second most important)
    _walkBox = await _openBox<Walk>(walkBoxName);
    
    // Open other boxes
    _feedingBox = await _openBox<FeedingEntry>(feedingBoxName);
    _medicationBox = await _openBox<MedicationEntry>(medicationBoxName);
    _appointmentBox = await _openBox<AppointmentEntry>(appointmentBoxName);
    _reportBox = await _openBox<ReportEntry>(reportBoxName);
    
    // Open settings boxes
    _settingsBox = await _openBox(settingsBoxName);
    _appPrefsBox = await _openBox(appPrefsBoxName);
    
    logger.i("✅ DEBUG: All boxes opened successfully");
  }
  
  /// Open a single box with error handling
  Future<Box<T>> _openBox<T>(String boxName) async {
    try {
      logger.d("🔍 DEBUG: Opening box '$boxName'");
      
      // Check if box is already open
      if (Hive.isBoxOpen(boxName)) {
        logger.d("✅ DEBUG: Box '$boxName' already open");
        return Hive.box<T>(boxName);
      }
      
      // Open the box
      final box = await Hive.openBox<T>(boxName);
      logger.d("✅ DEBUG: Box '$boxName' opened successfully - IsOpen: ${box.isOpen}, Length: ${box.length}");
      
      return box;
      
    } catch (e) {
      logger.e("🚨 ERROR: Failed to open box '$boxName': $e");
      
      // Try to delete corrupted box and recreate
      try {
        logger.i("🔧 DEBUG: Attempting to delete and recreate corrupted box '$boxName'");
        await Hive.deleteBoxFromDisk(boxName);
        final box = await Hive.openBox<T>(boxName);
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
      throw HiveError("Pet profiles box is not initialized. Call HiveManager.initialize() first.");
    }
    return _petProfileBox!;
  }
  
  /// Get walks box
  Box<Walk> get walkBox {
    if (_walkBox == null || !_walkBox!.isOpen) {
      throw HiveError("Walks box is not initialized. Call HiveManager.initialize() first.");
    }
    return _walkBox!;
  }
  
  /// Get feedings box
  Box<FeedingEntry> get feedingBox {
    if (_feedingBox == null || !_feedingBox!.isOpen) {
      throw HiveError("Feedings box is not initialized. Call HiveManager.initialize() first.");
    }
    return _feedingBox!;
  }
  
  /// Get medications box
  Box<MedicationEntry> get medicationBox {
    if (_medicationBox == null || !_medicationBox!.isOpen) {
      throw HiveError("Medications box is not initialized. Call HiveManager.initialize() first.");
    }
    return _medicationBox!;
  }
  
  /// Get appointments box
  Box<AppointmentEntry> get appointmentBox {
    if (_appointmentBox == null || !_appointmentBox!.isOpen) {
      throw HiveError("Appointments box is not initialized. Call HiveManager.initialize() first.");
    }
    return _appointmentBox!;
  }

  /// Get reports box
  Box<ReportEntry> get reportBox {
    if (_reportBox == null || !_reportBox!.isOpen) {
      throw HiveError("Reports box is not initialized. Call HiveManager.initialize() first.");
    }
    return _reportBox!;
  }

  /// Get settings box
  Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw HiveError("Settings box is not initialized. Call HiveManager.initialize() first.");
    }
    return _settingsBox!;
  }
  
  /// Get app prefs box
  Box get appPrefsBox {
    if (_appPrefsBox == null || !_appPrefsBox!.isOpen) {
      throw HiveError("App prefs box is not initialized. Call HiveManager.initialize() first.");
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
  
  /// Clear all data (for testing/debugging)
  /// Note: Hive must be initialized before calling this method
  Future<void> clearAllData() async {
    logger.i("🔧 DEBUG: Clearing all Hive data");

    try {
      // Initialize Hive if not already initialized
      if (!_isInitialized) {
        logger.i("🔍 DEBUG: Hive not initialized, initializing for clearAllData");
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
      await Hive.deleteBoxFromDisk(appointmentBoxName);
      await Hive.deleteBoxFromDisk(reportBoxName);
      await Hive.deleteBoxFromDisk(settingsBoxName);
      await Hive.deleteBoxFromDisk(appPrefsBoxName);

      logger.i("✅ DEBUG: All Hive data cleared");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to clear some Hive data: $e");
    }
  }
}
