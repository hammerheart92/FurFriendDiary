import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/photo_provider.dart';
import '../providers/pet_profile_provider.dart';
import '../widgets/add_photo_sheet.dart';
import '../../domain/exceptions/permission_exceptions.dart';

class PhotoGalleryScreen extends ConsumerStatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  ConsumerState<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends ConsumerState<PhotoGalleryScreen> {
  bool _isLoading = false;

  Future<void> _handleAddPhoto() async {
    final l10n = AppLocalizations.of(context)!;

    // Show bottom sheet to select source
    final source = await AddPhotoSheet.show(context);
    if (source == null || !mounted) return;

    if (source == 'gallery_multiple') {
      await _handleMultiplePhotos();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageService = ref.read(imageServiceProvider);
      File? imageFile;

      if (source == 'camera') {
        imageFile = await imageService.takePhoto();
      } else if (source == 'gallery') {
        imageFile = await imageService.pickFromGallery();
      }

      if (imageFile == null || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      // Get current pet
      final currentPet = ref.read(currentPetProfileProvider);
      if (currentPet == null) {
        throw Exception('No pet selected');
      }

      // Save photo
      final repository = ref.read(photoRepositoryProvider);
      await repository.savePhoto(
        imageFile: imageFile,
        petId: currentPet.id,
      );

      // Refresh photos list
      ref.invalidate(photosForCurrentPetProvider);
      ref.invalidate(photoCountForCurrentPetProvider);
      ref.invalidate(storageUsedByCurrentPetProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.photoAdded)),
        );
      }
    } on PermissionPermanentlyDeniedException {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.permissionDenied),
            content: Text(
              source == 'camera'
                  ? l10n.cameraPermissionDenied
                  : l10n.galleryPermissionDenied,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: Text(l10n.openSettings),
              ),
            ],
          ),
        );
      }
    } on PermissionDeniedException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == 'camera'
                  ? l10n.cameraPermissionDenied
                  : l10n.galleryPermissionDenied,
            ),
            action: SnackBarAction(
              label: l10n.openSettings,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleMultiplePhotos() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      // Show loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Text(l10n.processingPhotos),
              ],
            ),
            duration: const Duration(seconds: 60),
          ),
        );
      }

      final imageService = ref.read(imageServiceProvider);
      final imageFiles = await imageService.pickMultipleFromGallery();

      if (imageFiles.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          setState(() => _isLoading = false);
        }
        return;
      }

      // Get current pet
      final currentPet = ref.read(currentPetProfileProvider);
      if (currentPet == null) {
        throw Exception('No pet selected');
      }

      // Save all photos
      final repository = ref.read(photoRepositoryProvider);
      final savedPhotos = await repository.saveMultiplePhotos(
        imageFiles: imageFiles,
        petId: currentPet.id,
      );

      // Refresh photos list
      ref.invalidate(photosForCurrentPetProvider);
      ref.invalidate(photoCountForCurrentPetProvider);
      ref.invalidate(storageUsedByCurrentPetProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.photosAdded(savedPhotos.length)),
          ),
        );
      }
    } on PermissionPermanentlyDeniedException {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.permissionDenied),
            content: Text(l10n.galleryPermissionDenied),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: Text(l10n.openSettings),
              ),
            ],
          ),
        );
      }
    } on PermissionDeniedException {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.galleryPermissionDenied),
            action: SnackBarAction(
              label: l10n.openSettings,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photosAsync = ref.watch(photosForCurrentPetProvider);
    final storageAsync = ref.watch(storageUsedByCurrentPetProvider);

    return Scaffold(
      appBar: AppBar(
        title: photosAsync.maybeWhen(
          data: (photos) => Text('${l10n.photoGallery} (${photos.length})'),
          orElse: () => Text(l10n.photoGallery),
        ),
        actions: [
          if (storageAsync.hasValue)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Tooltip(
                message:
                    '${l10n.storageUsed}: ${_formatBytes(storageAsync.value!)}',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storage,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatBytes(storageAsync.value!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: photosAsync.when(
        data: (photos) {
          if (photos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 100,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.noPhotos,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.addFirstPhoto,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _handleAddPhoto,
                      icon: const Icon(Icons.add_a_photo),
                      label: Text(l10n.addPhoto),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(photosForCurrentPetProvider);
              ref.invalidate(storageUsedByCurrentPetProvider);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(4.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                final thumbnailFile = File(photo.thumbnailPath);

                return GestureDetector(
                  onTap: () {
                    // Pass all photo IDs and current index for swipe navigation
                    final photoIds = photos.map((p) => p.id).toList();
                    context.push(
                      '/photo-detail/${photo.id}',
                      extra: {
                        'photoIds': photoIds,
                        'initialIndex': index,
                      },
                    );
                  },
                  child: Hero(
                    tag: 'photo-${photo.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                        child: thumbnailFile.existsSync()
                            ? Image.file(
                                thumbnailFile,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image);
                                },
                              )
                            : const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      floatingActionButton: _isLoading
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(),
            )
          : FloatingActionButton(
              onPressed: _handleAddPhoto,
              child: const Icon(Icons.add_a_photo),
            ),
    );
  }
}
