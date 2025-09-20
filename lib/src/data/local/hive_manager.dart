import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/pet_profile.dart';
import '../../domain/models/feeding_entry.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/walk.dart';
import '../../domain/models/user_profile.dart';

class HiveManager {
  static HiveManager? _instance;
  static HiveManager get instance => _instance ??= HiveManager._();
  
  HiveManager._();
  
  bool _isInitialized = false;
  
  // Box names
  static const String petProfileBoxName = 'pet_profiles';
  static const String feedingBoxName = 'feedings';
  static const String medicationBoxName = 'medications';
  static const String appointmentBoxName = 'appointments';
  static const String walkBoxName = 'walks';
  static const String settingsBoxName = 'settings';
  static const String appPrefsBoxName = 'app_prefs';
  
  // Box references
  Box<PetProfile>? _petProfileBox;
  Box<FeedingEntry>? _feedingBox;
  Box<MedicationEntry>? _medicationBox;
  Box<AppointmentEntry>? _appointmentBox;
  Box<Walk>? _walkBox;
  Box? _settingsBox;
  Box? _appPrefsBox;
  
  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    if (_isInitialized) {
      print("🔍 DEBUG: HiveManager already initialized");
      return;
    }
    
    print("🔍 DEBUG: Starting HiveManager initialization");
    
    try {
      // Initialize Hive
      await Hive.initFlutter();
      print("🔍 DEBUG: Hive.initFlutter() completed");
      
      // Register all adapters
      await _registerAdapters();
      
      // Open all boxes in sequence
      await _openAllBoxes();
      
      _isInitialized = true;
      print("✅ DEBUG: HiveManager initialization completed successfully");
      
    } catch (e, stackTrace) {
      print("🚨 ERROR: HiveManager initialization failed: $e");
      print("🚨 STACK: $stackTrace");
      rethrow;
    }
  }
  
  /// Register all Hive adapters
  Future<void> _registerAdapters() async {
    print("🔍 DEBUG: Registering Hive adapters");
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PetProfileAdapter());
      print("✅ DEBUG: PetProfile adapter registered with typeId 1");
    }
    
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(FeedingEntryAdapter());
      print("✅ DEBUG: FeedingEntry adapter registered with typeId 2");
    }
    
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WalkAdapter());
      print("✅ DEBUG: Walk adapter registered with typeId 3");
    }
    
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(WalkTypeAdapter());
      print("✅ DEBUG: WalkType adapter registered with typeId 4");
    }
    
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(MedicationEntryAdapter());
      print("✅ DEBUG: MedicationEntry adapter registered with typeId 5");
    }
    
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(AppointmentEntryAdapter());
      print("✅ DEBUG: AppointmentEntry adapter registered with typeId 6");
    }
    
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(WalkLocationAdapter());
      print("✅ DEBUG: WalkLocation adapter registered with typeId 7");
    }
    
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(UserProfileAdapter());
      print("✅ DEBUG: UserProfile adapter registered with typeId 8");
    }
  }
  
  /// Open all boxes in the correct order
  Future<void> _openAllBoxes() async {
    print("🔍 DEBUG: Opening all Hive boxes");
    
    // Open pet profiles box first (most important)
    _petProfileBox = await _openBox<PetProfile>(petProfileBoxName);
    
    // Open walks box (second most important)
    _walkBox = await _openBox<Walk>(walkBoxName);
    
    // Open other boxes
    _feedingBox = await _openBox<FeedingEntry>(feedingBoxName);
    _medicationBox = await _openBox<MedicationEntry>(medicationBoxName);
    _appointmentBox = await _openBox<AppointmentEntry>(appointmentBoxName);
    
    // Open settings boxes
    _settingsBox = await _openBox(settingsBoxName);
    _appPrefsBox = await _openBox(appPrefsBoxName);
    
    print("✅ DEBUG: All boxes opened successfully");
  }
  
  /// Open a single box with error handling
  Future<Box<T>> _openBox<T>(String boxName) async {
    try {
      print("🔍 DEBUG: Opening box '$boxName'");
      
      // Check if box is already open
      if (Hive.isBoxOpen(boxName)) {
        print("✅ DEBUG: Box '$boxName' already open");
        return Hive.box<T>(boxName);
      }
      
      // Open the box
      final box = await Hive.openBox<T>(boxName);
      print("✅ DEBUG: Box '$boxName' opened successfully - IsOpen: ${box.isOpen}, Length: ${box.length}");
      
      return box;
      
    } catch (e) {
      print("🚨 ERROR: Failed to open box '$boxName': $e");
      
      // Try to delete corrupted box and recreate
      try {
        print("🔧 DEBUG: Attempting to delete and recreate corrupted box '$boxName'");
        await Hive.deleteBoxFromDisk(boxName);
        final box = await Hive.openBox<T>(boxName);
        print("✅ DEBUG: Box '$boxName' recreated successfully");
        return box;
      } catch (e2) {
        print("🚨 ERROR: Failed to recreate box '$boxName': $e2");
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
    print("🔍 DEBUG: Closing all Hive boxes");
    await Hive.close();
    _isInitialized = false;
    print("✅ DEBUG: All Hive boxes closed");
  }
  
  /// Clear all data (for testing/debugging)
  Future<void> clearAllData() async {
    print("🔧 DEBUG: Clearing all Hive data");
    
    try {
      await Hive.deleteBoxFromDisk(petProfileBoxName);
      await Hive.deleteBoxFromDisk(walkBoxName);
      await Hive.deleteBoxFromDisk(feedingBoxName);
      await Hive.deleteBoxFromDisk(medicationBoxName);
      await Hive.deleteBoxFromDisk(appointmentBoxName);
      await Hive.deleteBoxFromDisk(settingsBoxName);
      await Hive.deleteBoxFromDisk(appPrefsBoxName);
      
      print("✅ DEBUG: All Hive data cleared");
    } catch (e) {
      print("🚨 ERROR: Failed to clear some Hive data: $e");
    }
  }
}
