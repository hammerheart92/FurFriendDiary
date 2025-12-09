// lib/src/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/layout/app_page.dart';
import 'package:logger/logger.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/feeding_form_state_provider.dart';
import '../../domain/models/feeding_entry.dart';
import '../../data/repositories/feeding_repository_impl.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../presentation/providers/protocols/protocol_schedule_provider.dart';
import '../../presentation/models/upcoming_care_event.dart';
import '../../presentation/widgets/upcoming_care_card_widget.dart';

final _logger = Logger();
final _uuid = Uuid();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

    // Watch upcoming care events for the current pet
    final upcomingCareAsync = currentPet != null
        ? ref.watch(upcomingCareProvider(
            petId: currentPet.id,
            daysAhead: 14, // Next 2 weeks for dashboard
          ))
        : const AsyncValue.data(<UpcomingCareEvent>[]);

    return AppPage(
      title: currentPet != null ? l10n.petHome(currentPet.name) : l10n.home,
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

            // Upcoming Care Section
            if (currentPet != null) ...[
              upcomingCareAsync.when(
                data: (events) {
                  // Show first 5 events only
                  final displayEvents = events.take(5).toList();

                  if (displayEvents.isEmpty) {
                    return const SizedBox
                        .shrink(); // Don't show section if no events
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header with "View All" button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.upcomingCare,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/calendar'),
                            child: Text(l10n.viewAll),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Horizontal scrollable list of cards
                      SizedBox(
                        height: 130, // Card height
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: displayEvents.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final event = displayEvents[index];
                            return UpcomingCareCardWidget(
                              event: event,
                              onTap: () {
                                // Handle tap based on event type
                                switch (event) {
                                  case MedicationEvent(:final entry):
                                    // Navigate to medication detail
                                    context.push('/meds/detail/${entry.id}');
                                    break;
                                  case AppointmentEvent():
                                    // Navigate to Appointments tab
                                    context.go('/appointments');
                                    break;
                                  case VaccinationRecordEvent():
                                    // Navigate to specific vaccination detail
                                    context.push(
                                        '/vaccinations/detail/${event.id}');
                                    break;
                                  case VaccinationEvent():
                                    // Navigate to vaccination timeline (protocol schedule)
                                    context.push('/vaccinations');
                                    break;
                                  case DewormingEvent():
                                    // Navigate to deworming schedule
                                    context.push(
                                        '/deworming/schedule/${currentPet.id}',
                                        extra: currentPet);
                                    break;
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) =>
                    const SizedBox.shrink(), // Hide on error
              ),
            ],
          ],
          // Spacer to push FAB to bottom when there's little content
          const Spacer(),
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

  // Common food types
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

  String? _selectedFoodTypeKey; // Selected from dropdown (using keys)
  bool _showCustomFoodTypeField = false; // Show text field for custom food type

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
      _logger.d(
          '[FEEDING] Edit mode - Loading existing food type: ${widget.feeding!.foodType}');
      // Food type key detection will happen in build method with actual localization
      _logger.d('[FEEDING] Will detect food type key match in build method');
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
      _selectedFoodTypeKey = null;
      _showCustomFoodTypeField = false;
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

  /// Get localized food type name
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

  /// Detect which food type key matches the existing food type value
  String? _detectFoodTypeKey(String existingFoodType, AppLocalizations l10n) {
    for (final foodTypeKey in _commonFoodTypes) {
      final localizedValue = _getLocalizedFoodType(foodTypeKey, l10n);
      if (existingFoodType.toLowerCase() == localizedValue.toLowerCase()) {
        _logger.d(
            '[FEEDING] Matched existing food type "$existingFoodType" to key: $foodTypeKey');
        return foodTypeKey;
      }
    }
    // No match found - it's a custom food type
    _logger.d(
        '[FEEDING] No match for "$existingFoodType" - will use "other" with custom text');
    return 'other';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final petsAsync = ref.watch(petProfilesProvider);

    // In edit mode, detect the food type key if not already set
    if (widget.feeding != null && _selectedFoodTypeKey == null) {
      final detectedKey = _detectFoodTypeKey(widget.feeding!.foodType, l10n);
      _selectedFoodTypeKey = detectedKey;
      _showCustomFoodTypeField = (detectedKey == 'other');

      if (detectedKey == 'other') {
        // It's a custom food type, populate the text field
        _foodTypeController.text = widget.feeding!.foodType;
      }
    }

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

              // Food Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedFoodTypeKey,
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
                      // If user selected from dropdown, clear custom field
                      _foodTypeController.clear();
                      _logger.d(
                          '[FEEDING] Food type selected from dropdown: $value');
                    } else {
                      _logger.d(
                          '[FEEDING] Selected "Other (Custom)" - showing text field');
                    }
                  });
                },
                validator: (value) {
                  // If dropdown has value and it's not "other", it's valid
                  if (value != null && value != 'other') return null;

                  // If "Other" is selected, check the text field
                  if (_showCustomFoodTypeField &&
                      _foodTypeController.text.trim().isEmpty) {
                    return l10n.pleaseEnterFoodType;
                  }

                  // If "other" is selected and text field has value, it's valid
                  if (value == 'other' &&
                      _foodTypeController.text.trim().isNotEmpty) {
                    return null;
                  }

                  // No selection made
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
                          // Determine the final food type value
                          String finalFoodType;
                          if (_selectedFoodTypeKey != null &&
                              _selectedFoodTypeKey != 'other') {
                            // Use localized dropdown value
                            finalFoodType = _getLocalizedFoodType(
                                _selectedFoodTypeKey!, l10n);
                            _logger.d(
                                '[FEEDING] Saving with dropdown food type: $finalFoodType (key: $_selectedFoodTypeKey)');
                          } else {
                            // Use custom text
                            finalFoodType = _foodTypeController.text.trim();
                            _logger.d(
                                '[FEEDING] Saving with custom food type: $finalFoodType');
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
