import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/appointment_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../utils/date_helper.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEntry appointment;
  final VoidCallback? onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback? onSetReminder;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onToggleStatus,
    this.onDelete,
    this.onSetReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    // Get status-based border color
    final statusColor = appointment.isCompleted
        ? successColor
        : _getStatusColor(isDark);

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
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
                // Header row
                Row(
                  children: [
                    // Appointment icon and veterinarian
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getAppointmentColor(isDark).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getAppointmentIcon(),
                              color: _getAppointmentColor(isDark),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: DesignSpacing.sm + 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.veterinarian,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: DesignSpacing.xs / 2),
                                Text(
                                  '${appointment.clinic} • ${appointment.reason}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm + 2,
                        vertical: DesignSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        appointment.isCompleted
                            ? l10n.completed
                            : _getStatusText(context),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Reminder button
                    if (!appointment.isCompleted)
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: DesignColors.highlightYellow,
                        ),
                        tooltip: l10n.setReminder,
                        onPressed: onSetReminder,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                    // More options menu
                    PopupMenuButton<String>(
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
                                appointment.isCompleted
                                    ? Icons.undo
                                    : Icons.check,
                                color: appointment.isCompleted
                                    ? DesignColors.highlightYellow
                                    : successColor,
                              ),
                              SizedBox(width: DesignSpacing.sm),
                              Text(
                                appointment.isCompleted
                                    ? l10n.markPending
                                    : l10n.markCompleted,
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: dangerColor),
                              SizedBox(width: DesignSpacing.sm),
                              Text(
                                l10n.delete,
                                style: GoogleFonts.inter(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(Icons.more_vert, size: 20, color: secondaryText),
                    ),
                  ],
                ),

                SizedBox(height: DesignSpacing.md),

                // Appointment details row
                Row(
                  children: [
                    // Date
                    Expanded(
                      child: _buildDetailItem(
                        context: context,
                        icon: Icons.calendar_today,
                        label: l10n.date,
                        value: localizedShortDate(
                            context, appointment.appointmentDate),
                        color: DesignColors.highlightBlue,
                        isDark: isDark,
                      ),
                    ),

                    // Time
                    Expanded(
                      child: _buildDetailItem(
                        context: context,
                        icon: Icons.access_time,
                        label: l10n.timeLabel,
                        value:
                            localizedTime(context, appointment.appointmentTime),
                        color: DesignColors.highlightTeal,
                        isDark: isDark,
                      ),
                    ),

                    // Days until/since
                    Expanded(
                      child: _buildDetailItem(
                        context: context,
                        icon: _getDaysIcon(),
                        label: _getDaysLabel(context),
                        value: _getDaysValue(context),
                        color: _getDaysColor(isDark),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                // Notes section
                if (appointment.notes != null &&
                    appointment.notes!.isNotEmpty) ...[
                  SizedBox(height: DesignSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(DesignSpacing.sm + 4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note,
                              size: 16,
                              color: DesignColors.highlightYellow,
                            ),
                            SizedBox(width: DesignSpacing.xs),
                            Text(
                              l10n.notes,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: DesignColors.highlightYellow,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: DesignSpacing.xs),
                        Text(
                          appointment.notes!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        SizedBox(height: DesignSpacing.xs),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: DesignSpacing.xs / 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getAppointmentIcon() {
    final reason = appointment.reason.toLowerCase();
    if (reason.contains('vaccine') || reason.contains('vaccination')) {
      return Icons.vaccines;
    } else if (reason.contains('surgery') || reason.contains('operation')) {
      return Icons.medical_services;
    } else if (reason.contains('checkup') || reason.contains('exam')) {
      return Icons.health_and_safety;
    } else if (reason.contains('dental') || reason.contains('teeth')) {
      return Icons.medication;
    } else if (reason.contains('emergency') || reason.contains('urgent')) {
      return Icons.emergency;
    } else {
      return Icons.local_hospital;
    }
  }

  Color _getAppointmentColor(bool isDark) {
    final reason = appointment.reason.toLowerCase();
    if (reason.contains('vaccine') || reason.contains('vaccination')) {
      return DesignColors.highlightTeal;
    } else if (reason.contains('surgery') || reason.contains('operation')) {
      return isDark ? DesignColors.dDanger : DesignColors.lDanger;
    } else if (reason.contains('checkup') || reason.contains('exam')) {
      return DesignColors.highlightBlue;
    } else if (reason.contains('dental') || reason.contains('teeth')) {
      return DesignColors.highlightPurple;
    } else if (reason.contains('emergency') || reason.contains('urgent')) {
      return DesignColors.highlightYellow;
    } else {
      return DesignColors.highlightYellow;
    }
  }

  Color _getStatusColor(bool isDark) {
    if (appointment.isCompleted) {
      return isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    }

    final now = DateTime.now();
    final appointmentDateTime = appointment.appointmentDate;

    if (appointmentDateTime.isBefore(now)) {
      return isDark ? DesignColors.dDanger : DesignColors.lDanger; // Overdue
    } else if (appointmentDateTime.difference(now).inDays <= 1) {
      return DesignColors.highlightYellow; // Tomorrow or today
    } else {
      return DesignColors.highlightBlue; // Upcoming
    }
  }

  String _getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (appointment.isCompleted) {
      return l10n.completed;
    }

    final diff = daysUntil(appointment.appointmentDate);

    if (diff < 0) {
      return l10n.overdue;
    } else if (diff == 0) {
      return l10n.today;
    } else if (diff == 1) {
      return l10n.tomorrow;
    } else {
      return l10n.upcoming;
    }
  }

  IconData _getDaysIcon() {
    if (appointment.isCompleted) {
      return Icons.check_circle;
    }

    final now = DateTime.now();
    final appointmentDate = appointment.appointmentDate;

    if (appointmentDate.isBefore(now)) {
      return Icons.warning;
    } else {
      return Icons.schedule;
    }
  }

  String _getDaysLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (appointment.isCompleted) {
      return l10n.status;
    }

    final diff = daysUntil(appointment.appointmentDate);

    if (diff < 0) {
      return l10n.overdue;
    } else {
      return l10n.daysUntil;
    }
  }

  String _getDaysValue(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (appointment.isCompleted) {
      return l10n.done;
    }

    final diff = daysUntil(appointment.appointmentDate);

    if (diff < 0) {
      final overdueDays = -diff;
      return '${overdueDays}d';
    } else if (diff == 0) {
      return l10n.today;
    } else if (diff == 1) {
      return l10n.tomorrow;
    } else {
      return '${diff}d';
    }
  }

  Color _getDaysColor(bool isDark) {
    if (appointment.isCompleted) {
      return isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    }

    final now = DateTime.now();
    final appointmentDate = appointment.appointmentDate;

    if (appointmentDate.isBefore(now)) {
      return isDark ? DesignColors.dDanger : DesignColors.lDanger; // Overdue
    } else if (appointmentDate.difference(now).inDays <= 1) {
      return DesignColors.highlightYellow; // Soon
    } else {
      return DesignColors.highlightPurple; // Future
    }
  }
}
