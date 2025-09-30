// lib/src/ui/screens/feedings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fur_friend_diary/layout/app_page.dart';
import 'package:fur_friend_diary/theme/spacing.dart';
import 'package:logger/logger.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/feeding_form_state_provider.dart';
import '../../domain/models/feeding_entry.dart';
import '../../data/repositories/feeding_repository_impl.dart';
import '../../presentation/providers/care_data_provider.dart';


final _logger = Logger();
final _uuid = Uuid();

class FeedingsScreen extends ConsumerStatefulWidget {
  const FeedingsScreen({super.key});

  @override
  ConsumerState<FeedingsScreen> createState() => _FeedingsScreenState();
}

class _FeedingTile extends StatelessWidget {
  final FeedingEntry item;
  const _FeedingTile(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pets),
      title: Text(item.foodType),
      subtitle: Text(TimeOfDay.fromDateTime(item.dateTime).format(context)),
      trailing: const Icon(Icons.more_vert),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      minVerticalPadding: 12,
      onTap: () {},
    );
  }
}

class _FeedingsScreenState extends ConsumerState<FeedingsScreen> {
  
  Future<void> _addFeeding(String foodType) async {
    final currentPet = ref.read(currentPetProfileProvider);
    if (currentPet == null) {
      _logger.w('Cannot add feeding: no current pet selected');
      return;
    }

    final feeding = FeedingEntry(
      id: _uuid.v4(),
      petId: currentPet.id,
      foodType: foodType,
      amount: 0.0,
      dateTime: DateTime.now(),
    );

    try {
      await ref.read(feedingRepositoryProvider).addFeeding(feeding);
      ref.invalidate(feedingsByPetIdProvider(currentPet.id));
      _logger.i('Feeding "$foodType" saved to Hive successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feeding "$foodType" added'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _logger.e('Failed to save feeding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save feeding: $e'),
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
        onSubmit: (foodType) {
          _logger.i('🍽️ FEEDING FORM: Form submitted with foodType: $foodType');
          _addFeeding(foodType);
        },
      ),
    ).then((_) {
      _logger.i('🍽️ FEEDING FORM: Dialog closed');
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currentPet = ref.watch(currentPetProfileProvider);
    final feedingsAsync = ref.watch(feedingsByPetIdProvider(currentPet?.id ?? ''));

    return AppPage(
      title: currentPet != null ? '${currentPet.name} - Feedings' : 'Feedings',
      body: Column(
        children: [
          // Pet Profile Display
          if (currentPet != null) ...[
            Container(
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
                      currentPet.name.isNotEmpty ? currentPet.name[0].toUpperCase() : '?',
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${currentPet.species} • ${currentPet.breed ?? 'Mixed'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                size: 28, color: scheme.onSurface.withOpacity(0.60)),
                          ),
                          const SizedBox(height: AppSpacing.s5),
                          Text(
                            currentPet != null 
                                ? 'No feedings recorded for ${currentPet.name} yet'
                                : 'No feedings recorded yet',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _showAddFeedingDialog,
                            child: const Text('Add first feeding'),
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
                        itemBuilder: (_, i) => _FeedingTile(feedings[i]),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading feedings: $error'),
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
  const _AddFeedingSheet({required this.onSubmit});
  final ValueChanged<String> onSubmit;

  @override
  ConsumerState<_AddFeedingSheet> createState() => _AddFeedingSheetState();
}

class _AddFeedingSheetState extends ConsumerState<_AddFeedingSheet> {
  final _form = GlobalKey<FormState>();
  final _foodTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final formState = ref.read(feedingFormStateNotifierProvider);
    _foodTypeController.text = formState.foodType;
    _logger.i('🍽️ FEEDING FORM: initState() - Initial foodType from provider: "${formState.foodType}"');
  }

  void _clearDraftState() {
    _logger.i('🍽️ FEEDING FORM: Clearing draft state');
    _foodTypeController.clear();
    ref.read(feedingFormStateNotifierProvider.notifier).clearForm();
    _logger.i('🍽️ FEEDING FORM: Draft state cleared');
  }

  @override
  void dispose() {
    _logger.i('🍽️ FEEDING FORM: dispose() - Cleaning up form');
    _foodTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(feedingFormStateNotifierProvider, (previous, next) {
      _logger.i('🍽️ FEEDING FORM: Provider state changed - foodType: "${next.foodType}"');
      if (next.foodType != _foodTypeController.text) {
        _logger.i('🍽️ FEEDING FORM: Syncing controller to provider state');
        _foodTypeController.text = next.foodType;
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 8,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add a new feeding', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _foodTypeController,
              decoration: const InputDecoration(
                labelText: 'Food type',
                hintText: 'e.g., Dry Food, Wet Food, Treats',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a food type';
                }
                return null;
              },
              onChanged: (value) {
                _logger.i('🍽️ FEEDING FORM: Text field changed - value: "$value"');
                ref.read(feedingFormStateNotifierProvider.notifier).updateFoodType(value);
                _logger.i('🍽️ FEEDING FORM: Provider state updated with new foodType');
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearDraftState,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_form.currentState!.validate()) {
                        final foodType = _foodTypeController.text;
                        widget.onSubmit(foodType);
                        _clearDraftState();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}