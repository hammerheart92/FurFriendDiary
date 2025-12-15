import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/medication_entry.dart';
import '../../providers/medications_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

class MedicationDetailScreen extends ConsumerStatefulWidget {
  final String medicationId;

  const MedicationDetailScreen({
    super.key,
    required this.medicationId,
  });

  @override
  ConsumerState<MedicationDetailScreen> createState() =>
      _MedicationDetailScreenState();
}

class _MedicationDetailScreenState
    extends ConsumerState<MedicationDetailScreen> {
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
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
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              _isEditing ? l10n.editMedication : l10n.medicationDetails,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            backgroundColor: surfaceColor,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryText),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
              tooltip: 'Back',
            ),
            actions: [
              if (_isEditing)
                TextButton(
                  onPressed: _isLoading ? null : () => _saveMedication(medication),
                  child: Text(
                    l10n.save,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: DesignColors.highlightTeal,
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
                  icon: Icon(Icons.edit, color: DesignColors.highlightTeal),
                  tooltip: 'Edit medication',
                ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: secondaryText),
                color: surfaceColor,
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
                          color: medication.isActive
                              ? (isDark ? DesignColors.dWarning : DesignColors.lWarning)
                              : (isDark ? DesignColors.dSuccess : DesignColors.lSuccess),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          medication.isActive ? l10n.markInactive : l10n.markActive,
                          style: GoogleFonts.inter(color: primaryText),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: isDark ? DesignColors.dDanger : DesignColors.lDanger),
                        const SizedBox(width: 8),
                        Text(
                          l10n.delete,
                          style: GoogleFonts.inter(color: isDark ? DesignColors.dDanger : DesignColors.lDanger),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: DesignColors.highlightTeal))
              : _isEditing
                  ? _buildEditForm(context, medication)
                  : _buildDetailView(context, medication),
        );
      },
      loading: () => Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: DesignColors.highlightTeal)),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            l10n.errorLoadingMedications,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          backgroundColor: surfaceColor,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryText),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Back',
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: isDark ? DesignColors.dDanger : DesignColors.lDanger),
              SizedBox(height: DesignSpacing.md),
              Text(
                l10n.errorLoadingMedications,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              ElevatedButton(
                onPressed: () => ref.refresh(medicationsProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.highlightTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.retry,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, MedicationEntry medication) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        children: [
          // Header card with medication info
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
            ),
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _getMedicationColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getMedicationIcon(),
                      color: _getMedicationColor(),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.medicationName,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: medication.isActive
                                ? successColor.withOpacity(0.15)
                                : secondaryText.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            medication.isActive ? l10n.active : l10n.inactive,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: medication.isActive ? successColor : secondaryText,
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

          SizedBox(height: DesignSpacing.md),

          // Basic information card
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
            ),
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.basicInformation,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),
                  _buildDetailRow(l10n.dosage, medication.dosage, Icons.straighten, primaryText, secondaryText),
                  _buildDetailRow(l10n.frequency, _getLocalizedFrequency(medication.frequency), Icons.schedule, primaryText, secondaryText),
                  _buildDetailRow(l10n.administrationMethod, _getLocalizedAdministrationMethod(medication.administrationMethod), Icons.medical_services, primaryText, secondaryText),
                ],
              ),
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Schedule card
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
            ),
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.schedule,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),
                  _buildDetailRow(
                    l10n.startDate,
                    DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).toString()).format(medication.startDate),
                    Icons.calendar_today,
                    primaryText,
                    secondaryText,
                  ),
                  if (medication.endDate != null)
                    _buildDetailRow(
                      l10n.endDate,
                      DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).toString()).format(medication.endDate!),
                      Icons.event_available,
                      primaryText,
                      secondaryText,
                    )
                  else
                    _buildDetailRow(l10n.duration, l10n.ongoing, Icons.all_inclusive, primaryText, secondaryText),
                ],
              ),
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Administration times card
          if (medication.administrationTimes.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: Padding(
                padding: EdgeInsets.all(DesignSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.administrationTimes,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: medication.administrationTimes.map((time) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSpacing.md,
                            vertical: DesignSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: DesignColors.highlightTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: DesignColors.highlightTeal,
                              ),
                              SizedBox(width: 4),
                              Text(
                                time.format24Hour(),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: DesignColors.highlightTeal,
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
            SizedBox(height: DesignSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: Padding(
                padding: EdgeInsets.all(DesignSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes,
                          color: DesignColors.highlightTeal,
                          size: 20,
                        ),
                        SizedBox(width: DesignSpacing.sm),
                        Text(
                          l10n.additionalNotes,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: DesignSpacing.sm),
                    Text(
                      medication.notes!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: DesignSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, MedicationEntry medication) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    InputDecoration buildInputDecoration({
      required String label,
      required IconData prefixIcon,
      String? hintText,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText.withOpacity(0.6)),
        prefixIcon: Icon(prefixIcon, color: DesignColors.highlightTeal),
        filled: true,
        fillColor: backgroundColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DesignColors.highlightTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? DesignColors.dDanger : DesignColors.lDanger, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? DesignColors.dDanger : DesignColors.lDanger, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.md),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(DesignSpacing.md),
        children: [
          // Medication basic info card
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
            ),
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicationInformation,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),

                  // Medication name
                  TextFormField(
                    controller: _medicationNameController,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: buildInputDecoration(
                      label: l10n.medicationName,
                      prefixIcon: Icons.medication,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterMedicationName;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: DesignSpacing.md),

                  // Dosage
                  TextFormField(
                    controller: _dosageController,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: buildInputDecoration(
                      label: l10n.dosage,
                      prefixIcon: Icons.straighten,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterDosage;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: DesignSpacing.md),

                  // Frequency dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedFrequency,
                    dropdownColor: surfaceColor,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: buildInputDecoration(
                      label: l10n.frequency,
                      prefixIcon: Icons.schedule,
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
                  ),

                  SizedBox(height: DesignSpacing.md),

                  // Administration method dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedAdministrationMethod,
                    dropdownColor: surfaceColor,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: buildInputDecoration(
                      label: l10n.administrationMethod,
                      prefixIcon: Icons.medical_services,
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
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Notes card
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
            ),
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.additionalNotes,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    style: GoogleFonts.inter(color: primaryText),
                    decoration: InputDecoration(
                      hintText: l10n.additionalNotesHint,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryText.withOpacity(0.6),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(Icons.notes, color: DesignColors.highlightTeal),
                      ),
                      filled: true,
                      fillColor: backgroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: disabledColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: DesignColors.highlightTeal, width: 2),
                      ),
                      contentPadding: EdgeInsets.all(DesignSpacing.md),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: DesignSpacing.lg),

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
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: secondaryText),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveMedication(medication),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.highlightTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.saveChanges,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),

          SizedBox(height: DesignSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color primaryText, Color secondaryText) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: secondaryText),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryText,
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
        return DesignColors.highlightTeal;
      case 'administrationMethodTopical':
        return DesignColors.highlightPink;
      case 'administrationMethodInjection':
        return DesignColors.highlightPurple;
      case 'administrationMethodEyeDrops':
        return DesignColors.highlightBlue;
      case 'administrationMethodEarDrops':
        return DesignColors.highlightCoral;
      case 'administrationMethodInhaled':
        return DesignColors.highlightYellow;
      default:
        return DesignColors.highlightCoral;
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
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await ref
          .read(medicationsProvider.notifier)
          .updateMedication(updatedMedication);

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
      await ref
          .read(medicationsProvider.notifier)
          .toggleMedicationStatus(medication.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(medication.isActive
                ? l10n.medicationMarkedInactive
                : l10n.medicationMarkedActive),
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
        await ref
            .read(medicationsProvider.notifier)
            .deleteMedication(medication.id);

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
