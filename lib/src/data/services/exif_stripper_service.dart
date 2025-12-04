import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Service to strip EXIF metadata from images for GDPR compliance.
///
/// GDPR Article 5(1)(c) requires data minimization - GPS coordinates
/// and other EXIF metadata should not be retained in uploaded photos.
class ExifStripperService {
  final Logger _logger = Logger();

  /// Strips all EXIF metadata from an image file.
  ///
  /// Takes the original file path, strips EXIF data, and saves
  /// a cleaned copy to the app's documents directory.
  ///
  /// Returns the path to the cleaned image file.
  /// Returns original path if stripping fails (graceful degradation).
  Future<String> stripExifFromFile(String originalPath) async {
    try {
      _logger.d('Stripping EXIF from: $originalPath');

      // Read the original image bytes
      final file = File(originalPath);
      if (!await file.exists()) {
        _logger.w('File does not exist: $originalPath');
        return originalPath;
      }

      final imageBytes = await file.readAsBytes();

      // Strip EXIF metadata
      final cleanedBytes = await stripExifMetadata(imageBytes);

      // Save to app documents directory with unique filename
      final appDir = await getApplicationDocumentsDirectory();
      final certificatesDir = Directory('${appDir.path}/vaccination_certificates');
      if (!await certificatesDir.exists()) {
        await certificatesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanedPath = '${certificatesDir.path}/cert_$timestamp.png';

      final cleanedFile = File(cleanedPath);
      await cleanedFile.writeAsBytes(cleanedBytes);

      _logger.d('EXIF stripped, saved to: $cleanedPath');
      return cleanedPath;
    } catch (e) {
      _logger.e('Error stripping EXIF from file: $e');
      return originalPath; // Return original on error
    }
  }

  /// Strips all EXIF metadata from image bytes.
  ///
  /// Returns the cleaned image as bytes (PNG format to ensure no EXIF).
  Future<Uint8List> stripExifMetadata(Uint8List imageBytes) async {
    try {
      // Decode image (this discards EXIF in memory)
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        _logger.w('Failed to decode image for EXIF stripping');
        return imageBytes; // Return original if decode fails
      }

      // Re-encode as PNG (PNG does not support EXIF metadata)
      final cleanedBytes = img.encodePng(image);

      _logger.d('EXIF metadata stripped successfully');
      return Uint8List.fromList(cleanedBytes);
    } catch (e) {
      _logger.e('Error stripping EXIF metadata: $e');
      return imageBytes; // Return original on error
    }
  }
}
