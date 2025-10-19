import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../domain/models/walk.dart';
import '../../providers/walks_provider.dart';

class WalkTrackingScreen extends ConsumerStatefulWidget {
  final String petId;
  final String petName;

  const WalkTrackingScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  ConsumerState<WalkTrackingScreen> createState() => _WalkTrackingScreenState();
}

class _WalkTrackingScreenState extends ConsumerState<WalkTrackingScreen> {
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  WalkType _selectedWalkType = WalkType.regular;

  @override
  void dispose() {
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeWalk = ref.watch(activeWalkProvider(widget.petId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Walking ${widget.petName}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: activeWalk == null
          ? _buildStartWalkView(theme)
          : _buildActiveWalkView(theme, activeWalk),
    );
  }

  Widget _buildStartWalkView(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.1),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Pet avatar placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pets,
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Ready for a walk?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Choose walk type and start tracking',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // Walk type selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Walk Type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: WalkType.values.map((type) {
                          final isSelected = _selectedWalkType == type;
                          return FilterChip(
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedWalkType = type;
                              });
                            },
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(type.icon),
                                const SizedBox(width: 4),
                                Text(type.displayName),
                              ],
                            ),
                            backgroundColor: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.2)
                                : null,
                            selectedColor:
                                theme.colorScheme.primary.withOpacity(0.3),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Start walk button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _startWalk(),
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: const Text(
                    'Start Walk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildActiveWalkView(ThemeData theme, Walk activeWalk) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade400,
            Colors.green.shade50,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Status indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Walk in Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Timer display
              Consumer(
                builder: (context, ref, child) {
                  final durationAsync =
                      ref.watch(walkDurationProvider(activeWalk.startTime));
                  return durationAsync.when(
                    data: (duration) {
                      final hours = duration.inHours;
                      final minutes = duration.inMinutes.remainder(60);
                      final seconds = duration.inSeconds.remainder(60);
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              hours > 0
                                  ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                  : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              activeWalk.walkType.displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Error: $err'),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Walk details form
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Walk Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Distance input
                        TextField(
                          controller: _distanceController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Distance (km)',
                            hintText: 'Enter distance walked',
                            prefixIcon: Icon(Icons.straighten),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Notes input
                        Expanded(
                          child: TextField(
                            controller: _notesController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              hintText: 'How was the walk? Any observations?',
                              prefixIcon: Icon(Icons.note),
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // End walk button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _endWalk(activeWalk),
                  icon: const Icon(Icons.stop, size: 28),
                  label: const Text(
                    'End Walk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Future<void> _startWalk() async {
    try {
      await ref.read(walksProvider.notifier).startWalk(
            petId: widget.petId,
            walkType: _selectedWalkType,
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start walk: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _endWalk(Walk activeWalk) async {
    try {
      final distance = double.tryParse(_distanceController.text);
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      await ref.read(walksProvider.notifier).endWalk(
            walkId: activeWalk.id,
            distance: distance,
            notes: notes,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Walk completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to end walk: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
