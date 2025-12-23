import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/reminder.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'appointment_card.dart';

class AppointmentList extends ConsumerWidget {
  final String petId;
  final VoidCallback? onAddAppointment;
  final Function(AppointmentEntry)? onEditAppointment;

  const AppointmentList({
    super.key,
    required this.petId,
    this.onAddAppointment,
    this.onEditAppointment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsByPetIdProvider(petId));

    return appointmentsAsync.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return _buildEmptyState(context);
        }

        // Sort appointments by date (upcoming first, then completed)
        final sortedAppointments = [...appointments];
        sortedAppointments.sort((a, b) {
          // Completed appointments go to the bottom
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          // Within same completion status, sort by appointment date
          return a.appointmentDate.compareTo(b.appointmentDate);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedAppointments.length,
          itemBuilder: (context, index) {
            final appointment = sortedAppointments[index];
            return AppointmentCard(
              appointment: appointment,
              onTap: () => onEditAppointment?.call(appointment),
              onToggleStatus: () => _toggleAppointmentStatus(ref, appointment),
              onDelete: () => _showDeleteDialog(context, ref, appointment),
              onSetReminder: () =>
                  _showReminderDialog(context, ref, appointment),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load appointments',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(appointmentsByPetIdProvider(petId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Appointments Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Keep track of your pet\'s veterinary appointments.\nTap the + button to schedule your first appointment.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onAddAppointment,
                icon: const Icon(Icons.add),
                label: const Text('Add Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAppointmentStatus(
      WidgetRef ref, AppointmentEntry appointment) async {
    try {
      final updatedAppointment = appointment.copyWith(
        isCompleted: !appointment.isCompleted,
      );

      await ref
          .read(appointmentProviderProvider.notifier)
          .updateAppointment(updatedAppointment);
    } catch (error) {
      // Error handling would be done by the provider/repository
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, AppointmentEntry appointment) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text(
          'Are you sure you want to delete the appointment with ${appointment.veterinarian} at ${appointment.clinic}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref
            .read(appointmentProviderProvider.notifier)
            .deleteAppointment(appointment.id);
        if (context.mounted) {
          SnackBarHelper.showSuccess(context, 'Appointment deleted successfully');
        }
      } catch (error) {
        if (context.mounted) {
          SnackBarHelper.showError(context, 'Failed to delete appointment: $error');
        }
      }
    }
  }

  void _showReminderDialog(
      BuildContext context, WidgetRef ref, AppointmentEntry appointment) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.setReminder,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.today, color: Colors.blue),
                      title: Text(l10n.oneDayBefore),
                      subtitle: Text(_formatReminderTime(
                          appointment.appointmentDate,
                          const Duration(days: 1))),
                      onTap: () {
                        Navigator.pop(context);
                        _createReminder(
                          context,
                          ref,
                          appointment,
                          appointment.appointmentDate
                              .subtract(const Duration(days: 1)),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.access_time, color: Colors.orange),
                      title: Text(l10n.oneHourBefore),
                      subtitle: Text(_formatReminderTime(
                          appointment.appointmentDate,
                          const Duration(hours: 1))),
                      onTap: () {
                        Navigator.pop(context);
                        _createReminder(
                          context,
                          ref,
                          appointment,
                          appointment.appointmentDate
                              .subtract(const Duration(hours: 1)),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.notifications, color: Colors.green),
                      title: Text(l10n.thirtyMinutesBefore),
                      subtitle: Text(_formatReminderTime(
                          appointment.appointmentDate,
                          const Duration(minutes: 30))),
                      onTap: () {
                        Navigator.pop(context);
                        _createReminder(
                          context,
                          ref,
                          appointment,
                          appointment.appointmentDate
                              .subtract(const Duration(minutes: 30)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatReminderTime(DateTime appointmentDate, Duration before) {
    final reminderTime = appointmentDate.subtract(before);
    final day = reminderTime.day.toString().padLeft(2, '0');
    final month = reminderTime.month.toString().padLeft(2, '0');
    final hour = reminderTime.hour.toString().padLeft(2, '0');
    final minute = reminderTime.minute.toString().padLeft(2, '0');
    return '$day/$month at $hour:$minute';
  }

  Future<void> _createReminder(
    BuildContext context,
    WidgetRef ref,
    AppointmentEntry appointment,
    DateTime reminderTime,
  ) async {
    try {
      final reminder = Reminder(
        petId: appointment.petId,
        type: ReminderType.appointment,
        title: appointment.reason,
        description: '${appointment.veterinarian} at ${appointment.clinic}',
        scheduledTime: reminderTime,
        frequency: ReminderFrequency.once,
        linkedEntityId: appointment.id,
      );

      await ref.read(reminderRepositoryProvider).addReminder(reminder);

      if (context.mounted) {
        SnackBarHelper.showSuccess(context, 'Reminder created successfully');
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Failed to create reminder: $e');
      }
    }
  }
}
