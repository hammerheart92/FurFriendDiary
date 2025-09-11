
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: DarwinInitializationSettings());
    await _plugin.initialize(settings);
  }

  static Future<bool> ensurePermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<int> scheduleAt(DateTime time, {required String title, required String body}) async {
    // Convert to device timezone aware TZDateTime
    final tzTime = tz.TZDateTime.from(time, tz.local);
    final details = const NotificationDetails(
      android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.max, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
    final id = time.millisecondsSinceEpoch.remainder(1 << 31);
    await _plugin.zonedSchedule(id, title, body, tzTime, details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: null);
    return id;
  }
}
