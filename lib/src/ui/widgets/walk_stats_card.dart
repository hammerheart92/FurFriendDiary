import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/walks_provider.dart';

class WalkStatsCard extends ConsumerWidget {
  final String petId;

  const WalkStatsCard({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walksAsync = ref.watch(walksProvider);
    final theme = Theme.of(context);

    return walksAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => Card(
        color: Colors.red.shade100,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text('Failed to load stats: $err', textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (_) {
        // Now we can safely call the stats provider
        final stats = ref.watch(walkStatsProvider(petId));
        
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.primary,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'This Week\'s Stats',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatColumn(
                          title: 'Total Walks',
                          value: (stats['totalWalks'] as int).toString(),
                          icon: Icons.pets,
                          theme: theme,
                        ),
                      ),
                      
                      Container(
                        width: 1,
                        height: 50,
                        color: theme.colorScheme.onPrimary.withOpacity(0.3),
                      ),
                      
                      Expanded(
                        child: _buildStatColumn(
                          title: 'Total Time',
                          value: _formatDuration(stats['totalDuration'] as Duration),
                          icon: Icons.timer,
                          theme: theme,
                        ),
                      ),
                      
                      Container(
                        width: 1,
                        height: 50,
                        color: theme.colorScheme.onPrimary.withOpacity(0.3),
                      ),
                      
                      Expanded(
                        child: _buildStatColumn(
                          title: 'Distance',
                          value: _formatDistance(stats['totalDistance'] as double),
                          icon: Icons.straighten,
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Average stats
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Avg Duration',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDuration(stats['averageWalkDuration'] as Duration),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Avg Distance',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDistance(stats['averageDistance'] as double),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn({
    required String title,
    required String value,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onPrimary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimary.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDistance(double distance) {
    if (distance == 0) return '0km';
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }
}