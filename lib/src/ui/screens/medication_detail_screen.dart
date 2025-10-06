import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/models/medication_entry.dart';
import '../../providers/medications_provider.dart';
import '../../../l10n/app_localizations.dart';

class MedicationDetailScreen extends ConsumerStatefulWidget {
  final String medicationId;

  const MedicationDetailScreen({
    super.key,
    required this.medicationId,
  });

  @override
  ConsumerState<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends ConsumerState<MedicationDetailScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _medicationNameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;

  late String _selectedFrequency;
  late String _selectedAdministrationMethod;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _hasEndDate;
  late List<TimeOfDay> _administrationTimes;

  final List<String> _frequencies = [
    'frequencyOnceDaily',
    'frequencyTwiceDaily',
    'frequencyThreeTimesDaily',
    'frequencyFourTimesDaily',
    'frequencyEveryOtherDay',
    'frequencyWeekly',
    'frequencyAsNeeded',
    'frequencyCustom',
  ];

  final List<String> _administrationMethods = [
    'administrationMethodOral',
    'administrationMethodTopical',
    'administrationMethodInjection',
    'administrationMethodEyeDrops',
    'administrationMethodEarDrops',
    'administrationMethodInhaled',
    'administrationMethodOther',
  ];

  @override
  void initState() {
    super.initState();
    _medicationNameController = TextEditingController();
    _dosageController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFields(MedicationEntry medication) {
    _medicationNameController.text = medication.medicationName;
    _dosageController.text = medication.dosage;
    _notesController.text = medication.notes ?? '';
    _selectedFrequency = medication.frequency;
    _selectedAdministrationMethod = medication.administrationMethod;
    _startDate = medication.startDate;
    _endDate = medication.endDate;
    _hasEndDate = medication.endDate != null;
    _administrationTimes = medication.administrationTimes
        .map((timeModel) => timeModel.toTimeOfDay())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicationsAsync = ref.watch(medicationsProvider);

    return medicationsAsync.when(
      data: (medications) {
        final medication = medications.firstWhere(
          (med) => med.id == widget.medicationId,
          orElse: () => throw Exception('Medication not found'),
        );

        if (!_isEditing) {
          _initializeFields(medication);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? AppLocalizations.of(context)!.editMedication : AppLocalizations.of(context)!.medicationDetails),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            actions: [
              if (_isEditing)
                TextButton(
                  onPressed: _isLoading ? null : () => _saveMedication(medication),
                  child: Text(
                    AppLocalizations.of(context)!.save,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit medication',
                ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      _toggleMedicationStatus(medication);
                      break;
                    case 'delete':
                      _deleteMedication(medication);
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
                        Text(medication.isActive ? AppLocalizations.of(context)!.markInactive : AppLocalizations.of(context)!.markActive),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.delete),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isEditing
                  ? _buildEditForm(theme, medication)
                  : _buildDetailView(theme, medication),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.errorLoadingMedications)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.errorLoadingMedications),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(medicationsProvider),
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView(ThemeData theme, MedicationEntry medication) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getMedicationColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getMedicationIcon(),
                      color: _getMedicationColor(),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.medicationName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: medication.isActive ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            medication.isActive ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.inactive,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Basic information card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.basicInformation,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(AppLocalizations.of(context)!.dosage, medication.dosage, Icons.straighten),
                  _buildDetailRow(AppLocalizations.of(context)!.frequency, _getLocalizedFrequency(medication.frequency), Icons.schedule),
                  _buildDetailRow(AppLocalizations.of(context)!.administrationMethod, _getLocalizedAdministrationMethod(medication.administrationMethod), Icons.medical_services),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Schedule card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.schedule,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    AppLocalizations.of(context)!.startDate,
                    DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).toString()).format(medication.startDate),
                    Icons.calendar_today,
                  ),
                  if (medication.endDate != null)
                    _buildDetailRow(
                      AppLocalizations.of(context)!.endDate,
                      DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).toString()).format(medication.endDate!),
                      Icons.event_available,
                    )
                  else
                    _buildDetailRow(AppLocalizations.of(context)!.duration, AppLocalizations.of(context)!.ongoing, Icons.all_inclusive),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Administration times card
          if (medication.administrationTimes.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.administrationTimes,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: medication.administrationTimes.map((time) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time.format24Hour(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          // Notes card
          if (medication.notes != null && medication.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.additionalNotes,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      medication.notes!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditForm(ThemeData theme, MedicationEntry medication) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Medication basic info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.medicationInformation,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Medication name
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return TextFormField(
                        controller: _medicationNameController,
                        decoration: InputDecoration(
                          labelText: l10n.medicationName,
                          prefixIcon: const Icon(Icons.medication),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseEnterMedicationName;
                          }
                          return null;
                        },
                      );
                    }
                  ),

                  const SizedBox(height: 16),

                  // Dosage
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return TextFormField(
                        controller: _dosageController,
                        decoration: InputDecoration(
                          labelText: l10n.dosage,
                          prefixIcon: const Icon(Icons.straighten),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.pleaseEnterDosage;
                          }
                          return null;
                        },
                      );
                    }
                  ),

                  const SizedBox(height: 16),

                  // Frequency dropdown
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return DropdownButtonFormField<String>(
                        value: _selectedFrequency,
                        decoration: InputDecoration(
                          labelText: l10n.frequency,
                          prefixIcon: const Icon(Icons.schedule),
                          border: const OutlineInputBorder(),
                        ),
                        items: _frequencies.map((frequency) {
                          return DropdownMenuItem(
                            value: frequency,
                            child: Text(_getLocalizedFrequency(frequency)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFrequency = value!;
                          });
                        },
                      );
                    }
                  ),

                  const SizedBox(height: 16),

                  // Administration method dropdown
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return DropdownButtonFormField<String>(
                        value: _selectedAdministrationMethod,
                        decoration: InputDecoration(
                          labelText: l10n.administrationMethod,
                          prefixIcon: const Icon(Icons.medical_services),
                          border: const OutlineInputBorder(),
                        ),
                        items: _administrationMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(_getLocalizedAdministrationMethod(method)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAdministrationMethod = value!;
                          });
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notes card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.additionalNotes,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n.additionalNotesHint,
                          border: const OutlineInputBorder(),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveMedication(medication),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context)!.saveChanges),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMedicationIcon() {
    switch (_selectedAdministrationMethod) {
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
    switch (_selectedAdministrationMethod) {
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

  Future<void> _saveMedication(MedicationEntry originalMedication) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedMedication = originalMedication.copyWith(
        medicationName: _medicationNameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        administrationMethod: _selectedAdministrationMethod,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await ref.read(medicationsProvider.notifier).updateMedication(updatedMedication);

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicationAddedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateMedication),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleMedicationStatus(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(medicationsProvider.notifier).toggleMedicationStatus(medication.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              medication.isActive
                  ? l10n.medicationMarkedInactive
                  : l10n.medicationMarkedActive
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateMedication),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMedication(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedication),
        content: Text(
          l10n.deleteMedicationConfirm(medication.medicationName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref.read(medicationsProvider.notifier).deleteMedication(medication.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.medicationDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeleteMedication),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getLocalizedFrequency(String frequencyKey) {
    final l10n = AppLocalizations.of(context)!;
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

  String _getLocalizedAdministrationMethod(String methodKey) {
    final l10n = AppLocalizations.of(context)!;
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