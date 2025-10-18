import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/photo_provider.dart';
import '../../domain/models/pet_photo.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  final String photoId;

  const PhotoDetailScreen({
    super.key,
    required this.photoId,
  });

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isEditingCaption = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _saveCaption(PetPhoto photo) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final repository = ref.read(photoRepositoryProvider);
      await repository.updateCaption(widget.photoId, _captionController.text);

      // Refresh providers
      ref.invalidate(photosForCurrentPetProvider);
      ref.invalidate(photoDetailProvider(widget.photoId));

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
      await repository.deletePhoto(widget.photoId);

      // Refresh providers
      ref.invalidate(photosForCurrentPetProvider);
      ref.invalidate(photoCountForCurrentPetProvider);
      ref.invalidate(storageUsedByCurrentPetProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.photoDeleted)),
        );
        context.pop();
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
    final photo = ref.watch(photoDetailProvider(widget.photoId));

    if (photo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Photo not found'),
        ),
      );
    }

    // Initialize caption controller if not editing
    if (!_isEditingCaption && _captionController.text != (photo.caption ?? '')) {
      _captionController.text = photo.caption ?? '';
    }

    final photoFile = File(photo.filePath);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.photoDetails),
        actions: [
          if (_isEditingCaption)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _saveCaption(photo),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditingCaption = true;
                  _captionController.text = photo.caption ?? '';
                });
              },
            ),
          if (!_isEditingCaption)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete),
              onPressed: _isDeleting ? null : _deletePhoto,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo with zoom capability
            Hero(
              tag: 'photo-${photo.id}',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: photoFile.existsSync()
                    ? Image.file(
                        photoFile,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 80),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 300,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 80),
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
