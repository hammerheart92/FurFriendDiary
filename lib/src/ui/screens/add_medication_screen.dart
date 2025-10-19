import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/medications_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../domain/models/time_of_day_model.dart';
import '../../../l10n/app_localizations.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  // Inventory tracking controllers
  final _stockQuantityController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _costPerUnitController = TextEditingController();
  final _refillReminderDaysController = TextEditingController();

  String _selectedFrequency = 'frequencyOnceDaily';
  String _selectedAdministrationMethod = 'administrationMethodOral';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasEndDate = false;
  List<TimeOfDay> _administrationTimes = [const TimeOfDay(hour: 8, minute: 0)];

  // Inventory tracking state
  bool _enableInventoryTracking = false;
  String _selectedStockUnit = 'pills';
  bool _enableRefillReminders = false;

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

  bool _isLoading = false;

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    _stockQuantityController.dispose();
    _lowStockThresholdController.dispose();
    _costPerUnitController.dispose();
    _refillReminderDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addMedication),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                            l10n.medicationInformation,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Medication name
                          TextFormField(
                            controller: _medicationNameController,
                            decoration: InputDecoration(
                              labelText: l10n.medicationName,
                              hintText: l10n.medicationNameHint,
                              prefixIcon: const Icon(Icons.medication),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.pleaseEnterMedicationName;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Dosage
                          TextFormField(
                            controller: _dosageController,
                            decoration: InputDecoration(
                              labelText: l10n.dosage,
                              hintText: l10n.dosageHint,
                              prefixIcon: const Icon(Icons.straighten),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.pleaseEnterDosage;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Frequency dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedFrequency,
                            decoration: InputDecoration(
                              labelText: l10n.frequency,
                              prefixIcon: const Icon(Icons.schedule),
                              border: const OutlineInputBorder(),
                            ),
                            items: _frequencies.map((frequency) {
                              return DropdownMenuItem(
                                value: frequency,
                                child: Text(
                                    _getLocalizedFrequency(l10n, frequency)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFrequency = value!;
                                _updateAdministrationTimes();
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Administration method dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedAdministrationMethod,
                            decoration: InputDecoration(
                              labelText: l10n.administrationMethod,
                              prefixIcon: const Icon(Icons.medical_services),
                              border: const OutlineInputBorder(),
                            ),
                            items: _administrationMethods.map((method) {
                              return DropdownMenuItem(
                                value: method,
                                child: Text(_getLocalizedAdministrationMethod(
                                    l10n, method)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAdministrationMethod = value!;
                              });
                            },
                          ),
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

                          // Start date
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today),
                            title: Text(l10n.startDate),
                            subtitle: Text(
                                DateFormat('MMMM dd, yyyy').format(_startDate)),
                            onTap: () => _selectStartDate(),
                          ),

                          // End date toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.hasEndDate),
                            subtitle: _hasEndDate && _endDate != null
                                ? Text(DateFormat('MMMM dd, yyyy')
                                    .format(_endDate!))
                                : Text(l10n.ongoingMedication),
                            value: _hasEndDate,
                            onChanged: (value) {
                              setState(() {
                                _hasEndDate = value;
                                if (!value) {
                                  _endDate = null;
                                } else {
                                  _endDate =
                                      _startDate.add(const Duration(days: 30));
                                }
                              });
                            },
                          ),

                          // End date selector
                          if (_hasEndDate)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.event_available),
                              title: Text(l10n.endDate),
                              subtitle: _endDate != null
                                  ? Text(DateFormat('MMMM dd, yyyy')
                                      .format(_endDate!))
                                  : Text(l10n.selectEndDate),
                              onTap: () => _selectEndDate(),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Administration times card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.administrationTimes,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedFrequency == 'frequencyCustom')
                                IconButton(
                                  onPressed: _addAdministrationTime,
                                  icon: const Icon(Icons.add),
                                  tooltip: l10n.addTime,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // List of administration times
                          ..._administrationTimes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final time = entry.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.access_time),
                              title: Text(l10n.time(index + 1)),
                              subtitle: Text(time.format(context)),
                              trailing:
                                  _selectedFrequency == 'frequencyCustom' &&
                                          _administrationTimes.length > 1
                                      ? IconButton(
                                          onPressed: () =>
                                              _removeAdministrationTime(index),
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                        )
                                      : null,
                              onTap: () => _selectAdministrationTime(index),
                            );
                          }).toList(),
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

                  const SizedBox(height: 16),

                  // Inventory Tracking Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.inventoryTracking,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _enableInventoryTracking,
                                onChanged: (value) {
                                  setState(() {
                                    _enableInventoryTracking = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_enableInventoryTracking) ...[
                            const SizedBox(height: 16),
                            Text(
                              '${l10n.optional} - Track medication stock levels',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Stock Quantity & Unit
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Initial Stock field - full width
                                TextFormField(
                                  controller: _stockQuantityController,
                                  decoration: InputDecoration(
                                    labelText: l10n.initialStock,
                                    hintText: '30',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 16),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                // Stock Unit dropdown - full width
                                DropdownButtonFormField<String>(
                                  value: _selectedStockUnit,
                                  decoration: InputDecoration(
                                    labelText: l10n.stockUnit,
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 16),
                                  ),
                                  isExpanded:
                                      true, // CRITICAL: Makes dropdown expand to fill width
                                  items: [
                                    DropdownMenuItem(
                                        value: 'pills',
                                        child: Text(l10n.pills)),
                                    DropdownMenuItem(
                                        value: 'tablets',
                                        child: Text(l10n.tablets)),
                                    DropdownMenuItem(
                                        value: 'ml', child: Text(l10n.ml)),
                                    DropdownMenuItem(
                                        value: 'doses',
                                        child: Text(l10n.doses)),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedStockUnit = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Low Stock Threshold
                            TextFormField(
                              controller: _lowStockThresholdController,
                              decoration: InputDecoration(
                                labelText: l10n.lowStockThreshold,
                                hintText: '5',
                                helperText:
                                    'Alert when stock falls below this level',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 16),

                            // Cost Per Unit
                            TextFormField(
                              controller: _costPerUnitController,
                              decoration: InputDecoration(
                                labelText:
                                    '${l10n.costPerUnit} (${l10n.optional})',
                                hintText: '1.50',
                                prefixText: '\$ ',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),

                            const SizedBox(height: 16),

                            // Refill Reminders Toggle
                            SwitchListTile(
                              value: _enableRefillReminders,
                              onChanged: (value) {
                                setState(() {
                                  _enableRefillReminders = value;
                                });
                              },
                              title: Text(l10n.enableRefillReminders),
                              subtitle: Text(l10n.refillReminderDays),
                            ),

                            if (_enableRefillReminders) ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _refillReminderDaysController,
                                decoration: InputDecoration(
                                  labelText: l10n.daysBeforeEmpty,
                                  hintText: '3',
                                  helperText:
                                      'Get reminded X days before medication runs out',
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMedication,
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
                              l10n.saveMedication,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _updateAdministrationTimes() {
    setState(() {
      switch (_selectedFrequency) {
        case 'frequencyOnceDaily':
          _administrationTimes = [const TimeOfDay(hour: 8, minute: 0)];
          break;
        case 'frequencyTwiceDaily':
          _administrationTimes = [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ];
          break;
        case 'frequencyThreeTimesDaily':
          _administrationTimes = [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 14, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ];
          break;
        case 'frequencyFourTimesDaily':
          _administrationTimes = [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 12, minute: 0),
            const TimeOfDay(hour: 16, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ];
          break;
        default:
          _administrationTimes = [const TimeOfDay(hour: 8, minute: 0)];
      }
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_hasEndDate && _endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectAdministrationTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _administrationTimes[index],
    );

    if (picked != null) {
      setState(() {
        _administrationTimes[index] = picked;
      });
    }
  }

  void _addAdministrationTime() {
    setState(() {
      _administrationTimes.add(const TimeOfDay(hour: 8, minute: 0));
    });
  }

  void _removeAdministrationTime(int index) {
    setState(() {
      _administrationTimes.removeAt(index);
    });
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final activePet = ref.read(currentPetProfileProvider);
    final l10n = AppLocalizations.of(context)!;

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
      // Convert TimeOfDay to TimeOfDayModel
      final administrationTimeModels = _administrationTimes
          .map((time) => TimeOfDayModel.fromTimeOfDay(time))
          .toList();

      // Parse inventory tracking values
      int? stockQuantity;
      int? lowStockThreshold;
      double? costPerUnit;
      int? refillReminderDays;

      if (_enableInventoryTracking) {
        stockQuantity = _stockQuantityController.text.isEmpty
            ? null
            : int.tryParse(_stockQuantityController.text);
        lowStockThreshold = _lowStockThresholdController.text.isEmpty
            ? null
            : int.tryParse(_lowStockThresholdController.text);
        costPerUnit = _costPerUnitController.text.isEmpty
            ? null
            : double.tryParse(_costPerUnitController.text);

        if (_enableRefillReminders) {
          refillReminderDays = _refillReminderDaysController.text.isEmpty
              ? null
              : int.tryParse(_refillReminderDaysController.text);
        }
      }

      await ref.read(medicationsProvider.notifier).addMedication(
            petId: activePet.id,
            medicationName: _medicationNameController.text.trim(),
            dosage: _dosageController.text.trim(),
            frequency: _selectedFrequency,
            startDate: _startDate,
            endDate: _endDate,
            administrationMethod: _selectedAdministrationMethod,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            administrationTimes: administrationTimeModels,
            stockQuantity: stockQuantity,
            stockUnit: _enableInventoryTracking ? _selectedStockUnit : null,
            lowStockThreshold: lowStockThreshold,
            costPerUnit: costPerUnit,
            refillReminderDays: refillReminderDays,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicationAddedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToAddMedication(error.toString())),
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

  String _getLocalizedFrequency(AppLocalizations l10n, String key) {
    switch (key) {
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
        return key;
    }
  }

  String _getLocalizedAdministrationMethod(AppLocalizations l10n, String key) {
    switch (key) {
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
        return key;
    }
  }
}
