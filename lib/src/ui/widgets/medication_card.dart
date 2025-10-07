import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/medication_entry.dart';
import '../../../l10n/app_localizations.dart';

class MedicationCard extends StatelessWidget {
  final MedicationEntry medication;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
                  // Medication icon and name
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getMedicationColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getMedicationIcon(),
                            color: _getMedicationColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication.medicationName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${medication.dosage} • ${_getLocalizedFrequency(l10n, medication.frequency)}',
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
                      color: medication.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      medication.isActive ? 'Active' : 'Inactive',
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
                              medication.isActive ? Icons.pause : Icons.play_arrow,
                              color: medication.isActive ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(medication.isActive ? 'Mark Inactive' : 'Mark Active'),
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

              // Medication details row
              Row(
                children: [
                  // Administration method
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.medical_services,
                      label: l10n.method,
                      value: _getLocalizedAdministrationMethod(l10n, medication.administrationMethod),
                      color: Colors.blue,
                    ),
                  ),

                  // Start date
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.calendar_today,
                      label: l10n.started,
                      value: DateFormat('MMM dd').format(medication.startDate),
                      color: Colors.green,
                    ),
                  ),

                  // End date or duration
                  Expanded(
                    child: _buildDetailItem(
                      icon: medication.endDate != null ? Icons.event_available : Icons.all_inclusive,
                      label: medication.endDate != null ? l10n.ends : l10n.duration,
                      value: medication.endDate != null
                          ? DateFormat('MMM dd').format(medication.endDate!)
                          : l10n.ongoing,
                      color: medication.endDate != null ? Colors.orange : Colors.purple,
                    ),
                  ),
                ],
              ),

              // Administration times
              if (medication.administrationTimes.isNotEmpty) ...[
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
                            Icons.schedule,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.administrationTimes,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: medication.administrationTimes.map((time) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              time.format24Hour(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              // Notes section
              if (medication.notes != null && medication.notes!.isNotEmpty) ...[
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
                        medication.notes!,
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

  IconData _getMedicationIcon() {
    switch (medication.administrationMethod) {
      case 'administrationMethodOral':
        return Icons.medication;
      case 'administrationMethodTopical':
        return Icons.touch_app;
      case 'administrationMethodInjection':
        return Icons.vaccines;
      case 'administrationMethodEyeDrops':
        return Icons.remove_red_eye;
      case 'administrationMethodEarDrops':
        return Icons.hearing;
      case 'administrationMethodInhaled':
        return Icons.air;
      default:
        return Icons.medical_services;
    }
  }

  Color _getMedicationColor() {
    switch (medication.administrationMethod) {
      case 'administrationMethodOral':
        return Colors.blue;
      case 'administrationMethodTopical':
        return Colors.green;
      case 'administrationMethodInjection':
        return Colors.red;
      case 'administrationMethodEyeDrops':
        return Colors.cyan;
      case 'administrationMethodEarDrops':
        return Colors.orange;
      case 'administrationMethodInhaled':
        return Colors.teal;
      default:
        return Colors.purple;
    }
  }

  String _getLocalizedFrequency(AppLocalizations l10n, String frequencyKey) {
    switch (frequencyKey) {
      case 'frequencyOnceDaily':
        return l10n.frequencyOnceDaily;
      case 'frequencyTwiceDaily':
        return l10n.frequencyTwiceDaily;
      case 'frequencyThreeTimesDaily':
        return l10n.frequencyThreeTimesDaily;
      case 'frequencyFourTimesDaily':
        return l10n.frequencyFourTimesDaily;
      case 'frequencyEveryOtherDay':
        return l10n.frequencyEveryOtherDay;
      case 'frequencyWeekly':
        return l10n.frequencyWeekly;
      case 'frequencyAsNeeded':
        return l10n.frequencyAsNeeded;
      case 'frequencyCustom':
        return l10n.frequencyCustom;
      default:
        return frequencyKey;
    }
  }

  String _getLocalizedAdministrationMethod(AppLocalizations l10n, String methodKey) {
    switch (methodKey) {
      case 'administrationMethodOral':
        return l10n.administrationMethodOral;
      case 'administrationMethodTopical':
        return l10n.administrationMethodTopical;
      case 'administrationMethodInjection':
        return l10n.administrationMethodInjection;
      case 'administrationMethodEyeDrops':
        return l10n.administrationMethodEyeDrops;
      case 'administrationMethodEarDrops':
        return l10n.administrationMethodEarDrops;
      case 'administrationMethodInhaled':
        return l10n.administrationMethodInhaled;
      case 'administrationMethodOther':
        return l10n.administrationMethodOther;
      default:
        return methodKey;
    }
  }
}