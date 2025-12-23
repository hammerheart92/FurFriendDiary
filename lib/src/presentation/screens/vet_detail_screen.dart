import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../domain/models/vet_profile.dart';
import '../../domain/models/appointment_entry.dart';
import '../providers/vet_provider.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../../l10n/app_localizations.dart';
import '../../utils/specialty_helper.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../utils/snackbar_helper.dart';

class VetDetailScreen extends ConsumerWidget {
  final String vetId;

  const VetDetailScreen({super.key, required this.vetId});

  Future<void> _callVet(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        SnackBarHelper.showError(context, AppLocalizations.of(context)!.invalidPhone);
      }
    }
  }

  Future<void> _emailVet(BuildContext context, String? email) async {
    if (email == null || email.isEmpty) return;

    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        SnackBarHelper.showError(context, AppLocalizations.of(context)!.invalidEmail);
      }
    }
  }

  Future<void> _openWebsite(BuildContext context, String? website) async {
    if (website == null || website.isEmpty) return;

    // Add https:// if not present
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        SnackBarHelper.showError(context, AppLocalizations.of(context)!.invalidWebsite);
      }
    }
  }

  Future<void> _deleteVet(
      BuildContext context, WidgetRef ref, VetProfile vet) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: dangerColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete_forever, color: dangerColor),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Text(
                l10n.deleteVet,
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
          l10n.deleteVetConfirm,
          style: GoogleFonts.inter(fontSize: 14, color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontSize: 14,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(vetRepositoryProvider).deleteVet(vet.id);
        // Invalidate providers to refresh list
        ref.invalidate(vetsProvider);
        ref.invalidate(filteredVetsProvider);
        if (context.mounted) {
          SnackBarHelper.showSuccess(context, l10n.vetDeleted);
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showError(context, 'Error: $e');
        }
      }
    }
  }

  Future<void> _togglePreferred(
      BuildContext context, WidgetRef ref, VetProfile vet) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      if (vet.isPreferred) {
        // Cannot unset preferred directly, need to set another vet as preferred
        SnackBarHelper.showWarning(context, l10n.alreadyPreferred);
      } else {
        await ref.read(vetRepositoryProvider).setPreferredVet(vet.id);
        // Invalidate providers to refresh list
        ref.invalidate(vetsProvider);
        ref.invalidate(filteredVetsProvider);
        if (context.mounted) {
          SnackBarHelper.showSuccess(context, '${vet.name} ${AppLocalizations.of(context)!.setAsPreferred}');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    final vet = ref.watch(vetDetailProvider(vetId));

    if (vet == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          title: Text(
            l10n.vetDetails,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
        ),
        body: Center(
          child: Text(
            l10n.vetNotFound,
            style: GoogleFonts.inter(fontSize: 16, color: secondaryText),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          l10n.vetDetails,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: DesignColors.highlightYellow),
            onPressed: () => context.push('/edit-vet/$vetId'),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: dangerColor),
            onPressed: () => _deleteVet(context, ref, vet),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(DesignSpacing.md),
        children: [
          // Header Card
          Container(
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
                    // Vet icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: DesignColors.highlightYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.medical_services,
                        color: DesignColors.highlightYellow,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vet.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                              if (vet.isPreferred)
                                Icon(
                                  Icons.star,
                                  color: DesignColors.highlightYellow,
                                  size: 28,
                                ),
                            ],
                          ),
                          SizedBox(height: DesignSpacing.xs),
                          Text(
                            vet.clinicName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (vet.specialty != null) ...[
                  SizedBox(height: DesignSpacing.md),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm + 4,
                      vertical: DesignSpacing.xs + 2,
                    ),
                    decoration: BoxDecoration(
                      color: DesignColors.highlightTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      SpecialtyHelper.getLocalizedSpecialty(vet.specialty, l10n),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DesignColors.highlightTeal,
                      ),
                    ),
                  ),
                ],
                if (!vet.isPreferred) ...[
                  SizedBox(height: DesignSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _togglePreferred(context, ref, vet),
                      icon: Icon(Icons.star_border, color: DesignColors.highlightYellow),
                      label: Text(
                        l10n.setAsPreferred,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DesignColors.highlightYellow,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: DesignColors.highlightYellow),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.md),

          // Contact Card
          if (vet.phoneNumber != null ||
              vet.email != null ||
              vet.address != null ||
              vet.website != null)
            _buildSectionCard(
              isDark: isDark,
              surfaceColor: surfaceColor,
              primaryText: primaryText,
              icon: Icons.contact_phone,
              title: l10n.contactInformation,
              children: [
                if (vet.phoneNumber != null)
                  _buildContactTile(
                    icon: Icons.phone,
                    title: vet.phoneNumber!,
                    actionIcon: Icons.call,
                    onAction: () => _callVet(context, vet.phoneNumber),
                    color: DesignColors.highlightBlue,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                if (vet.email != null)
                  _buildContactTile(
                    icon: Icons.email,
                    title: vet.email!,
                    actionIcon: Icons.send,
                    onAction: () => _emailVet(context, vet.email),
                    color: DesignColors.highlightPurple,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                if (vet.address != null)
                  _buildContactTile(
                    icon: Icons.location_on,
                    title: vet.address!,
                    color: DesignColors.highlightCoral,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                if (vet.website != null)
                  _buildContactTile(
                    icon: Icons.language,
                    title: vet.website!,
                    actionIcon: Icons.open_in_new,
                    onAction: () => _openWebsite(context, vet.website),
                    color: DesignColors.highlightTeal,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
              ],
            ),
          if (vet.phoneNumber != null ||
              vet.email != null ||
              vet.address != null ||
              vet.website != null)
            SizedBox(height: DesignSpacing.md),

          // Statistics Card
          FutureBuilder<List<AppointmentEntry>>(
            future:
                ref.read(appointmentRepositoryProvider).getAllAppointments(),
            builder: (context, snapshot) {
              final allAppointments = snapshot.data ?? [];
              final vetAppointments =
                  allAppointments.where((apt) => apt.vetId == vetId).toList();

              // Sort by date descending
              vetAppointments.sort(
                  (a, b) => b.appointmentDate.compareTo(a.appointmentDate));

              final recentAppointments = vetAppointments.take(5).toList();

              return Column(
                children: [
                  _buildSectionCard(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    primaryText: primaryText,
                    icon: Icons.analytics,
                    title: l10n.statistics,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: l10n.totalAppointments,
                              value: vetAppointments.length.toString(),
                              icon: Icons.calendar_today,
                              color: DesignColors.highlightBlue,
                              isDark: isDark,
                            ),
                          ),
                          SizedBox(width: DesignSpacing.md),
                          Expanded(
                            child: _StatCard(
                              label: l10n.lastVisit,
                              value: vet.lastVisitDate != null
                                  ? DateFormat.yMMMd()
                                      .format(vet.lastVisitDate!)
                                  : 'N/A',
                              icon: Icons.access_time,
                              color: DesignColors.highlightPurple,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.md),

                  // Recent Appointments
                  if (recentAppointments.isNotEmpty)
                    _buildSectionCard(
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                      primaryText: primaryText,
                      icon: Icons.history,
                      title: l10n.recentAppointments,
                      children: recentAppointments.map((appointment) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: appointment.isCompleted
                                      ? successColor.withOpacity(0.15)
                                      : DesignColors.highlightYellow.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  appointment.isCompleted
                                      ? Icons.check_circle
                                      : Icons.schedule,
                                  color: appointment.isCompleted
                                      ? successColor
                                      : DesignColors.highlightYellow,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: DesignSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.reason,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: primaryText,
                                      ),
                                    ),
                                    Text(
                                      DateFormat.yMMMd()
                                          .format(appointment.appointmentDate),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                appointment.isCompleted
                                    ? Icons.check
                                    : Icons.arrow_forward_ios,
                                size: 16,
                                color: secondaryText,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),

          // Notes Card
          if (vet.notes != null && vet.notes!.isNotEmpty) ...[
            SizedBox(height: DesignSpacing.md),
            _buildSectionCard(
              isDark: isDark,
              surfaceColor: surfaceColor,
              primaryText: primaryText,
              icon: Icons.note,
              title: l10n.notes,
              children: [
                Text(
                  vet.notes!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ],
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
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
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

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    IconData? actionIcon,
    VoidCallback? onAction,
    required Color color,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: primaryText,
              ),
            ),
          ),
          if (actionIcon != null && onAction != null)
            IconButton(
              icon: Icon(actionIcon, color: color, size: 20),
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.xs / 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
