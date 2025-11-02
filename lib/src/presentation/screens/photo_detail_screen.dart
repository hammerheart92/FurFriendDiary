import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/photo_provider.dart';
import '../providers/pet_profile_provider.dart';
import '../../domain/models/pet_photo.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  final String photoId; // Keep for routing
  final int initialIndex;
  final List<String> photoIds;

  const PhotoDetailScreen({
    super.key,
    required this.photoId,
    required this.initialIndex,
    required this.photoIds,
  });

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isEditingCaption = false;
  bool _isDeleting = false;
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveCaption(PetPhoto photo) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final repository = ref.read(photoRepositoryProvider);
      final currentPhotoId = widget.photoIds[_currentIndex];
      await repository.updateCaption(currentPhotoId, _captionController.text);

      // Refresh providers
      ref.invalidate(photosForCurrentPetProvider);
      ref.invalidate(photoDetailProvider(currentPhotoId));

      setState(() => _isEditingCaption = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.captionSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sharePhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final currentPhotoId = widget.photoIds[_currentIndex];
    final photo = ref.read(photoDetailProvider(currentPhotoId));

    if (photo == null) return;

    try {
      final file = File(photo.filePath);
      if (!file.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.photoNotFound)),
          );
        }
        return;
      }

      // Get current pet name for share text
      final currentPet = ref.read(currentPetProfileProvider);
      final petName = currentPet?.name ?? 'My pet';

      final shareText = photo.caption?.isNotEmpty == true
          ? '${photo.caption} - $petName'
          : petName;

      await Share.shareXFiles(
        [XFile(photo.filePath)],
        text: shareText,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _setAsProfilePhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final currentPhotoId = widget.photoIds[_currentIndex];
    final photo = ref.read(photoDetailProvider(currentPhotoId));
    final currentPet = ref.read(currentPetProfileProvider);

    if (photo == null || currentPet == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setProfilePhoto),
        content: Text(l10n.setProfilePhotoConfirm(currentPet.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final petRepository = ref.read(petProfileRepositoryProvider);

      // Update pet profile with new photo path
      final updatedPet = currentPet.copyWith(
        photoPath: photo.filePath,
      );

      await petRepository.update(updatedPet);

      // Refresh providers
      ref.invalidate(petProfilesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profilePhotoUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deletePhoto() async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePhoto),
        content: Text(l10n.deletePhotoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final repository = ref.read(photoRepositoryProvider);
      final currentPhotoId = widget.photoIds[_currentIndex];
      await repository.deletePhoto(currentPhotoId);

      // Refresh providers
      ref.invalidate(photosForCurrentPetProvider);
      ref.invalidate(photoCountForCurrentPetProvider);
      ref.invalidate(storageUsedByCurrentPetProvider);

      if (mounted) {
        // If this was the last photo, go back to gallery
        if (widget.photoIds.length == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.photoDeleted)),
          );
          context.pop();
        } else {
          // Remove from local list and update page
          setState(() {
            widget.photoIds.removeAt(_currentIndex);
            if (_currentIndex >= widget.photoIds.length) {
              _currentIndex = widget.photoIds.length - 1;
            }
            _pageController.jumpToPage(_currentIndex);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.photoDeleted)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPhotoId = widget.photoIds[_currentIndex];
    final photo = ref.watch(photoDetailProvider(currentPhotoId));

    if (photo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(l10n.photoNotFound),
        ),
      );
    }

    // Initialize caption controller if not editing
    if (!_isEditingCaption &&
        _captionController.text != (photo.caption ?? '')) {
      _captionController.text = photo.caption ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.photo} ${_currentIndex + 1} / ${widget.photoIds.length}',
        ),
        actions: [
          if (_isEditingCaption)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _saveCaption(photo),
            )
          else ...[
            // Share button
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: l10n.share,
              onPressed: _sharePhoto,
            ),
            // Set as profile photo button
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: l10n.setProfilePhoto,
              onPressed: _setAsProfilePhoto,
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.edit,
              onPressed: () {
                setState(() {
                  _isEditingCaption = true;
                  _captionController.text = photo.caption ?? '';
                });
              },
            ),
          ],
          if (!_isEditingCaption)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              tooltip: l10n.delete,
              onPressed: _isDeleting ? null : _deletePhoto,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo with swipe and zoom capability
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.photoIds.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _isEditingCaption = false; // Reset edit mode on swipe
                  });
                },
                itemBuilder: (context, index) {
                  final pagePhotoId = widget.photoIds[index];
                  final pagePhoto = ref.watch(photoDetailProvider(pagePhotoId));

                  if (pagePhoto == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final pagePhotoFile = File(pagePhoto.filePath);

                  return Hero(
                    tag: 'photo-${pagePhoto.id}',
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: pagePhotoFile.existsSync()
                          ? Image.file(
                              pagePhotoFile,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 80),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 80),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            if (widget.photoIds.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Text(
                    '${_currentIndex + 1} / ${widget.photoIds.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),

            // Photo details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  Text(
                    l10n.caption,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_isEditingCaption)
                    TextField(
                      controller: _captionController,
                      decoration: InputDecoration(
                        hintText: l10n.addCaption,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      autofocus: true,
                    )
                  else
                    Text(
                      photo.caption?.isEmpty ?? true
                          ? l10n.noCaption
                          : photo.caption!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                  const SizedBox(height: 24),

                  // Date taken
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    label: l10n.dateTaken,
                    value: _formatDate(photo.dateTaken),
                  ),

                  const SizedBox(height: 12),

                  // File size
                  _buildInfoRow(
                    context,
                    icon: Icons.storage,
                    label: l10n.fileSize,
                    value: _formatBytes(photo.fileSize),
                  ),

                  if (photo.createdAt != photo.dateTaken) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      icon: Icons.add_circle,
                      label: l10n.dateAdded,
                      value: _formatDate(photo.createdAt),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
