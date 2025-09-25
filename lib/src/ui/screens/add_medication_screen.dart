import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/medications_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../domain/models/time_of_day_model.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedFrequency = 'Once daily';
  String _selectedAdministrationMethod = 'Oral';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasEndDate = false;
  List<TimeOfDay> _administrationTimes = [const TimeOfDay(hour: 8, minute: 0)];

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every other day',
    'Weekly',
    'As needed',
    'Custom',
  ];

  final List<String> _administrationMethods = [
    'Oral',
    'Topical',
    'Injection',
    'Eye drops',
    'Ear drops',
    'Inhaled',
    'Other',
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: Text(
              'Save',
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
                            'Medication Information',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Medication name
                          TextFormField(
                            controller: _medicationNameController,
                            decoration: const InputDecoration(
                              labelText: 'Medication Name *',
                              hintText: 'e.g., Apoquel, Heartgard',
                              prefixIcon: Icon(Icons.medication),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter medication name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Dosage
                          TextFormField(
                            controller: _dosageController,
                            decoration: const InputDecoration(
                              labelText: 'Dosage *',
                              hintText: 'e.g., 5mg, 1 tablet, 2ml',
                              prefixIcon: Icon(Icons.straighten),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter dosage';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Frequency dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedFrequency,
                            decoration: const InputDecoration(
                              labelText: 'Frequency *',
                              prefixIcon: Icon(Icons.schedule),
                              border: OutlineInputBorder(),
                            ),
                            items: _frequencies.map((frequency) {
                              return DropdownMenuItem(
                                value: frequency,
                                child: Text(frequency),
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
                            decoration: const InputDecoration(
                              labelText: 'Administration Method *',
                              prefixIcon: Icon(Icons.medical_services),
                              border: OutlineInputBorder(),
                            ),
                            items: _administrationMethods.map((method) {
                              return DropdownMenuItem(
                                value: method,
                                child: Text(method),
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
                            'Schedule',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Start date
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Start Date'),
                            subtitle: Text(DateFormat('MMMM dd, yyyy').format(_startDate)),
                            onTap: () => _selectStartDate(),
                          ),

                          // End date toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Has End Date'),
                            subtitle: _hasEndDate && _endDate != null
                                ? Text(DateFormat('MMMM dd, yyyy').format(_endDate!))
                                : const Text('Ongoing medication'),
                            value: _hasEndDate,
                            onChanged: (value) {
                              setState(() {
                                _hasEndDate = value;
                                if (!value) {
                                  _endDate = null;
                                } else {
                                  _endDate = _startDate.add(const Duration(days: 30));
                                }
                              });
                            },
                          ),

                          // End date selector
                          if (_hasEndDate)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.event_available),
                              title: const Text('End Date'),
                              subtitle: _endDate != null
                                  ? Text(DateFormat('MMMM dd, yyyy').format(_endDate!))
                                  : const Text('Select end date'),
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
                                'Administration Times',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedFrequency == 'Custom')
                                IconButton(
                                  onPressed: _addAdministrationTime,
                                  icon: const Icon(Icons.add),
                                  tooltip: 'Add time',
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
                              title: Text('Time ${index + 1}'),
                              subtitle: Text(time.format(context)),
                              trailing: _selectedFrequency == 'Custom' && _administrationTimes.length > 1
                                  ? IconButton(
                                      onPressed: () => _removeAdministrationTime(index),
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
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
                            'Additional Notes',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Add any additional notes, instructions, or reminders...',
                              border: OutlineInputBorder(),
                            ),
                          ),
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
                          : const Text(
                              'Save Medication',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        case 'Once daily':
          _administrationTimes = [const TimeOfDay(hour: 8, minute: 0)];
          break;
        case 'Twice daily':
          _administrationTimes = [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ];
          break;
        case 'Three times daily':
          _administrationTimes = [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 14, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ];
          break;
        case 'Four times daily':
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

    if (activePet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active pet found. Please select a pet first.'),
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

      await ref.read(medicationsProvider.notifier).addMedication(
        petId: activePet.id,
        medicationName: _medicationNameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        startDate: _startDate,
        endDate: _endDate,
        administrationMethod: _selectedAdministrationMethod,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        administrationTimes: administrationTimeModels,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add medication: $error'),
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