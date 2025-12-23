import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/reminder.dart';
import '../../providers/medications_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../widgets/medication_card.dart';
import '../../presentation/widgets/add_refill_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../utils/snackbar_helper.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();

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
    return _buildMedicationsView(theme, activePet.id);
  }

  Widget _buildNoPetView(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Scaffold(
      backgroundColor: isDark ? DesignColors.dBackground : DesignColors.lBackground,
      appBar: AppBar(
        title: Text(
          l10n.medications,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DesignColors.highlightTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pets,
                  size: 40,
                  color: DesignColors.highlightTeal.withOpacity(0.7),
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

  Widget _buildMedicationsView(ThemeData theme, String petId) {
    final medicationsAsync = ref.watch(medicationsProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.medications,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.inventory_2_outlined, color: secondaryText),
            onPressed: () => context.push('/medication-inventory'),
            tooltip: l10n.medicationInventory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: DesignColors.highlightTeal,
          indicatorWeight: 3,
          labelColor: DesignColors.highlightTeal,
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
            Tab(text: l10n.active),
            Tab(text: l10n.all),
            Tab(text: l10n.inactive),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(color: primaryText),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.searchMedications,
                  hintStyle: GoogleFonts.inter(color: secondaryText),
                  prefixIcon: Icon(Icons.search, color: DesignColors.highlightTeal),
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
                  filled: true,
                  fillColor: Colors.transparent,
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
            child: medicationsAsync.when(
              data: (medications) {
                final petMedications =
                    medications.where((med) => med.petId == petId).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMedicationsList(
                      petMedications.where((med) => med.isActive).toList(),
                      l10n.noActiveMedications,
                      theme,
                    ),
                    _buildMedicationsList(
                      petMedications,
                      l10n.noMedicationsFound,
                      theme,
                    ),
                    _buildMedicationsList(
                      petMedications.where((med) => !med.isActive).toList(),
                      l10n.noInactiveMedications,
                      theme,
                    ),
                  ],
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: DesignColors.highlightTeal,
                ),
              ),
              error: (error, stack) => _buildErrorState(theme, l10n, error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/meds/add'),
        backgroundColor: DesignColors.highlightTeal,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: Text(
          l10n.addMedication,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n, Object error) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? DesignColors.dDanger : DesignColors.lDanger).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.errorLoadingMedications,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
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
              onPressed: () => ref.refresh(medicationsProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.highlightTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.xl,
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
    );
  }

  Widget _buildMedicationsList(
    List<MedicationEntry> medications,
    String emptyMessage,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    // Filter medications based on search query
    final filteredMedications = medications.where((medication) {
      if (_searchQuery.isEmpty) return true;
      return medication.medicationName.toLowerCase().contains(_searchQuery) ||
          medication.dosage.toLowerCase().contains(_searchQuery) ||
          medication.frequency.toLowerCase().contains(_searchQuery) ||
          medication.administrationMethod.toLowerCase().contains(_searchQuery);
    }).toList();

    // Sort by start date (newest first)
    filteredMedications.sort((a, b) => b.startDate.compareTo(a.startDate));

    if (filteredMedications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: DesignColors.highlightTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_outlined,
                  size: 40,
                  color: DesignColors.highlightTeal.withOpacity(0.7),
                ),
              ),
              SizedBox(height: DesignSpacing.lg),
              Text(
                _searchQuery.isNotEmpty
                    ? l10n.noMedicationsMatchSearch
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
                  onPressed: () => context.push('/meds/add'),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    l10n.addMedication,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.highlightTeal,
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
      color: DesignColors.highlightTeal,
      onRefresh: () async {
        await ref.read(medicationsProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(DesignSpacing.md),
        itemCount: filteredMedications.length,
        itemBuilder: (context, index) {
          final medication = filteredMedications[index];
          return MedicationCard(
            medication: medication,
            onTap: () => context.push('/meds/detail/${medication.id}'),
            onToggleStatus: () => _toggleMedicationStatus(medication),
            onDelete: () => _deleteMedication(medication),
            onSetReminder: () => _showReminderDialog(medication),
            onMarkAsGiven: medication.stockQuantity != null
                ? () => _markAsGiven(medication)
                : null,
            onAddRefill: medication.stockQuantity != null
                ? () => _showAddRefillDialog(medication)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _toggleMedicationStatus(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(medicationsProvider.notifier)
          .toggleMedicationStatus(medication.id);

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          medication.isActive
              ? l10n.medicationMarkedInactive
              : l10n.medicationMarkedActive,
        );
      }
    } catch (error) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          '${l10n.failedToUpdateMedication}: $error',
        );
      }
    }
  }

  Future<void> _deleteMedication(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: dangerColor,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                l10n.deleteMedication,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                l10n.deleteMedicationConfirm(medication.medicationName),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                        side: BorderSide(color: secondaryText.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.delete,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref
            .read(medicationsProvider.notifier)
            .deleteMedication(medication.id);

        if (mounted) {
          SnackBarHelper.showSuccess(context, l10n.medicationDeletedSuccessfully);
        }
      } catch (error) {
        if (mounted) {
          SnackBarHelper.showError(
            context,
            '${l10n.failedToDeleteMedication}: $error',
          );
        }
      }
    }
  }

  Future<void> _markAsGiven(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Determine dosage units to decrement (default to 1)
      final dosageUnits =
          1; // Could be made configurable based on medication.dosage

      await ref.read(medicationsRepositoryProvider).recordDosageGiven(
            medication.id,
            dosageUnits,
          );

      await ref.read(medicationsProvider.notifier).refresh();

      if (mounted) {
        SnackBarHelper.showSuccess(context, l10n.stockUpdated);
      }
    } catch (error) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Error: $error');
      }
    }
  }

  Future<void> _showAddRefillDialog(MedicationEntry medication) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddRefillDialog(medication: medication),
    );

    if (result == true && mounted) {
      // Dialog already shows success message, just refresh the list
      await ref.read(medicationsProvider.notifier).refresh();
    }
  }

  /// Shows a bottom sheet to create medication reminders.
  ///
  /// Known Issue (Non-Critical - Deferred to v1.2.0):
  /// - "Remind Daily" and "Remind Once" options do not auto-dismiss the bottom sheet
  /// - Workaround: Users can tap "View" button or swipe down to manually dismiss
  /// - "Remind All Doses" works correctly (auto-dismisses as expected)
  ///
  /// Fix Attempts (Week 4 Manual Testing):
  /// 1. Attempt 1: Context renaming (builder context → bottomSheetContext)
  ///    Result: No change
  ///
  /// 2. Attempt 2: Explicit Navigator.of() with rootNavigator flag
  ///    Result: No change
  ///
  /// 3. Attempt 3: Added 100ms delay before Navigator.pop() to resolve gesture conflicts
  ///    Result: No change
  ///
  /// 4. Attempt 4: Captured Navigator reference before delay to prevent context disposal
  ///    Code: `final navigator = Navigator.of(bottomSheetContext);`
  ///          `await Future.delayed(const Duration(milliseconds: 100));`
  ///          `navigator.pop();`
  ///    Result: Partial improvement - "Remind All Doses" works, others still require manual dismiss
  ///
  /// Root Cause Analysis:
  /// - DraggableScrollableSheet + ListTile tap gesture conflict
  /// - Manual swipe-down dismissal works correctly (proves modal config is correct)
  /// - Context lifecycle + async operations create race condition
  /// - Different code paths have different timing characteristics
  ///
  /// Current Status:
  /// - All reminder functionality works correctly (save, fire, frequency labels)
  /// - Only auto-dismiss UX is affected
  /// - Acceptable workaround available (tap "View" or swipe down)
  /// - Deferred to v1.2.0 for proper investigation (may require different bottom sheet approach)
  ///
  /// See also: MANUAL_TESTING_CHECKLIST.md - Scenario 5 notes
  void _showReminderDialog(MedicationEntry medication) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: DesignSpacing.md, bottom: DesignSpacing.lg),
                decoration: BoxDecoration(
                  color: secondaryText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DesignColors.highlightTeal.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: DesignColors.highlightTeal,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.md),
                    Text(
                      l10n.setReminder,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              Divider(color: secondaryText.withOpacity(0.15)),
              // Options list
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
                  children: [
                    _buildReminderOption(
                      icon: Icons.schedule,
                      title: l10n.remindDaily,
                      subtitle: medication.administrationTimes.isNotEmpty
                          ? '${l10n.firstDose}: ${medication.administrationTimes.first.format24Hour()}'
                          : null,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      onTap: () async {
                        final navigator = Navigator.of(bottomSheetContext);
                        await Future.delayed(const Duration(milliseconds: 100));
                        navigator.pop();
                        await _createReminder(
                          medication,
                          ReminderFrequency.daily,
                          medication.administrationTimes.isNotEmpty
                              ? TimeOfDay(
                                  hour: medication.administrationTimes.first.hour,
                                  minute: medication.administrationTimes.first.minute,
                                )
                              : null,
                        );
                      },
                    ),
                    if (medication.administrationTimes.length > 1)
                      _buildReminderOption(
                        icon: Icons.repeat,
                        title: l10n.remindAllDoses,
                        subtitle: '${medication.administrationTimes.length} ${l10n.timesDaily}',
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                        onTap: () async {
                          final navigator = Navigator.of(bottomSheetContext);
                          await Future.delayed(const Duration(milliseconds: 100));
                          navigator.pop();
                          await _createMultipleReminders(medication);
                        },
                      ),
                    _buildReminderOption(
                      icon: Icons.today,
                      title: l10n.remindOnce,
                      subtitle: l10n.customTime,
                      primaryText: primaryText,
                      secondaryText: secondaryText,
                      onTap: () async {
                        final navigator = Navigator.of(bottomSheetContext);
                        await Future.delayed(const Duration(milliseconds: 100));
                        navigator.pop();
                        await _selectCustomReminderTime(medication);
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
    required String title,
    String? subtitle,
    required Color primaryText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DesignColors.highlightTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: DesignColors.highlightTeal, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: secondaryText,
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right,
          color: secondaryText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _createReminder(
    MedicationEntry medication,
    ReminderFrequency frequency,
    TimeOfDay? time,
  ) async {
    // ✅ Capture messages BEFORE async operations
    final l10n = AppLocalizations.of(context);
    final successMsg = l10n.reminderSet;
    final failedMsg = l10n.failedToCreateReminder;
    final viewLabel = l10n.view;
    final frequencyLabel = _getReminderFrequencyLabel(frequency, l10n);

    try {
      final now = DateTime.now();
      final scheduledTime = time != null
          ? DateTime(now.year, now.month, now.day, time.hour, time.minute)
          : now.add(const Duration(hours: 1));

      final reminder = Reminder(
        petId: medication.petId,
        type: ReminderType.medication,
        title: medication.medicationName,
        description: '${medication.dosage} - $frequencyLabel',
        scheduledTime: scheduledTime,
        frequency: frequency,
        linkedEntityId: medication.id,
      );

      await ref.read(reminderRepositoryProvider).addReminder(reminder);

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          successMsg,
          action: SnackBarAction(
            label: viewLabel,
            textColor: Colors.white,
            onPressed: () => context.push('/settings'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '$failedMsg: $e');
      }
    }
  }

  Future<void> _createMultipleReminders(MedicationEntry medication) async {
    // ✅ Capture messages BEFORE async operations
    final l10n = AppLocalizations.of(context);
    final failedMsg = l10n.failedToCreateReminder;
    final count = medication.administrationTimes.length;

    try {
      final now = DateTime.now();

      for (final time in medication.administrationTimes) {
        final scheduledTime =
            DateTime(now.year, now.month, now.day, time.hour, time.minute);

        final reminder = Reminder(
          petId: medication.petId,
          type: ReminderType.medication,
          title: medication.medicationName,
          description: '${medication.dosage} - ${time.format24Hour()}',
          scheduledTime: scheduledTime,
          frequency: ReminderFrequency.daily,
          linkedEntityId: medication.id,
        );

        await ref.read(reminderRepositoryProvider).addReminder(reminder);
      }

      if (mounted) {
        SnackBarHelper.showSuccess(context, l10n.remindersCreated(count));
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, '$failedMsg: $e');
      }
    }
  }

  Future<void> _selectCustomReminderTime(MedicationEntry medication) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      await _createReminder(medication, ReminderFrequency.once, selectedTime);
    }
  }

  String _getReminderFrequencyLabel(
      ReminderFrequency frequency, AppLocalizations l10n) {
    switch (frequency) {
      case ReminderFrequency.once:
        return l10n.once;
      case ReminderFrequency.daily:
        return l10n.daily;
      case ReminderFrequency.twiceDaily:
        return l10n.twiceDaily;
      case ReminderFrequency.weekly:
        return l10n.weekly;
      case ReminderFrequency.custom:
        return l10n.custom;
    }
  }
}
