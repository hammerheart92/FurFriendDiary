import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/appointment_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../widgets/appointment_list.dart';
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
                      appointments
                          .where((apt) =>
                              !apt.isCompleted &&
                              apt.appointmentDate.isAfter(DateTime.now()))
                          .toList(),
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
      child: AppointmentList(
        petId: petId,
        onAddAppointment: () {
          setState(() {
            _showForm = true;
            _editingAppointment = null;
          });
        },
        onEditAppointment: (appointment) {
          setState(() {
            _showForm = true;
            _editingAppointment = appointment;
          });
        },
      ),
    );
  }
}
