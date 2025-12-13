import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        await _showPermissionDialog(
          source == 'camera'
              ? l10n.cameraPermissionDenied
              : l10n.galleryPermissionDenied,
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
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: DesignColors.highlightTeal,
                  ),
                ),
                SizedBox(width: DesignSpacing.md),
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
        await _showPermissionDialog(l10n.galleryPermissionDenied);
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
            backgroundColor: DesignColors.highlightCoral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showPermissionDialog(String message) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: DesignShadows.lg,
          ),
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.permissionDenied,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.inter(
                        color: secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.highlightTeal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.lg,
                        vertical: DesignSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.openSettings,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    return Scaffold(
      appBar: AppBar(
        title: photosAsync.maybeWhen(
          data: (photos) => Text(
            '${l10n.photoGallery} (${photos.length})',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          orElse: () => Text(
            l10n.photoGallery,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
        ),
        actions: [
          if (storageAsync.hasValue)
            Padding(
              padding: EdgeInsets.only(right: DesignSpacing.md),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.sm,
                  vertical: DesignSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: DesignColors.highlightTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storage,
                      size: 14,
                      color: DesignColors.highlightTeal,
                    ),
                    SizedBox(width: DesignSpacing.xs),
                    Text(
                      _formatBytes(storageAsync.value!),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DesignColors.highlightTeal,
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
            return _buildEmptyState(l10n);
          }

          return RefreshIndicator(
            color: DesignColors.highlightTeal,
            onRefresh: () async {
              ref.invalidate(photosForCurrentPetProvider);
              ref.invalidate(storageUsedByCurrentPetProvider);
            },
            child: GridView.builder(
              padding: EdgeInsets.all(DesignSpacing.md),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: DesignSpacing.sm,
                mainAxisSpacing: DesignSpacing.sm,
              ),
              itemCount: photos.length + 1, // +1 for Add Photo card
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddPhotoCard(l10n);
                }
                return _buildPhotoTile(photos[index - 1], index - 1, photos);
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: DesignColors.highlightTeal,
          ),
        ),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      floatingActionButton: _isLoading
          ? FloatingActionButton(
              onPressed: null,
              backgroundColor: DesignColors.highlightTeal,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : FloatingActionButton(
              onPressed: _handleAddPhoto,
              backgroundColor: DesignColors.highlightTeal,
              elevation: 8,
              child: const Icon(
                Icons.add_a_photo,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cute cat icon
            Icon(
              Icons.pets,
              size: 80,
              color: DesignColors.highlightPeach.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.md),
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: DesignColors.highlightTeal.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              l10n.noPhotos,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xs),
            Text(
              l10n.addFirstPhoto,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: _handleAddPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: Text(l10n.addPhoto),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.highlightTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                  vertical: DesignSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoCard(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleAddPhoto,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: DesignColors.highlightPeach.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DesignColors.highlightTeal.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cute cat illustration - enlarged, centered
              SvgPicture.asset(
                'assets/illustrations/new_image.svg',
                width: 120,
                height: 120,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTile(dynamic photo, int photoIndex, List<dynamic> photos) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thumbnailFile = File(photo.thumbnailPath);
    final currentPet = ref.watch(currentPetProfileProvider);
    final isProfilePhoto = currentPet?.photoPath == photo.filePath;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Pass all photo IDs and current index for swipe navigation
          final photoIds = photos.map((p) => p.id).toList();
          context.push(
            '/photo-detail/${photo.id}',
            extra: {
              'photoIds': photoIds,
              'initialIndex': photoIndex,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
            border: isProfilePhoto
                ? Border.all(color: DesignColors.highlightTeal, width: 3)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Hero(
              tag: 'photo-${photo.id}',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo image
                  thumbnailFile.existsSync()
                      ? Image.file(
                          thumbnailFile,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDark
                                  ? DesignColors.dSurfaces
                                  : DesignColors.lSurfaces,
                              child: Icon(
                                Icons.broken_image,
                                color: DesignColors.highlightTeal.withOpacity(0.5),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: isDark
                              ? DesignColors.dSurfaces
                              : DesignColors.lSurfaces,
                          child: Icon(
                            Icons.broken_image,
                            color: DesignColors.highlightTeal.withOpacity(0.5),
                          ),
                        ),
                  // Profile photo badge
                  if (isProfilePhoto)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: DesignColors.highlightTeal,
                          shape: BoxShape.circle,
                          boxShadow: DesignShadows.md,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
