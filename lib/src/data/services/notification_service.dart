import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import '../../domain/models/reminder.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

/// Helper to get the current app locale from SharedPreferences
Future<Locale> _getCurrentLocale() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('app_language') ??
                         prefs.getString('language_code') ??
                         ui.PlatformDispatcher.instance.locale.languageCode;
    return Locale(languageCode);
  } catch (e) {
    return const Locale('en'); // Fallback to English
  }
}

/// Helper to format reminder frequency enum to localized string
String _formatFrequency(ReminderFrequency frequency, AppLocalizations l10n) {
  switch (frequency) {
    case ReminderFrequency.once:
      return l10n.once; // "Once" / "O dată"
    case ReminderFrequency.daily:
      return l10n.frequencyOnceDaily; // "Once Daily" / "O dată pe zi"
    case ReminderFrequency.twiceDaily:
      return l10n.frequencyTwiceDaily; // "Twice Daily" / "De două ori pe zi"
    case ReminderFrequency.weekly:
      return l10n.frequencyWeekly; // "Weekly" / "Săptămânal"
    case ReminderFrequency.custom:
      return l10n.custom; // "Custom" / "Personalizat"
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  bool _initialized = false;

  /// Generate localized notification title and body based on reminder
  Future<Map<String, String>> _getLocalizedNotificationText(Reminder reminder) async {
    final locale = await _getCurrentLocale();
    final l10n = lookupAppLocalizations(locale);

    // Get localized title based on reminder type
    String title;
    String body;

    switch (reminder.type) {
      case ReminderType.medication:
        title = l10n.medicationReminder;
        // Format: "Medication Name - Frequency"
        final frequency = _formatFrequency(reminder.frequency, l10n);
        body = l10n.medicationReminderBody(reminder.title, frequency);
        break;
      case ReminderType.appointment:
        title = l10n.appointmentReminder;
        // Format: "Title at/la Location" or just title if no description
        body = reminder.description != null && reminder.description!.isNotEmpty
            ? l10n.appointmentAt(reminder.title, reminder.description!)
            : reminder.title;
        break;
      case ReminderType.feeding:
        title = l10n.feedingReminder;
        body = reminder.description ?? reminder.title;
        break;
      case ReminderType.walk:
        title = l10n.walkReminder;
        body = reminder.description ?? reminder.title;
        break;
    }

    return {'title': title, 'body': body};
  }

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

      // Note: cancelAll() removed - it was deleting scheduled reminders on app restart!
      // The "Missing type parameter" error was fixed by adding complete AndroidNotificationDetails
      _logger.i('✅ DEBUG: NotificationService initializing (preserving existing reminders)');

      // CRITICAL: Delete old channel and create new one with correct importance
      await _deleteOldChannel();
      await _createNotificationChannel();

      // Check permissions
      await _checkPermissions();

      _initialized = true;
      _logger.i('✅ NotificationService fully initialized');
    } catch (e) {
      _logger.e('❌ Error: NotificationService initialization failed: $e');
      rethrow;
    }
  }

  /// Force delete old notification channel to clear cached settings
  Future<void> _deleteOldChannel() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      try {
        // Delete the old 'reminders' channel that was cached with Importance.high
        await androidPlugin.deleteNotificationChannel('reminders');
        _logger.i('🗑️ Deleted old notification channel');
      } catch (e) {
        // Channel might not exist, that's fine
        _logger.d('Old channel not found (this is expected on fresh install): $e');
      }
    }
  }

  /// CRITICAL: Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminders_v2', // NEW channel ID to force recreation with correct importance
      'Pet Reminders', // name
      description: 'Critical pet care reminders and alarms',
      importance: Importance.max, // CRITICAL: Use max for time-sensitive alarms
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      _logger.i('✅ Notification channel "reminders_v2" created with Importance.max');
    }
  }

  /// Check notification permissions
/// CRITICAL FIX: Handle null values from canScheduleExactNotifications()
Future<void> _checkPermissions() async {
  final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    // Request permissions on Android 13+
    await androidPlugin.requestNotificationsPermission();

    // Check exact alarm permission (Android 12+/API 31+)
    final canScheduleExactAlarms =
        await androidPlugin.canScheduleExactNotifications();

    // CRITICAL FIX: Treat null and false the same - both mean permission not granted
    if (canScheduleExactAlarms != true) {
      // Request permission - this opens Settings on Android 12+
      await androidPlugin.requestExactAlarmsPermission();

      // Wait a moment for settings to potentially be changed
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify again
      final canScheduleAfterRequest =
          await androidPlugin.canScheduleExactNotifications();

      if (canScheduleAfterRequest != true) {
        _logger.e(
            'CRITICAL: Exact alarm permission NOT granted. Scheduled reminders WILL NOT WORK until user enables this permission manually!');
      }
    }
  }
}

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      _logger.i('Attempting to schedule reminder: ${reminder.id}');

      // CRITICAL: Cancel any existing notification with same ID first
      try {
        await _notifications.cancel(reminder.id.hashCode);
        _logger.d(
            'Cancelled any existing notification with ID: ${reminder.id.hashCode}');
      } catch (e) {
        _logger.w('Could not cancel existing notification (may not exist): $e');
      }

      // Small delay to ensure cancellation completes
      await Future.delayed(const Duration(milliseconds: 50));

      // Get pending notifications BEFORE scheduling
      final pendingBefore = await _notifications.pendingNotificationRequests();
      _logger.d(
          'Pending notifications before scheduling: ${pendingBefore.length}');

      // Schedule according to frequency
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

      // Verify it was scheduled
      final pendingAfter = await _notifications.pendingNotificationRequests();
      _logger.i(
          '✅ Reminder scheduled successfully. Pending count: ${pendingAfter.length}');
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to schedule reminder: $e');
      _logger.e('Stack trace: $stackTrace');

      // If this is the "Missing type parameter" error, clear ALL notifications
      if (e.toString().contains('Missing type parameter')) {
        _logger.w(
            '⚠️ Detected "Missing type parameter" error - clearing all notifications');
        try {
          await _notifications.cancelAll();
          _logger.i('✅ All notifications cleared due to format error');
        } catch (clearError) {
          _logger.e('❌ Could not clear notifications: $clearError');
        }
      }

      rethrow;
    }
  }

  Future<void> _scheduleOnce(Reminder reminder) async {
    _logger.i('\n=== SCHEDULING REMINDER (ONCE) ===');
    _logger.i('Type: ${reminder.type}');
    _logger.i('ID: ${reminder.id}');
    _logger.i('Notification ID (hashCode): ${reminder.id.hashCode}');
    _logger.i('Title: [REDACTED] (len: ${reminder.title.length})');
    _logger.i(
        'Description: [REDACTED] (len: ${(reminder.description ?? '').length}, present: ${reminder.description != null})');
    _logger.d('Scheduled DateTime (original): ${reminder.scheduledTime}');

    final tzDateTime = tz.TZDateTime.from(reminder.scheduledTime, tz.local);
    final currentTime = DateTime.now();
    final currentTzTime = tz.TZDateTime.now(tz.local);

    _logger.d('Scheduled as TZDateTime: $tzDateTime');
    _logger.d('TZ Location: ${tz.local.name}');
    _logger.d('Current DateTime: $currentTime');
    _logger.d('Current TZDateTime: $currentTzTime');
    _logger.d(
        'Time until notification: ${reminder.scheduledTime.difference(currentTime)}');
    _logger.d('Is in future: ${reminder.scheduledTime.isAfter(currentTime)}');
    _logger.d('TZ time is in future: ${tzDateTime.isAfter(currentTzTime)}');

    // Get localized notification text
    final localizedText = await _getLocalizedNotificationText(reminder);
    final notificationTitle = localizedText['title']!;
    final notificationBody = localizedText['body']!;

    // CRITICAL: Complete notification details with ALL required parameters
    final androidDetails = AndroidNotificationDetails(
      'reminders_v2', // MUST match channel ID created in _createNotificationChannel
      'Pet Reminders',
      channelDescription: 'Critical pet care reminders and alarms',
      importance: Importance.max, // CRITICAL: Must match channel importance
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      when: reminder.scheduledTime.millisecondsSinceEpoch,
      ticker: 'Pet Care Reminder',
      // CRITICAL: Add these to prevent "Missing type parameter" error
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        notificationBody,
        contentTitle: notificationTitle,
      ),
      // CRITICAL: Required fields for proper serialization
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false,
      channelShowBadge: true,
      enableLights: true,
      ledColor: const Color(0xFF00FF00),
      ledOnMs: 1000,
      ledOffMs: 500,
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
        notificationTitle,
        notificationBody,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );
      _logger.i('✅ zonedSchedule completed successfully!');

      // Verify it was scheduled
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      _logger.d('Pending notifications: ${pendingNotifications.length} total');
      for (var notif in pendingNotifications) {
        _logger.d(
            '  - ID: ${notif.id} (titleLen: ${notif.title?.length ?? 0}, bodyLen: ${notif.body?.length ?? 0})');
      }
      _logger.d(
          'Current reminder in pending: ${pendingNotifications.any((n) => n.id == reminder.id.hashCode)}');
    } catch (e, stackTrace) {
      _logger.e('❌ ERROR scheduling notification: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
    _logger.i('=== END SCHEDULING ===\n');
  }

  Future<void> _scheduleDaily(Reminder reminder) async {
    // Get localized notification text
    final localizedText = await _getLocalizedNotificationText(reminder);
    final notificationTitle = localizedText['title']!;
    final notificationBody = localizedText['body']!;

    final androidDetails = AndroidNotificationDetails(
      'reminders_v2',
      'Pet Reminders',
      channelDescription: 'Critical pet care reminders and alarms',
      importance: Importance.max, // CRITICAL: Must match channel importance
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      when: reminder.scheduledTime.millisecondsSinceEpoch,
      ticker: 'Pet Care Reminder',
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        notificationBody,
        contentTitle: notificationTitle,
      ),
      // CRITICAL: Required fields for proper serialization
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false,
      channelShowBadge: true,
      enableLights: true,
      ledColor: const Color(0xFF00FF00),
      ledOnMs: 1000,
      ledOffMs: 500,
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
      notificationTitle,
      notificationBody,
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
    // Get localized notification text
    final localizedText = await _getLocalizedNotificationText(reminder);
    final notificationTitle = localizedText['title']!;
    final notificationBody = localizedText['body']!;

    final androidDetails = AndroidNotificationDetails(
      'reminders_v2',
      'Pet Reminders',
      channelDescription: 'Critical pet care reminders and alarms',
      importance: Importance.max, // CRITICAL: Must match channel importance
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      when: reminder.scheduledTime.millisecondsSinceEpoch,
      ticker: 'Pet Care Reminder',
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        notificationBody,
        contentTitle: notificationTitle,
      ),
      // CRITICAL: Required fields for proper serialization
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false,
      channelShowBadge: true,
      enableLights: true,
      ledColor: const Color(0xFF00FF00),
      ledOnMs: 1000,
      ledOffMs: 500,
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
      notificationTitle,
      '$notificationBody (Morning)',
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
      notificationTitle,
      '$notificationBody (Evening)',
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
    // Get localized notification text
    final localizedText = await _getLocalizedNotificationText(reminder);
    final notificationTitle = localizedText['title']!;
    final notificationBody = localizedText['body']!;

    final androidDetails = AndroidNotificationDetails(
      'reminders_v2',
      'Pet Reminders',
      channelDescription: 'Critical pet care reminders and alarms',
      importance: Importance.max, // CRITICAL: Must match channel importance
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      when: reminder.scheduledTime.millisecondsSinceEpoch,
      ticker: 'Pet Care Reminder',
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        notificationBody,
        contentTitle: notificationTitle,
      ),
      // CRITICAL: Required fields for proper serialization
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false,
      channelShowBadge: true,
      enableLights: true,
      ledColor: const Color(0xFF00FF00),
      ledOnMs: 1000,
      ledOffMs: 500,
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
      notificationTitle,
      notificationBody,
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
      'reminders_v2',
      'Pet Reminders',
      channelDescription: 'Critical pet care reminders and alarms',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      ticker: 'Test Notification',
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(
        'If you see this, notifications are working!',
        contentTitle: 'Test Notification',
      ),
      // CRITICAL: Required fields for proper serialization
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false,
      channelShowBadge: true,
      enableLights: true,
      ledColor: const Color(0xFF00FF00),
      ledOnMs: 1000,
      ledOffMs: 500,
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
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_v2',
            'Pet Reminders',
            channelDescription: 'Critical pet care reminders and alarms',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            showWhen: true,
            when: DateTime.now().millisecondsSinceEpoch,
            ticker: 'Pet Care',
            icon: '@mipmap/ic_launcher',
            largeIcon:
                const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            // CRITICAL: Required fields for proper serialization
            autoCancel: true,
            ongoing: false,
            onlyAlertOnce: false,
            channelShowBadge: true,
            enableLights: true,
            ledColor: const Color(0xFF00FF00),
            ledOnMs: 1000,
            ledOffMs: 500,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

    await _notifications.show(id, title, body, notificationDetails);
  }
}
