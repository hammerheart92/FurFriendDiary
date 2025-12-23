import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../utils/snackbar_helper.dart';

class ReportGenerationForm extends ConsumerStatefulWidget {
  final VoidCallback? onGenerated;
  final VoidCallback? onCancelled;

  const ReportGenerationForm({
    super.key,
    this.onGenerated,
    this.onCancelled,
  });

  @override
  ConsumerState<ReportGenerationForm> createState() =>
      _ReportGenerationFormState();
}

class _ReportGenerationFormState extends ConsumerState<ReportGenerationForm> {
  final _formKey = GlobalKey<FormState>();

  String _reportType = 'Health Summary';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _reportTypes = [
    'Health Summary',
    'Medication History',
    'Activity Report',
    'Veterinary Records',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor =
        isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return Container(
      color: backgroundColor,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            top: DesignSpacing.md,
            bottom: DesignSpacing.xl,
          ),
          children: [
            // Report Configuration Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportConfiguration,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),

                  // Report Type label
                  Text(
                    '${l10n.reportType} *',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: secondaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.sm),

                  // Report type dropdown
                  DropdownButtonFormField<String>(
                    value: _reportType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.md,
                        vertical: DesignSpacing.md,
                      ),
                      prefixIcon: Icon(
                        _getReportTypeIcon(_reportType),
                        color: DesignColors.highlightTeal,
                      ),
                    ),
                    dropdownColor: surfaceColor,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: primaryText,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: secondaryText,
                    ),
                    items: _reportTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _getReportTypeIcon(type),
                              color: DesignColors.highlightTeal,
                              size: 20,
                            ),
                            SizedBox(width: DesignSpacing.sm),
                            Text(_getLocalizedReportType(type, l10n)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _reportType = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseSelectReportType;
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: DesignSpacing.md),

                  // Info box (dynamic based on report type)
                  Container(
                    padding: EdgeInsets.all(DesignSpacing.md),
                    decoration: BoxDecoration(
                      color: DesignColors.highlightTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: DesignColors.highlightTeal,
                        ),
                        SizedBox(width: DesignSpacing.sm),
                        Expanded(
                          child: Text(
                            _getReportTypeDescription(_reportType, l10n),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: DesignSpacing.md),

            // Date Range Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dateRange,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),

                  // Start Date field
                  InkWell(
                    onTap: () => _selectStartDate(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(DesignSpacing.md),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: DesignColors.highlightTeal,
                            size: 20,
                          ),
                          SizedBox(width: DesignSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.startDate,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMMM dd, yyyy').format(_startDate),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: primaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: DesignSpacing.md),

                  // End Date field
                  InkWell(
                    onTap: () => _selectEndDate(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(DesignSpacing.md),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: DesignColors.highlightTeal,
                            size: 20,
                          ),
                          SizedBox(width: DesignSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.endDate,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMMM dd, yyyy').format(_endDate),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: primaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Date range validation error
                  if (_endDate.isBefore(_startDate))
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.md),
                      margin: EdgeInsets.only(top: DesignSpacing.md),
                      decoration: BoxDecoration(
                        color: dangerColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 20,
                            color: dangerColor,
                          ),
                          SizedBox(width: DesignSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.endDateMustBeAfterStartDate,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: dangerColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: DesignSpacing.md),

            // Quick Ranges Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickRanges,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),
                  Wrap(
                    spacing: DesignSpacing.sm,
                    runSpacing: DesignSpacing.sm,
                    children: [
                      _buildQuickRangeButton(l10n.last7Days, 7, primaryText, secondaryText),
                      _buildQuickRangeButton(l10n.last30Days, 30, primaryText, secondaryText),
                      _buildQuickRangeButton(l10n.last3Months, 90, primaryText, secondaryText),
                      _buildQuickRangeButton(l10n.last6Months, 180, primaryText, secondaryText),
                      _buildQuickRangeButton(l10n.lastYear, 365, primaryText, secondaryText),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: DesignSpacing.lg),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              widget.onCancelled?.call();
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: secondaryText,
                        padding: EdgeInsets.symmetric(
                          vertical: DesignSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: DesignSpacing.md),

                  // Generate Report button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading || _endDate.isBefore(_startDate)
                          ? null
                          : _generateReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColors.highlightTeal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            DesignColors.highlightTeal.withOpacity(0.5),
                        padding: EdgeInsets.symmetric(
                          vertical: DesignSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.generateReport,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRangeButton(
    String label,
    int days,
    Color primaryText,
    Color secondaryText,
  ) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _startDate = DateTime.now().subtract(Duration(days: days));
          _endDate = DateTime.now();
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryText,
        side: BorderSide(color: secondaryText.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getReportTypeIcon(String type) {
    switch (type) {
      case 'Health Summary':
        return Icons.favorite_outline;
      case 'Medication History':
        return Icons.medication_outlined;
      case 'Activity Report':
        return Icons.directions_walk_outlined;
      case 'Veterinary Records':
        return Icons.local_hospital_outlined;
      default:
        return Icons.assessment_outlined;
    }
  }

  String _getLocalizedReportType(String type, AppLocalizations l10n) {
    switch (type) {
      case 'Health Summary':
        return l10n.healthSummary;
      case 'Medication History':
        return l10n.medicationHistory;
      case 'Activity Report':
        return l10n.activityReport;
      case 'Veterinary Records':
        return l10n.veterinaryRecords;
      default:
        return type;
    }
  }

  String _getReportTypeDescription(String type, AppLocalizations l10n) {
    switch (type) {
      case 'Health Summary':
        return l10n.healthSummaryDescription;
      case 'Medication History':
        return l10n.medicationHistoryDescription;
      case 'Activity Report':
        return l10n.activityReportDescription;
      case 'Veterinary Records':
        return l10n.veterinaryRecordsDescription;
      default:
        return l10n.selectReportTypeDescription;
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Ensure end date is not before start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _generateReport() async {
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
      // Generate report data based on type
      final reportData = await _generateReportData(_reportType, activePet.id);

      final report = ReportEntry(
        petId: activePet.id,
        reportType: _reportType,
        startDate: _startDate,
        endDate: _endDate,
        data: reportData,
        filters: {
          'reportType': _reportType,
          'startDate': _startDate.toIso8601String(),
          'endDate': _endDate.toIso8601String(),
        },
      );

      await ref.read(reportProviderProvider.notifier).addReport(report);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        SnackBarHelper.showSuccess(context, l10n.reportGeneratedSuccessfully);
        widget.onGenerated?.call();
      }
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        SnackBarHelper.showError(
          context,
          l10n.failedToGenerateReport(error.toString()),
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

  Future<Map<String, dynamic>> _generateReportData(
      String reportType, String petId) async {
    // Get data from providers
    final medications =
        await ref.read(medicationsByPetIdProvider(petId).future);
    final appointments =
        await ref.read(appointmentsByPetIdProvider(petId).future);
    final feedings = await ref.read(feedingsByPetIdProvider(petId).future);

    // Filter data by date range
    final filteredMedications = medications
        .where((med) =>
            med.startDate
                .isAfter(_startDate.subtract(const Duration(days: 1))) &&
            med.startDate.isBefore(_endDate.add(const Duration(days: 1))))
        .toList();

    final filteredAppointments = appointments
        .where((apt) =>
            apt.appointmentDate
                .isAfter(_startDate.subtract(const Duration(days: 1))) &&
            apt.appointmentDate.isBefore(_endDate.add(const Duration(days: 1))))
        .toList();

    final filteredFeedings = feedings
        .where((feed) =>
            feed.dateTime
                .isAfter(_startDate.subtract(const Duration(days: 1))) &&
            feed.dateTime.isBefore(_endDate.add(const Duration(days: 1))))
        .toList();

    switch (reportType) {
      case 'Health Summary':
        return {
          'medications': filteredMedications.map((m) => m.toJson()).toList(),
          'appointments': filteredAppointments.map((a) => a.toJson()).toList(),
          'feedings': filteredFeedings.map((f) => f.toJson()).toList(),
          'summary': {
            'totalMedications': filteredMedications.length,
            'activeMedications':
                filteredMedications.where((m) => m.isActive).length,
            'totalAppointments': filteredAppointments.length,
            'completedAppointments':
                filteredAppointments.where((a) => a.isCompleted).length,
            'totalFeedings': filteredFeedings.length,
          },
        };

      case 'Medication History':
        return {
          'medications': filteredMedications.map((m) => m.toJson()).toList(),
          'summary': {
            'totalMedications': filteredMedications.length,
            'activeMedications':
                filteredMedications.where((m) => m.isActive).length,
            'inactiveMedications':
                filteredMedications.where((m) => !m.isActive).length,
            'medicationsByMethod':
                _groupMedicationsByMethod(filteredMedications),
          },
        };

      case 'Activity Report':
        return {
          'feedings': filteredFeedings.map((f) => f.toJson()).toList(),
          'summary': {
            'totalFeedings': filteredFeedings.length,
            'averageFeedingsPerDay': filteredFeedings.length /
                (_endDate.difference(_startDate).inDays + 1),
            'feedingsByType': _groupFeedingsByType(filteredFeedings),
          },
        };

      case 'Veterinary Records':
        return {
          'appointments': filteredAppointments.map((a) => a.toJson()).toList(),
          'summary': {
            'totalAppointments': filteredAppointments.length,
            'completedAppointments':
                filteredAppointments.where((a) => a.isCompleted).length,
            'pendingAppointments':
                filteredAppointments.where((a) => !a.isCompleted).length,
            'appointmentsByReason':
                _groupAppointmentsByReason(filteredAppointments),
          },
        };

      default:
        return {};
    }
  }

  Map<String, int> _groupMedicationsByMethod(List<dynamic> medications) {
    final Map<String, int> grouped = {};
    for (final med in medications) {
      final method = med.administrationMethod as String;
      grouped[method] = (grouped[method] ?? 0) + 1;
    }
    return grouped;
  }

  Map<String, int> _groupFeedingsByType(List<dynamic> feedings) {
    final Map<String, int> grouped = {};
    for (final feed in feedings) {
      final type = feed.foodType as String;
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }

  Map<String, int> _groupAppointmentsByReason(List<dynamic> appointments) {
    final Map<String, int> grouped = {};
    for (final apt in appointments) {
      final reason = apt.reason as String;
      grouped[reason] = (grouped[reason] ?? 0) + 1;
    }
    return grouped;
  }
}
