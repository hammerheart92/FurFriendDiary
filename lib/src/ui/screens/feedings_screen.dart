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

  void _addFeeding() {
    final item = _Feeding(type: 'Dry food', time: TimeOfDay.now());
    setState(() => _items.add(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feeding added'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => setState(() => _items.remove(item)),
        ),
      ),
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
                    onPressed: _addFeeding,
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
        onPressed: _addFeeding,
        child: const Icon(Icons.add),
      ),
    );
  }
}
