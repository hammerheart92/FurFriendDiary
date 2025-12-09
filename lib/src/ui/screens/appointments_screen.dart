import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/reminder.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_form.dart';
import '../../../l10n/app_localizations.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showForm = false;
  AppointmentEntry? _editingAppointment;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final activePet = ref.watch(currentPetProfileProvider);

    if (activePet == null) {
      return _buildNoPetView(theme);
    }

    if (_showForm) {
      return _buildFormView(theme, activePet.id);
    }

    return _buildAppointmentsView(theme, activePet.id);
  }

  Widget _buildNoPetView(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointments),
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

  Widget _buildFormView(ThemeData theme, String petId) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingAppointment != null
            ? l10n.editAppointment
            : l10n.addAppointment),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              _showForm = false;
              _editingAppointment = null;
            });
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: AppointmentForm(
        appointment: _editingAppointment,
        onSaved: () {
          setState(() {
            _showForm = false;
            _editingAppointment = null;
          });
        },
        onCancelled: () {
          setState(() {
            _showForm = false;
            _editingAppointment = null;
          });
        },
      ),
    );
  }

  Widget _buildAppointmentsView(ThemeData theme, String petId) {
    final appointmentsAsync = ref.watch(appointmentsByPetIdProvider(petId));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointments),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.local_hospital),
            tooltip: l10n.veterinarians,
            onPressed: () => context.push('/vet-list'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
          tabs: [
            Tab(text: l10n.upcoming),
            Tab(text: l10n.all),
            Tab(text: l10n.completed),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchAppointments,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.background,
              ),
            ),
          ),

          // Tabs content
          Expanded(
            child: appointmentsAsync.when(
              data: (appointments) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(
                      _filterUpcomingAppointments(appointments),
                      l10n.noUpcomingAppointments,
                      theme,
                      petId,
                    ),
                    _buildAppointmentsList(
                      appointments,
                      l10n.noAppointmentsFound,
                      theme,
                      petId,
                    ),
                    _buildAppointmentsList(
                      appointments.where((apt) => apt.isCompleted).toList(),
                      l10n.noCompletedAppointments,
                      theme,
                      petId,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('${l10n.errorLoadingAppointments}: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(appointmentsByPetIdProvider(petId)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showForm = true;
            _editingAppointment = null;
          });
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(l10n.addAppointment),
      ),
    );
  }

  /// Filter appointments for the Upcoming tab
  /// Includes appointments that are:
  /// 1. Not completed
  /// 2. Scheduled for today or future dates
  List<AppointmentEntry> _filterUpcomingAppointments(
      List<AppointmentEntry> appointments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return appointments.where((apt) {
      // Must not be completed
      if (apt.isCompleted) return false;

      // Compare dates only (without time component)
      final aptDate = DateTime(
        apt.appointmentDate.year,
        apt.appointmentDate.month,
        apt.appointmentDate.day,
      );

      // Include appointments from today onwards
      return aptDate.isAfter(today) || aptDate.isAtSameMomentAs(today);
    }).toList();
  }

  Widget _buildAppointmentsList(
    List<AppointmentEntry> appointments,
    String emptyMessage,
    ThemeData theme,
    String petId,
  ) {
    final l10n = AppLocalizations.of(context);

    // Filter appointments based on search query
    final filteredAppointments = appointments.where((appointment) {
      if (_searchQuery.isEmpty) return true;
      return appointment.veterinarian.toLowerCase().contains(_searchQuery) ||
          appointment.clinic.toLowerCase().contains(_searchQuery) ||
          appointment.reason.toLowerCase().contains(_searchQuery) ||
          (appointment.notes?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    // Sort by appointment date (upcoming first, then by date)
    filteredAppointments.sort((a, b) {
      // Completed appointments go to the bottom
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Within same completion status, sort by appointment date
      return a.appointmentDate.compareTo(b.appointmentDate);
    });

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n.noAppointmentsMatchSearch
                  : emptyMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.tryAdjustingSearchTerms,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(appointmentsByPetIdProvider(petId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredAppointments.length,
        itemBuilder: (context, index) {
          final appointment = filteredAppointments[index];
          return AppointmentCard(
            appointment: appointment,
            onTap: () {
              setState(() {
                _showForm = true;
                _editingAppointment = appointment;
              });
            },
            onToggleStatus: () => _toggleAppointmentStatus(appointment),
            onDelete: () => _showDeleteDialog(appointment),
            onSetReminder: () => _showReminderDialog(appointment),
          );
        },
      ),
    );
  }

  Future<void> _toggleAppointmentStatus(AppointmentEntry appointment) async {
    try {
      final updatedAppointment = appointment.copyWith(
        isCompleted: !appointment.isCompleted,
      );

      await ref
          .read(appointmentProviderProvider.notifier)
          .updateAppointment(updatedAppointment);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appointment: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(AppointmentEntry appointment) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text(
          'Are you sure you want to delete the appointment with ${appointment.veterinarian} at ${appointment.clinic}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref
            .read(appointmentProviderProvider.notifier)
            .deleteAppointment(appointment.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete appointment: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showReminderDialog(AppointmentEntry appointment) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.setReminder,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.today, color: Colors.blue),
                      title: Text(l10n.oneDayBefore),
                      subtitle: Text(_formatReminderTime(
                          _combineDateTime(appointment),
                          const Duration(days: 1))),
                      onTap: () {
                        Navigator.pop(context);
                        final appointmentDateTime =
                            _combineDateTime(appointment);
                        _createReminder(
                          appointment,
                          appointmentDateTime.subtract(const Duration(days: 1)),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.access_time, color: Colors.orange),
                      title: Text(l10n.oneHourBefore),
                      subtitle: Text(_formatReminderTime(
                          _combineDateTime(appointment),
                          const Duration(hours: 1))),
                      onTap: () {
                        Navigator.pop(context);
                        final appointmentDateTime =
                            _combineDateTime(appointment);
                        _createReminder(
                          appointment,
                          appointmentDateTime
                              .subtract(const Duration(hours: 1)),
                        );
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.notifications, color: Colors.green),
                      title: Text(l10n.thirtyMinutesBefore),
                      subtitle: Text(_formatReminderTime(
                          _combineDateTime(appointment),
                          const Duration(minutes: 30))),
                      onTap: () {
                        Navigator.pop(context);
                        final appointmentDateTime =
                            _combineDateTime(appointment);
                        _createReminder(
                          appointment,
                          appointmentDateTime
                              .subtract(const Duration(minutes: 30)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Combine separate date and time fields into a single DateTime
  DateTime _combineDateTime(AppointmentEntry appointment) {
    return DateTime(
      appointment.appointmentDate.year,
      appointment.appointmentDate.month,
      appointment.appointmentDate.day,
      appointment.appointmentTime.hour,
      appointment.appointmentTime.minute,
      0, // seconds
      0, // milliseconds
    );
  }

  String _formatReminderTime(DateTime appointmentDate, Duration before) {
    final reminderTime = appointmentDate.subtract(before);
    final day = reminderTime.day.toString().padLeft(2, '0');
    final month = reminderTime.month.toString().padLeft(2, '0');
    final hour = reminderTime.hour.toString().padLeft(2, '0');
    final minute = reminderTime.minute.toString().padLeft(2, '0');
    return '$day/$month at $hour:$minute';
  }

  Future<void> _createReminder(
    AppointmentEntry appointment,
    DateTime reminderTime,
  ) async {
    try {
      final reminder = Reminder(
        petId: appointment.petId,
        type: ReminderType.appointment,
        title: appointment.reason,
        description: '${appointment.veterinarian} at ${appointment.clinic}',
        scheduledTime: reminderTime,
        frequency: ReminderFrequency.once,
        linkedEntityId: appointment.id,
      );

      await ref.read(reminderRepositoryProvider).addReminder(reminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToCreateReminder}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
