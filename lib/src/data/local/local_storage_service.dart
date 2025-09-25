import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';
import 'hive_manager.dart';

class LocalStorageService {
  static final logger = Logger();

  static Future<void> initialize() async {
    logger.i("🔍 DEBUG: LocalStorageService.initialize() called");
    
    // Initialize timezone data
    tz.initializeTimeZones();
    logger.i("✅ DEBUG: Timezone data initialized");
    
    // HiveManager should already be initialized in main.dart
    if (!HiveManager.instance.isInitialized) {
      logger.w("⚠️ WARNING: HiveManager not initialized, initializing now");
      await HiveManager.instance.initialize();
    }
    
    logger.i("✅ DEBUG: LocalStorageService initialization completed");
  }
  
  static Future<void> close() async {
    await HiveManager.instance.close();
  }
}
