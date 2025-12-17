import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'walks_state.dart';
import '../../l10n/app_localizations.dart';
import '../../src/presentation/providers/care_data_provider.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/shadows.dart';

/// Walks screen with reactive Riverpod StreamProvider, quick filters, responsive layout,
/// empty state, semantics, and walk management.

class WalksScreen extends ConsumerStatefulWidget {
  final String petId;

  const WalksScreen({super.key, required this.petId});

  @override
  ConsumerState<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends ConsumerState<WalksScreen>
    with AutomaticKeepAliveClientMixin {
  final logger = Logger();
  WalkFilter _filter =
      WalkFilter.all; // Default to "All" so new items are visible

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Watch the walks stream for this pet
    final walksAsync = ref.watch(walksByPetIdProvider(widget.petId));

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.walks),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterBar(
              value: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: walksAsync.when(
                data: (walks) {
                  // Convert Walk models to WalkEntry for UI display
                  final allWalks =
                      walks.map((w) => WalkEntry.fromWalk(w)).toList();
                  final filtered = _filteredWalks(allWalks);
                  final isEmpty = filtered.isEmpty;

                  logger.d(
                      '📱 UI REBUILD: Rendering ${allWalks.length} total walks, ${filtered.length} filtered');
                  logger.d('📱 UI FILTER: Current filter: $_filter');
                  logger.d('📱 UI EMPTY CHECK: isEmpty = $isEmpty');

                  if (filtered.isNotEmpty) {
                    logger.d('📱 UI WALKS LIST:');
                    for (int i = 0; i < filtered.length; i++) {
                      logger.d(
                          '   ${i + 1}. ${filtered[i].note} at ${filtered[i].start}');
                    }
                  } else if (allWalks.isNotEmpty) {
                    logger.d(
                        '📱 UI NOTE: ${allWalks.length} walks exist but filtered to 0 for $_filter');
                  }

                  return isEmpty
                      ? _EmptyState(onAdd: _showAddWalkSheet)
                      : _ResponsiveWalkList(
                          entries: filtered,
                          key: const PageStorageKey('walks_list'),
                          onEdit: _showEditWalkSheet,
                          onDelete: _showDeleteConfirmation,
                        );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading walks: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: l10n.addWalk,
        child: FloatingActionButton(
          onPressed: _showAddWalkSheet,
          backgroundColor: DesignColors.highlightTeal,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<WalkEntry> _filteredWalks(List<WalkEntry> source) {
    final now = DateTime.now();
    DateTime startBoundary;

    logger.d('🔍 FILTERING: Input ${source.length} walks, filter: $_filter');

    switch (_filter) {
      case WalkFilter.today:
        startBoundary = DateTime(now.year, now.month, now.day);
        logger.d('🔍 TODAY filter: Looking for walks after $startBoundary');
        break;
      case WalkFilter.thisWeek:
        final weekday = now.weekday; // 1 Mon, 7 Sun
        startBoundary = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
        logger.d('🔍 THIS WEEK filter: Looking for walks after $startBoundary');
        break;
      case WalkFilter.all:
        logger.d('🔍 ALL filter: Showing all ${source.length} walks');
        final sorted = List.of(source)
          ..sort((a, b) => b.start.compareTo(a.start));
        for (int i = 0; i < sorted.length; i++) {
          logger.d('   Walk ${i + 1}: ${sorted[i].note} at ${sorted[i].start}');
        }
        return sorted;
    }

    final list = source.where((w) {
      final isAfter = w.start.isAfter(startBoundary);
      logger.d(
          '   Walk "${w.note}" at ${w.start} - isAfter($startBoundary): $isAfter');
      return isAfter;
    }).toList();

    list.sort((a, b) => b.start.compareTo(a.start));
    logger.d('🔍 FILTER RESULT: ${list.length} walks match $_filter filter');
    return list;
  }

  void _showAddWalkSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AddWalkSheet(
        onSubmit: (entry) async {
          logger.i(
              '📝 FORM SUBMITTED - Walk Data: ${entry.note} at ${entry.start}');
          logger.i('📅 Walk Date: ${entry.start}');
          logger.i('💾 SAVING TO REPOSITORY...');

          // Convert WalkEntry to Walk model and save via repository
          final walk = entry.toWalk(petId: widget.petId);
          final repository = ref.read(walkRepositoryProvider);
          await repository.startWalk(walk);

          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.walkAddedSuccessfully)),
            );
          }

          logger.i('🔙 NAVIGATION: Returned to walks screen, data refreshed');
        },
      ),
    );
  }

  /// Show edit walk sheet with pre-filled data
  void _showEditWalkSheet(WalkEntry entry) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AddWalkSheet(
        existingEntry: entry,
        onSubmit: (updatedEntry) async {
          logger.i('✏️ EDIT SUBMITTED - Walk ID: ${updatedEntry.id}');
          logger.i('📅 Updated Walk Date: ${updatedEntry.start}');
          logger.i('💾 UPDATING IN REPOSITORY...');

          // Convert WalkEntry to Walk model and update via repository
          final walk = updatedEntry.toWalk(petId: widget.petId);
          final repository = ref.read(walkRepositoryProvider);
          await repository.updateWalk(walk);

          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.walkUpdated)),
            );
          }

          logger.i('🔙 NAVIGATION: Returned to walks screen, data refreshed');
        },
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(WalkEntry entry) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor =
        isDark ? DesignColors.dDanger : DesignColors.lDanger;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 32,
                  color: dangerColor,
                ),
              ),
              SizedBox(height: DesignSpacing.md),

              // Title
              Text(
                l10n.deleteWalk,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignSpacing.sm),

              // Message
              Text(
                l10n.deleteWalkMessage,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignSpacing.lg),

              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryText,
                        side: BorderSide(color: secondaryText.withOpacity(0.3)),
                        padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),

                  // Delete button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (entry.id == null) {
                          logger.e('❌ Cannot delete walk without ID');
                          Navigator.of(dialogContext).pop();
                          return;
                        }

                        logger.i('🗑️ DELETE CONFIRMED - Walk ID: ${entry.id}');

                        // Delete via repository
                        final repository = ref.read(walkRepositoryProvider);
                        await repository.deleteWalk(entry.id!);

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.walkDeleted)),
                          );
                        }

                        logger.i('✅ Walk deleted successfully');
                      },
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
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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
  }
}

/// Filters
enum WalkFilter { today, thisWeek, all }

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.value, required this.onChanged});

  final WalkFilter value;
  final ValueChanged<WalkFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    final labels = {
      WalkFilter.today: l10n.today,
      WalkFilter.thisWeek: l10n.thisWeek,
      WalkFilter.all: l10n.all,
    };

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      padding: EdgeInsets.all(DesignSpacing.xs),
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
        children: WalkFilter.values.map((filter) {
          final isSelected = value == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DesignColors.highlightTeal
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels[filter]!,
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
        }).toList(),
      ),
    );
  }
}

/// Responsive list: 1 column on narrow, 2 columns when width >= 600
class _ResponsiveWalkList extends StatelessWidget {
  const _ResponsiveWalkList({
    super.key,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });
  final List<WalkEntry> entries;
  final ValueChanged<WalkEntry> onEdit;
  final ValueChanged<WalkEntry> onDelete;
  static final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final useGrid = w >= 600;
        if (useGrid) {
          return GridView.builder(
            key: const PageStorageKey('walks_grid'),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 140,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: entries.length,
            itemBuilder: (context, i) => WalkCard(
              entry: entries[i],
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          );
        }
        logger.d('📋 BUILDING ListView with ${entries.length} entries');
        return ListView.separated(
          key: const PageStorageKey('walks_list'),
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            logger.d('📋 ListView building item $i: ${entries[i].note}');
            return WalkCard(
              entry: entries[i],
              onEdit: onEdit,
              onDelete: onDelete,
            );
          },
        );
      },
    );
  }
}

class WalkCard extends StatelessWidget {
  const WalkCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });
  final WalkEntry entry;
  final ValueChanged<WalkEntry> onEdit;
  final ValueChanged<WalkEntry> onDelete;
  static final logger = Logger();

  String _getLocalizedSurface(BuildContext context, String? surface) {
    if (surface == null) return 'n/a';
    final l10n = AppLocalizations.of(context);
    switch (surface) {
      case 'paved':
        return l10n.surfacePaved;
      case 'gravel':
        return l10n.surfaceGravel;
      case 'mixed':
        return l10n.surfaceMixed;
      default:
        return surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d('🃏 RENDERING WalkCard: ${entry.note} at ${entry.start}');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final time = DateFormat.Hm().format(entry.start);
    final primaryLine =
        '$time • ${entry.durationMin} ${l10n.min} • ${entry.distanceKm.toStringAsFixed(1)} ${l10n.km}';

    // Theme-aware colors
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Semantics(
      container: true,
      label: l10n.walkDetailsFor(primaryLine),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
          border: Border(
            left: BorderSide(
              color: DesignColors.highlightTeal,
              width: 4,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showWalkDetailsDialog(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon + Primary info row + Menu
                  Row(
                    children: [
                      // Walk icon with teal background
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: DesignColors.highlightTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_walk,
                          color: DesignColors.highlightTeal,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: DesignSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primaryLine,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (entry.note != null &&
                                entry.note!.isNotEmpty) ...[
                              SizedBox(height: DesignSpacing.xs),
                              Text(
                                entry.note!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: primaryText,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // 3-dot menu for edit/delete
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: secondaryText,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: surfaceColor,
                        elevation: 4,
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit(entry);
                          } else if (value == 'delete') {
                            onDelete(entry);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: primaryText,
                                ),
                                SizedBox(width: DesignSpacing.sm),
                                Text(
                                  l10n.edit,
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
                                  Icons.delete,
                                  size: 20,
                                  color: isDark
                                      ? DesignColors.dDanger
                                      : DesignColors.lDanger,
                                ),
                                SizedBox(width: DesignSpacing.sm),
                                Text(
                                  l10n.delete,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDark
                                        ? DesignColors.dDanger
                                        : DesignColors.lDanger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  // Meta row: surface and pace with icons
                  Row(
                    children: [
                      Icon(
                        Icons.terrain,
                        size: 14,
                        color: secondaryText,
                      ),
                      SizedBox(width: DesignSpacing.xs),
                      Text(
                        '${l10n.surfaceLabel}: ${_getLocalizedSurface(context, entry.surface)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: secondaryText,
                        ),
                      ),
                      SizedBox(width: DesignSpacing.md),
                      Icon(
                        Icons.speed,
                        size: 14,
                        color: secondaryText,
                      ),
                      SizedBox(width: DesignSpacing.xs),
                      Flexible(
                        child: Text(
                          '${l10n.pace}: ${entry.paceMinPerKm?.toStringAsFixed(0) ?? '—'}\'/km',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showWalkDetailsDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.walkDetails,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignSpacing.lg),
              _WalkDetails(entry: entry),
              SizedBox(height: DesignSpacing.lg),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: DesignColors.highlightTeal,
                  padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                ),
                child: Text(
                  l10n.close,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Theme-aware colors
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Paw icon with teal circle background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: DesignColors.highlightTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets,
                size: 56,
                color: DesignColors.highlightTeal,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.noWalksYet,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.trackFirstWalk,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            Semantics(
              button: true,
              label: l10n.addFirstWalk,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  l10n.addFirstWalk,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkDetails extends StatelessWidget {
  const _WalkDetails({required this.entry});
  final WalkEntry entry;

  String _getLocalizedSurface(BuildContext context, String? surface) {
    if (surface == null) return 'n/a';
    final l10n = AppLocalizations.of(context);
    switch (surface) {
      case 'paved':
        return l10n.surfacePaved;
      case 'gravel':
        return l10n.surfaceGravel;
      case 'mixed':
        return l10n.surfaceMixed;
      default:
        return surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final df = DateFormat(
        'EEE, MMM d • HH:mm', Localizations.localeOf(context).toString());
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(
          label: l10n.start,
          value: df.format(entry.start),
          icon: Icons.calendar_today,
        ),
        _DetailRow(
          label: l10n.durationMin,
          value: '${entry.durationMin} ${l10n.min}',
          icon: Icons.timer,
        ),
        _DetailRow(
          label: l10n.distance,
          value: '${entry.distanceKm.toStringAsFixed(2)} ${l10n.km}',
          icon: Icons.straighten,
        ),
        if (entry.paceMinPerKm != null)
          _DetailRow(
            label: l10n.pace,
            value: "${entry.paceMinPerKm!.toStringAsFixed(0)}'/km",
            icon: Icons.speed,
          ),
        if (entry.surface != null)
          _DetailRow(
            label: l10n.surfaceLabel,
            value: _getLocalizedSurface(context, entry.surface),
            icon: Icons.terrain,
          ),
        if (entry.note?.isNotEmpty == true)
          _DetailRow(
            label: l10n.notes,
            value: entry.note!,
            icon: Icons.notes,
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DesignColors.highlightTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: DesignColors.highlightTeal,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
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
}

// WalkEntry model moved to walks_state.dart

/// Add/Edit walk sheet with form fields for walk data.
/// When [existingEntry] is provided, the sheet operates in edit mode.
class _AddWalkSheet extends StatefulWidget {
  const _AddWalkSheet({
    required this.onSubmit,
    this.existingEntry,
  });
  final ValueChanged<WalkEntry> onSubmit;
  final WalkEntry? existingEntry;

  /// Whether this sheet is in edit mode
  bool get isEditing => existingEntry != null;

  @override
  State<_AddWalkSheet> createState() => _AddWalkSheetState();
}

class _AddWalkSheetState extends State<_AddWalkSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _durationCtrl;
  late final TextEditingController _distanceCtrl;
  late final TextEditingController _noteCtrl;
  late String? _surface;
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    // Pre-fill form fields if editing an existing entry
    final entry = widget.existingEntry;
    _durationCtrl = TextEditingController(
      text: entry?.durationMin.toString() ?? '30',
    );
    _distanceCtrl = TextEditingController(
      text: entry?.distanceKm.toString() ?? '2.0',
    );
    _noteCtrl = TextEditingController(
      text: entry?.note ?? '',
    );
    _surface = entry?.surface ?? 'paved';
    _start = entry?.start ?? DateTime.now();
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _distanceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final df = DateFormat(
        'EEE, MMM d • HH:mm', Localizations.localeOf(context).toString());

    // Theme-aware colors
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    // Teal-focused input decoration
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark
          ? DesignColors.dSurfaces.withOpacity(0.5)
          : DesignColors.lSurfaces,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryText.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryText.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DesignColors.highlightTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: DesignSpacing.lg,
          right: DesignSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + DesignSpacing.lg,
          top: DesignSpacing.sm,
        ),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: secondaryText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: DesignSpacing.md),

                // Title - changes based on add/edit mode
                Text(
                  widget.isEditing ? l10n.editWalk : l10n.addWalk,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.lg),

                // Start date/time field
                _RowField(
                  label: l10n.start,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now(),
                        initialDate: _start,
                      );
                      if (date == null) return;
                      if (!mounted) return;
                      final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_start));
                      if (time == null || !mounted) return;
                      setState(() => _start = DateTime(date.year, date.month,
                          date.day, time.hour, time.minute));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignColors.highlightTeal,
                      side: const BorderSide(color: DesignColors.highlightTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.md,
                        vertical: DesignSpacing.sm,
                      ),
                    ),
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(
                      df.format(_start),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Duration field
                _RowField(
                  label: l10n.durationMin,
                  child: TextFormField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(fontSize: 14, color: primaryText),
                    decoration: inputDecoration.copyWith(
                      suffixText: l10n.min,
                      hintText: '30',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryText,
                      ),
                    ),
                    validator: _positiveInt,
                  ),
                ),

                // Distance field
                _RowField(
                  label: l10n.distance,
                  child: TextFormField(
                    controller: _distanceCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(fontSize: 14, color: primaryText),
                    decoration: inputDecoration.copyWith(
                      suffixText: l10n.km,
                      hintText: '2.0',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryText,
                      ),
                    ),
                    validator: _positiveDouble,
                  ),
                ),

                // Surface dropdown
                _RowField(
                  label: l10n.surfaceLabel,
                  child: DropdownButtonFormField<String>(
                    value: _surface,
                    style: GoogleFonts.inter(fontSize: 14, color: primaryText),
                    decoration: inputDecoration,
                    dropdownColor: surfaceColor,
                    items: [
                      DropdownMenuItem(
                        value: 'paved',
                        child: Text(
                          l10n.surfacePaved,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: primaryText,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'gravel',
                        child: Text(
                          l10n.surfaceGravel,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: primaryText,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'mixed',
                        child: Text(
                          l10n.surfaceMixed,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: primaryText,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _surface = v),
                  ),
                ),

                // Notes field
                _RowField(
                  label: l10n.notes,
                  child: TextFormField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    style: GoogleFonts.inter(fontSize: 14, color: primaryText),
                    decoration: inputDecoration.copyWith(
                      hintText: l10n.optional,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryText,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: DesignSpacing.lg),

                // Add/Update button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_form.currentState!.validate()) return;
                      final entry = WalkEntry(
                        // Preserve ID when editing for proper update
                        id: widget.existingEntry?.id,
                        start: _start,
                        durationMin: int.parse(_durationCtrl.text),
                        distanceKm: double.parse(_distanceCtrl.text),
                        note: _noteCtrl.text.trim().isEmpty
                            ? null
                            : _noteCtrl.text.trim(),
                        surface: _surface,
                        paceMinPerKm: null,
                      );
                      widget.onSubmit(entry);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.highlightTeal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isEditing ? l10n.update : l10n.add,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _positiveInt(String? v) {
    final l10n = AppLocalizations.of(context);
    if (v == null || v.trim().isEmpty) return l10n.required;
    final n = int.tryParse(v);
    if (n == null || n <= 0) return l10n.enterPositiveNumber;
    return null;
  }

  String? _positiveDouble(String? v) {
    final l10n = AppLocalizations.of(context);
    if (v == null || v.trim().isEmpty) return l10n.required;
    final n = double.tryParse(v);
    if (n == null || n <= 0) return l10n.enterPositiveNumber;
    return null;
  }
}

class _RowField extends StatelessWidget {
  const _RowField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(child: child),
        ],
      ),
    );
  }
}
