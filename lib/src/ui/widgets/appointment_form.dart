import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../domain/models/appointment_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/vet_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../utils/snackbar_helper.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

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
        padding: EdgeInsets.all(DesignSpacing.md),
        children: [
          // Appointment basic info card
          _buildSectionCard(
            isDark: isDark,
            surfaceColor: surfaceColor,
            primaryText: primaryText,
            icon: Icons.event,
            title: l10n.appointmentInformation,
            children: [
              // Vet selection or manual entry
              _buildVetSelection(l10n, isDark, surfaceColor, primaryText, secondaryText, disabledColor),

              SizedBox(height: DesignSpacing.md),

              // Reason dropdown
              DropdownButtonFormField<String>(
                value: _selectedReasonKey,
                style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                decoration: InputDecoration(
                  labelText: '${l10n.reason} *',
                  labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: disabledColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: disabledColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: DesignColors.highlightYellow, width: 2),
                  ),
                  prefixIcon: Icon(Icons.medical_services, color: DesignColors.highlightYellow),
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
                      _reasonController.clear();
                      logger.d('[APPOINTMENT] Reason selected from dropdown: $value');
                    } else {
                      logger.d('[APPOINTMENT] Selected "Other (Custom)" - showing text field');
                    }
                  });
                },
                validator: (value) {
                  if (value != null && value != 'other') return null;
                  if (_showCustomReasonField && _reasonController.text.trim().isEmpty) {
                    return l10n.pleaseEnterReason;
                  }
                  if (value == 'other' && _reasonController.text.trim().isNotEmpty) {
                    return null;
                  }
                  if (value == null) {
                    return l10n.pleaseEnterReason;
                  }
                  return null;
                },
              ),

              // Show custom text field if "Other" is selected
              if (_showCustomReasonField) ...[
                SizedBox(height: DesignSpacing.md),
                TextFormField(
                  controller: _reasonController,
                  style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                  decoration: InputDecoration(
                    labelText: l10n.appointmentReasonCustomPlaceholder,
                    labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                    hintText: l10n.reasonHint,
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: disabledColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: disabledColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: DesignColors.highlightYellow, width: 2),
                    ),
                    prefixIcon: Icon(Icons.edit, color: DesignColors.highlightYellow),
                  ),
                  validator: (value) {
                    if (_showCustomReasonField && (value == null || value.trim().isEmpty)) {
                      return l10n.pleaseEnterReason;
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),

          SizedBox(height: DesignSpacing.md),

          // Schedule card
          _buildSectionCard(
            isDark: isDark,
            surfaceColor: surfaceColor,
            primaryText: primaryText,
            icon: Icons.schedule,
            title: l10n.schedule,
            children: [
              // Appointment date
              _buildDateTimeTile(
                icon: Icons.calendar_today,
                title: l10n.appointmentDate,
                subtitle: DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).toString())
                    .format(_appointmentDate),
                onTap: () => _selectAppointmentDate(),
                primaryText: primaryText,
                secondaryText: secondaryText,
              ),

              SizedBox(height: DesignSpacing.sm),

              // Appointment time
              _buildDateTimeTile(
                icon: Icons.access_time,
                title: l10n.appointmentTime,
                subtitle: _appointmentTime.format(context),
                onTap: () => _selectAppointmentTime(),
                primaryText: primaryText,
                secondaryText: secondaryText,
              ),
            ],
          ),

          SizedBox(height: DesignSpacing.md),

          // Status card (only show for existing appointments)
          if (widget.appointment != null)
            _buildSectionCard(
              isDark: isDark,
              surfaceColor: surfaceColor,
              primaryText: primaryText,
              icon: Icons.check_circle_outline,
              title: l10n.status,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: DesignColors.highlightYellow,
                  title: Text(
                    l10n.markAsCompleted,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: primaryText),
                  ),
                  subtitle: Text(
                    _isCompleted ? l10n.appointmentCompleted : l10n.appointmentPending,
                    style: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                  ),
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value;
                    });
                  },
                ),
              ],
            ),

          if (widget.appointment != null) SizedBox(height: DesignSpacing.md),

          // Notes card
          _buildSectionCard(
            isDark: isDark,
            surfaceColor: surfaceColor,
            primaryText: primaryText,
            icon: Icons.note,
            title: l10n.additionalNotes,
            children: [
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                decoration: InputDecoration(
                  hintText: l10n.additionalNotesHint,
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: disabledColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: disabledColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: DesignColors.highlightYellow, width: 2),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: DesignSpacing.xl),

          // Action buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => widget.onCancelled?.call(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: disabledColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: DesignSpacing.md),

              // Save button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.highlightYellow,
                      foregroundColor: Colors.white,
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
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildSectionCard({
    required bool isDark,
    required Color surfaceColor,
    required Color primaryText,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DesignColors.highlightYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: DesignColors.highlightYellow),
              ),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateTimeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignColors.highlightYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: DesignColors.highlightYellow, size: 20),
            ),
            SizedBox(width: DesignSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.xs / 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DesignColors.highlightYellow,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: secondaryText),
          ],
        ),
      ),
    );
  }

  Widget _buildVetSelection(
    AppLocalizations l10n,
    bool isDark,
    Color surfaceColor,
    Color primaryText,
    Color secondaryText,
    Color disabledColor,
  ) {
    final vetsAsync = ref.watch(vetsProvider);

    InputDecoration buildInputDecoration({
      required String labelText,
      String? hintText,
      required IconData icon,
    }) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
        hintText: hintText,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(icon, color: DesignColors.highlightYellow),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DesignColors.highlightYellow, width: 2),
        ),
      );
    }

    return vetsAsync.when(
      data: (vets) {
        if (vets.isEmpty || _useManualEntry) {
          // Manual entry mode
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _veterinarianController,
                style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                decoration: buildInputDecoration(
                  labelText: '${l10n.veterinarian} *',
                  hintText: l10n.veterinarianHint,
                  icon: Icons.person,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterVeterinarian;
                  }
                  return null;
                },
              ),
              SizedBox(height: DesignSpacing.md),
              TextFormField(
                controller: _clinicController,
                style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                decoration: buildInputDecoration(
                  labelText: '${l10n.clinic} *',
                  hintText: l10n.clinicHint,
                  icon: Icons.local_hospital,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterClinic;
                  }
                  return null;
                },
              ),
              if (vets.isNotEmpty) ...[
                SizedBox(height: DesignSpacing.sm),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _useManualEntry = false;
                    });
                  },
                  icon: Icon(Icons.arrow_back, color: DesignColors.highlightYellow),
                  label: Text(
                    l10n.selectVet,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: DesignColors.highlightYellow,
                    ),
                  ),
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
              style: GoogleFonts.inter(fontSize: 16, color: primaryText),
              decoration: buildInputDecoration(
                labelText: l10n.selectVet,
                icon: Icons.local_hospital,
              ),
              menuMaxHeight: 300,
              items: [
                ...vets.map((vet) => DropdownMenuItem(
                      value: vet.id,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: DesignSpacing.sm,
                          horizontal: 0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 20,
                              color: DesignColors.highlightYellow,
                            ),
                            SizedBox(width: DesignSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    vet.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: primaryText,
                                    ),
                                  ),
                                  SizedBox(height: DesignSpacing.xs / 2),
                                  Text(
                                    vet.clinicName,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: secondaryText,
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
            SizedBox(height: DesignSpacing.sm),
            Wrap(
              spacing: DesignSpacing.sm,
              runSpacing: DesignSpacing.sm,
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
                  icon: Icon(Icons.edit, color: DesignColors.highlightYellow, size: 18),
                  label: Text(
                    l10n.enterManually,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: DesignColors.highlightYellow,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm + 4,
                      vertical: DesignSpacing.sm,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to veterinarian list where user can add new vet
                    context.push('/vet-list');
                  },
                  icon: Icon(Icons.add, color: DesignColors.highlightYellow, size: 18),
                  label: Text(
                    l10n.addNewVet,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: DesignColors.highlightYellow,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm + 4,
                      vertical: DesignSpacing.sm,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: DesignColors.highlightYellow),
      ),
      error: (_, __) => Column(
        children: [
          TextFormField(
            controller: _veterinarianController,
            style: GoogleFonts.inter(fontSize: 16, color: primaryText),
            decoration: buildInputDecoration(
              labelText: '${l10n.veterinarian} *',
              hintText: l10n.veterinarianHint,
              icon: Icons.person,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterVeterinarian;
              }
              return null;
            },
          ),
          SizedBox(height: DesignSpacing.md),
          TextFormField(
            controller: _clinicController,
            style: GoogleFonts.inter(fontSize: 16, color: primaryText),
            decoration: buildInputDecoration(
              labelText: '${l10n.clinic} *',
              hintText: l10n.clinicHint,
              icon: Icons.local_hospital,
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
      SnackBarHelper.showWarning(context, l10n.noActivePetFound);
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
        // Invalidate provider to refresh list
        ref.invalidate(appointmentsByPetIdProvider(activePet.id));
        if (mounted) {
          SnackBarHelper.showSuccess(context, l10n.appointmentUpdatedSuccessfully);
        }
      } else {
        // Add new appointment
        await ref
            .read(appointmentProviderProvider.notifier)
            .addAppointment(appointment);
        // Invalidate provider to refresh list
        ref.invalidate(appointmentsByPetIdProvider(activePet.id));
        if (mounted) {
          SnackBarHelper.showSuccess(context, l10n.appointmentAddedSuccessfully);
        }
      }

      if (mounted) {
        widget.onSaved?.call();
      }
    } catch (error) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          l10n.failedToSaveAppointment(error.toString()),
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
