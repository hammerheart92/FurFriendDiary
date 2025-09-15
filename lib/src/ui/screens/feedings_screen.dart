// lib/src/ui/screens/feedings_screen.dart
import 'package:flutter/material.dart';
import 'package:fur_friend_diary/layout/app_page.dart';
import 'package:fur_friend_diary/theme/spacing.dart';

class FeedingsScreen extends StatefulWidget {
  const FeedingsScreen({super.key});

  @override
  State<FeedingsScreen> createState() => _FeedingsScreenState();
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

class _FeedingsScreenState extends State<FeedingsScreen> {
  final List<_Feeding> _items = [];

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
    final foodTypeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new feeding'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: foodTypeController,
              decoration: const InputDecoration(
                labelText: 'Food type',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a food type';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _addFeeding(foodTypeController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppPage(
      title: 'Feedings',
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: scheme.onSurface.withOpacity(0.08),
                    child: Icon(Icons.pets,
                        size: 28, color: scheme.onSurface.withOpacity(0.60)),
                  ),
                  const SizedBox(height: AppSpacing.s5), // 20
                  FilledButton(
                    onPressed: _showAddFeedingDialog,
                    child: const Text('Add feeding'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFeedingDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
