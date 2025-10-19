import 'dart:io';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import '../../domain/models/pet_photo.dart';

/// Repository for managing pet photos
class PhotoRepository {
  final Box<PetPhoto> _box;
  final Logger _logger = Logger();

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int targetFileSizeBytes = 1 * 1024 * 1024; // 1MB
  static const int compressionQuality = 85;
  static const int maxImageWidth = 1920;
  static const int thumbnailSize = 300;

  PhotoRepository(this._box);

  /// Get the photos directory for the app
  Future<Directory> _getPhotosDirectory(String petId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(appDir.path, 'photos', petId));

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
      _logger.d('Created photos directory: ${photosDir.path}');
    }

    return photosDir;
  }

  /// Compress image using the image package
  Future<File> _compressImage(File imageFile) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if too large (max 1920px on longest side)
      if (image.width > 1920 || image.height > 1920) {
        if (image.width > image.height) {
          image = img.copyResize(image, width: 1920);
        } else {
          image = img.copyResize(image, height: 1920);
        }
      }

      // Compress to JPEG with 85% quality
      final compressedBytes = img.encodeJpg(image, quality: 85);

      // Save compressed image
      final compressedFile = File('${imageFile.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      // Delete original if different
      if (imageFile.path != compressedFile.path) {
        await imageFile.delete();
      }

      return compressedFile;
    } catch (e) {
      _logger.e('Compression error: $e');
      // If compression fails, return original file
      return imageFile;
    }
  }

  /// Generate thumbnail using the image package
  Future<File> _generateThumbnail(File imageFile, String thumbnailPath) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image for thumbnail');
      }

      // Create 300x300 thumbnail
      img.Image thumbnail = img.copyResizeCropSquare(image, size: 300);

      // Compress thumbnail
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);

      // Save thumbnail
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return thumbnailFile;
    } catch (e) {
      _logger.e('Thumbnail generation error: $e');
      // Return original if thumbnail fails
      return imageFile;
    }
  }

  /// Save a photo with compression and thumbnail generation
  /// Throws exception if file is too large or compression fails
  Future<PetPhoto> savePhoto({
    required File imageFile,
    required String petId,
    String? caption,
    String? medicationId,
    String? appointmentId,
  }) async {
    try {
      _logger.d('Saving photo for pet: $petId');

      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > maxFileSizeBytes) {
        throw Exception(
            'File is too large. Maximum size is ${maxFileSizeBytes ~/ (1024 * 1024)}MB');
      }

      _logger.d('Original file size: ${fileSize ~/ 1024}KB');

      // Generate unique ID
      final photoId = const Uuid().v4();

      // Get photos directory
      final photosDir = await _getPhotosDirectory(petId);

      // Compress main image
      _logger.d('Compressing main image...');
      final compressedFile = await _compressImage(imageFile);

      final compressedFileSize = await compressedFile.length();
      _logger.d('Compressed image size: ${compressedFileSize ~/ 1024}KB');

      // Create target paths
      final photoPath = path.join(photosDir.path, '$photoId.jpg');
      final thumbnailPath = path.join(photosDir.path, '${photoId}_thumb.jpg');

      // Move compressed file to final location
      final photoFile = await compressedFile.copy(photoPath);
      if (compressedFile.path != photoPath) {
        await compressedFile.delete();
      }
      _logger.d('Compressed image saved: ${compressedFileSize ~/ 1024}KB');

      // Generate thumbnail
      _logger.d('Generating thumbnail...');
      final thumbnailFile = await _generateThumbnail(photoFile, thumbnailPath);
      final thumbnailFileSize = await thumbnailFile.length();
      _logger.d('Thumbnail saved: ${thumbnailFileSize ~/ 1024}KB');

      // Create PetPhoto model
      final petPhoto = PetPhoto(
        id: photoId,
        petId: petId,
        filePath: photoPath,
        thumbnailPath: thumbnailPath,
        caption: caption,
        dateTaken: DateTime.now(),
        fileSize: compressedFileSize,
        medicationId: medicationId,
        appointmentId: appointmentId,
      );

      // Save to Hive
      await _box.put(photoId, petPhoto);
      _logger.d('Photo saved to Hive: $photoId');

      return petPhoto;
    } catch (e) {
      _logger.e('Error saving photo: $e');
      rethrow;
    }
  }

  /// Save multiple photos with compression and thumbnail generation
  /// Returns list of successfully saved photos
  Future<List<PetPhoto>> saveMultiplePhotos({
    required List<File> imageFiles,
    required String petId,
    String? caption,
    String? medicationId,
    String? appointmentId,
  }) async {
    final savedPhotos = <PetPhoto>[];

    for (final imageFile in imageFiles) {
      try {
        final photo = await savePhoto(
          imageFile: imageFile,
          petId: petId,
          caption: caption,
          medicationId: medicationId,
          appointmentId: appointmentId,
        );
        savedPhotos.add(photo);
      } catch (e) {
        _logger.e('Failed to save photo: $e');
        // Continue with other photos even if one fails
      }
    }

    return savedPhotos;
  }

  /// Update photo caption
  Future<void> updateCaption(String photoId, String? caption) async {
    try {
      final photo = _box.get(photoId);
      if (photo == null) {
        throw Exception('Photo not found: $photoId');
      }

      final updatedPhoto = photo.copyWith(caption: caption);
      await _box.put(photoId, updatedPhoto);
      _logger.d('Photo caption updated: $photoId');
    } catch (e) {
      _logger.e('Error updating caption: $e');
      rethrow;
    }
  }

  /// Delete a photo (removes both file and Hive entry)
  Future<void> deletePhoto(String photoId) async {
    try {
      _logger.d('Deleting photo: $photoId');

      final photo = _box.get(photoId);
      if (photo == null) {
        _logger.w('Photo not found in Hive: $photoId');
        return;
      }

      // Delete main image file
      final photoFile = File(photo.filePath);
      if (await photoFile.exists()) {
        await photoFile.delete();
        _logger.d('Deleted photo file: ${photo.filePath}');
      } else {
        _logger.w('Photo file not found: ${photo.filePath}');
      }

      // Delete thumbnail file
      final thumbnailFile = File(photo.thumbnailPath);
      if (await thumbnailFile.exists()) {
        await thumbnailFile.delete();
        _logger.d('Deleted thumbnail file: ${photo.thumbnailPath}');
      } else {
        _logger.w('Thumbnail file not found: ${photo.thumbnailPath}');
      }

      // Delete from Hive
      await _box.delete(photoId);
      _logger.d('Photo deleted from Hive: $photoId');
    } catch (e) {
      _logger.e('Error deleting photo: $e');
      rethrow;
    }
  }

  /// Get all photos for a specific pet, sorted by date descending
  List<PetPhoto> getPhotosForPet(String petId) {
    return _box.values.where((photo) => photo.petId == petId).toList()
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
  }

  /// Get a single photo by ID
  PetPhoto? getPhoto(String photoId) {
    return _box.get(photoId);
  }

  /// Get photos as a stream for real-time updates
  Stream<List<PetPhoto>> getPhotosStream(String petId) {
    return _box.watch().map((_) => getPhotosForPet(petId));
  }

  /// Get total storage used by all photos in bytes
  Future<int> getTotalStorageUsed() async {
    try {
      int totalSize = 0;

      for (final photo in _box.values) {
        // Add main image size
        final photoFile = File(photo.filePath);
        if (await photoFile.exists()) {
          totalSize += await photoFile.length();
        }

        // Add thumbnail size
        final thumbnailFile = File(photo.thumbnailPath);
        if (await thumbnailFile.exists()) {
          totalSize += await thumbnailFile.length();
        }
      }

      _logger.d('Total storage used: ${totalSize ~/ 1024}KB');
      return totalSize;
    } catch (e) {
      _logger.e('Error calculating storage: $e');
      return 0;
    }
  }

  /// Get storage used for a specific pet in bytes
  Future<int> getStorageUsedForPet(String petId) async {
    try {
      int totalSize = 0;
      final photos = getPhotosForPet(petId);

      for (final photo in photos) {
        // Add main image size
        final photoFile = File(photo.filePath);
        if (await photoFile.exists()) {
          totalSize += await photoFile.length();
        }

        // Add thumbnail size
        final thumbnailFile = File(photo.thumbnailPath);
        if (await thumbnailFile.exists()) {
          totalSize += await thumbnailFile.length();
        }
      }

      return totalSize;
    } catch (e) {
      _logger.e('Error calculating pet storage: $e');
      return 0;
    }
  }

  /// Delete all photos for a specific pet
  Future<void> deletePhotosForPet(String petId) async {
    try {
      _logger.d('Deleting all photos for pet: $petId');
      final photos = getPhotosForPet(petId);

      for (final photo in photos) {
        await deletePhoto(photo.id);
      }

      _logger.d('Deleted ${photos.length} photos for pet: $petId');
    } catch (e) {
      _logger.e('Error deleting photos for pet: $e');
      rethrow;
    }
  }

  /// Get count of photos for a pet
  int getPhotoCount(String petId) {
    return _box.values.where((photo) => photo.petId == petId).length;
  }

  /// Check if a photo file exists
  Future<bool> photoFileExists(String photoId) async {
    final photo = _box.get(photoId);
    if (photo == null) return false;

    final photoFile = File(photo.filePath);
    return await photoFile.exists();
  }
}
