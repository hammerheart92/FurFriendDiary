import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
import '../../domain/models/reminder.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../data/services/notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/add_reminder_sheet.dart';
import '../../utils/snackbar_helper.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  int _selectedTab = 0; // 0 = Active, 1 = Inactive

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final activePet = ref.watch(currentPetProfileProvider);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;

    if (activePet == null) {
      return _buildNoPetView(isDark, primaryText, secondaryText, backgroundColor, l10n);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.reminders,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
        actions: [
          // Test notification button
          IconButton(
            icon: const Icon(Icons.notifications_active, color: DesignColors.highlightYellow),
            tooltip: 'Test Notification',
            onPressed: () async {
              await NotificationService().showTestNotification();
              if (context.mounted) {
                SnackBarHelper.showSuccess(context, 'Test notification sent! Check your notification bar.');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Pill-shaped tab selector
          _buildTabSelector(l10n, isDark, secondaryText),
          // Tab content
          Expanded(
            child: _buildRemindersList(activePet.id, _selectedTab == 0, isDark, primaryText, secondaryText),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(activePet.id),
        backgroundColor: DesignColors.highlightYellow,
        foregroundColor: Colors.white,
        elevation: isDark ? 8 : 4,
        icon: const Icon(Icons.add, size: 24),
        label: Text(
          l10n.addReminder,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(AppLocalizations l10n, bool isDark, Color secondaryText) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      padding: const EdgeInsets.all(DesignSpacing.xs),
      decoration: BoxDecoration(
        color: isDark
            ? DesignColors.dSurfaces.withOpacity(0.5)
            : DesignColors.lSurfaces,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(
            label: l10n.activeReminders,
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
            secondaryText: secondaryText,
          ),
          _buildTabButton(
            label: l10n.inactive,
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
            secondaryText: secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color secondaryText,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: DesignSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? DesignColors.highlightYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoPetView(
    bool isDark,
    Color primaryText,
    Color secondaryText,
    Color backgroundColor,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.reminders,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 80,
                color: secondaryText.withOpacity(0.4),
              ),
              const SizedBox(height: DesignSpacing.md),
              Text(
                l10n.noPetSelected,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: DesignSpacing.sm),
              Text(
                l10n.pleaseSetupPetFirst,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemindersList(
    String petId,
    bool showActive,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final remindersAsync = ref.watch(remindersByPetIdProvider(petId));
    final l10n = AppLocalizations.of(context);

    return remindersAsync.when(
      data: (reminders) {
        final filteredReminders =
            reminders.where((r) => r.isActive == showActive).toList();

        if (filteredReminders.isEmpty) {
          return _buildEmptyState(showActive, isDark, primaryText, secondaryText, l10n);
        }

        return RefreshIndicator(
          color: DesignColors.highlightYellow,
          onRefresh: () async {
            ref.invalidate(remindersByPetIdProvider(petId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.lg,
              vertical: DesignSpacing.sm,
            ),
            itemCount: filteredReminders.length,
            itemBuilder: (context, index) {
              final reminder = filteredReminders[index];
              return _buildReminderCard(reminder, isDark, primaryText, secondaryText);
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: DesignColors.highlightYellow),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error: $error',
          style: GoogleFonts.inter(color: DesignColors.highlightCoral),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool showActive,
    bool isDark,
    Color primaryText,
    Color secondaryText,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: secondaryText.withOpacity(0.4),
            ),
            const SizedBox(height: DesignSpacing.md),
            Text(
              showActive ? l10n.noActiveReminders : l10n.noInactiveReminders,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (showActive) ...[
              const SizedBox(height: DesignSpacing.sm),
              Text(
                l10n.noRemindersDescription,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getReminderTypeColor(ReminderType type, bool isDark) {
    switch (type) {
      case ReminderType.medication:
        return DesignColors.highlightPink;
      case ReminderType.appointment:
        return DesignColors.highlightYellow;
      case ReminderType.feeding:
        return isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
      case ReminderType.walk:
        return DesignColors.highlightTeal;
    }
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.appointment:
        return Icons.event;
      case ReminderType.feeding:
        return Icons.restaurant;
      case ReminderType.walk:
        return Icons.pets;
    }
  }

  String _getReminderTypeLabel(ReminderType type, AppLocalizations l10n) {
    switch (type) {
      case ReminderType.medication:
        return l10n.medicationReminder;
      case ReminderType.appointment:
        return l10n.appointmentReminder;
      case ReminderType.feeding:
        return l10n.feedingReminder;
      case ReminderType.walk:
        return l10n.walkReminder;
    }
  }

  Widget _buildReminderCard(
    Reminder reminder,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final l10n = AppLocalizations.of(context);
    final timeFormat = DateFormat.jm();
    final dateFormat = DateFormat.yMMMd();

    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final typeColor = _getReminderTypeColor(reminder.type, isDark);
    final typeIcon = _getReminderTypeIcon(reminder.type);
    final typeLabel = _getReminderTypeLabel(reminder.type, l10n);
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Optional: Add navigation to detail view
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type-colored icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: DesignSpacing.md),
                // Content column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        reminder.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DesignSpacing.xs),
                      // Type label with colored badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignSpacing.sm),
                      // Date and time
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: secondaryText,
                          ),
                          const SizedBox(width: DesignSpacing.xs),
                          Flexible(
                            child: Text(
                              '${dateFormat.format(reminder.scheduledTime)} at ${timeFormat.format(reminder.scheduledTime)}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Description (if present)
                      if (reminder.description != null &&
                          reminder.description!.isNotEmpty) ...[
                        const SizedBox(height: DesignSpacing.xs),
                        Text(
                          reminder.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Actions menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: secondaryText),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: surfaceColor,
                  onSelected: (value) {
                    if (value == 'toggle') {
                      _toggleReminderActive(reminder, isDark);
                    } else if (value == 'delete') {
                      _deleteReminder(reminder, isDark, primaryText, secondaryText);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            reminder.isActive ? Icons.pause : Icons.play_arrow,
                            size: 20,
                            color: secondaryText,
                          ),
                          const SizedBox(width: DesignSpacing.sm),
                          Text(
                            reminder.isActive ? 'Deactivate' : 'Activate',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: dangerColor,
                          ),
                          const SizedBox(width: DesignSpacing.sm),
                          Text(
                            l10n.delete,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: dangerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleReminderActive(Reminder reminder, bool isDark) async {
    final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    try {
      await ref
          .read(reminderNotifierProvider.notifier)
          .updateReminder(updatedReminder);
      // Invalidate the provider to refresh the UI
      ref.invalidate(remindersByPetIdProvider(reminder.petId));
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        SnackBarHelper.showSuccess(context, l10n.reminderUpdated);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        SnackBarHelper.showError(context, l10n.failedToUpdateReminder);
      }
    }
  }

  void _deleteReminder(
    Reminder reminder,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) async {
    final l10n = AppLocalizations.of(context);
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.deleteReminder,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.deleteReminderConfirm,
          style: GoogleFonts.inter(color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: dangerColor,
            ),
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: dangerColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(reminderNotifierProvider.notifier)
            .deleteReminder(reminder.id);
        // Invalidate the provider to refresh the UI
        ref.invalidate(remindersByPetIdProvider(reminder.petId));
        if (mounted) {
          SnackBarHelper.showSuccess(context, l10n.reminderDeleted);
        }
      } catch (e) {
        if (mounted) {
          SnackBarHelper.showError(context, l10n.failedToDeleteReminder);
        }
      }
    }
  }

  void _showAddReminderDialog(String petId) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReminderSheet(),
    );

    // Show success message in parent context and refresh UI
    if (result == true && mounted) {
      // Invalidate the provider to refresh the UI
      ref.invalidate(remindersByPetIdProvider(petId));
      SnackBarHelper.showSuccess(context, AppLocalizations.of(context).reminderAdded);
    }
  }
}
