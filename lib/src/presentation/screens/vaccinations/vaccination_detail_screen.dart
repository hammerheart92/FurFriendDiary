// File: lib/src/presentation/screens/vaccinations/vaccination_detail_screen.dart
// Purpose: Display detailed information about a specific vaccination event including
//          veterinary details, certificate photos, and protocol information

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../domain/models/vaccination_event.dart';
import '../../../domain/constants/vaccine_type_translations.dart';
import '../../providers/vaccinations_provider.dart';

class VaccinationDetailScreen extends ConsumerWidget {
  final String vaccinationId;

  const VaccinationDetailScreen({
    super.key,
    required this.vaccinationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final vaccinationsAsync = ref.watch(vaccinationProviderProvider);

    return vaccinationsAsync.when(
      data: (vaccinations) {
        // Find the vaccination event by ID
        final vaccination = vaccinations.firstWhere(
          (v) => v.id == vaccinationId,
          orElse: () => throw Exception(l10n.vaccinationNotFound),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.vaccinationDetails),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
            actions: [
              // Edit button - navigate to edit screen
              IconButton(
                onPressed: () {
                  context.push(
                    '/vaccinations/edit/${vaccination.id}',
                    extra: vaccination,
                  );
                },
                icon: const Icon(Icons.edit),
                tooltip: l10n.edit,
              ),
              // Delete button with confirmation
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteVaccination(context, ref, vaccination);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.delete),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _buildDetailView(context, theme, l10n, vaccination),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.errorLoadingVaccinations),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.errorLoadingVaccinations),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(vaccinationProviderProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card: Vaccine type with status badge
          _buildHeaderCard(context, theme, l10n, vaccination),

          const SizedBox(height: 16),

          // Dates Card: Administered date and next due date
          _buildDatesCard(context, theme, l10n, vaccination),

          const SizedBox(height: 16),

          // Veterinary Details Card (if any data exists)
          if (_hasVeterinaryDetails(vaccination))
            _buildVeterinaryDetailsCard(context, theme, l10n, vaccination),

          if (_hasVeterinaryDetails(vaccination)) const SizedBox(height: 16),

          // Certificate Photos Card (if any photos exist)
          if (vaccination.certificatePhotoUrls != null &&
              vaccination.certificatePhotoUrls!.isNotEmpty)
            _buildCertificatePhotosCard(
                context, theme, l10n, vaccination.certificatePhotoUrls!),

          if (vaccination.certificatePhotoUrls != null &&
              vaccination.certificatePhotoUrls!.isNotEmpty)
            const SizedBox(height: 16),

          // Notes Card (if notes exist)
          if (vaccination.notes != null && vaccination.notes!.isNotEmpty)
            _buildNotesCard(context, theme, l10n, vaccination),

          if (vaccination.notes != null && vaccination.notes!.isNotEmpty)
            const SizedBox(height: 16),

          // Protocol Info Card (if vaccination is from protocol)
          if (vaccination.isFromProtocol)
            _buildProtocolInfoCard(context, theme, l10n, vaccination),
        ],
      ),
    );
  }

  // ============================================================================
  // Header Card: Vaccine type with status badge
  // ============================================================================
  Widget _buildHeaderCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
  ) {
    final status = _getVaccinationStatus(vaccination);
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(l10n, status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Vaccine icon with colored background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.vaccines,
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vaccine type as title
                  // ISSUE 3 FIX: Display translated vaccine type name
                  Text(
                    VaccineTypeTranslations.getDisplayName(
                      vaccination.vaccineType,
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  // ============================================================================
  // Dates Card: Administered date and next due date
  // ============================================================================
  Widget _buildDatesCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
  ) {
    final dateFormat = DateFormat('MMMM dd, yyyy',
        Localizations.localeOf(context).toString());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dates,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Administered date
            _buildDetailRow(
              l10n.administeredDate,
              dateFormat.format(vaccination.administeredDate),
              Icons.calendar_today,
              theme,
            ),
            // Next due date (if exists)
            if (vaccination.nextDueDate != null)
              _buildDetailRow(
                l10n.nextDueDate,
                dateFormat.format(vaccination.nextDueDate!),
                Icons.event_available,
                theme,
              )
            else
              _buildDetailRow(
                l10n.dueStatus,
                l10n.completed,
                Icons.check_circle,
                theme,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Veterinary Details Card: Vet name, clinic, batch number
  // ============================================================================
  Widget _buildVeterinaryDetailsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.veterinaryDetails,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (vaccination.veterinarianName != null &&
                vaccination.veterinarianName!.isNotEmpty)
              _buildDetailRow(
                l10n.veterinarianName,
                vaccination.veterinarianName!,
                Icons.person,
                theme,
              ),
            if (vaccination.clinicName != null &&
                vaccination.clinicName!.isNotEmpty)
              _buildDetailRow(
                l10n.clinicName,
                vaccination.clinicName!,
                Icons.local_hospital,
                theme,
              ),
            if (vaccination.batchNumber != null &&
                vaccination.batchNumber!.isNotEmpty)
              _buildDetailRow(
                l10n.batchNumber,
                vaccination.batchNumber!,
                Icons.qr_code,
                theme,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Certificate Photos Card: Display photos in grid
  // ============================================================================
  Widget _buildCertificatePhotosCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    List<String> photoUrls,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.certificatePhotos,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display photos in a grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photoUrls.length,
              itemBuilder: (context, index) {
                final photoPath = photoUrls[index];
                return _buildPhotoThumbnail(context, photoPath);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, String photoPath) {
    return GestureDetector(
      onTap: () {
        // Open full-screen photo viewer (could be implemented later)
        _showPhotoDialog(context, photoPath);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(photoPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPhotoDialog(BuildContext context, String photoPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              File(photoPath),
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 64,
                    ),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Notes Card: Display notes text with locale-aware translation
  // ============================================================================
  Widget _buildNotesCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
  ) {
    // Use Romanian notes if locale is Romanian and notesRo is available
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';
    print('💉 [DETAIL] Locale: ${locale.languageCode}');
    print('💉 [DETAIL] notes: ${vaccination.notes}');
    print('💉 [DETAIL] notesRo: ${vaccination.notesRo}');
    print('💉 [DETAIL] Displaying: ${isRomanian && vaccination.notesRo != null && vaccination.notesRo!.isNotEmpty ? vaccination.notesRo : vaccination.notes}');
    final notes = (isRomanian && vaccination.notesRo != null && vaccination.notesRo!.isNotEmpty)
        ? vaccination.notesRo!
        : vaccination.notes!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.notes,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notes,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Protocol Info Card: Shows if vaccination was generated from protocol
  // ============================================================================
  Widget _buildProtocolInfoCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
  ) {
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.protocolInformation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.generatedFromProtocol,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (vaccination.protocolStepIndex != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.doseNumber(vaccination.protocolStepIndex! + 1),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Helper: Build detail row with icon, label, and value
  // ============================================================================
  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Helper: Check if vaccination has any veterinary details
  // ============================================================================
  bool _hasVeterinaryDetails(VaccinationEvent vaccination) {
    return (vaccination.veterinarianName != null &&
            vaccination.veterinarianName!.isNotEmpty) ||
        (vaccination.clinicName != null &&
            vaccination.clinicName!.isNotEmpty) ||
        (vaccination.batchNumber != null &&
            vaccination.batchNumber!.isNotEmpty);
  }

  // ============================================================================
  // Helper: Get vaccination status (Overdue, Upcoming, Completed)
  // ============================================================================
  VaccinationStatus _getVaccinationStatus(VaccinationEvent vaccination) {
    if (vaccination.nextDueDate == null) {
      return VaccinationStatus.completed;
    }

    final today = DateTime.now();
    final dueDate = vaccination.nextDueDate!;

    if (dueDate.isBefore(DateTime(today.year, today.month, today.day))) {
      return VaccinationStatus.overdue;
    } else {
      return VaccinationStatus.upcoming;
    }
  }

  // ============================================================================
  // Helper: Get status color based on vaccination status
  // ============================================================================
  Color _getStatusColor(VaccinationStatus status) {
    switch (status) {
      case VaccinationStatus.overdue:
        return Colors.red;
      case VaccinationStatus.upcoming:
        return Colors.blue;
      case VaccinationStatus.completed:
        return Colors.green;
    }
  }

  // ============================================================================
  // Helper: Get status label based on vaccination status
  // ============================================================================
  String _getStatusLabel(AppLocalizations l10n, VaccinationStatus status) {
    switch (status) {
      case VaccinationStatus.overdue:
        return l10n.overdue;
      case VaccinationStatus.upcoming:
        return l10n.upcoming;
      case VaccinationStatus.completed:
        return l10n.completed;
    }
  }

  // ============================================================================
  // Action: Delete vaccination with confirmation dialog
  // ============================================================================
  Future<void> _deleteVaccination(
    BuildContext context,
    WidgetRef ref,
    VaccinationEvent vaccination,
  ) async {
    final l10n = AppLocalizations.of(context);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteVaccination),
        content: Text(
          l10n.deleteVaccinationConfirm(vaccination.vaccineType),
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

    if (shouldDelete == true && context.mounted) {
      try {
        await ref
            .read(vaccinationProviderProvider.notifier)
            .deleteVaccination(vaccination.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.vaccinationDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeleteVaccination),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// ============================================================================
// Enum: Vaccination status for UI display
// ============================================================================
enum VaccinationStatus {
  overdue,
  upcoming,
  completed,
}
