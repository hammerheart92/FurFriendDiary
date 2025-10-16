import 'package:hive/hive.dart';
import '../../domain/models/reminder.dart';
import '../services/notification_service.dart';
import '../local/hive_manager.dart';
import 'package:logger/logger.dart';

class ReminderRepository {
  final Logger _logger = Logger();
  final NotificationService _notificationService = NotificationService();

  Box<Reminder> get _box => HiveManager.instance.reminderBox;

  Future<void> addReminder(Reminder reminder) async {
    print('📦 DEBUG: ReminderRepository.addReminder called');
    print('📦 DEBUG: Reminder: ${reminder.title}, Active: ${reminder.isActive}');
    
    await _box.put(reminder.id, reminder);
    print('✅ DEBUG: Saved to Hive');

    if (reminder.isActive) {
      print('📦 DEBUG: Calling NotificationService.scheduleReminder...');
      await _notificationService.scheduleReminder(reminder);
      print('✅ DEBUG: NotificationService.scheduleReminder completed');
    }

    _logger.i('Added reminder: ${reminder.title}');
    print('✅ DEBUG: ReminderRepository.addReminder completed');
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _box.put(reminder.id, reminder);

    // Cancel old notification and schedule new one if active
    await _notificationService.cancelReminder(reminder.id);

    if (reminder.isActive) {
      await _notificationService.scheduleReminder(reminder);
    }

    _logger.i('Updated reminder: ${reminder.title}');
  }

  Future<void> deleteReminder(String reminderId) async {
    await _box.delete(reminderId);
    await _notificationService.cancelReminder(reminderId);
    _logger.i('Deleted reminder: $reminderId');
  }

  Future<void> toggleReminderStatus(String reminderId) async {
    final reminder = _box.get(reminderId);

    if (reminder == null) {
      _logger.w('Reminder not found: $reminderId');
      return;
    }

    final updated = reminder.copyWith(isActive: !reminder.isActive);
    await updateReminder(updated);
  }

  List<Reminder> getAllReminders() {
    return _box.values.toList();
  }

  List<Reminder> getRemindersByPetId(String petId) {
    return _box.values.where((r) => r.petId == petId).toList();
  }

  List<Reminder> getActiveRemindersByPetId(String petId) {
    return _box.values
        .where((r) => r.petId == petId && r.isActive)
        .toList();
  }

  List<Reminder> getRemindersByType(String petId, ReminderType type) {
    return _box.values
        .where((r) => r.petId == petId && r.type == type)
        .toList();
  }

  List<Reminder> getRemindersByLinkedEntity(String linkedEntityId) {
    return _box.values
        .where((r) => r.linkedEntityId == linkedEntityId)
        .toList();
  }

  Reminder? getReminderById(String reminderId) {
    return _box.get(reminderId);
  }

  Future<void> deleteRemindersByPetId(String petId) async {
    final reminders = getRemindersByPetId(petId);

    for (final reminder in reminders) {
      await deleteReminder(reminder.id);
    }

    _logger.i('Deleted all reminders for pet: $petId');
  }

  Future<void> deleteRemindersByLinkedEntity(String linkedEntityId) async {
    final reminders = getRemindersByLinkedEntity(linkedEntityId);

    for (final reminder in reminders) {
      await deleteReminder(reminder.id);
    }

    _logger.i('Deleted all reminders for linked entity: $linkedEntityId');
  }

  Future<void> rescheduleAllActiveReminders() async {
    final activeReminders = _box.values.where((r) => r.isActive).toList();

    for (final reminder in activeReminders) {
      await _notificationService.scheduleReminder(reminder);
    }

    _logger.i('Rescheduled ${activeReminders.length} active reminders');
  }

}
