import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/appointment_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
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
              onPressed: () => ref.invalidate(appointmentsByPetIdProvider(petId)),
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

  Future<void> _toggleAppointmentStatus(WidgetRef ref, AppointmentEntry appointment) async {
    try {
      final updatedAppointment = appointment.copyWith(
        isCompleted: !appointment.isCompleted,
      );

      await ref.read(appointmentProviderProvider.notifier).updateAppointment(updatedAppointment);
    } catch (error) {
      // Error handling would be done by the provider/repository
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, AppointmentEntry appointment) async {
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
        await ref.read(appointmentProviderProvider.notifier).deleteAppointment(appointment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete appointment: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}