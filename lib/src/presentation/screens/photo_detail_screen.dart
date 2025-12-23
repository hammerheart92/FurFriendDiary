import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
import '../providers/photo_provider.dart';
import '../providers/pet_profile_provider.dart';
import '../../domain/models/pet_photo.dart';
import '../../utils/snackbar_helper.dart';

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
        SnackBarHelper.showSuccess(context, l10n.captionSaved);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Error: ${e.toString()}');
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
          SnackBarHelper.showWarning(context, l10n.photoNotFound);
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
        SnackBarHelper.showError(context, 'Error sharing: ${e.toString()}');
      }
    }
  }

  Future<void> _setAsProfilePhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final currentPhotoId = widget.photoIds[_currentIndex];
    final photo = ref.read(photoDetailProvider(currentPhotoId));
    final currentPet = ref.read(currentPetProfileProvider);

    if (photo == null || currentPet == null) return;

    // Show styled confirmation dialog
    final confirmed = await _showSetProfilePhotoDialog(currentPet.name);

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
        SnackBarHelper.showSuccess(context, l10n.profilePhotoUpdated);
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<bool?> _showSetProfilePhotoDialog(String petName) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return showDialog<bool>(
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
                l10n.setProfilePhoto,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                l10n.setProfilePhotoConfirm(petName),
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
                    onPressed: () => Navigator.of(context).pop(false),
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
                    onPressed: () => Navigator.of(context).pop(true),
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
                      l10n.confirm,
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

  Future<void> _deletePhoto() async {
    final l10n = AppLocalizations.of(context)!;

    // Show styled confirmation dialog
    final confirmed = await _showDeleteDialog();

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
          SnackBarHelper.showSuccess(context, l10n.photoDeleted);
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

          SnackBarHelper.showSuccess(context, l10n.photoDeleted);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<bool?> _showDeleteDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return showDialog<bool>(
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
                l10n.deletePhoto,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                l10n.deletePhotoConfirm,
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
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.inter(
                        color: DesignColors.highlightTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.highlightCoral,
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
                      l10n.delete,
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

  String _formatDate(DateTime date) {
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPhotoId = widget.photoIds[_currentIndex];
    final photo = ref.watch(photoDetailProvider(currentPhotoId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

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
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${l10n.photo} ${_currentIndex + 1} / ${widget.photoIds.length}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        actions: [
          if (_isEditingCaption)
            IconButton(
              icon: Icon(Icons.check, color: DesignColors.highlightTeal),
              onPressed: () => _saveCaption(photo),
            )
          else ...[
            // Share button
            IconButton(
              icon: Icon(Icons.share, color: DesignColors.highlightTeal),
              tooltip: l10n.share,
              onPressed: _sharePhoto,
            ),
            // Set as profile photo button
            IconButton(
              icon:
                  Icon(Icons.account_circle, color: DesignColors.highlightTeal),
              tooltip: l10n.setProfilePhoto,
              onPressed: _setAsProfilePhoto,
            ),
            // Edit button
            IconButton(
              icon: Icon(Icons.edit, color: DesignColors.highlightTeal),
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
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DesignColors.highlightCoral,
                      ),
                    )
                  : Icon(Icons.delete, color: DesignColors.highlightCoral),
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
            Container(
              color: Colors.black,
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
                    return Center(
                      child: CircularProgressIndicator(
                        color: DesignColors.highlightTeal,
                      ),
                    );
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
                                  color: Colors.black,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: DesignColors.highlightTeal
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.black,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: DesignColors.highlightTeal
                                      .withOpacity(0.5),
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            if (widget.photoIds.length > 1)
              Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                child: Center(
                  child: Text(
                    '${_currentIndex + 1} / ${widget.photoIds.length}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

            // Photo details section
            Container(
              color: surfaceColor,
              padding: EdgeInsets.all(DesignSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption header
                  Text(
                    l10n.caption,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.xs),

                  // Caption input/display
                  if (_isEditingCaption)
                    TextField(
                      controller: _captionController,
                      maxLines: 3,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.addCaption,
                        hintStyle: GoogleFonts.inter(
                          color: secondaryText.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: surfaceColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? DesignColors.dDisabled
                                : DesignColors.lDisabled,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: DesignColors.highlightTeal,
                            width: 2,
                          ),
                        ),
                      ),
                      autofocus: true,
                    )
                  else
                    Text(
                      photo.caption?.isEmpty ?? true
                          ? l10n.noCaption
                          : photo.caption!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: photo.caption?.isEmpty ?? true
                            ? secondaryText.withOpacity(0.6)
                            : primaryText,
                        fontStyle: photo.caption?.isEmpty ?? true
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),

                  SizedBox(height: DesignSpacing.lg),

                  // Date taken
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: l10n.dateTaken,
                    value: _formatDate(photo.dateTaken),
                    secondaryText: secondaryText,
                    primaryText: primaryText,
                  ),

                  SizedBox(height: DesignSpacing.sm),

                  // File size
                  _buildInfoRow(
                    icon: Icons.storage,
                    label: l10n.fileSize,
                    value: _formatBytes(photo.fileSize),
                    secondaryText: secondaryText,
                    primaryText: primaryText,
                  ),

                  if (photo.createdAt != photo.dateTaken) ...[
                    SizedBox(height: DesignSpacing.sm),
                    _buildInfoRow(
                      icon: Icons.add_circle,
                      label: l10n.dateAdded,
                      value: _formatDate(photo.createdAt),
                      secondaryText: secondaryText,
                      primaryText: primaryText,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color secondaryText,
    required Color primaryText,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: secondaryText,
        ),
        SizedBox(width: DesignSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: secondaryText,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
