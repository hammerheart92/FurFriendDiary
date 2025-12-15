// File: lib/src/presentation/screens/vaccinations/vaccination_detail_screen.dart
// Purpose: Display detailed information about a specific vaccination event including
//          veterinary details, certificate photos, and protocol information

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';
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

    // Design tokens
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return vaccinationsAsync.when(
      data: (vaccinations) {
        // Find the vaccination event by ID
        final vaccination = vaccinations.firstWhere(
          (v) => v.id == vaccinationId,
          orElse: () => throw Exception(l10n.vaccinationNotFound),
        );

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.vaccinationDetails,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            backgroundColor: surfaceColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryText),
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
                icon: Icon(Icons.edit, color: DesignColors.highlightPurple),
                tooltip: l10n.edit,
              ),
              // Delete button with confirmation
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: primaryText),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteVaccination(context, ref, vaccination, isDark);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: dangerColor),
                        SizedBox(width: DesignSpacing.sm),
                        Text(
                          l10n.delete,
                          style: GoogleFonts.inter(color: dangerColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: _buildDetailView(context, l10n, vaccination, isDark),
        );
      },
      loading: () => Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: DesignColors.highlightPurple,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            l10n.errorLoadingVaccinations,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          backgroundColor: surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryText),
            onPressed: () => context.pop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  decoration: BoxDecoration(
                    color: dangerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.error_outline, size: 64, color: dangerColor),
                ),
                SizedBox(height: DesignSpacing.lg),
                Text(
                  l10n.errorLoadingVaccinations,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  error.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DesignSpacing.lg),
                ElevatedButton(
                  onPressed: () => ref.refresh(vaccinationProviderProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.highlightPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.lg,
                      vertical: DesignSpacing.md,
                    ),
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
      ),
    );
  }

  Widget _buildDetailView(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        children: [
          // Header Card: Vaccine type with status badge
          _buildHeaderCard(context, l10n, vaccination, isDark),

          SizedBox(height: DesignSpacing.md),

          // Dates Card: Administered date and next due date
          _buildDatesCard(context, l10n, vaccination, isDark),

          SizedBox(height: DesignSpacing.md),

          // Veterinary Details Card (if any data exists)
          if (_hasVeterinaryDetails(vaccination))
            _buildVeterinaryDetailsCard(context, l10n, vaccination, isDark),

          if (_hasVeterinaryDetails(vaccination)) SizedBox(height: DesignSpacing.md),

          // Certificate Photos Card (if any photos exist)
          if (vaccination.certificatePhotoUrls != null &&
              vaccination.certificatePhotoUrls!.isNotEmpty)
            _buildCertificatePhotosCard(
                context, l10n, vaccination.certificatePhotoUrls!, isDark),

          if (vaccination.certificatePhotoUrls != null &&
              vaccination.certificatePhotoUrls!.isNotEmpty)
            SizedBox(height: DesignSpacing.md),

          // Notes Card (if notes exist)
          if (vaccination.notes != null && vaccination.notes!.isNotEmpty)
            _buildNotesCard(context, l10n, vaccination, isDark),

          if (vaccination.notes != null && vaccination.notes!.isNotEmpty)
            SizedBox(height: DesignSpacing.md),

          // Protocol Info Card (if vaccination is from protocol)
          if (vaccination.isFromProtocol)
            _buildProtocolInfoCard(context, l10n, vaccination, isDark),
        ],
      ),
    );
  }

  // ============================================================================
  // Header Card: Vaccine type with status badge
  // ============================================================================
  Widget _buildHeaderCard(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
    bool isDark,
  ) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    final status = _getVaccinationStatus(vaccination);
    final statusColor = _getStatusColor(status, isDark);
    final statusLabel = _getStatusLabel(l10n, status);

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Row(
        children: [
          // Vaccine icon with colored background
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.vaccines,
              color: statusColor,
              size: 36,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vaccine type as title
                Text(
                  VaccineTypeTranslations.getDisplayName(
                    vaccination.vaccineType,
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.sm),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm + 4,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
  // Dates Card: Administered date and next due date
  // ============================================================================
  Widget _buildDatesCard(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
    bool isDark,
  ) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    final dateFormat =
        DateFormat('MMMM dd, yyyy', Localizations.localeOf(context).toString());

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
              Icon(
                Icons.calendar_month,
                color: DesignColors.highlightPurple,
                size: 24,
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                l10n.dates,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          // Administered date
          _buildDetailRow(
            l10n.administeredDate,
            dateFormat.format(vaccination.administeredDate),
            Icons.calendar_today,
            DesignColors.highlightPurple,
            isDark,
          ),
          // Next due date (if exists)
          if (vaccination.nextDueDate != null)
            _buildDetailRow(
              l10n.nextDueDate,
              dateFormat.format(vaccination.nextDueDate!),
              Icons.event_available,
              DesignColors.highlightBlue,
              isDark,
            )
          else
            _buildDetailRow(
              l10n.dueStatus,
              l10n.completed,
              Icons.check_circle,
              successColor,
              isDark,
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // Veterinary Details Card: Vet name, clinic, batch number
  // ============================================================================
  Widget _buildVeterinaryDetailsCard(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
    bool isDark,
  ) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

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
              Icon(
                Icons.medical_services_outlined,
                color: DesignColors.highlightTeal,
                size: 24,
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                l10n.veterinaryDetails,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          if (vaccination.veterinarianName != null &&
              vaccination.veterinarianName!.isNotEmpty)
            _buildDetailRow(
              l10n.veterinarianName,
              vaccination.veterinarianName!,
              Icons.person_outline,
              DesignColors.highlightTeal,
              isDark,
            ),
          if (vaccination.clinicName != null &&
              vaccination.clinicName!.isNotEmpty)
            _buildDetailRow(
              l10n.clinicName,
              vaccination.clinicName!,
              Icons.local_hospital_outlined,
              DesignColors.highlightTeal,
              isDark,
            ),
          if (vaccination.batchNumber != null &&
              vaccination.batchNumber!.isNotEmpty)
            _buildDetailRow(
              l10n.batchNumber,
              vaccination.batchNumber!,
              Icons.qr_code_2,
              DesignColors.highlightTeal,
              isDark,
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // Certificate Photos Card: Display photos in grid
  // ============================================================================
  Widget _buildCertificatePhotosCard(
    BuildContext context,
    AppLocalizations l10n,
    List<String> photoUrls,
    bool isDark,
  ) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

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
              Icon(
                Icons.photo_library_outlined,
                color: DesignColors.highlightCoral,
                size: 24,
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                l10n.certificatePhotos,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          // Display photos in a grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: DesignSpacing.sm,
              mainAxisSpacing: DesignSpacing.sm,
            ),
            itemCount: photoUrls.length,
            itemBuilder: (context, index) {
              final photoPath = photoUrls[index];
              return _buildPhotoThumbnail(context, photoPath, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, String photoPath, bool isDark) {
    final disabledColor =
        isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    return GestureDetector(
      onTap: () {
        // Open full-screen photo viewer
        _showPhotoDialog(context, photoPath, isDark);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(photoPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: disabledColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.broken_image_outlined,
                color: disabledColor,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPhotoDialog(BuildContext context, String photoPath, bool isDark) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final disabledColor =
        isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.file(
                File(photoPath),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: disabledColor.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: disabledColor,
                        size: 64,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(DesignSpacing.sm),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: DesignColors.highlightPurple,
                ),
                child: Text(
                  MaterialLocalizations.of(context).closeButtonLabel,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
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
    AppLocalizations l10n,
    VaccinationEvent vaccination,
    bool isDark,
  ) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    // Use Romanian notes if locale is Romanian and notesRo is available
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';
    final notes = (isRomanian &&
            vaccination.notesRo != null &&
            vaccination.notesRo!.isNotEmpty)
        ? vaccination.notesRo!
        : vaccination.notes!;

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
              Icon(
                Icons.notes_outlined,
                color: DesignColors.highlightYellow,
                size: 24,
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                l10n.notes,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm + 4),
          Text(
            notes,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Protocol Info Card: Shows if vaccination was generated from protocol
  // ============================================================================
  Widget _buildProtocolInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationEvent vaccination,
    bool isDark,
  ) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignColors.highlightBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignColors.highlightBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: DesignColors.highlightBlue,
                  size: 22,
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                l10n.protocolInformation,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm + 4),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: DesignColors.highlightBlue,
                size: 20,
              ),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: Text(
                  l10n.generatedFromProtocol,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: DesignColors.highlightBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (vaccination.protocolStepIndex != null) ...[
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.doseNumber(vaccination.protocolStepIndex! + 1),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: secondaryText,
              ),
            ),
          ],
        ],
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
    Color iconColor,
    bool isDark,
  ) {
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm + 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          SizedBox(width: DesignSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs / 2),
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
  Color _getStatusColor(VaccinationStatus status, bool isDark) {
    switch (status) {
      case VaccinationStatus.overdue:
        return isDark ? DesignColors.dDanger : DesignColors.lDanger;
      case VaccinationStatus.upcoming:
        return DesignColors.highlightBlue;
      case VaccinationStatus.completed:
        return isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
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
    bool isDark,
  ) async {
    final l10n = AppLocalizations.of(context);
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: dangerColor,
                size: 24,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                l10n.deleteVaccination,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.deleteVaccinationConfirm(vaccination.vaccineType),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: dangerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await ref
            .read(vaccinationProviderProvider.notifier)
            .deleteVaccination(vaccination.id);

        // Invalidate the family provider to refresh the list immediately
        ref.invalidate(vaccinationsByPetIdProvider(vaccination.petId));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.vaccinationDeletedSuccessfully,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          context.pop();
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.failedToDeleteVaccination,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: dangerColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
