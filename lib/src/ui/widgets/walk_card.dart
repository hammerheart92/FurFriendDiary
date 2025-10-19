import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/walk.dart';

class WalkCard extends StatelessWidget {
  final Walk walk;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WalkCard({
    super.key,
    required this.walk,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header row
              Row(
                children: [
                  // Walk type icon and name
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getWalkTypeColor(walk.walkType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            _getWalkTypeColor(walk.walkType).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          walk.walkType.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          walk.walkType.displayName,
                          style: TextStyle(
                            color: _getWalkTypeColor(walk.walkType),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Date and time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('MMM dd').format(walk.startTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(walk.startTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),

                  // More options menu
                  if (onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert, size: 20),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Walk stats row
              Row(
                children: [
                  // Duration
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: walk.formattedDuration,
                      color: Colors.blue,
                    ),
                  ),

                  // Distance
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.straighten,
                      label: 'Distance',
                      value: walk.formattedDistance,
                      color: Colors.green,
                    ),
                  ),

                  // Status
                  Expanded(
                    child: _buildStatItem(
                      icon: walk.isActive
                          ? Icons.play_circle
                          : Icons.check_circle,
                      label: 'Status',
                      value: walk.isActive ? 'Active' : 'Completed',
                      color: walk.isActive ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),

              // Notes section
              if (walk.notes != null && walk.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Notes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        walk.notes!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getWalkTypeColor(WalkType walkType) {
    switch (walkType) {
      case WalkType.walk:
        return Colors.green;
      case WalkType.run:
        return Colors.red;
      case WalkType.hike:
        return Colors.brown;
      case WalkType.play:
        return Colors.pink;
      case WalkType.regular:
        return Colors.blue;
      case WalkType.short:
        return Colors.orange;
      case WalkType.long:
        return Colors.purple;
      case WalkType.training:
        return Colors.red;
    }
  }
}
