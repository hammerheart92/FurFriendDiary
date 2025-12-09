import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../domain/exceptions/permission_exceptions.dart';

/// Service for handling image picking from camera and gallery
class ImageService {
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  /// Pick an image from the gallery
  /// Returns null if the user cancels
  /// Throws [PermissionDeniedException] or [PermissionPermanentlyDeniedException] if permission is denied
  Future<File?> pickFromGallery() async {
    try {
      // Request photos permission (Android 13+) or storage (Android 12-)
      PermissionStatus status;

      if (await _isAndroid13OrHigher()) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      if (status.isDenied) {
        throw PermissionDeniedException('Gallery permission denied');
      }

      if (status.isPermanentlyDenied) {
        throw PermissionPermanentlyDeniedException(
            'Gallery permission permanently denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 100,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      rethrow;
    }
  }

  /// Pick multiple images from the gallery
  /// Returns empty list if the user cancels
  /// Throws [PermissionDeniedException] or [PermissionPermanentlyDeniedException] if permission is denied
  Future<List<File>> pickMultipleFromGallery() async {
    try {
      // Request photos permission (Android 13+) or storage (Android 12-)
      PermissionStatus status;

      if (await _isAndroid13OrHigher()) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      if (status.isDenied) {
        throw PermissionDeniedException('Gallery permission denied');
      }

      if (status.isPermanentlyDenied) {
        throw PermissionPermanentlyDeniedException(
            'Gallery permission permanently denied');
      }

      // Pick multiple images
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 100,
      );

      if (images.isEmpty) return [];

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Take a photo with the camera
  /// Returns null if the user cancels
  /// Throws [PermissionDeniedException] or [PermissionPermanentlyDeniedException] if permission is denied
  Future<File?> takePhoto() async {
    try {
      final status = await Permission.camera.request();

      if (status.isDenied) {
        throw PermissionDeniedException('Camera permission denied');
      }

      if (status.isPermanentlyDenied) {
        throw PermissionPermanentlyDeniedException(
            'Camera permission permanently denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 100,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to check if device is running Android 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  /// Check if camera permission is permanently denied
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Check if gallery permission is permanently denied
  Future<bool> isGalleryPermissionPermanentlyDenied() async {
    final status = await Permission.photos.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings (for when permission is permanently denied)
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
