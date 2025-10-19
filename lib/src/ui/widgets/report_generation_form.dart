import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../../l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Report Type card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportConfiguration,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Report type dropdown
                  DropdownButtonFormField<String>(
                    value: _reportType,
                    decoration: InputDecoration(
                      labelText: '${l10n.reportType} *',
                      prefixIcon: const Icon(Icons.assessment),
                      border: const OutlineInputBorder(),
                    ),
                    items: _reportTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getLocalizedReportType(type, l10n)),
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

                  const SizedBox(height: 16),

                  // Report type description
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getReportTypeDescription(_reportType, l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
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

          const SizedBox(height: 16),

          // Date Range card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dateRange,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Start date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.date_range),
                    title: Text(l10n.startDate),
                    subtitle:
                        Text(DateFormat('MMMM dd, yyyy').format(_startDate)),
                    onTap: () => _selectStartDate(),
                  ),

                  // End date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event),
                    title: Text(l10n.endDate),
                    subtitle:
                        Text(DateFormat('MMMM dd, yyyy').format(_endDate)),
                    onTap: () => _selectEndDate(),
                  ),

                  // Date range validation
                  if (_endDate.isBefore(_startDate))
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 20,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.endDateMustBeAfterStartDate,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick date range shortcuts
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickRanges,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickRangeChip(l10n.last7Days, 7),
                      _buildQuickRangeChip(l10n.last30Days, 30),
                      _buildQuickRangeChip(l10n.last3Months, 90),
                      _buildQuickRangeChip(l10n.last6Months, 180),
                      _buildQuickRangeChip(l10n.lastYear, 365),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            widget.onCancelled?.call();
                          },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Generate button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading || _endDate.isBefore(_startDate)
                        ? null
                        : _generateReport,
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
                            l10n.generateReport,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildQuickRangeChip(String label, int days) {
    final theme = Theme.of(context);
    final isSelected = _startDate
            .isAtSameMomentAs(DateTime.now().subtract(Duration(days: days))) &&
        _endDate.isAtSameMomentAs(DateTime.now());

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _startDate = DateTime.now().subtract(Duration(days: days));
            _endDate = DateTime.now();
          });
        }
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reportGeneratedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        widget.onGenerated?.call();
      }
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToGenerateReport(error.toString())),
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
