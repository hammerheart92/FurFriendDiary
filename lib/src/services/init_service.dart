import '../data/local/local_storage_service.dart';

class InitService {
  /// Bootstrap Hive and timezone. Keep it small and safe for unit tests.
  static Future<void> bootstrap() async {
    await LocalStorageService.initialize();
  }
}
