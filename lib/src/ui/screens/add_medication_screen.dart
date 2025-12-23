import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/medications_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../domain/models/time_of_day_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../utils/snackbar_helper.dart';

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

  // Helper method for input decoration
  InputDecoration _buildInputDecoration({
    required String label,
    required IconData prefixIcon,
    String? hintText,
    String? helperText,
    String? prefixText,
    required bool isDark,
    required Color secondaryText,
    required Color disabledColor,
    required Color surfaceColor,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      prefixText: prefixText,
      labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText.withOpacity(0.6)),
      prefixIcon: Icon(prefixIcon, color: DesignColors.highlightTeal),
      filled: true,
      fillColor: surfaceColor,
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

  // Helper method for date picker tiles
  Widget _buildDateTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryText,
    required Color secondaryText,
    required Color backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: secondaryText.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignColors.highlightTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: DesignColors.highlightTeal,
                size: 20,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: secondaryText,
            ),
          ],
        ),
      ),
    );
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
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.addMedication,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: Text(
              l10n.save,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: DesignColors.highlightTeal,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: DesignColors.highlightTeal))
          : Form(
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
                            decoration: _buildInputDecoration(
                              label: l10n.medicationName,
                              hintText: l10n.medicationNameHint,
                              prefixIcon: Icons.medication,
                              isDark: isDark,
                              secondaryText: secondaryText,
                              disabledColor: disabledColor,
                              surfaceColor: backgroundColor,
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
                            decoration: _buildInputDecoration(
                              label: l10n.dosage,
                              hintText: l10n.dosageHint,
                              prefixIcon: Icons.straighten,
                              isDark: isDark,
                              secondaryText: secondaryText,
                              disabledColor: disabledColor,
                              surfaceColor: backgroundColor,
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
                            decoration: _buildInputDecoration(
                              label: l10n.frequency,
                              prefixIcon: Icons.schedule,
                              isDark: isDark,
                              secondaryText: secondaryText,
                              disabledColor: disabledColor,
                              surfaceColor: backgroundColor,
                            ),
                            items: _frequencies.map((frequency) {
                              return DropdownMenuItem(
                                value: frequency,
                                child: Text(_getLocalizedFrequency(l10n, frequency)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFrequency = value!;
                                _updateAdministrationTimes();
                              });
                            },
                          ),

                          SizedBox(height: DesignSpacing.md),

                          // Administration method dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedAdministrationMethod,
                            dropdownColor: surfaceColor,
                            style: GoogleFonts.inter(color: primaryText),
                            decoration: _buildInputDecoration(
                              label: l10n.administrationMethod,
                              prefixIcon: Icons.medical_services,
                              isDark: isDark,
                              secondaryText: secondaryText,
                              disabledColor: disabledColor,
                              surfaceColor: backgroundColor,
                            ),
                            items: _administrationMethods.map((method) {
                              return DropdownMenuItem(
                                value: method,
                                child: Text(_getLocalizedAdministrationMethod(l10n, method)),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          SizedBox(height: DesignSpacing.md),

                          // Start date
                          _buildDateTile(
                            icon: Icons.calendar_today,
                            title: l10n.startDate,
                            subtitle: DateFormat('MMMM dd, yyyy').format(_startDate),
                            onTap: () => _selectStartDate(),
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                            backgroundColor: backgroundColor,
                          ),

                          SizedBox(height: DesignSpacing.sm),

                          // End date toggle
                          Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
                              title: Text(
                                l10n.hasEndDate,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: primaryText,
                                ),
                              ),
                              subtitle: Text(
                                _hasEndDate && _endDate != null
                                    ? DateFormat('MMMM dd, yyyy').format(_endDate!)
                                    : l10n.ongoingMedication,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: secondaryText,
                                ),
                              ),
                              value: _hasEndDate,
                              activeColor: DesignColors.highlightTeal,
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
                          ),

                          // End date selector
                          if (_hasEndDate) ...[
                            SizedBox(height: DesignSpacing.sm),
                            _buildDateTile(
                              icon: Icons.event_available,
                              title: l10n.endDate,
                              subtitle: _endDate != null
                                  ? DateFormat('MMMM dd, yyyy').format(_endDate!)
                                  : l10n.selectEndDate,
                              onTap: () => _selectEndDate(),
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                              backgroundColor: backgroundColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: DesignSpacing.md),

                  // Administration times card
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
                              Text(
                                l10n.administrationTimes,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedFrequency == 'frequencyCustom')
                                IconButton(
                                  onPressed: _addAdministrationTime,
                                  icon: Icon(Icons.add_circle, color: DesignColors.highlightTeal),
                                  tooltip: l10n.addTime,
                                ),
                            ],
                          ),
                          SizedBox(height: DesignSpacing.md),

                          // List of administration times
                          ..._administrationTimes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final time = entry.value;
                            return Container(
                              margin: EdgeInsets.only(bottom: DesignSpacing.sm),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: secondaryText.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: DesignColors.highlightTeal.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.access_time,
                                    color: DesignColors.highlightTeal,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  l10n.time(index + 1),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: secondaryText,
                                  ),
                                ),
                                subtitle: Text(
                                  time.format(context),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),
                                trailing: _selectedFrequency == 'frequencyCustom' &&
                                        _administrationTimes.length > 1
                                    ? IconButton(
                                        onPressed: () => _removeAdministrationTime(index),
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
                                        ),
                                      )
                                    : Icon(Icons.chevron_right, color: secondaryText),
                                onTap: () => _selectAdministrationTime(index),
                              ),
                            );
                          }),

                          // Add time button (for custom frequency)
                          if (_selectedFrequency == 'frequencyCustom') ...[
                            SizedBox(height: DesignSpacing.sm),
                            OutlinedButton.icon(
                              onPressed: _addAdministrationTime,
                              icon: Icon(Icons.add, color: DesignColors.highlightTeal),
                              label: Text(
                                l10n.addTime,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: DesignColors.highlightTeal,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: DesignColors.highlightTeal),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: DesignSpacing.md,
                                  vertical: DesignSpacing.sm,
                                ),
                              ),
                            ),
                          ],
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

                  SizedBox(height: DesignSpacing.md),

                  // Inventory Tracking Card
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
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: DesignColors.highlightPurple.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: DesignColors.highlightPurple,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: DesignSpacing.sm),
                              Expanded(
                                child: Text(
                                  l10n.inventoryTracking,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _enableInventoryTracking,
                                activeColor: DesignColors.highlightTeal,
                                onChanged: (value) {
                                  setState(() {
                                    _enableInventoryTracking = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_enableInventoryTracking) ...[
                            SizedBox(height: DesignSpacing.sm),
                            Text(
                              '${l10n.optional} - Track medication stock levels',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                            ),
                            SizedBox(height: DesignSpacing.md),

                            // Stock Quantity & Unit
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Initial Stock field
                                TextFormField(
                                  controller: _stockQuantityController,
                                  style: GoogleFonts.inter(color: primaryText),
                                  decoration: _buildInputDecoration(
                                    label: l10n.initialStock,
                                    hintText: '30',
                                    prefixIcon: Icons.numbers,
                                    isDark: isDark,
                                    secondaryText: secondaryText,
                                    disabledColor: disabledColor,
                                    surfaceColor: backgroundColor,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: DesignSpacing.sm),
                                // Stock Unit dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedStockUnit,
                                  dropdownColor: surfaceColor,
                                  style: GoogleFonts.inter(color: primaryText),
                                  decoration: _buildInputDecoration(
                                    label: l10n.stockUnit,
                                    prefixIcon: Icons.category,
                                    isDark: isDark,
                                    secondaryText: secondaryText,
                                    disabledColor: disabledColor,
                                    surfaceColor: backgroundColor,
                                  ),
                                  isExpanded: true,
                                  items: [
                                    DropdownMenuItem(value: 'pills', child: Text(l10n.pills)),
                                    DropdownMenuItem(value: 'tablets', child: Text(l10n.tablets)),
                                    DropdownMenuItem(value: 'ml', child: Text(l10n.ml)),
                                    DropdownMenuItem(value: 'doses', child: Text(l10n.doses)),
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

                            SizedBox(height: DesignSpacing.md),

                            // Low Stock Threshold
                            TextFormField(
                              controller: _lowStockThresholdController,
                              style: GoogleFonts.inter(color: primaryText),
                              decoration: _buildInputDecoration(
                                label: l10n.lowStockThreshold,
                                hintText: '5',
                                helperText: 'Alert when stock falls below this level',
                                prefixIcon: Icons.warning_amber,
                                isDark: isDark,
                                secondaryText: secondaryText,
                                disabledColor: disabledColor,
                                surfaceColor: backgroundColor,
                              ),
                              keyboardType: TextInputType.number,
                            ),

                            SizedBox(height: DesignSpacing.md),

                            // Cost Per Unit
                            TextFormField(
                              controller: _costPerUnitController,
                              style: GoogleFonts.inter(color: primaryText),
                              decoration: _buildInputDecoration(
                                label: '${l10n.costPerUnit} (${l10n.optional})',
                                hintText: '1.50',
                                prefixText: '\$ ',
                                prefixIcon: Icons.attach_money,
                                isDark: isDark,
                                secondaryText: secondaryText,
                                disabledColor: disabledColor,
                                surfaceColor: backgroundColor,
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),

                            SizedBox(height: DesignSpacing.md),

                            // Refill Reminders Toggle
                            Container(
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
                                value: _enableRefillReminders,
                                activeColor: DesignColors.highlightTeal,
                                onChanged: (value) {
                                  setState(() {
                                    _enableRefillReminders = value;
                                  });
                                },
                                title: Text(
                                  l10n.enableRefillReminders,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: primaryText,
                                  ),
                                ),
                                subtitle: Text(
                                  l10n.refillReminderDays,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                            ),

                            if (_enableRefillReminders) ...[
                              SizedBox(height: DesignSpacing.sm),
                              TextFormField(
                                controller: _refillReminderDaysController,
                                style: GoogleFonts.inter(color: primaryText),
                                decoration: _buildInputDecoration(
                                  label: l10n.daysBeforeEmpty,
                                  hintText: '3',
                                  helperText: 'Get reminded X days before medication runs out',
                                  prefixIcon: Icons.notification_important,
                                  isDark: isDark,
                                  secondaryText: secondaryText,
                                  disabledColor: disabledColor,
                                  surfaceColor: backgroundColor,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: DesignSpacing.lg),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMedication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColors.highlightTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              l10n.saveMedication,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: DesignSpacing.lg),
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
      SnackBarHelper.showWarning(context, l10n.noActivePetFound);
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

      // Prepare notes
      String? finalNotes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      await ref.read(medicationsProvider.notifier).addMedication(
            petId: activePet.id,
            medicationName: _medicationNameController.text.trim(),
            dosage: _dosageController.text.trim(),
            frequency: _selectedFrequency,
            startDate: _startDate,
            endDate: _endDate,
            administrationMethod: _selectedAdministrationMethod,
            notes: finalNotes,
            administrationTimes: administrationTimeModels,
            stockQuantity: stockQuantity,
            stockUnit: _enableInventoryTracking ? _selectedStockUnit : null,
            lowStockThreshold: lowStockThreshold,
            costPerUnit: costPerUnit,
            refillReminderDays: refillReminderDays,
          );

      if (mounted) {
        SnackBarHelper.showSuccess(context, l10n.medicationAddedSuccessfully);
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          l10n.failedToAddMedication(error.toString()),
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
