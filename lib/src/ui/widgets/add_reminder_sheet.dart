import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
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

  Color _getReminderTypeColor(ReminderType type, bool isDark) {
    switch (type) {
      case ReminderType.medication:
        return DesignColors.highlightPink;
      case ReminderType.appointment:
        return DesignColors.highlightYellow;
      case ReminderType.feeding:
        return isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
      case ReminderType.walk:
        return DesignColors.highlightTeal;
    }
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.appointment:
        return Icons.event;
      case ReminderType.feeding:
        return Icons.restaurant;
      case ReminderType.walk:
        return Icons.pets;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: isDark ? DesignShadows.darkLg : DesignShadows.lg,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
                      decoration: BoxDecoration(
                        color: secondaryText.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header with icon
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: DesignColors.highlightYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: DesignColors.highlightYellow,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.md),
                      Text(
                        l10n.addReminder,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: secondaryText),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSpacing.lg),

                  // Reminder Type Dropdown
                  DropdownButtonFormField<ReminderType>(
                    initialValue: _selectedType,
                    dropdownColor: surfaceColor,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: primaryText,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.reminderType,
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      prefixIcon: Icon(
                        _getReminderTypeIcon(_selectedType),
                        color: _getReminderTypeColor(_selectedType, isDark),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DesignColors.highlightYellow,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: backgroundColor,
                    ),
                    items: ReminderType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _getReminderTypeIcon(type),
                              size: 20,
                              color: _getReminderTypeColor(type, isDark),
                            ),
                            const SizedBox(width: DesignSpacing.sm),
                            Text(_getReminderTypeLabel(type, l10n)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: DesignSpacing.md),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: InputDecoration(
                      labelText: '${l10n.reminderTitle} *',
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      hintText: 'Enter reminder title',
                      hintStyle:
                          GoogleFonts.inter(color: secondaryText.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.title, color: secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DesignColors.highlightYellow,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: backgroundColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterTitle;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: DesignSpacing.md),

                  // Description Field (optional)
                  TextFormField(
                    controller: _descriptionController,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: InputDecoration(
                      labelText: l10n.reminderDescription,
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      hintText: 'Optional notes',
                      hintStyle:
                          GoogleFonts.inter(color: secondaryText.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.notes, color: secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DesignColors.highlightYellow,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: backgroundColor,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: DesignSpacing.md),

                  // Date and Time Row
                  Row(
                    children: [
                      // Date Picker
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.date,
                              labelStyle: GoogleFonts.inter(color: secondaryText),
                              prefixIcon:
                                  Icon(Icons.calendar_today, color: secondaryText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            child: Text(
                              DateFormat.yMMMd().format(_selectedDate),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: primaryText,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.md),
                      // Time Picker
                      Expanded(
                        child: InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.timeLabel,
                              labelStyle: GoogleFonts.inter(color: secondaryText),
                              prefixIcon:
                                  Icon(Icons.access_time, color: secondaryText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            child: Text(
                              _selectedTime.format(context),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: primaryText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignSpacing.md),

                  // Frequency Dropdown
                  DropdownButtonFormField<ReminderFrequency>(
                    initialValue: _selectedFrequency,
                    dropdownColor: surfaceColor,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: primaryText,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.frequency,
                      labelStyle: GoogleFonts.inter(color: secondaryText),
                      prefixIcon: Icon(Icons.repeat, color: secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: DesignColors.highlightYellow,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: backgroundColor,
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
                  const SizedBox(height: DesignSpacing.md),

                  // Active toggle
                  Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: secondaryText.withOpacity(0.3),
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        l10n.active,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: primaryText,
                        ),
                      ),
                      subtitle: Text(
                        _isActive
                            ? l10n.reminderWillFire
                            : l10n.reminderIsPaused,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                      value: _isActive,
                      activeTrackColor: DesignColors.highlightYellow.withOpacity(0.5),
                      activeColor: DesignColors.highlightYellow,
                      inactiveThumbColor: secondaryText.withOpacity(0.5),
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignSpacing.lg),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.of(context).pop(),
                        child: Text(
                          l10n.cancel,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: secondaryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignSpacing.md),
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _saveReminder,
                        style: FilledButton.styleFrom(
                          backgroundColor: DesignColors.highlightYellow,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignSpacing.lg,
                            vertical: DesignSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          l10n.save,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Extra padding at bottom for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: DesignColors.highlightYellow,
              onPrimary: Colors.white,
              surface: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
              onSurface: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: DesignColors.highlightYellow,
              onPrimary: Colors.white,
              surface: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
              onSurface: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    setState(() => _isLoading = true);

    try {
      final currentPet = ref.read(currentPetProfileProvider);
      if (currentPet == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No pet selected',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: dangerColor,
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
            content: Text(
              'Error: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: dangerColor,
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
