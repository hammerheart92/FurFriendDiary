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
      print('✅ DEBUG: NotificationService already initialized');
      return;
    }

    print('🔔 DEBUG: Starting NotificationService initialization');

    try {
      // Initialize timezone
      print('🔔 DEBUG: Initializing timezones...');
      tz.initializeTimeZones();
      final location = tz.getLocation('Europe/Bucharest');
      tz.setLocalLocation(location);
      print('✅ DEBUG: Timezone set to: ${tz.local.name}');
      print('🔔 DEBUG: Current local time: ${DateTime.now()}');

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
      print('🔔 DEBUG: Initializing flutter_local_notifications...');
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('🔔 DEBUG: Notification tapped! Payload: ${response.payload}');
        },
      );

      print('✅ DEBUG: flutter_local_notifications initialized: $initialized');

      // CRITICAL: Create notification channel on Android
      await _createNotificationChannel();

      // Check permissions
      await _checkPermissions();

      _initialized = true;
      print('✅ DEBUG: NotificationService fully initialized');
    } catch (e, stackTrace) {
      print('❌ DEBUG: NotificationService initialization failed: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// CRITICAL: Create Android notification channel
  Future<void> _createNotificationChannel() async {
    print('🔔 DEBUG: Creating Android notification channel...');

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
      print('✅ DEBUG: Notification channel created successfully');
    } else {
      print('⚠️ DEBUG: Could not get Android plugin implementation');
    }
  }

  /// Check notification permissions
  Future<void> _checkPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Request permissions on Android 13+
      final permissionGranted =
          await androidPlugin.requestNotificationsPermission();
      print('🔔 DEBUG: Notification permission granted: $permissionGranted');

      // Check exact alarm permission
      final canScheduleExactAlarms =
          await androidPlugin.canScheduleExactNotifications();
      print('🔔 DEBUG: Can schedule exact alarms: $canScheduleExactAlarms');

      if (canScheduleExactAlarms == false) {
        print('⚠️ WARNING: Exact alarm permission not granted!');
        // Request permission
        await androidPlugin.requestExactAlarmsPermission();
      }
    }
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    print('🔔 DEBUG: scheduleReminder called for: ${reminder.title}');
    print('🔔 DEBUG: Scheduled time: ${reminder.scheduledTime}');
    print('🔔 DEBUG: Frequency: ${reminder.frequency}');
    print('🔔 DEBUG: Is active: ${reminder.isActive}');

    if (!_initialized) {
      print(
          '⚠️ DEBUG: NotificationService not initialized! Initializing now...');
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

      print('✅ DEBUG: Notification scheduled successfully!');

      // Verify scheduling
      await _printPendingNotifications();
    } catch (e, stackTrace) {
      print('❌ DEBUG: Error scheduling notification: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _scheduleOnce(Reminder reminder) async {
    print('🔔 DEBUG: _scheduleOnce called');
    print('🔔 DEBUG: Reminder ID: ${reminder.id}');
    print('🔔 DEBUG: Title: ${reminder.title}');
    print('🔔 DEBUG: Scheduled DateTime: ${reminder.scheduledTime}');

    final now = DateTime.now();
    print('🔔 DEBUG: Current time: $now');
    print(
        '🔔 DEBUG: Time until notification: ${reminder.scheduledTime.difference(now).inSeconds} seconds');

    final tzDateTime = tz.TZDateTime.from(reminder.scheduledTime, tz.local);
    print('🔔 DEBUG: TZ DateTime: $tzDateTime');
    print('🔔 DEBUG: TZ Location: ${tz.local.name}');

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
      print('✅ DEBUG: zonedSchedule completed successfully');
    } catch (e, stackTrace) {
      print('❌ DEBUG: zonedSchedule failed: $e');
      print('❌ DEBUG: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _scheduleDaily(Reminder reminder) async {
    print('🔔 DEBUG: Scheduling DAILY reminder');

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
    print('🔔 DEBUG: Scheduling TWICE DAILY reminder');

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
    print('🔔 DEBUG: Scheduling WEEKLY reminder');

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

  Future<void> _printPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    print('🔔 DEBUG: Total pending notifications: ${pending.length}');
    for (final notif in pending) {
      print('  - ID: ${notif.id}, Title: ${notif.title}');
    }
  }

  Future<void> showTestNotification() async {
    print('🔔 DEBUG: Showing immediate test notification');

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

    print('✅ DEBUG: Test notification shown');
  }

  Future<void> cancelReminder(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
    print('🔔 DEBUG: Cancelled notification for reminder: $reminderId');
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('🔔 DEBUG: Cancelled all notifications');
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
    print('✅ DEBUG: Notification shown - ID: $id, Title: $title');
  }
}
