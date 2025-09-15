// lib/src/services/profile_picture_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
//Errors occured in this file:

class ProfilePictureService {
  final ImagePicker _picker = ImagePicker();

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
        content: const Text('Choose how you want to select a photo for your pet.'),
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
    final appDir = await getApplicationDocumentsDirectory();
    final profilePicsDir = Directory('${appDir.path}/profile_pictures');
    
    // Create directory if it doesn't exist
    if (!await profilePicsDir.exists()) {
      await profilePicsDir.create(recursive: true);
    }

    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(pickedFile.path);
    final fileName = 'profile_$timestamp$extension';
    final localPath = '${profilePicsDir.path}/$fileName';

    // Copy file to local directory
    final File localFile = await File(pickedFile.path).copy(localPath);
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