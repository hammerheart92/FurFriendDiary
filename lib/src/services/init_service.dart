
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

class InitService {
  /// Bootstrap Hive and timezone. Keep it small and safe for unit tests.
  static Future<void> bootstrap() async {
    await Hive.initFlutter();
    tz.initializeTimeZones();
  }
}
