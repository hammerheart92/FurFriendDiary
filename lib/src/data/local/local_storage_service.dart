import 'package:timezone/data/latest.dart' as tz;
import 'hive_manager.dart';

class LocalStorageService {
  static Future<void> initialize() async {
    print("🔍 DEBUG: LocalStorageService.initialize() called");
    
    // Initialize timezone data
    tz.initializeTimeZones();
    print("✅ DEBUG: Timezone data initialized");
    
    // HiveManager should already be initialized in main.dart
    if (!HiveManager.instance.isInitialized) {
      print("⚠️ WARNING: HiveManager not initialized, initializing now");
      await HiveManager.instance.initialize();
    }
    
    print("✅ DEBUG: LocalStorageService initialization completed");
  }
  
  static Future<void> close() async {
    await HiveManager.instance.close();
  }
}
