import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(petProfilesProvider);
    final currentProfile = ref.watch(currentPetProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profiles'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/profile-setup'),
            icon: const Icon(Icons.add),
            tooltip: 'Add new pet',
          ),
        ],
      ),
      body: profilesAsync.when(
        data: (profiles) => _buildProfileList(context, ref, profiles, currentProfile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading profiles: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(petProfilesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileList(
    BuildContext context,
    WidgetRef ref,
    List<PetProfile> profiles,
    PetProfile? currentProfile,
  ) {
    if (profiles.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(petProfilesProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (currentProfile != null) ...[
            _buildActiveProfileCard(context, ref, currentProfile),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],
          Text(
            'All Profiles',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...profiles.map((profile) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildProfileCard(context, ref, profile, profile == currentProfile),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 96,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 255*0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No pets yet!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first pet to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 255*0.6),
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/profile-setup'),
            icon: const Icon(Icons.add),
            label: const Text('Add Pet'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProfileCard(BuildContext context, WidgetRef ref, PetProfile profile) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withValues(alpha: 255*0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildProfileAvatar(context, profile, 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${profile.species}${profile.breed != null ? ' • ${profile.breed}' : ''}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 255*0.8),
                          ),
                        ),
                        if (profile.age > 0)
                          Text(
                            '${profile.age} year${profile.age != 1 ? 's' : ''} old',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 255*0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (profile.notes != null) ...[
                const SizedBox(height: 12),
                Text(
                  profile.notes!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 255*0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, PetProfile profile, bool isActive) {
    final theme = Theme.of(context);
    
    return Card(
      child: ListTile(
        leading: _buildProfileAvatar(context, profile, 40),
        title: Text(
          profile.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${profile.species}${profile.breed != null ? ' • ${profile.breed}' : ''}'),
            if (profile.age > 0)
              Text('${profile.age} year${profile.age != 1 ? 's' : ''} old'),
          ],
        ),
        trailing: isActive
            ? Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              )
            : PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, ref, profile, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'activate',
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('Make Active'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
        onTap: isActive ? null : () => _activateProfile(context, ref, profile),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, PetProfile profile, double radius) {
    if (profile.photoPath != null && File(profile.photoPath!).existsSync()) {
      return CircleAvatar(
        radius: radius / 2,
        backgroundImage: FileImage(File(profile.photoPath!)),
      );
    }
    
    return CircleAvatar(
      radius: radius / 2,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.pets,
        size: radius * 0.6,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    PetProfile profile,
    String action,
  ) async {
    switch (action) {
      case 'activate':
        await _activateProfile(context, ref, profile);
        break;
      case 'edit':
        // TODO: Navigate to edit screen (could reuse setup screen with profile data)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit feature coming soon!')),
        );
        break;
      case 'delete':
        await _deleteProfile(context, ref, profile);
        break;
    }
  }

  Future<void> _activateProfile(BuildContext context, WidgetRef ref, PetProfile profile) async {
    try {
      await ref.read(petProfilesProvider.notifier).setActive(profile.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${profile.name} is now your active pet')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to activate profile: $e')),
        );
      }
    }
  }

  Future<void> _deleteProfile(BuildContext context, WidgetRef ref, PetProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete ${profile.name}\'s profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(petProfilesProvider.notifier).remove(profile.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${profile.name}\'s profile deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete profile: $e')),
          );
        }
      }
    }
  }
}

