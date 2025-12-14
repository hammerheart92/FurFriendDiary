// lib/src/presentation/screens/feedings/feeding_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/feeding_entry.dart';
import '../../../data/repositories/feeding_repository_impl.dart';
import '../../providers/care_data_provider.dart';
import '../../providers/pet_profile_provider.dart';
import '../../providers/feeding_form_state_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/date_helper.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';

final _logger = Logger(); // ignore: prefer_const_constructors
final _uuid = Uuid();

class FeedingHistoryScreen extends ConsumerStatefulWidget {
  const FeedingHistoryScreen({super.key});

  @override
  ConsumerState<FeedingHistoryScreen> createState() =>
      _FeedingHistoryScreenState();
}

class _FeedingHistoryScreenState extends ConsumerState<FeedingHistoryScreen> {
  Future<void> _showFeedingDetails(FeedingEntry feeding) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    final formattedDateTime =
        '${relativeDateLabel(context, feeding.dateTime)} ${l10n.at} ${localizedTime(context, feeding.dateTime)}';

    final foodColor = _getFoodTypeColor(feeding.foodType);
    final foodIcon = _getFoodTypeIcon(feeding.foodType);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: DesignShadows.lg,
          ),
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Food type icon
              Container(
                padding: EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  color: foodColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  foodIcon,
                  size: 48,
                  color: foodColor,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                feeding.foodType,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              // Details
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignColors.dBackground
                      : DesignColors.lBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 16, color: DesignColors.highlightTeal),
                        SizedBox(width: DesignSpacing.sm),
                        Expanded(
                          child: Text(
                            formattedDateTime,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: primaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (feeding.amount > 0) ...[
                      SizedBox(height: DesignSpacing.sm),
                      Row(
                        children: [
                          Icon(Icons.scale,
                              size: 16, color: DesignColors.highlightTeal),
                          SizedBox(width: DesignSpacing.sm),
                          Text(
                            '${feeding.amount.toStringAsFixed(0)} g',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (feeding.notes != null && feeding.notes!.isNotEmpty) ...[
                      SizedBox(height: DesignSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note,
                              size: 16, color: DesignColors.highlightTeal),
                          SizedBox(width: DesignSpacing.sm),
                          Expanded(
                            child: Text(
                              feeding.notes!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: DesignSpacing.lg),
              // Close button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignColors.highlightTeal,
                    padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                  ),
                  child: Text(
                    l10n.close,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editFeeding(FeedingEntry feeding) async {
    _logger.i('Edit feeding: ${feeding.id}');
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AddFeedingSheet(
        feeding: feeding,
        onSubmit: (updatedFeeding) {
          _updateFeeding(updatedFeeding);
        },
      ),
    );
  }

  Future<void> _updateFeeding(FeedingEntry feeding) async {
    try {
      await ref.read(feedingRepositoryProvider).updateFeeding(feeding);
      final currentPet = ref.read(currentPetProfileProvider);
      if (currentPet != null) {
        ref.invalidate(feedingsByPetIdProvider(currentPet.id));
      }
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.feedingAdded(feeding.foodType)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _logger.e('Failed to update feeding: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToSaveFeeding}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteFeeding(FeedingEntry feeding) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: DesignShadows.lg,
          ),
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  color: DesignColors.lDanger.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_outlined,
                  size: 48,
                  color: DesignColors.lDanger,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                l10n.confirmDelete,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                l10n.deleteConfirmationMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.inter(
                        color: secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.lDanger,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.lg,
                        vertical: DesignSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.delete,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(feedingRepositoryProvider).deleteFeeding(feeding.id);
        final currentPet = ref.read(currentPetProfileProvider);
        if (currentPet != null) {
          ref.invalidate(feedingsByPetIdProvider(currentPet.id));
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.feedingDeleted,
                style: GoogleFonts.inter(),
              ),
              backgroundColor: DesignColors.highlightTeal,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        _logger.e('Failed to delete feeding: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.failedToSaveFeeding}: $e',
                style: GoogleFonts.inter(),
              ),
              backgroundColor: DesignColors.lDanger,
            ),
          );
        }
      }
    }
  }

  Future<void> _addFeeding(FeedingEntry feeding) async {
    try {
      await ref.read(feedingRepositoryProvider).addFeeding(feeding);
      final currentPet = ref.read(currentPetProfileProvider);
      if (currentPet != null) {
        ref.invalidate(feedingsByPetIdProvider(currentPet.id));
      }
      _logger.i('Feeding "${feeding.foodType}" saved to Hive successfully');

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.feedingAdded(feeding.foodType)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _logger.e('Failed to save feeding: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToSaveFeeding}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showAddFeedingDialog() async {
    _logger.i('Opening add feeding dialog');
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AddFeedingSheet(
        onSubmit: (feeding) {
          _addFeeding(feeding);
        },
      ),
    );
  }

  /// Get color for food type
  Color _getFoodTypeColor(String foodType) {
    final lowerType = foodType.toLowerCase();
    if (lowerType.contains('dry')) return DesignColors.highlightCoral;
    if (lowerType.contains('wet')) return DesignColors.highlightTeal;
    if (lowerType.contains('treat')) return DesignColors.highlightPink;
    if (lowerType.contains('snack')) return DesignColors.highlightYellow;
    return DesignColors.highlightBlue;
  }

  /// Get icon for food type
  IconData _getFoodTypeIcon(String foodType) {
    final lowerType = foodType.toLowerCase();
    if (lowerType.contains('dry')) return Icons.pets;
    if (lowerType.contains('wet')) return Icons.restaurant_menu;
    if (lowerType.contains('treat')) return Icons.cookie;
    if (lowerType.contains('snack')) return Icons.fastfood;
    return Icons.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final currentPet = ref.watch(currentPetProfileProvider);

    final feedingsAsync =
        ref.watch(feedingsByPetIdProvider(currentPet?.id ?? ''));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.feedingHistory,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: feedingsAsync.when(
        data: (feedings) {
          if (feedings.isEmpty) {
            return _buildEmptyState(context, l10n, primaryText, secondaryText);
          }

          // Sort feedings by date (newest first)
          final sortedFeedings = List<FeedingEntry>.from(feedings)
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return RefreshIndicator(
            color: DesignColors.highlightTeal,
            onRefresh: () async {
              final pet = ref.read(currentPetProfileProvider);
              if (pet != null) {
                ref.invalidate(feedingsByPetIdProvider(pet.id));
              }
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: DesignSpacing.md,
                horizontal: DesignSpacing.md,
              ),
              itemCount: sortedFeedings.length,
              itemBuilder: (_, index) => _FeedingTile(
                item: sortedFeedings[index],
                onTap: () => _showFeedingDetails(sortedFeedings[index]),
                onEdit: () => _editFeeding(sortedFeedings[index]),
                onDelete: () => _deleteFeeding(sortedFeedings[index]),
                getFoodTypeColor: _getFoodTypeColor,
                getFoodTypeIcon: _getFoodTypeIcon,
              ),
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: DesignColors.highlightTeal,
          ),
        ),
        error: (error, stack) => _buildErrorState(context, l10n, error, primaryText),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFeedingDialog,
        backgroundColor: DesignColors.highlightTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          l10n.addNewFeeding,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    Color primaryText,
    Color secondaryText,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 80,
              color: DesignColors.highlightCoral.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.sm),
            Icon(
              Icons.food_bank_outlined,
              size: 64,
              color: DesignColors.highlightTeal.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              l10n.noFeedingLogsYet,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xs),
            Text(
              l10n.feedingLogEmpty,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: _showAddFeedingDialog,
              icon: const Icon(Icons.add),
              label: Text(l10n.addFirstFeeding),
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
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    Object error,
    Color primaryText,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: DesignColors.lDanger,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              '${l10n.errorLoadingFeedings}: $error',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display a single feeding entry in the list
class _FeedingTile extends StatelessWidget {
  final FeedingEntry item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color Function(String) getFoodTypeColor;
  final IconData Function(String) getFoodTypeIcon;

  const _FeedingTile({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.getFoodTypeColor,
    required this.getFoodTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    final formattedDateTime =
        '${relativeDateLabel(context, item.dateTime)} ${l10n.at} ${localizedTime(context, item.dateTime)}';

    final foodColor = getFoodTypeColor(item.foodType);
    final foodIcon = getFoodTypeIcon(item.foodType);

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: foodColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            foodIcon,
            color: foodColor,
            size: 24,
          ),
        ),
        title: Text(
          item.foodType,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: DesignSpacing.xs),
            Text(
              formattedDateTime,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
            ),
            if (item.amount > 0) ...[
              SizedBox(height: DesignSpacing.xs),
              Row(
                children: [
                  Icon(Icons.scale, size: 14, color: secondaryText),
                  SizedBox(width: DesignSpacing.xs),
                  Text(
                    '${item.amount.toStringAsFixed(0)} g',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: secondaryText),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: surfaceColor,
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: DesignColors.highlightTeal,
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Text(
                    l10n.edit,
                    style: GoogleFonts.inter(color: primaryText),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: DesignColors.lDanger,
                  ),
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
        onTap: onTap,
      ),
    );
  }
}

/// Bottom sheet form for adding/editing feeding entries
class _AddFeedingSheet extends ConsumerStatefulWidget {
  const _AddFeedingSheet({
    required this.onSubmit,
    this.feeding,
  });
  final ValueChanged<FeedingEntry> onSubmit;
  final FeedingEntry? feeding;

  @override
  ConsumerState<_AddFeedingSheet> createState() => _AddFeedingSheetState();
}

class _AddFeedingSheetState extends ConsumerState<_AddFeedingSheet> {
  final _form = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPetId;
  DateTime _selectedDateTime = DateTime.now();
  bool _isEditMode = false;

  static const List<String> _commonFoodTypes = [
    'dryFood',
    'wetFood',
    'treats',
    'rawFood',
    'chicken',
    'fish',
    'turkey',
    'beef',
    'vegetables',
    'other',
  ];

  String? _selectedFoodTypeKey;
  bool _showCustomFoodTypeField = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.feeding != null;

    if (_isEditMode) {
      _foodTypeController.text = widget.feeding!.foodType;
      _amountController.text = widget.feeding!.amount.toString();
      _notesController.text = widget.feeding!.notes ?? '';
      _selectedPetId = widget.feeding!.petId;
      _selectedDateTime = widget.feeding!.dateTime;
    } else {
      final formState = ref.read(feedingFormStateNotifierProvider);
      _foodTypeController.text = formState.foodType;
      _selectedPetId = ref.read(currentPetProfileProvider)?.id;
    }
  }

  void _clearDraftState() {
    _foodTypeController.clear();
    _amountController.clear();
    _notesController.clear();
    ref.read(feedingFormStateNotifierProvider.notifier).clearForm();
    setState(() {
      _selectedDateTime = DateTime.now();
      _selectedFoodTypeKey = null;
      _showCustomFoodTypeField = false;
    });
  }

  @override
  void dispose() {
    _foodTypeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getLocalizedFoodType(String foodTypeKey, AppLocalizations l10n) {
    switch (foodTypeKey) {
      case 'dryFood':
        return l10n.foodTypeDryFood;
      case 'wetFood':
        return l10n.foodTypeWetFood;
      case 'treats':
        return l10n.foodTypeTreats;
      case 'rawFood':
        return l10n.foodTypeRawFood;
      case 'chicken':
        return l10n.foodTypeChicken;
      case 'fish':
        return l10n.foodTypeFish;
      case 'turkey':
        return l10n.foodTypeTurkey;
      case 'beef':
        return l10n.foodTypeBeef;
      case 'vegetables':
        return l10n.foodTypeVegetables;
      case 'other':
        return l10n.foodTypeOther;
      default:
        return foodTypeKey;
    }
  }

  String? _detectFoodTypeKey(String existingFoodType, AppLocalizations l10n) {
    for (final foodTypeKey in _commonFoodTypes) {
      final localizedValue = _getLocalizedFoodType(foodTypeKey, l10n);
      if (existingFoodType.toLowerCase() == localizedValue.toLowerCase()) {
        return foodTypeKey;
      }
    }
    return 'other';
  }

  /// Build consistent input decoration with design system
  InputDecoration _buildInputDecoration({
    required String label,
    required IconData prefixIcon,
    IconData? suffixIcon,
    String? suffixText,
    String? hintText,
    bool alignLabelTop = false,
    required Color secondaryText,
    required Color surfaceColor,
    required Color disabledColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
      hintText: hintText,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
      alignLabelWithHint: alignLabelTop,
      prefixIcon: alignLabelTop
          ? Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(prefixIcon, color: DesignColors.highlightTeal),
            )
          : Icon(prefixIcon, color: DesignColors.highlightTeal),
      suffixIcon:
          suffixIcon != null ? Icon(suffixIcon, color: secondaryText) : null,
      suffixText: suffixText,
      suffixStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondaryText,
      ),
      filled: true,
      fillColor: surfaceColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: disabledColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DesignColors.highlightTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DesignColors.lDanger, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DesignColors.lDanger, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final disabledColor =
        isDark ? DesignColors.dDisabled : DesignColors.lDisabled;
    final petsAsync = ref.watch(petProfilesProvider);

    if (widget.feeding != null && _selectedFoodTypeKey == null) {
      final detectedKey = _detectFoodTypeKey(widget.feeding!.foodType, l10n);
      _selectedFoodTypeKey = detectedKey;
      _showCustomFoodTypeField = (detectedKey == 'other');

      if (detectedKey == 'other') {
        _foodTypeController.text = widget.feeding!.foodType;
      }
    }

    if (!_isEditMode) {
      ref.listen(feedingFormStateNotifierProvider, (previous, next) {
        if (next.foodType != _foodTypeController.text) {
          _foodTypeController.text = next.foodType;
        }
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        left: DesignSpacing.md,
        right: DesignSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + DesignSpacing.md,
        top: DesignSpacing.sm,
      ),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: disabledColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: DesignSpacing.md),

              // Title
              Text(
                _isEditMode ? l10n.editFeeding : l10n.addNewFeeding,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.lg),

              // Pet Selection (if multiple pets exist)
              petsAsync.when(
                data: (pets) {
                  if (pets.length > 1) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: DesignSpacing.md),
                      child: DropdownButtonFormField<String>(
                        value: _selectedPetId,
                        decoration: _buildInputDecoration(
                          label: '${l10n.pet} *',
                          prefixIcon: Icons.pets,
                          secondaryText: secondaryText,
                          surfaceColor: surfaceColor,
                          disabledColor: disabledColor,
                        ),
                        dropdownColor: surfaceColor,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: primaryText,
                        ),
                        items: pets
                            .map((pet) => DropdownMenuItem(
                                  value: pet.id,
                                  child: Text(pet.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPetId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseSelectPet;
                          }
                          return null;
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Food Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedFoodTypeKey,
                decoration: _buildInputDecoration(
                  label: '${l10n.foodType} *',
                  prefixIcon: Icons.restaurant,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                ),
                dropdownColor: surfaceColor,
                style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                items: _commonFoodTypes.map((foodTypeKey) {
                  return DropdownMenuItem(
                    value: foodTypeKey == 'other' ? 'other' : foodTypeKey,
                    child: Text(_getLocalizedFoodType(foodTypeKey, l10n)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFoodTypeKey = value;
                    _showCustomFoodTypeField = (value == 'other');

                    if (value != 'other') {
                      _foodTypeController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value != null && value != 'other') return null;

                  if (_showCustomFoodTypeField &&
                      _foodTypeController.text.trim().isEmpty) {
                    return l10n.pleaseEnterFoodType;
                  }

                  if (value == 'other' &&
                      _foodTypeController.text.trim().isNotEmpty) {
                    return null;
                  }

                  if (value == null) {
                    return l10n.pleaseEnterFoodType;
                  }

                  return null;
                },
              ),

              // Show custom text field if "Other" is selected
              if (_showCustomFoodTypeField) ...[
                SizedBox(height: DesignSpacing.md),
                TextFormField(
                  controller: _foodTypeController,
                  decoration: _buildInputDecoration(
                    label: l10n.foodTypeCustomPlaceholder,
                    hintText: l10n.foodTypeHint,
                    prefixIcon: Icons.edit,
                    secondaryText: secondaryText,
                    surfaceColor: surfaceColor,
                    disabledColor: disabledColor,
                  ),
                  style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                  validator: (value) {
                    if (_showCustomFoodTypeField &&
                        (value == null || value.trim().isEmpty)) {
                      return l10n.pleaseEnterFoodType;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (!_isEditMode && _showCustomFoodTypeField) {
                      ref
                          .read(feedingFormStateNotifierProvider.notifier)
                          .updateFoodType(value);
                    }
                  },
                ),
              ],
              SizedBox(height: DesignSpacing.md),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: _buildInputDecoration(
                  label: '${l10n.amount} *',
                  hintText: '0.0',
                  prefixIcon: Icons.scale,
                  suffixText: 'g',
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                ),
                style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterAmount;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.enterPositiveNumber;
                  }
                  return null;
                },
              ),
              SizedBox(height: DesignSpacing.md),

              // Timestamp Picker
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  if (!mounted) return;

                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null && mounted) {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );
                    if (time != null && mounted) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: InputDecorator(
                  decoration: _buildInputDecoration(
                    label: l10n.feedingTime,
                    prefixIcon: Icons.access_time,
                    suffixIcon: Icons.calendar_today,
                    secondaryText: secondaryText,
                    surfaceColor: surfaceColor,
                    disabledColor: disabledColor,
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(_selectedDateTime),
                    style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                  ),
                ),
              ),
              SizedBox(height: DesignSpacing.md),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: _buildInputDecoration(
                  label: l10n.notes,
                  hintText: l10n.addNotesOptional,
                  prefixIcon: Icons.note,
                  alignLabelTop: true,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                ),
                style: GoogleFonts.inter(fontSize: 16, color: primaryText),
                maxLines: 3,
              ),
              SizedBox(height: DesignSpacing.lg),

              // Action Buttons
              Row(
                children: [
                  if (!_isEditMode) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearDraftState,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: secondaryText,
                          side: BorderSide(color: disabledColor),
                          padding:
                              EdgeInsets.symmetric(vertical: DesignSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.clear,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: DesignSpacing.md),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_form.currentState!.validate()) {
                          String finalFoodType;
                          if (_selectedFoodTypeKey != null &&
                              _selectedFoodTypeKey != 'other') {
                            finalFoodType = _getLocalizedFoodType(
                                _selectedFoodTypeKey!, l10n);
                          } else {
                            finalFoodType = _foodTypeController.text.trim();
                          }

                          final feeding = _isEditMode
                              ? widget.feeding!.copyWith(
                                  petId: _selectedPetId,
                                  foodType: finalFoodType,
                                  amount: double.parse(_amountController.text),
                                  dateTime: _selectedDateTime,
                                  notes: _notesController.text.isEmpty
                                      ? null
                                      : _notesController.text,
                                )
                              : FeedingEntry(
                                  id: _uuid.v4(),
                                  petId: _selectedPetId!,
                                  foodType: finalFoodType,
                                  amount: double.parse(_amountController.text),
                                  dateTime: _selectedDateTime,
                                  notes: _notesController.text.isEmpty
                                      ? null
                                      : _notesController.text,
                                );

                          widget.onSubmit(feeding);
                          if (!_isEditMode) {
                            _clearDraftState();
                          }
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColors.highlightTeal,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: DesignSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isEditMode ? l10n.save : l10n.add,
                        style: GoogleFonts.inter(
                          fontSize: 16,
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
