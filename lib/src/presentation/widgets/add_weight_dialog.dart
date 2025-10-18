import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/src/domain/models/weight_entry.dart';
import 'package:fur_friend_diary/src/presentation/providers/weight_provider.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';

class AddWeightDialog extends ConsumerStatefulWidget {
  final WeightEntry? existingEntry;

  const AddWeightDialog({super.key, this.existingEntry});

  @override
  ConsumerState<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends ConsumerState<AddWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.existingEntry?.weight.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingEntry?.notes ?? '',
    );
    _selectedDate = widget.existingEntry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.existingEntry == null ? l10n.addWeight : l10n.editWeight),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Weight input
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: l10n.weight,
                  suffixText: 'kg',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterWeight;
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return l10n.pleaseEnterValidWeight;
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                title: Text(l10n.date),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              const SizedBox(height: 16),

              // Notes input
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  hintText: l10n.optionalNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveWeight,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _saveWeight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentPet = ref.read(currentPetProfileProvider);
      if (currentPet == null) {
        throw Exception('No pet selected');
      }

      final weight = double.parse(_weightController.text);
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      final entry = widget.existingEntry?.copyWith(
        weight: weight,
        date: _selectedDate,
        notes: notes,
      ) ?? WeightEntry(
        petId: currentPet.id,
        weight: weight,
        date: _selectedDate,
        notes: notes,
      );

      final repository = ref.read(weightRepositoryProvider);
      if (widget.existingEntry == null) {
        await repository.addWeightEntry(entry);
      } else {
        await repository.updateWeightEntry(entry);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingEntry == null
                  ? AppLocalizations.of(context).weightAdded
                  : AppLocalizations.of(context).weightUpdated,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

