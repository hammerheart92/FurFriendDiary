import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/medication_entry.dart';
import '../../providers/inventory_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

/// Extension to translate stock unit values from database to localized strings
extension StockUnitTranslation on AppLocalizations {
  String translateStockUnit(String? unit) {
    if (unit == null) return pills;
    switch (unit.toLowerCase()) {
      case 'pills':
        return pills;
      case 'tablets':
        return tablets;
      case 'ml':
        return ml;
      case 'doses':
        return doses;
      default:
        return unit; // Return as-is if unknown
    }
  }
}

class MedicationCard extends ConsumerWidget {
  final MedicationEntry medication;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback? onSetReminder;
  final VoidCallback? onMarkAsGiven;
  final VoidCallback? onAddRefill;

  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
    this.onToggleStatus,
    this.onDelete,
    this.onSetReminder,
    this.onMarkAsGiven,
    this.onAddRefill,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final stockStatus = ref.watch(stockStatusProvider(medication.id));

    // Design system colors
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final methodColor = _getMedicationColor();

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row 1: Icon + Name/Dosage + Status + Menu
                Row(
                  children: [
                    // Medication icon (48px circular)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: methodColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getMedicationIcon(),
                        color: methodColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    // Name + Dosage/Frequency (NOW HAS MORE SPACE!)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.medicationName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: DesignSpacing.xs),
                          Text(
                            '${medication.dosage} • ${_getLocalizedFrequency(l10n, medication.frequency)}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: DesignSpacing.sm),

                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: DesignSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: medication.isActive
                            ? (isDark ? DesignColors.dSuccess : DesignColors.lSuccess).withOpacity(0.15)
                            : (isDark ? DesignColors.dDisabled : DesignColors.lDisabled).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        medication.isActive ? l10n.active : l10n.inactive,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: medication.isActive
                              ? (isDark ? DesignColors.dSuccess : DesignColors.lSuccess)
                              : secondaryText,
                        ),
                      ),
                    ),

                    // 3-dot menu
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20, color: secondaryText),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'toggle':
                            onToggleStatus?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
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
                                size: 20,
                                color: medication.isActive
                                    ? DesignColors.highlightYellow
                                    : DesignColors.lSuccess,
                              ),
                              SizedBox(width: DesignSpacing.sm),
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
                              Icon(Icons.delete_outline, size: 20, color: DesignColors.lDanger),
                              SizedBox(width: DesignSpacing.sm),
                              Text(
                                l10n.delete,
                                style: GoogleFonts.inter(color: DesignColors.lDanger),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Header Row 2: Stock Badge + Bell Icon (only when stock tracking enabled)
                if (medication.stockQuantity != null) ...[
                  SizedBox(height: DesignSpacing.sm),
                  Row(
                    children: [
                      // Stock status badge (now has its own row!)
                      _buildStockBadge(stockStatus, isDark, l10n),
                      const Spacer(),
                      // Reminder bell
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, size: 20, color: secondaryText),
                        tooltip: l10n.setReminder,
                        onPressed: onSetReminder,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ] else ...[
                  // Bell icon in its own row when no stock tracking
                  SizedBox(height: DesignSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, size: 20, color: secondaryText),
                        tooltip: l10n.setReminder,
                        onPressed: onSetReminder,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: DesignSpacing.md),

                // Info badges row
                Row(
                  children: [
                    // Method badge
                    _buildInfoBadge(
                      icon: Icons.medical_services_outlined,
                      label: l10n.method,
                      value: _getLocalizedAdministrationMethod(
                          l10n, medication.administrationMethod),
                      color: DesignColors.highlightBlue,
                      isDark: isDark,
                    ),

                    SizedBox(width: DesignSpacing.sm),

                    // Started badge
                    _buildInfoBadge(
                      icon: Icons.calendar_today,
                      label: l10n.started,
                      value: DateFormat('MMM dd').format(medication.startDate),
                      color: isDark ? DesignColors.dSuccess : DesignColors.lSuccess,
                      isDark: isDark,
                    ),

                    SizedBox(width: DesignSpacing.sm),

                    // Ends badge
                    _buildInfoBadge(
                      icon: medication.endDate != null
                          ? Icons.event_available
                          : Icons.all_inclusive,
                      label: medication.endDate != null
                          ? l10n.ends
                          : l10n.duration,
                      value: medication.endDate != null
                          ? DateFormat('MMM dd').format(medication.endDate!)
                          : l10n.ongoing,
                      color: medication.endDate != null
                          ? (isDark ? DesignColors.dSecondary : DesignColors.lSecondary)
                          : DesignColors.highlightPurple,
                      isDark: isDark,
                    ),
                  ],
                ),

                // Administration times
                if (medication.administrationTimes.isNotEmpty) ...[
                  SizedBox(height: DesignSpacing.md),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: secondaryText),
                      SizedBox(width: DesignSpacing.xs),
                      Text(
                        l10n.administrationTimes,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  Wrap(
                    spacing: DesignSpacing.sm,
                    runSpacing: DesignSpacing.sm,
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
                              size: 14,
                              color: DesignColors.highlightTeal,
                            ),
                            SizedBox(width: DesignSpacing.xs),
                            Text(
                              time.format24Hour(),
                              style: GoogleFonts.inter(
                                fontSize: 13,
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

                // Notes section
                if (medication.notes != null && medication.notes!.isNotEmpty) ...[
                  SizedBox(height: DesignSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(DesignSpacing.sm),
                    decoration: BoxDecoration(
                      color: (isDark ? DesignColors.dBackground : DesignColors.lBackground).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note_outlined, size: 16, color: secondaryText),
                            SizedBox(width: DesignSpacing.xs),
                            Text(
                              l10n.notes,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        Text(
                          medication.notes!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: primaryText,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],

                // Inventory action buttons (if stock tracking enabled)
                if (medication.stockQuantity != null &&
                    medication.isActive &&
                    (onMarkAsGiven != null || onAddRefill != null)) ...[
                  SizedBox(height: DesignSpacing.md),
                  Row(
                    children: [
                      if (onMarkAsGiven != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onMarkAsGiven,
                            icon: Icon(Icons.check_circle_outline, size: 18, color: DesignColors.highlightTeal),
                            label: Text(
                              l10n.markAsGiven,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: DesignColors.highlightTeal,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                              side: BorderSide(color: DesignColors.highlightTeal),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (onMarkAsGiven != null && onAddRefill != null)
                        SizedBox(width: DesignSpacing.sm),
                      if (onAddRefill != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onAddRefill,
                            icon: const Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
                            label: Text(
                              l10n.addRefill,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignColors.highlightTeal,
                              padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge(
      StockStatus status, bool isDark, AppLocalizations l10n) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    switch (status) {
      case StockStatus.critical:
        badgeColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
        badgeIcon = Icons.warning;
        badgeText = l10n.pillsLeft(
          medication.stockQuantity.toString(),
          l10n.translateStockUnit(medication.stockUnit),
        );
        break;
      case StockStatus.low:
        badgeColor = isDark ? DesignColors.dWarning : DesignColors.lWarning;
        badgeIcon = Icons.info;
        badgeText = l10n.pillsLeft(
          medication.stockQuantity.toString(),
          l10n.translateStockUnit(medication.stockUnit),
        );
        break;
      case StockStatus.sufficient:
        badgeColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
        badgeIcon = Icons.inventory;
        badgeText = l10n.pillsLeft(
          medication.stockQuantity.toString(),
          l10n.translateStockUnit(medication.stockUnit),
        );
        break;
      case StockStatus.notTracked:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          SizedBox(width: DesignSpacing.xs),
          Text(
            badgeText,
            style: GoogleFonts.inter(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(DesignSpacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(height: DesignSpacing.xs),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: secondaryText,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMedicationIcon() {
    switch (medication.administrationMethod) {
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
    switch (medication.administrationMethod) {
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

  String _getLocalizedFrequency(AppLocalizations l10n, String frequencyKey) {
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

  String _getLocalizedAdministrationMethod(
      AppLocalizations l10n, String methodKey) {
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
