import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../domain/models/appointment_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/vet_provider.dart';
import '../../../l10n/app_localizations.dart';

class AppointmentForm extends ConsumerStatefulWidget {
  final AppointmentEntry? appointment;
  final VoidCallback? onSaved;
  final VoidCallback? onCancelled;

  const AppointmentForm({
    super.key,
    this.appointment,
    this.onSaved,
    this.onCancelled,
  });

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
  final logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _veterinarianController = TextEditingController();
  final _clinicController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _appointmentDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _appointmentTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isCompleted = false;
  bool _isLoading = false;
  String? _selectedVetId;
  bool _useManualEntry = false;

  // Common appointment reasons
  static const List<String> _commonReasons = [
    'checkup',
    'vaccination',
    'surgery',
    'emergency',
    'followUp',
    'dentalCleaning',
    'grooming',
    'bloodTest',
    'xRay',
    'spayingNeutering',
    'other',
  ];

  String? _selectedReasonKey; // Selected from dropdown (using keys)
  bool _showCustomReasonField = false; // Show text field for custom reason

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final appointment = widget.appointment!;
    _veterinarianController.text = appointment.veterinarian;
    _clinicController.text = appointment.clinic;
    _notesController.text = appointment.notes ?? '';
    _appointmentDate = appointment.appointmentDate;
    _appointmentTime = TimeOfDay.fromDateTime(appointment.appointmentTime);
    _isCompleted = appointment.isCompleted;
    _selectedVetId = appointment.vetId;
    _useManualEntry = appointment.vetId == null;

    // Detect if existing reason matches a dropdown option
    final existingReason = appointment.reason;
    logger.d('[APPOINTMENT] Loading existing reason: $existingReason');

    // Set the text controller with existing reason
    // This will be used for custom reasons or initial display
    _reasonController.text = existingReason;

    // Reason key detection will happen in build method with actual localization
    logger.d('[APPOINTMENT] Will detect reason key match in build method');
  }

  @override
  void dispose() {
    _veterinarianController.dispose();
    _clinicController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Get localized appointment reason name
  String _getLocalizedReason(String reasonKey, AppLocalizations l10n) {
    switch (reasonKey) {
      case 'checkup':
        return l10n.appointmentReasonCheckup;
      case 'vaccination':
        return l10n.appointmentReasonVaccination;
      case 'surgery':
        return l10n.appointmentReasonSurgery;
      case 'emergency':
        return l10n.appointmentReasonEmergency;
      case 'followUp':
        return l10n.appointmentReasonFollowUp;
      case 'dentalCleaning':
        return l10n.appointmentReasonDentalCleaning;
      case 'grooming':
        return l10n.appointmentReasonGrooming;
      case 'bloodTest':
        return l10n.appointmentReasonBloodTest;
      case 'xRay':
        return l10n.appointmentReasonXRay;
      case 'spayingNeutering':
        return l10n.appointmentReasonSpayingNeutering;
      case 'other':
        return l10n.appointmentReasonOther;
      default:
        return reasonKey;
    }
  }

  /// Detect which reason key matches the existing reason value
  String? _detectReasonKey(String existingReason, AppLocalizations l10n) {
    for (final reasonKey in _commonReasons) {
      final localizedValue = _getLocalizedReason(reasonKey, l10n);
      if (existingReason.toLowerCase() == localizedValue.toLowerCase()) {
        logger.d(
            '[APPOINTMENT] Matched existing reason "$existingReason" to key: $reasonKey');
        return reasonKey;
      }
    }
    // No match found - it's a custom reason
    logger.d(
        '[APPOINTMENT] No match for "$existingReason" - will use "other" with custom text');
    return 'other';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // In edit mode, detect the reason key if not already set
    if (widget.appointment != null && _selectedReasonKey == null) {
      final detectedKey = _detectReasonKey(widget.appointment!.reason, l10n);
      _selectedReasonKey = detectedKey;
      _showCustomReasonField = (detectedKey == 'other');

      if (detectedKey == 'other') {
        // It's a custom reason, populate the text field
        _reasonController.text = widget.appointment!.reason;
      }
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appointment basic info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appointmentInformation,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vet selection or manual entry
                  _buildVetSelection(l10n),

                  const SizedBox(height: 16),

                  // Reason dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedReasonKey,
                    decoration: InputDecoration(
                      labelText: '${l10n.reason} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.medical_services),
                    ),
                    items: _commonReasons.map((reasonKey) {
                      return DropdownMenuItem(
                        value: reasonKey == 'other' ? 'other' : reasonKey,
                        child: Text(_getLocalizedReason(reasonKey, l10n)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedReasonKey = value;
                        _showCustomReasonField = (value == 'other');

                        if (value != 'other') {
                          // If user selected from dropdown, clear custom field
                          _reasonController.clear();
                          logger.d(
                              '[APPOINTMENT] Reason selected from dropdown: $value');
                        } else {
                          logger.d(
                              '[APPOINTMENT] Selected "Other (Custom)" - showing text field');
                        }
                      });
                    },
                    validator: (value) {
                      // If dropdown has value and it's not "other", it's valid
                      if (value != null && value != 'other') return null;

                      // If "Other" is selected, check the text field
                      if (_showCustomReasonField &&
                          _reasonController.text.trim().isEmpty) {
                        return l10n.pleaseEnterReason;
                      }

                      // If "other" is selected and text field has value, it's valid
                      if (value == 'other' &&
                          _reasonController.text.trim().isNotEmpty) {
                        return null;
                      }

                      // No selection made
                      if (value == null) {
                        return l10n.pleaseEnterReason;
                      }

                      return null;
                    },
                  ),

                  // Show custom text field if "Other" is selected
                  if (_showCustomReasonField) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        labelText: l10n.appointmentReasonCustomPlaceholder,
                        hintText: l10n.reasonHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.edit),
                      ),
                      validator: (value) {
                        if (_showCustomReasonField &&
                            (value == null || value.trim().isEmpty)) {
                          return l10n.pleaseEnterReason;
                        }
                        return null;
                      },
                    ),
                  ],
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
                    l10n.schedule,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Appointment date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(l10n.appointmentDate),
                    subtitle: Text(DateFormat('MMMM dd, yyyy',
                            Localizations.localeOf(context).toString())
                        .format(_appointmentDate)),
                    onTap: () => _selectAppointmentDate(),
                  ),

                  // Appointment time
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: Text(l10n.appointmentTime),
                    subtitle: Text(_appointmentTime.format(context)),
                    onTap: () => _selectAppointmentTime(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status card (only show for existing appointments)
          if (widget.appointment != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.status,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Completed toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.markAsCompleted),
                      subtitle: Text(_isCompleted
                          ? l10n.appointmentCompleted
                          : l10n.appointmentPending),
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

          if (widget.appointment != null) const SizedBox(height: 16),

          // Notes card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.additionalNotes,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.additionalNotesHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            widget.onCancelled?.call();
                          },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Save button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.appointment != null
                                ? l10n.updateAppointment
                                : l10n.saveAppointment,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVetSelection(AppLocalizations l10n) {
    final vetsAsync = ref.watch(vetsProvider);

    return vetsAsync.when(
      data: (vets) {
        if (vets.isEmpty || _useManualEntry) {
          // Manual entry mode
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _veterinarianController,
                decoration: InputDecoration(
                  labelText: '${l10n.veterinarian} *',
                  hintText: l10n.veterinarianHint,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterVeterinarian;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clinicController,
                decoration: InputDecoration(
                  labelText: '${l10n.clinic} *',
                  hintText: l10n.clinicHint,
                  prefixIcon: const Icon(Icons.local_hospital),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterClinic;
                  }
                  return null;
                },
              ),
              if (vets.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _useManualEntry = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.selectVet),
                ),
              ],
            ],
          );
        }

        // Vet selection mode
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedVetId,
              isExpanded: true,
              isDense: false,
              itemHeight: 56,
              decoration: InputDecoration(
                labelText: l10n.selectVet,
                prefixIcon: const Icon(Icons.local_hospital),
                border: const OutlineInputBorder(),
              ),
              menuMaxHeight: 300,
              items: [
                ...vets.map((vet) => DropdownMenuItem(
                      value: vet.id,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.medical_services,
                              size: 20,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    vet.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    vet.clinicName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedVetId = value;
                  if (value != null) {
                    final selectedVet = vets.firstWhere((v) => v.id == value);
                    _veterinarianController.text = selectedVet.name;
                    _clinicController.text = selectedVet.clinicName;
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return l10n.pleaseEnterVeterinarian;
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _useManualEntry = true;
                      _selectedVetId = null;
                      _veterinarianController.clear();
                      _clinicController.clear();
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.enterManually),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to veterinarian list where user can add new vet
                    context.push('/vet-list');
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addNewVet),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => Column(
        children: [
          TextFormField(
            controller: _veterinarianController,
            decoration: InputDecoration(
              labelText: '${l10n.veterinarian} *',
              hintText: l10n.veterinarianHint,
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterVeterinarian;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _clinicController,
            decoration: InputDecoration(
              labelText: '${l10n.clinic} *',
              hintText: l10n.clinicHint,
              prefixIcon: const Icon(Icons.local_hospital),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterClinic;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectAppointmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _appointmentDate = picked;
      });
    }
  }

  Future<void> _selectAppointmentTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _appointmentTime,
    );

    if (picked != null) {
      setState(() {
        _appointmentTime = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final activePet = ref.read(currentPetProfileProvider);
    final l10n = AppLocalizations.of(context);

    if (activePet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noActivePetFound),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time
      final appointmentDateTime = DateTime(
        _appointmentDate.year,
        _appointmentDate.month,
        _appointmentDate.day,
        _appointmentTime.hour,
        _appointmentTime.minute,
      );

      // Determine the final reason value
      String finalReason;
      if (_selectedReasonKey != null && _selectedReasonKey != 'other') {
        // Use localized dropdown value
        finalReason = _getLocalizedReason(_selectedReasonKey!, l10n);
        logger.d(
            '[APPOINTMENT] Saving with dropdown reason: $finalReason (key: $_selectedReasonKey)');
      } else {
        // Use custom text
        finalReason = _reasonController.text.trim();
        logger.d('[APPOINTMENT] Saving with custom reason: $finalReason');
      }

      final appointment = AppointmentEntry(
        id: widget.appointment?.id,
        petId: activePet.id,
        veterinarian: _veterinarianController.text.trim(),
        clinic: _clinicController.text.trim(),
        appointmentDate: _appointmentDate,
        appointmentTime: appointmentDateTime,
        reason: finalReason,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isCompleted: _isCompleted,
        createdAt: widget.appointment?.createdAt,
        vetId: _selectedVetId,
      );

      if (widget.appointment != null) {
        // Update existing appointment
        await ref
            .read(appointmentProviderProvider.notifier)
            .updateAppointment(appointment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.appointmentUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new appointment
        await ref
            .read(appointmentProviderProvider.notifier)
            .addAppointment(appointment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.appointmentAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        widget.onSaved?.call();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToSaveAppointment(error.toString())),
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
}
