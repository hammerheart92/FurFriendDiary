import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/appointment_entry.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEntry appointment;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Appointment icon and veterinarian
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getAppointmentColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getAppointmentIcon(),
                            color: _getAppointmentColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.veterinarian,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${appointment.clinic} • ${appointment.reason}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: appointment.isCompleted ? Colors.green : _getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.isCompleted
                          ? 'Completed'
                          : _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // More options menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'toggle':
                          onToggleStatus?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              appointment.isCompleted ? Icons.undo : Icons.check,
                              color: appointment.isCompleted ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(appointment.isCompleted ? 'Mark Pending' : 'Mark Completed'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Appointment details row
              Row(
                children: [
                  // Date
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: DateFormat('MMM dd').format(appointment.appointmentDate),
                      color: Colors.blue,
                    ),
                  ),

                  // Time
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: DateFormat('HH:mm').format(appointment.appointmentTime),
                      color: Colors.green,
                    ),
                  ),

                  // Days until/since
                  Expanded(
                    child: _buildDetailItem(
                      icon: _getDaysIcon(),
                      label: _getDaysLabel(),
                      value: _getDaysValue(),
                      color: _getDaysColor(),
                    ),
                  ),
                ],
              ),

              // Notes section
              if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Notes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.notes!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getAppointmentIcon() {
    final reason = appointment.reason.toLowerCase();
    if (reason.contains('vaccine') || reason.contains('vaccination')) {
      return Icons.vaccines;
    } else if (reason.contains('surgery') || reason.contains('operation')) {
      return Icons.medical_services;
    } else if (reason.contains('checkup') || reason.contains('exam')) {
      return Icons.health_and_safety;
    } else if (reason.contains('dental') || reason.contains('teeth')) {
      return Icons.medication;
    } else if (reason.contains('emergency') || reason.contains('urgent')) {
      return Icons.emergency;
    } else {
      return Icons.local_hospital;
    }
  }

  Color _getAppointmentColor() {
    final reason = appointment.reason.toLowerCase();
    if (reason.contains('vaccine') || reason.contains('vaccination')) {
      return Colors.green;
    } else if (reason.contains('surgery') || reason.contains('operation')) {
      return Colors.red;
    } else if (reason.contains('checkup') || reason.contains('exam')) {
      return Colors.blue;
    } else if (reason.contains('dental') || reason.contains('teeth')) {
      return Colors.purple;
    } else if (reason.contains('emergency') || reason.contains('urgent')) {
      return Colors.orange;
    } else {
      return Colors.teal;
    }
  }

  Color _getStatusColor() {
    if (appointment.isCompleted) {
      return Colors.green;
    }

    final now = DateTime.now();
    final appointmentDateTime = appointment.appointmentDate;

    if (appointmentDateTime.isBefore(now)) {
      return Colors.red; // Overdue
    } else if (appointmentDateTime.difference(now).inDays <= 1) {
      return Colors.orange; // Tomorrow or today
    } else {
      return Colors.blue; // Upcoming
    }
  }

  String _getStatusText() {
    if (appointment.isCompleted) {
      return 'Completed';
    }

    final now = DateTime.now();
    final appointmentDate = appointment.appointmentDate;

    if (appointmentDate.isBefore(now)) {
      return 'Overdue';
    } else if (appointmentDate.difference(now).inDays == 0) {
      return 'Today';
    } else if (appointmentDate.difference(now).inDays == 1) {
      return 'Tomorrow';
    } else {
      return 'Upcoming';
    }
  }

  IconData _getDaysIcon() {
    if (appointment.isCompleted) {
      return Icons.check_circle;
    }

    final now = DateTime.now();
    final appointmentDate = appointment.appointmentDate;

    if (appointmentDate.isBefore(now)) {
      return Icons.warning;
    } else {
      return Icons.schedule;
    }
  }

  String _getDaysLabel() {
    if (appointment.isCompleted) {
      return 'Status';
    }

    final now = DateTime.now();
    final appointmentDate = appointment.appointmentDate;

    if (appointmentDate.isBefore(now)) {
      return 'Overdue';
    } else {
      return 'In';
    }
  }

  String _getDaysValue() {
    if (appointment.isCompleted) {
      return 'Done';
    }

    final now = DateTime.now();
    final appointmentDate = appointment.appointmentDate;
    final difference = appointmentDate.difference(now).inDays;

    if (difference < 0) {
      final overdueDays = -difference;
      return '${overdueDays}d';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return '1 day';
    } else {
      return '${difference}d';
    }
  }

  Color _getDaysColor() {
    if (appointment.isCompleted) {
      return Colors.green;
    }

    final now = DateTime.now();
    final appointmentDate = appointment.appointmentDate;

    if (appointmentDate.isBefore(now)) {
      return Colors.red; // Overdue
    } else if (appointmentDate.difference(now).inDays <= 1) {
      return Colors.orange; // Soon
    } else {
      return Colors.purple; // Future
    }
  }
}