import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

final _logger = Logger();

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(petProfilesProvider);
    final currentProfile = ref.watch(currentPetProfileProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.petProfiles),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/profile-setup'),
            icon: const Icon(Icons.add),
            tooltip: l10n.addPet,
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
              Text('${l10n.errorLoadingProfiles}: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(petProfilesProvider),
                child: Text(l10n.retry),
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
            AppLocalizations.of(context).allProfiles,
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
    final l10n = AppLocalizations.of(context);
    
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
            l10n.noPetsYet,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addYourFirstPet,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 255*0.6),
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/profile-setup'),
            icon: const Icon(Icons.add),
            label: Text(l10n.addPet),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProfileCard(BuildContext context, WidgetRef ref, PetProfile profile) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
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
                            l10n.yearsOld(profile.age, profile.age != 1 ? 's' : ''),
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
                      l10n.activeProfile,
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
    final l10n = AppLocalizations.of(context);
    
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
              Text(l10n.yearsOld(profile.age, profile.age != 1 ? 's' : '')),
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
                  PopupMenuItem(
                    value: 'activate',
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(l10n.makeActive),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: const Icon(Icons.edit),
                      title: Text(l10n.edit),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
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
    _logger.d('[PROFILE_PIC] Building avatar for pet: ${profile.name}');
    _logger.d('[PROFILE_PIC] photoPath from profile: ${profile.photoPath}');

    if (profile.photoPath != null && profile.photoPath!.isNotEmpty) {
      final imageFile = File(profile.photoPath!);
      final exists = imageFile.existsSync();

      _logger.d('[PROFILE_PIC] Checking file existence...');
      _logger.d('[PROFILE_PIC] - Path: ${profile.photoPath}');
      _logger.d('[PROFILE_PIC] - Absolute path: ${imageFile.absolute.path}');
      _logger.d('[PROFILE_PIC] - File exists: $exists');

      if (exists) {
        try {
          final fileSize = imageFile.lengthSync();
          _logger.d('[PROFILE_PIC] SUCCESS: File verified! Size: $fileSize bytes');
          _logger.d('[PROFILE_PIC] Creating CircleAvatar with FileImage');

          return CircleAvatar(
            radius: radius / 2,
            backgroundImage: FileImage(imageFile),
          );
        } catch (e) {
          _logger.e('[PROFILE_PIC] ERROR: Failed to read file: $e');
        }
      } else {
        _logger.e('[PROFILE_PIC] ERROR: photoPath is set but file does NOT exist!');
        _logger.e('[PROFILE_PIC] ERROR: Expected at: ${imageFile.absolute.path}');
      }
    } else {
      _logger.d('[PROFILE_PIC] photoPath is null or empty, showing default icon');
    }

    _logger.d('[PROFILE_PIC] Falling back to default pet icon');
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
          SnackBar(content: Text('${AppLocalizations.of(context).edit} feature coming soon!')),
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.nowActive(profile.name))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToActivateProfile(e.toString()))),
        );
      }
    }
  }

  Future<void> _deleteProfile(BuildContext context, WidgetRef ref, PetProfile profile) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProfile),
        content: Text(l10n.deleteProfileConfirm(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(petProfilesProvider.notifier).remove(profile.id);
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.profileDeleted(profile.name))),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.failedToDeleteProfile}: $e')),
          );
        }
      }
    }
  }
}

