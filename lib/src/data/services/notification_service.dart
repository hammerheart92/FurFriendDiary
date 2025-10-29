import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:logger/logger.dart';
import '../../domain/models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
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

      // CRITICAL: Clear any old notifications that might have been scheduled
      // with incomplete format (prevents "Missing type parameter" error)
      try {
        await _notifications.cancelAll();
        _logger.i('✅ DEBUG: Cleared old pending notifications');
      } catch (e) {
        _logger.w('⚠️ WARNING: Could not clear old notifications: $e');
        // Don't fail initialization if this fails
      }

      // CRITICAL: Create notification channel on Android
      await _createNotificationChannel();

      // Check permissions
      await _checkPermissions();

      _initialized = true;
    } catch (e) {
      _logger.e('❌ Error: NotificationService initialization failed: $e');
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
      _logger.e('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> _scheduleOnce(Reminder reminder) async {
    _logger.i('\n=== SCHEDULING REMINDER (ONCE) ===');
    _logger.i('Type: ${reminder.type}');
    _logger.i('ID: ${reminder.id}');
    _logger.i('Notification ID (hashCode): ${reminder.id.hashCode}');
    _logger.i('Title: ${reminder.title}');
    _logger.i('Description: ${reminder.description ?? 'Pet care reminder'}');
    _logger.i('Scheduled DateTime (original): ${reminder.scheduledTime}');

    final tzDateTime = tz.TZDateTime.from(reminder.scheduledTime, tz.local);
    final currentTime = DateTime.now();
    final currentTzTime = tz.TZDateTime.now(tz.local);

    _logger.i('Scheduled as TZDateTime: $tzDateTime');
    _logger.i('TZ Location: ${tz.local.name}');
    _logger.i('Current DateTime: $currentTime');
    _logger.i('Current TZDateTime: $currentTzTime');
    _logger.i('Time until notification: ${reminder.scheduledTime.difference(currentTime)}');
    _logger.i('Is in future: ${reminder.scheduledTime.isAfter(currentTime)}');
    _logger.i('TZ time is in future: ${tzDateTime.isAfter(currentTzTime)}');

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
      _logger.i('Calling zonedSchedule...');
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
      _logger.i('✅ zonedSchedule completed successfully!');

      // Verify it was scheduled
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      _logger.i('📋 Total pending notifications: ${pendingNotifications.length}');
      for (var notif in pendingNotifications) {
        _logger.d('  - ID: ${notif.id}, Title: ${notif.title}, Body: ${notif.body}');
      }
      _logger.i('✓ This notification in pending list: ${pendingNotifications.any((n) => n.id == reminder.id.hashCode)}');

    } catch (e, stackTrace) {
      _logger.e('❌ ERROR scheduling notification: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
    _logger.i('=== END SCHEDULING ===\n');
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
