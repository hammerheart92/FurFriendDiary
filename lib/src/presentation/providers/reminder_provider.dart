import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/reminder.dart';
import '../../data/repositories/reminder_repository.dart';

part 'reminder_provider.g.dart';

// Repository provider
@riverpod
ReminderRepository reminderRepository(ReminderRepositoryRef ref) {
  return ReminderRepository();
}

// Reminder notifier for managing state
@riverpod
class ReminderNotifier extends _$ReminderNotifier {
  @override
  Future<List<Reminder>> build() async {
    final repository = ref.read(reminderRepositoryProvider);
    return repository.getAllReminders();
  }

  Future<void> addReminder(Reminder reminder) async {
    final repository = ref.read(reminderRepositoryProvider);
    await repository.addReminder(reminder);
    ref.invalidateSelf();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final repository = ref.read(reminderRepositoryProvider);
    await repository.updateReminder(reminder);
    ref.invalidateSelf();
  }

  Future<void> deleteReminder(String reminderId) async {
    final repository = ref.read(reminderRepositoryProvider);
    await repository.deleteReminder(reminderId);
    ref.invalidateSelf();
  }

  Future<void> toggleReminderStatus(String reminderId) async {
    final repository = ref.read(reminderRepositoryProvider);
    await repository.toggleReminderStatus(reminderId);
    ref.invalidateSelf();
  }
}

// Get reminders by pet ID
@riverpod
Future<List<Reminder>> remindersByPetId(
  RemindersByPetIdRef ref,
  String petId,
) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getRemindersByPetId(petId);
}

// Get active reminders by pet ID
@riverpod
Future<List<Reminder>> activeRemindersByPetId(
  ActiveRemindersByPetIdRef ref,
  String petId,
) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getActiveRemindersByPetId(petId);
}

// Get reminders by type
@riverpod
Future<List<Reminder>> remindersByType(
  RemindersByTypeRef ref,
  String petId,
  ReminderType type,
) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getRemindersByType(petId, type);
}

// Get reminders by linked entity ID
@riverpod
Future<List<Reminder>> remindersByLinkedEntity(
  RemindersByLinkedEntityRef ref,
  String linkedEntityId,
) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getRemindersByLinkedEntity(linkedEntityId);
}

// Get reminder by ID
@riverpod
Future<Reminder?> reminderById(
  ReminderByIdRef ref,
  String reminderId,
) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getReminderById(reminderId);
}
