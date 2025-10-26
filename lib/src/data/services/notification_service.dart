import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../domain/models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      final location = tz.getLocation('Europe/Bucharest');
      tz.setLocalLocation(location);

      // Android initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Notification tapped - handle payload if needed
        },
      );

      // CRITICAL: Create notification channel on Android
      await _createNotificationChannel();

      // Check permissions
      await _checkPermissions();

      _initialized = true;
    } catch (e) {
      print('Error: NotificationService initialization failed: $e');
      rethrow;
    }
  }

  /// CRITICAL: Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminders', // id - MUST match the channelId in notification details
      'Reminders', // name
      description: 'Pet care reminders and notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Check notification permissions
  Future<void> _checkPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Request permissions on Android 13+
      await androidPlugin.requestNotificationsPermission();

      // Check exact alarm permission
      final canScheduleExactAlarms =
          await androidPlugin.canScheduleExactNotifications();

      if (canScheduleExactAlarms == false) {
        // Request permission
        await androidPlugin.requestExactAlarmsPermission();
      }
    }
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      switch (reminder.frequency) {
        case ReminderFrequency.once:
          await _scheduleOnce(reminder);
          break;
        case ReminderFrequency.daily:
          await _scheduleDaily(reminder);
          break;
        case ReminderFrequency.twiceDaily:
          await _scheduleTwiceDaily(reminder);
          break;
        case ReminderFrequency.weekly:
          await _scheduleWeekly(reminder);
          break;
        case ReminderFrequency.custom:
          await _scheduleOnce(reminder);
          break;
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> _scheduleOnce(Reminder reminder) async {
    final tzDateTime = tz.TZDateTime.from(reminder.scheduledTime, tz.local);

    // CRITICAL: Complete notification details with ALL required parameters
    final androidDetails = AndroidNotificationDetails(
      'reminders', // MUST match channel ID created in _createNotificationChannel
      'Reminders',
      channelDescription: 'Pet care reminders and notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      ticker: 'Pet Care Reminder',
      // CRITICAL: Add these to prevent "Missing type parameter" error
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        reminder.description ?? 'Pet care reminder',
        contentTitle: reminder.title,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        reminder.id.hashCode,
        reminder.title,
        reminder.description ?? 'Pet care reminder',
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );
    } catch (e) {
      print('Error: zonedSchedule failed: $e');
      rethrow;
    }
  }

  Future<void> _scheduleDaily(Reminder reminder) async {
    final androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Pet care reminders and notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        reminder.description ?? 'Pet care reminder',
        contentTitle: reminder.title,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Pet care reminder',
      tz.TZDateTime.from(reminder.scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: reminder.id,
    );
  }

  Future<void> _scheduleTwiceDaily(Reminder reminder) async {
    final androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Pet care reminders and notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        reminder.description ?? 'Pet care reminder',
        contentTitle: reminder.title,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Morning notification
    final morning = tz.TZDateTime.from(
      reminder.scheduledTime.copyWith(hour: 9, minute: 0),
      tz.local,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      '${reminder.description ?? 'Pet care reminder'} (Morning)',
      morning,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${reminder.id}_morning',
    );

    // Evening notification
    final evening = tz.TZDateTime.from(
      reminder.scheduledTime.copyWith(hour: 21, minute: 0),
      tz.local,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode + 1,
      reminder.title,
      '${reminder.description ?? 'Pet care reminder'} (Evening)',
      evening,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${reminder.id}_evening',
    );
  }

  Future<void> _scheduleWeekly(Reminder reminder) async {
    final androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Pet care reminders and notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        reminder.description ?? 'Pet care reminder',
        contentTitle: reminder.title,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Pet care reminder',
      tz.TZDateTime.from(reminder.scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: reminder.id,
    );
  }

  Future<void> showTestNotification() async {

    if (!_initialized) {
      await initialize();
    }

    final androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Pet care reminders and notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(
        'If you see this, notifications are working!',
        contentTitle: 'Test Notification',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999999,
      'Test Notification',
      'If you see this, notifications are working!',
      notificationDetails,
    );
  }

  Future<void> cancelReminder(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Show a notification with custom details
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    NotificationDetails? details,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Use provided details or default
    final notificationDetails = details ??
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Reminders',
            channelDescription: 'Pet care reminders and notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

    await _notifications.show(id, title, body, notificationDetails);
  }
}
