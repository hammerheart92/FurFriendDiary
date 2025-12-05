// lib/src/presentation/screens/feedings/feeding_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../../domain/models/feeding_entry.dart';
import '../../../data/repositories/feeding_repository_impl.dart';
import '../../providers/care_data_provider.dart';
import '../../providers/pet_profile_provider.dart';
import '../../providers/feeding_form_state_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../utils/date_helper.dart';

final _logger = Logger();  // ignore: prefer_const_constructors
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

    final formattedDateTime =
        '${relativeDateLabel(context, feeding.dateTime)} ${l10n.at} ${localizedTime(context, feeding.dateTime)}';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feeding.foodType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.date}: $formattedDateTime'),
            if (feeding.amount > 0) Text('${l10n.amount}: ${feeding.amount}'),
            if (feeding.notes != null && feeding.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.notes}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(feeding.notes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
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
              content: Text(l10n.feedingDeleted),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        _logger.e('Failed to delete feeding: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.failedToSaveFeeding}: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final currentPet = ref.watch(currentPetProfileProvider);

    final feedingsAsync =
        ref.watch(feedingsByPetIdProvider(currentPet?.id ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedingHistory),
      ),
      body: feedingsAsync.when(
        data: (feedings) {
          if (feedings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noFeedingLogsYet,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.feedingLogEmpty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _showAddFeedingDialog,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addFirstFeeding),
                    ),
                  ],
                ),
              ),
            );
          }

          // Sort feedings by date (newest first)
          final sortedFeedings = List<FeedingEntry>.from(feedings)
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(feedingsByPetIdProvider(currentPet!.id));
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: sortedFeedings.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) => _FeedingTile(
                item: sortedFeedings[index],
                onTap: () => _showFeedingDetails(sortedFeedings[index]),
                onEdit: () => _editFeeding(sortedFeedings[index]),
                onDelete: () => _deleteFeeding(sortedFeedings[index]),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: scheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '${l10n.errorLoadingFeedings}: $error',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFeedingDialog,
        child: const Icon(Icons.add),
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

  const _FeedingTile({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final formattedDateTime =
        '${relativeDateLabel(context, item.dateTime)} ${l10n.at} ${localizedTime(context, item.dateTime)}';

    return ListTile(
      leading: const Icon(Icons.pets),
      title: Text(item.foodType),
      subtitle: Text(formattedDateTime),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
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
                const Icon(Icons.edit),
                const SizedBox(width: 8),
                Text(l10n.edit),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red),
                const SizedBox(width: 8),
                Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      minVerticalPadding: 12,
      onTap: onTap,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 8,
      ),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? l10n.editFeeding : l10n.addNewFeeding,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Pet Selection (if multiple pets exist)
              petsAsync.when(
                data: (pets) {
                  if (pets.length > 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPetId,
                        decoration: InputDecoration(
                          labelText: '${l10n.pet} *',
                          prefixIcon: const Icon(Icons.pets),
                          border: const OutlineInputBorder(),
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
                initialValue: _selectedFoodTypeKey,
                decoration: InputDecoration(
                  labelText: '${l10n.foodType} *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.restaurant),
                ),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _foodTypeController,
                  decoration: InputDecoration(
                    labelText: l10n.foodTypeCustomPlaceholder,
                    hintText: l10n.foodTypeHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.edit),
                  ),
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
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: '${l10n.amount} *',
                  hintText: '0.0',
                  prefixIcon: const Icon(Icons.fitness_center),
                  suffixText: 'g',
                  border: const OutlineInputBorder(),
                ),
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
              const SizedBox(height: 16),

              // Timestamp Picker
              InkWell(
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
                  decoration: InputDecoration(
                    labelText: l10n.feedingTime,
                    prefixIcon: const Icon(Icons.access_time),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(_selectedDateTime),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  hintText: l10n.addNotesOptional,
                  prefixIcon: const Icon(Icons.note),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  if (!_isEditMode) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearDraftState,
                        child: Text(l10n.clear),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
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
                      child: Text(_isEditMode ? l10n.save : l10n.add),
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
