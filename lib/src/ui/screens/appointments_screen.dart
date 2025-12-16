import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/appointment_entry.dart';
import '../../domain/models/reminder.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_form.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          l10n.appointments,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: DesignColors.highlightYellow.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pets,
                  size: 48,
                  color: DesignColors.highlightYellow,
                ),
              ),
              SizedBox(height: DesignSpacing.lg),
              Text(
                l10n.noPetSelected,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignSpacing.sm),
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

  Widget _buildFormView(ThemeData theme, String petId) {
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          _editingAppointment != null
              ? l10n.editAppointment
              : l10n.addAppointment,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            setState(() {
              _showForm = false;
              _editingAppointment = null;
            });
          },
          icon: Icon(Icons.close, color: primaryText),
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
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    // Count upcoming appointments for badge
    final upcomingCount = appointmentsAsync.when(
      data: (appointments) => _filterUpcomingAppointments(appointments).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          l10n.appointments,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.local_hospital, color: DesignColors.highlightYellow),
            tooltip: l10n.veterinarians,
            onPressed: () => context.push('/vet-list'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: DesignColors.highlightYellow,
          indicatorWeight: 3,
          labelColor: DesignColors.highlightYellow,
          unselectedLabelColor: secondaryText,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l10n.upcoming,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (upcomingCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: DesignColors.highlightYellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$upcomingCount',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: l10n.all),
            Tab(text: l10n.completed),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.searchAppointments,
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                  prefixIcon: Icon(Icons.search, color: DesignColors.highlightYellow),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: Icon(Icons.clear, color: secondaryText),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.md,
                    vertical: DesignSpacing.md,
                  ),
                ),
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
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: DesignColors.highlightYellow,
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.all(DesignSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: dangerColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline, size: 40, color: dangerColor),
                      ),
                      SizedBox(height: DesignSpacing.md),
                      Text(
                        l10n.errorLoadingAppointments,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      SizedBox(height: DesignSpacing.sm),
                      Text(
                        '$error',
                        style: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: DesignSpacing.lg),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(appointmentsByPetIdProvider(petId)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignColors.highlightYellow,
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
        backgroundColor: DesignColors.highlightYellow,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: Text(
          l10n.addAppointment,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
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
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

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
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: DesignColors.highlightYellow.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_available,
                  size: 48,
                  color: DesignColors.highlightYellow,
                ),
              ),
              SizedBox(height: DesignSpacing.lg),
              Text(
                _searchQuery.isNotEmpty
                    ? l10n.noAppointmentsMatchSearch
                    : emptyMessage,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              if (_searchQuery.isNotEmpty) ...[
                SizedBox(height: DesignSpacing.sm),
                Text(
                  l10n.tryAdjustingSearchTerms,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_searchQuery.isEmpty) ...[
                SizedBox(height: DesignSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showForm = true;
                      _editingAppointment = null;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: Text(
                    l10n.addAppointment,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.highlightYellow,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.lg,
                      vertical: DesignSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: DesignColors.highlightYellow,
      onRefresh: () async {
        ref.invalidate(appointmentsByPetIdProvider(petId));
      },
      child: ListView.builder(
        padding: EdgeInsets.all(DesignSpacing.md),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    try {
      final updatedAppointment = appointment.copyWith(
        isCompleted: !appointment.isCompleted,
      );

      await ref
          .read(appointmentProviderProvider.notifier)
          .updateAppointment(updatedAppointment);

      // Invalidate provider to refresh list
      ref.invalidate(appointmentsByPetIdProvider(appointment.petId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedAppointment.isCompleted
                  ? 'Appointment marked as completed'
                  : 'Appointment marked as upcoming',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update appointment: $error',
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

  Future<void> _showDeleteDialog(AppointmentEntry appointment) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    final result = await showDialog<bool>(
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
                'Delete Appointment',
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
          'Are you sure you want to delete the appointment with ${appointment.veterinarian} at ${appointment.clinic}?',
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

    if (result == true) {
      try {
        await ref
            .read(appointmentProviderProvider.notifier)
            .deleteAppointment(appointment.id);

        // Invalidate provider to refresh list immediately
        ref.invalidate(appointmentsByPetIdProvider(appointment.petId));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Appointment deleted successfully',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete appointment: $error',
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

  void _showReminderDialog(AppointmentEntry appointment) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: DesignSpacing.lg),
                decoration: BoxDecoration(
                  color: disabledColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.setReminder,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildReminderOption(
                      icon: Icons.today,
                      iconColor: DesignColors.highlightBlue,
                      title: l10n.oneDayBefore,
                      subtitle: _formatReminderTime(
                          _combineDateTime(appointment),
                          const Duration(days: 1)),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
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
                    _buildReminderOption(
                      icon: Icons.access_time,
                      iconColor: DesignColors.highlightYellow,
                      title: l10n.oneHourBefore,
                      subtitle: _formatReminderTime(
                          _combineDateTime(appointment),
                          const Duration(hours: 1)),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
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
                    _buildReminderOption(
                      icon: Icons.notifications,
                      iconColor: DesignColors.highlightTeal,
                      title: l10n.thirtyMinutesBefore,
                      subtitle: _formatReminderTime(
                          _combineDateTime(appointment),
                          const Duration(minutes: 30)),
                      primaryText: primaryText,
                      secondaryText: secondaryText,
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

  Widget _buildReminderOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color primaryText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: secondaryText,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
