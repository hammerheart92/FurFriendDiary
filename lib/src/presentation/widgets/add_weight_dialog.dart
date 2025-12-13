import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/src/domain/models/weight_entry.dart';
import 'package:fur_friend_diary/src/presentation/providers/weight_provider.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final borderColor =
        isDark ? DesignColors.dDisabled : DesignColors.lDisabled;
    final fillColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: surfaceColor,
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  widget.existingEntry == null
                      ? l10n.addWeight
                      : l10n.editWeight,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DesignSpacing.lg),

                // Weight Input with Teal Label
                _buildLabel(l10n.weight, primaryText),
                SizedBox(height: DesignSpacing.xs),
                TextFormField(
                  controller: _weightController,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: primaryText,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: '0.0',
                    suffixText: 'kg',
                    fillColor: fillColor,
                    borderColor: borderColor,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                SizedBox(height: DesignSpacing.md),

                // Date Picker
                _buildLabel(l10n.date, primaryText),
                SizedBox(height: DesignSpacing.xs),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(DesignSpacing.md),
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: DesignColors.highlightTeal,
                        ),
                        SizedBox(width: DesignSpacing.sm),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: DesignSpacing.md),

                // Notes Input
                _buildLabel(l10n.notes, secondaryText),
                SizedBox(height: DesignSpacing.xs),
                TextFormField(
                  controller: _notesController,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: primaryText,
                  ),
                  decoration: _buildInputDecoration(
                    hintText: l10n.optionalNotes,
                    fillColor: fillColor,
                    borderColor: borderColor,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: DesignSpacing.lg),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: secondaryText,
                          side: BorderSide(color: borderColor),
                          padding:
                              EdgeInsets.symmetric(vertical: DesignSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    SizedBox(width: DesignSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveWeight,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignColors.highlightTeal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              DesignColors.highlightTeal.withOpacity(0.5),
                          padding:
                              EdgeInsets.symmetric(vertical: DesignSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.save,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: DesignColors.highlightTeal,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    String? hintText,
    String? suffixText,
    required Color fillColor,
    required Color borderColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        color: Theme.of(context).brightness == Brightness.dark
            ? DesignColors.dSecondaryText
            : DesignColors.lSecondaryText,
      ),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DesignColors.highlightTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DesignColors.lDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DesignColors.lDanger, width: 2),
      ),
      contentPadding: EdgeInsets.all(DesignSpacing.md),
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
          ) ??
          WeightEntry(
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
              style: GoogleFonts.inter(),
            ),
            backgroundColor: DesignColors.highlightTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: DesignColors.lDanger,
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
