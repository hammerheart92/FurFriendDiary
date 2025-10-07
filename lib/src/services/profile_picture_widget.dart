// lib/src/ui/widgets/profile_picture_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditIcon;

  static final _logger = Logger();

  const ProfilePictureWidget({
    super.key,
    this.imagePath,
    this.radius = 32,
    this.onTap,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    _logger.d('[PROFILE_PIC] ProfilePictureWidget building');
    _logger.d('[PROFILE_PIC] imagePath: $imagePath');

    ImageProvider? backgroundImage;
    Widget? child;

    if (imagePath != null && imagePath!.isNotEmpty) {
      final imageFile = File(imagePath!);
      final exists = imageFile.existsSync();

      _logger.d('[PROFILE_PIC] Checking file existence...');
      _logger.d('[PROFILE_PIC] - Path: $imagePath');
      _logger.d('[PROFILE_PIC] - Absolute path: ${imageFile.absolute.path}');
      _logger.d('[PROFILE_PIC] - File exists: $exists');

      if (exists) {
        try {
          final fileSize = imageFile.lengthSync();
          _logger.d('[PROFILE_PIC] SUCCESS: File verified! Size: $fileSize bytes');
          backgroundImage = FileImage(imageFile);
        } catch (e) {
          _logger.e('[PROFILE_PIC] ERROR: Failed to read file: $e');
          child = Icon(
            Icons.pets,
            size: radius * 0.7,
            color: scheme.onSurface.withOpacity(0.60),
          );
        }
      } else {
        _logger.e('[PROFILE_PIC] ERROR: imagePath is set but file does NOT exist!');
        _logger.e('[PROFILE_PIC] ERROR: Expected at: ${imageFile.absolute.path}');
        child = Icon(
          Icons.pets,
          size: radius * 0.7,
          color: scheme.onSurface.withOpacity(0.60),
        );
      }
    } else {
      _logger.d('[PROFILE_PIC] imagePath is null or empty, showing default icon');
      child = Icon(
        Icons.pets,
        size: radius * 0.7,
        color: scheme.onSurface.withOpacity(0.60),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: scheme.onSurface.withOpacity(0.08),
            backgroundImage: backgroundImage,
            child: child,
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.surface,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: scheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}