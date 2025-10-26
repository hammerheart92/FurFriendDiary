import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/reminder.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../data/services/notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/add_reminder_sheet.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final activePet = ref.watch(currentPetProfileProvider);

    if (activePet == null) {
      return _buildNoPetView(theme, l10n);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminders),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          // Test notification button
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notification',
            onPressed: () async {
              await NotificationService().showTestNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Test notification sent! Check your notification bar.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
          tabs: [
            Tab(text: l10n.activeReminders),
            Tab(text: l10n.inactive),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersList(activePet.id, true),
          _buildRemindersList(activePet.id, false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(activePet.id),
        icon: const Icon(Icons.add),
        label: Text(l10n.addReminder),
      ),
    );
  }

  Widget _buildNoPetView(ThemeData theme, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminders),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPetSelected,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pleaseSetupPetFirst,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList(String petId, bool showActive) {
    final remindersAsync = ref.watch(remindersByPetIdProvider(petId));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return remindersAsync.when(
      data: (reminders) {
        final filteredReminders =
            reminders.where((r) => r.isActive == showActive).toList();

        if (filteredReminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  showActive
                      ? l10n.noActiveReminders
                      : l10n.noInactiveReminders,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                if (showActive) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.noRemindersDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredReminders.length,
          itemBuilder: (context, index) {
            final reminder = filteredReminders[index];
            return _buildReminderCard(reminder);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final timeFormat = DateFormat.jm();
    final dateFormat = DateFormat.yMMMd();

    IconData typeIcon;
    String typeLabel;
    switch (reminder.type) {
      case ReminderType.medication:
        typeIcon = Icons.medication;
        typeLabel = l10n.medicationReminder;
        break;
      case ReminderType.appointment:
        typeIcon = Icons.event;
        typeLabel = l10n.appointmentReminder;
        break;
      case ReminderType.feeding:
        typeIcon = Icons.restaurant;
        typeLabel = l10n.feedingReminder;
        break;
      case ReminderType.walk:
        typeIcon = Icons.pets;
        typeLabel = l10n.walkReminder;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(typeIcon, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(
          reminder.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(typeLabel),
            const SizedBox(height: 2),
            Text(
              '${dateFormat.format(reminder.scheduledTime)} at ${timeFormat.format(reminder.scheduledTime)}',
              style: theme.textTheme.bodySmall,
            ),
            if (reminder.description != null &&
                reminder.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                reminder.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: ListTile(
                leading: Icon(
                  reminder.isActive ? Icons.pause : Icons.play_arrow,
                  size: 20,
                ),
                title: Text(reminder.isActive ? 'Deactivate' : 'Activate'),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () => _toggleReminderActive(reminder),
            ),
            PopupMenuItem(
              child: ListTile(
                leading: const Icon(Icons.delete, size: 20, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () => _deleteReminder(reminder),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _toggleReminderActive(Reminder reminder) async {
    final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);
    try {
      await ref
          .read(reminderNotifierProvider.notifier)
          .updateReminder(updatedReminder);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reminderUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToUpdateReminder)),
        );
      }
    }
  }

  void _deleteReminder(Reminder reminder) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReminder),
        content: Text(l10n.deleteReminderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(reminderNotifierProvider.notifier)
            .deleteReminder(reminder.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.reminderDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedToDeleteReminder)),
          );
        }
      }
    }
  }

  void _showAddReminderDialog(String petId) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddReminderSheet(),
    );

    // Show success message in parent context
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).reminderAdded),
        ),
      );
    }
  }
}
