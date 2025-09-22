import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'walks_state.dart';

/// Drop-in Walks screen with mock data, quick filters, responsive layout,
/// empty state, semantics, and a local-only "Add walk" sheet.
/// No backend, no persistence. Safe to run locally.

class WalksScreen extends StatefulWidget {
  const WalksScreen({super.key});

  @override
  State<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends State<WalksScreen> with AutomaticKeepAliveClientMixin {
  WalkFilter _filter = WalkFilter.all; // Default to "All" so new items are visible

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final controller = WalksScope.of(context);
    
        return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final allWalks = controller.items;
        final filtered = _filteredWalks(allWalks);
        final isEmpty = filtered.isEmpty;
        
        print('📱 UI REBUILD: Rendering ${allWalks.length} total walks, ${filtered.length} filtered');
        print('📱 UI FILTER: Current filter: $_filter');
        print('📱 UI EMPTY CHECK: isEmpty = $isEmpty');
        
        if (filtered.isNotEmpty) {
          print('📱 UI WALKS LIST:');
          for (int i = 0; i < filtered.length; i++) {
            print('   ${i + 1}. ${filtered[i].note} at ${filtered[i].start}');
          }
        } else if (allWalks.isNotEmpty) {
          print('📱 UI NOTE: ${allWalks.length} walks exist but filtered to 0 for $_filter');
        }

        return Scaffold(
      appBar: AppBar(
        title: const Text('Walks'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterBar(
              value: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: isEmpty ? _EmptyState(onAdd: _showAddWalkSheet) : _ResponsiveWalkList(
                entries: filtered,
                key: const PageStorageKey('walks_list'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'Add walk',
        child: FloatingActionButton(
          onPressed: _showAddWalkSheet,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  List<WalkEntry> _filteredWalks(List<WalkEntry> source) {
    final now = DateTime.now();
    DateTime startBoundary;

    print('🔍 FILTERING: Input ${source.length} walks, filter: $_filter');
    
    switch (_filter) {
      case WalkFilter.today:
        startBoundary = DateTime(now.year, now.month, now.day);
        print('🔍 TODAY filter: Looking for walks after $startBoundary');
        break;
      case WalkFilter.thisWeek:
        final weekday = now.weekday; // 1 Mon, 7 Sun
        startBoundary = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
        print('🔍 THIS WEEK filter: Looking for walks after $startBoundary');
        break;
      case WalkFilter.all:
        print('🔍 ALL filter: Showing all ${source.length} walks');
        final sorted = List.of(source)..sort((a, b) => b.start.compareTo(a.start));
        for (int i = 0; i < sorted.length; i++) {
          print('   Walk ${i + 1}: ${sorted[i].note} at ${sorted[i].start}');
        }
        return sorted;
    }

    final list = source.where((w) {
      final isAfter = w.start.isAfter(startBoundary);
      print('   Walk "${w.note}" at ${w.start} - isAfter($startBoundary): $isAfter');
      return isAfter;
    }).toList();
    
    list.sort((a, b) => b.start.compareTo(a.start));
    print('🔍 FILTER RESULT: ${list.length} walks match $_filter filter');
    return list;
  }

  void _showAddWalkSheet() {
    final controller = WalksScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _AddWalkSheet(
        onSubmit: (entry) async {
          print('📝 FORM SUBMITTED - Walk Data: ${entry.note} at ${entry.start}');
          print('📅 Walk Date: ${entry.start}');
          print('💾 SAVING TO REPOSITORY...');
          
          await controller.add(entry);
          if (context.mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Walk added successfully!')),
            );
          }
          
          print('🔙 NAVIGATION: Returned to walks screen, data refreshed');
        },
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
    const labels = {
      WalkFilter.today: 'Today',
      WalkFilter.thisWeek: 'This Week',
      WalkFilter.all: 'All',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<WalkFilter>(
        segments: [
          ButtonSegment(value: WalkFilter.today, label: Text(labels[WalkFilter.today]!)),
          ButtonSegment(value: WalkFilter.thisWeek, label: Text(labels[WalkFilter.thisWeek]!)),
          ButtonSegment(value: WalkFilter.all, label: Text(labels[WalkFilter.all]!)),
        ],
        selected: {value},
        onSelectionChanged: (set) => onChanged(set.first),
        showSelectedIcon: false,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        ),
      ),
    );
  }
}

/// Responsive list: 1 column on narrow, 2 columns when width >= 600
class _ResponsiveWalkList extends StatelessWidget {
  const _ResponsiveWalkList({super.key, required this.entries});
  final List<WalkEntry> entries;

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
            itemBuilder: (context, i) => WalkCard(entry: entries[i]),
          );
        }
        print('📋 BUILDING ListView with ${entries.length} entries');
        return ListView.separated(
          key: const PageStorageKey('walks_list'),
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            print('📋 ListView building item $i: ${entries[i].note}');
            return WalkCard(entry: entries[i]);
          },
        );
      },
    );
  }
}

class WalkCard extends StatelessWidget {
  const WalkCard({super.key, required this.entry});
  final WalkEntry entry;

  @override
  Widget build(BuildContext context) {
    print('🃏 RENDERING WalkCard: ${entry.note} at ${entry.start}');
    final theme = Theme.of(context);
    final time = DateFormat.Hm().format(entry.start);
    final primaryLine = '$time • ${entry.durationMin} min • ${entry.distanceKm.toStringAsFixed(1)} km';

    return Semantics(
      container: true,
      label: 'Walk details for $primaryLine',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // No navigation. Show details locally.
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Walk details'),
                content: _WalkDetails(entry: entry),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary row: stats only (no icon)
                Text(
                  primaryLine,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Note/title
                Text(
                  entry.note ?? 'No notes',
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Meta row: simple text with dots
                Text(
                  'Surface: ${entry.surface ?? 'n/a'} • Pace: ${entry.paceMinPerKm?.toStringAsFixed(0) ?? '—'}\'/km',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('No walks yet', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Track your first walk to see distance and duration here.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: 'Add first walk',
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add first walk'),
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

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, MMM d • HH:mm');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow('Start', df.format(entry.start)),
        _DetailRow('Duration', '${entry.durationMin} min'),
        _DetailRow('Distance', '${entry.distanceKm.toStringAsFixed(2)} km'),
        if (entry.paceMinPerKm != null) _DetailRow('Pace', "${entry.paceMinPerKm!.toStringAsFixed(0)}'/km"),
        if (entry.surface != null) _DetailRow('Surface', entry.surface!),
        if (entry.note?.isNotEmpty == true) _DetailRow('Notes', entry.note!),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

// WalkEntry model moved to walks_state.dart

/// Simple add-walk sheet that appends to the in-memory list. No persistence.
class _AddWalkSheet extends StatefulWidget {
  const _AddWalkSheet({required this.onSubmit});
  final ValueChanged<WalkEntry> onSubmit;

  @override
  State<_AddWalkSheet> createState() => _AddWalkSheetState();
}

class _AddWalkSheetState extends State<_AddWalkSheet> {
  final _form = GlobalKey<FormState>();
  final _durationCtrl = TextEditingController(text: '30');
  final _distanceCtrl = TextEditingController(text: '2.0');
  final _noteCtrl = TextEditingController(text: 'Neighborhood loop');
  String? _surface = 'paved';
  DateTime _start = DateTime.now();

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
    final df = DateFormat('EEE, MMM d • HH:mm');

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
            children: [
            Text('Add walk', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _RowField(
              label: 'Start',
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                    initialDate: _start,
                  );
                  if (date == null) return;
                  if (!mounted) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
                  if (time == null || !mounted) return;
                  setState(() => _start = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                },
                icon: const Icon(Icons.event),
                label: Text(df.format(_start)),
              ),
            ),
            _RowField(
              label: 'Duration',
              child: TextFormField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(suffixText: 'min', hintText: '30'),
                validator: _positiveInt,
              ),
            ),
            _RowField(
              label: 'Distance',
              child: TextFormField(
                controller: _distanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(suffixText: 'km', hintText: '2.0'),
                validator: _positiveDouble,
              ),
            ),
            _RowField(
              label: 'Surface',
              child: DropdownButtonFormField<String>(
                initialValue: _surface,
                items: const [
                  DropdownMenuItem(value: 'paved', child: Text('paved')),
                  DropdownMenuItem(value: 'gravel', child: Text('gravel')),
                  DropdownMenuItem(value: 'mixed', child: Text('mixed')),
                ],
                onChanged: (v) => setState(() => _surface = v),
              ),
            ),
            _RowField(
              label: 'Notes',
              child: TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Optional'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (!_form.currentState!.validate()) return;
                      final entry = WalkEntry(
                        start: _start,
                        durationMin: int.parse(_durationCtrl.text),
                        distanceKm: double.parse(_distanceCtrl.text),
                        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
                        surface: _surface,
                        paceMinPerKm: null,
                      );
                      widget.onSubmit(entry);
                    },
                    child: const Text('Add'),
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

  String? _positiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }

  String? _positiveDouble(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'Enter a positive number';
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 92, child: Text(label, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}