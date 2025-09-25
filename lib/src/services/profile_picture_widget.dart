// lib/src/ui/widgets/profile_picture_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditIcon;

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
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: scheme.onSurface.withOpacity(0.08),
            backgroundImage: imagePath != null && imagePath!.isNotEmpty
                ? FileImage(File(imagePath!))
                : null,
            child: imagePath == null || imagePath!.isEmpty
                ? Icon(
                    Icons.pets,
                    size: radius * 0.7,
                    color: scheme.onSurface.withOpacity(0.60),
                  )
                : null,
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