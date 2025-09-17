import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/walks_provider.dart';

class WalksHistoryScreen extends ConsumerStatefulWidget {
  final String? petId; // null means show all pets

  const WalksHistoryScreen({super.key, this.petId});

  @override
  ConsumerState<WalksHistoryScreen> createState() => _WalksHistoryScreenState();
}

class _WalksHistoryScreenState extends ConsumerState<WalksHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  Future<void> _selectDateRange() async {
    // TODO: Implement date range picker logic here
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walksAsync = ref.watch(walksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk History'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
    );
  }
}