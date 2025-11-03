import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import '../../domain/repositories/medication_repository.dart';
import '../../data/repositories/medication_repository_impl.dart';
import 'notification_service.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class InventoryAlertService {
  final NotificationService _notificationService = NotificationService();
  final MedicationRepository _medicationRepository = MedicationRepositoryImpl();

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

  /// Check for low stock medications and send notifications
  Future<void> checkLowStockAndNotify(String petId) async {
    try {
      // Ensure notification service is initialized
      await _notificationService.initialize();

      // Get all medications for the pet
      final medications =
          await _medicationRepository.getMedicationsByPetId(petId);

      for (final med in medications) {
        // Skip if medication is not active or doesn't have stock tracking
        if (!med.isActive || med.stockQuantity == null) {
          continue;
        }

        // Check for critical low stock
        if (med.lowStockThreshold != null &&
            med.stockQuantity! <= med.lowStockThreshold!) {
          await _showLowStockNotification(
            id: med.id.hashCode,
            medicationName: med.medicationName,
            stockQuantity: med.stockQuantity!,
            stockUnit: med.stockUnit ?? 'units',
            isCritical: true,
          );
          continue;
        }

        // Check for refill reminder (days until empty)
        if (med.refillReminderDays != null && med.stockQuantity != null) {
          final daysUntilEmpty = _medicationRepository.getDaysUntilEmpty(med);

          if (daysUntilEmpty != null &&
              daysUntilEmpty <= med.refillReminderDays! &&
              daysUntilEmpty > 0) {
            await _showRefillReminderNotification(
              id: med.id.hashCode + 1000000, // Different ID from low stock
              medicationName: med.medicationName,
              daysUntilEmpty: daysUntilEmpty,
            );
          }
        }
      }
    } catch (e) {
      print('❌ ERROR: Failed to check low stock: $e');
    }
  }

  /// Show low stock notification
  Future<void> _showLowStockNotification({
    required int id,
    required String medicationName,
    required int stockQuantity,
    required String stockUnit,
    required bool isCritical,
  }) async {
    // Get current locale and localization
    final locale = await _getCurrentLocale();
    final l10n = lookupAppLocalizations(locale);

    // Use localized unit name for pills, fallback to provided unit
    final localizedUnit = stockUnit.toLowerCase() == 'pills' ? l10n.pills : stockUnit;

    // Get localized body text
    final bodyText = l10n.lowStockBody(stockQuantity, localizedUnit);
    final titleText = isCritical ? l10n.criticalLowStockAlert : 'Low Stock Alert';

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
        bodyText,
        contentTitle: titleText,
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

    await _notificationService.showNotification(
      id: id,
      title: '${isCritical ? '🚨 ' : '⚠️ '}$medicationName',
      body: bodyText,
      details: notificationDetails,
    );
  }

  /// Show refill reminder notification
  Future<void> _showRefillReminderNotification({
    required int id,
    required String medicationName,
    required int daysUntilEmpty,
  }) async {
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
        'Only $daysUntilEmpty days of supply remaining. Consider refilling soon.',
        contentTitle: 'Refill Reminder',
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

    await _notificationService.showNotification(
      id: id,
      title: '💊 Refill Soon: $medicationName',
      body: 'Only $daysUntilEmpty days of supply left',
      details: notificationDetails,
    );
  }
}
