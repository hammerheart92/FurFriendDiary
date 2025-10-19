import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/reminder.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../../l10n/app_localizations.dart';

class AddReminderSheet extends ConsumerStatefulWidget {
  final ReminderType? prefilledType;
  final String? prefilledTitle;
  final String? prefilledDescription;
  final String? linkedEntityId;
  final DateTime? scheduledTime;

  const AddReminderSheet({
    super.key,
    this.prefilledType,
    this.prefilledTitle,
    this.prefilledDescription,
    this.linkedEntityId,
    this.scheduledTime,
  });

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  ReminderType _selectedType = ReminderType.medication;
  ReminderFrequency _selectedFrequency = ReminderFrequency.once;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.prefilledTitle);
    _descriptionController =
        TextEditingController(text: widget.prefilledDescription);

    if (widget.prefilledType != null) {
      _selectedType = widget.prefilledType!;
    }

    if (widget.scheduledTime != null) {
      _selectedDate = widget.scheduledTime!;
      _selectedTime = TimeOfDay.fromDateTime(widget.scheduledTime!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.addReminder,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Reminder Type
                DropdownButtonFormField<ReminderType>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: l10n.reminderType,
                    border: const OutlineInputBorder(),
                  ),
                  items: ReminderType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getReminderTypeLabel(type, l10n)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.reminderTitle,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterTitle;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description (optional)
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.reminderDescription,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Date Picker
                ListTile(
                  title: Text(l10n.date),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),

                // Time Picker
                ListTile(
                  title: Text(l10n.timeLabel),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                ),
                const SizedBox(height: 16),

                // Frequency
                DropdownButtonFormField<ReminderFrequency>(
                  initialValue: _selectedFrequency,
                  decoration: InputDecoration(
                    labelText: l10n.frequency,
                    border: const OutlineInputBorder(),
                  ),
                  items: ReminderFrequency.values.map((freq) {
                    return DropdownMenuItem(
                      value: freq,
                      child: Text(_getFrequencyLabel(freq, l10n)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFrequency = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Active toggle
                SwitchListTile(
                  title: Text(l10n.active),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() => _isActive = value);
                  },
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveReminder,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentPet = ref.read(currentPetProfileProvider);
      if (currentPet == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No pet selected'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final reminder = Reminder(
        petId: currentPet.id,
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        scheduledTime: scheduledDateTime,
        frequency: _selectedFrequency,
        isActive: _isActive,
        linkedEntityId: widget.linkedEntityId,
      );

      await ref.read(reminderNotifierProvider.notifier).addReminder(reminder);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getReminderTypeLabel(ReminderType type, AppLocalizations l10n) {
    switch (type) {
      case ReminderType.medication:
        return l10n.medicationReminder;
      case ReminderType.appointment:
        return l10n.appointmentReminder;
      case ReminderType.feeding:
        return l10n.feedingReminder;
      case ReminderType.walk:
        return l10n.walkReminder;
    }
  }

  String _getFrequencyLabel(ReminderFrequency freq, AppLocalizations l10n) {
    switch (freq) {
      case ReminderFrequency.once:
        return l10n.once;
      case ReminderFrequency.daily:
        return l10n.daily;
      case ReminderFrequency.twiceDaily:
        return l10n.twiceDaily;
      case ReminderFrequency.weekly:
        return l10n.weekly;
      case ReminderFrequency.custom:
        return l10n.custom;
    }
  }
}
