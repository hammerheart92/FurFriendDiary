import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../data/repositories/medication_repository_impl.dart';
import 'notification_service.dart';

class InventoryAlertService {
  final NotificationService _notificationService = NotificationService();
  final MedicationRepository _medicationRepository = MedicationRepositoryImpl();

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
        'Only $stockQuantity $stockUnit remaining. Time to refill!',
        contentTitle: '${isCritical ? 'Critical: ' : ''}Low Stock Alert',
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
      title: '${isCritical ? '🚨 ' : '⚠️ '}Low Stock: $medicationName',
      body: 'Only $stockQuantity $stockUnit remaining',
      details: notificationDetails,
    );

    print('✅ DEBUG: Low stock notification sent for $medicationName');
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

    print('✅ DEBUG: Refill reminder notification sent for $medicationName');
  }
}
