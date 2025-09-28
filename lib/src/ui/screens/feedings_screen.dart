// lib/src/ui/screens/feedings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/layout/app_page.dart';
import 'package:fur_friend_diary/theme/spacing.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/feeding_form_state_provider.dart';

class FeedingsScreen extends ConsumerStatefulWidget {
  const FeedingsScreen({super.key});

  @override
  ConsumerState<FeedingsScreen> createState() => _FeedingsScreenState();
}

class _Feeding {
  final String type;
  final TimeOfDay time;
  _Feeding({required this.type, required this.time});
}

class _FeedingTile extends StatelessWidget {
  final _Feeding item;
  const _FeedingTile(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pets),
      title: Text(item.type),
      subtitle: Text(item.time.format(context)),
      trailing: const Icon(Icons.more_vert),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      minVerticalPadding: 12, // ~56dp row height with title/subtitle
      onTap: () {},
    );
  }
}

class _FeedingsScreenState extends ConsumerState<FeedingsScreen> with AutomaticKeepAliveClientMixin {
  final List<_Feeding> _items = [];

  @override
  bool get wantKeepAlive => true;

  void _addFeeding(String foodType) {
    final item = _Feeding(type: foodType, time: TimeOfDay.now());
    setState(() => _items.add(item));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feeding "$foodType" added'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => setState(() => _items.remove(item)),
        ),
      ),
    );
  }

  Future<void> _showAddFeedingDialog() async {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AddFeedingSheet(
        onSubmit: (foodType) {
          _addFeeding(foodType);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final scheme = Theme.of(context).colorScheme;
    final currentPet = ref.watch(currentPetProfileProvider);

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
            child: _items.isEmpty
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
                        const SizedBox(height: AppSpacing.s5), // 20
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
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _FeedingTile(_items[i]),
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
    // Initialize with draft state from provider if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDraftState();
    });
  }

  void _loadDraftState() {
    // Try to load draft state from the provider
    final formState = ref.read(feedingFormStateNotifierProvider);
    print('🍽️ FEEDING FORM: Loading draft state - foodType: "${formState.foodType}"');
    if (formState.foodType.isNotEmpty) {
      _foodTypeController.text = formState.foodType;
      print('🍽️ FEEDING FORM: Controller loaded with: "${_foodTypeController.text}"');
    }
  }

  void _saveDraftState() {
    // Save current state to provider
    print('🍽️ FEEDING FORM: Saving draft state - foodType: "${_foodTypeController.text}"');
    ref.read(feedingFormStateNotifierProvider.notifier)
        .updateFoodType(_foodTypeController.text);
  }

  void _clearDraftState() {
    // Clear draft state
    print('🍽️ FEEDING FORM: Clearing draft state');
    ref.read(feedingFormStateNotifierProvider.notifier).clearForm();
    _foodTypeController.clear();
  }

  @override
  void dispose() {
    // Save draft state when disposing (user navigated away without submitting)
    print('🍽️ FEEDING FORM: Disposing form, saving draft state');
    _saveDraftState();
    _foodTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              onChanged: (_) => _saveDraftState(), // Save draft on every change
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _clearDraftState();
                    },
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
                        _clearDraftState(); // Clear draft after successful submission
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
