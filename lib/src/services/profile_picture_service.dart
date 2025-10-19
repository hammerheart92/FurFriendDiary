// lib/src/services/profile_picture_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

class ProfilePictureService {
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  /// Shows a dialog to choose between camera and gallery
  Future<String?> selectProfilePicture(BuildContext context) async {
    final source = await _showImageSourceDialog(context);
    if (source == null) return null;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return null;

    // Save the image to app directory
    return await _saveImageLocally(pickedFile);
  }

  /// Shows dialog to choose image source
  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Photo'),
        content:
            const Text('Choose how you want to select a photo for your pet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            child: const Text('Camera'),
          ),
        ],
      ),
    );
  }

  /// Saves the picked image to local app directory
  Future<String> _saveImageLocally(XFile pickedFile) async {
    _logger.d('[PROFILE_PIC] Starting _saveImageLocally');
    _logger.d('[PROFILE_PIC] Picked image path: ${pickedFile.path}');

    final appDir = await getApplicationDocumentsDirectory();
    _logger.d('[PROFILE_PIC] App documents directory: ${appDir.path}');

    final profilePicsDir = Directory('${appDir.path}/profile_pictures');
    _logger
        .d('[PROFILE_PIC] Profile pictures directory: ${profilePicsDir.path}');

    // Create directory if it doesn't exist
    if (!await profilePicsDir.exists()) {
      _logger.d('[PROFILE_PIC] Creating profile_pictures directory');
      await profilePicsDir.create(recursive: true);
      _logger.d('[PROFILE_PIC] Directory created successfully');
    } else {
      _logger.d('[PROFILE_PIC] Directory already exists');
    }

    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(pickedFile.path);
    final fileName = 'profile_$timestamp$extension';
    final localPath = '${profilePicsDir.path}/$fileName';
    _logger.d('[PROFILE_PIC] Target local path: $localPath');

    // Copy file to local directory
    final File localFile = await File(pickedFile.path).copy(localPath);
    _logger.d('[PROFILE_PIC] File copied successfully');
    _logger.d('[PROFILE_PIC] Final saved path: ${localFile.path}');
    _logger.d('[PROFILE_PIC] File exists: ${await localFile.exists()}');

    return localFile.path;
  }

  /// Deletes a profile picture file
  Future<void> deleteProfilePicture(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
