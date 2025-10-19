// lib/src/ui/screens/feedings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/layout/app_page.dart';
import 'package:fur_friend_diary/theme/spacing.dart';
import 'package:logger/logger.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/feeding_form_state_provider.dart';
import '../../domain/models/feeding_entry.dart';
import '../../data/repositories/feeding_repository_impl.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../../l10n/app_localizations.dart';

final _logger = Logger();
final _uuid = Uuid();

class FeedingsScreen extends ConsumerStatefulWidget {
  const FeedingsScreen({super.key});

  @override
  ConsumerState<FeedingsScreen> createState() => _FeedingsScreenState();
}

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

    return ListTile(
      leading: const Icon(Icons.pets),
      title: Text(item.foodType),
      subtitle: Text(TimeOfDay.fromDateTime(item.dateTime).format(context)),
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

class _FeedingsScreenState extends ConsumerState<FeedingsScreen> {
  Future<void> _showFeedingDetails(FeedingEntry feeding) async {
    final l10n = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feeding.foodType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${l10n.date}: ${TimeOfDay.fromDateTime(feeding.dateTime).format(context)}'),
            if (feeding.amount > 0) Text('${l10n.amount}: ${feeding.amount}'),
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
    _logger.i('🍽️ FEEDING FORM: Opening add feeding dialog');
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AddFeedingSheet(
        onSubmit: (feeding) {
          _logger.i(
              '🍽️ FEEDING FORM: Form submitted with foodType: ${feeding.foodType}');
          _addFeeding(feeding);
        },
      ),
    ).then((_) {
      _logger.i('🍽️ FEEDING FORM: Dialog closed');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final currentPet = ref.watch(currentPetProfileProvider);
    final feedingsAsync =
        ref.watch(feedingsByPetIdProvider(currentPet?.id ?? ''));

    return AppPage(
      title: currentPet != null
          ? l10n.petFeedings(currentPet.name)
          : l10n.feedings,
      body: Column(
        children: [
          // Pet Profile Display
          if (currentPet != null) ...[
            InkWell(
              onTap: () {
                // Navigate to pet profiles screen
                context.go('/profiles');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: scheme.primary,
                      child: Text(
                        currentPet.name.isNotEmpty
                            ? currentPet.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPet.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${currentPet.species} • ${currentPet.breed ?? l10n.mixed}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.pets,
                      color: scheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Feedings Content
          Expanded(
            child: feedingsAsync.when(
              data: (feedings) => feedings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: scheme.onSurface.withOpacity(0.08),
                            child: Icon(Icons.restaurant,
                                size: 28,
                                color: scheme.onSurface.withOpacity(0.60)),
                          ),
                          const SizedBox(height: AppSpacing.s5),
                          Text(
                            currentPet != null
                                ? l10n.noFeedingsRecorded(currentPet.name)
                                : l10n.noFeedingsRecordedGeneric,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: scheme.onSurface.withOpacity(0.7),
                                    ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _showAddFeedingDialog,
                            child: Text(l10n.addFirstFeeding),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(feedingsByPetIdProvider(currentPet!.id));
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: feedings.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _FeedingTile(
                          item: feedings[i],
                          onTap: () => _showFeedingDetails(feedings[i]),
                          onEdit: () => _editFeeding(feedings[i]),
                          onDelete: () => _deleteFeeding(feedings[i]),
                        ),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('${l10n.errorLoadingFeedings}: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFeedingDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.feeding != null;

    if (_isEditMode) {
      // Edit mode - pre-fill with existing data
      _foodTypeController.text = widget.feeding!.foodType;
      _amountController.text = widget.feeding!.amount.toString();
      _notesController.text = widget.feeding!.notes ?? '';
      _selectedPetId = widget.feeding!.petId;
      _selectedDateTime = widget.feeding!.dateTime;
      _logger.i(
          '🍽️ FEEDING FORM: Edit mode - Pre-filled with existing feeding data');
    } else {
      // Add mode - use draft state
      final formState = ref.read(feedingFormStateNotifierProvider);
      _foodTypeController.text = formState.foodType;
      _selectedPetId = ref.read(currentPetProfileProvider)?.id;
      _logger.i(
          '🍽️ FEEDING FORM: Add mode - Initial foodType from provider: "${formState.foodType}"');
    }
  }

  void _clearDraftState() {
    _logger.i('🍽️ FEEDING FORM: Clearing draft state');
    _foodTypeController.clear();
    _amountController.clear();
    _notesController.clear();
    ref.read(feedingFormStateNotifierProvider.notifier).clearForm();
    setState(() {
      _selectedDateTime = DateTime.now();
    });
    _logger.i('🍽️ FEEDING FORM: Draft state cleared');
  }

  @override
  void dispose() {
    _logger.i('🍽️ FEEDING FORM: dispose() - Cleaning up form');
    _foodTypeController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final petsAsync = ref.watch(petProfilesProvider);

    if (!_isEditMode) {
      ref.listen(feedingFormStateNotifierProvider, (previous, next) {
        _logger.i(
            '🍽️ FEEDING FORM: Provider state changed - foodType: "${next.foodType}"');
        if (next.foodType != _foodTypeController.text) {
          _logger.i('🍽️ FEEDING FORM: Syncing controller to provider state');
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
                        value: _selectedPetId,
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

              // Food Type
              TextFormField(
                controller: _foodTypeController,
                decoration: InputDecoration(
                  labelText: '${l10n.foodType} *',
                  hintText: l10n.foodTypeHint,
                  prefixIcon: const Icon(Icons.restaurant),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterFoodType;
                  }
                  return null;
                },
                onChanged: (value) {
                  if (!_isEditMode) {
                    ref
                        .read(feedingFormStateNotifierProvider.notifier)
                        .updateFoodType(value);
                  }
                },
              ),
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
                  final navigator = Navigator.of(context);

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
                          final feeding = _isEditMode
                              ? widget.feeding!.copyWith(
                                  petId: _selectedPetId,
                                  foodType: _foodTypeController.text,
                                  amount: double.parse(_amountController.text),
                                  dateTime: _selectedDateTime,
                                  notes: _notesController.text.isEmpty
                                      ? null
                                      : _notesController.text,
                                )
                              : FeedingEntry(
                                  id: _uuid.v4(),
                                  petId: _selectedPetId!,
                                  foodType: _foodTypeController.text,
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
