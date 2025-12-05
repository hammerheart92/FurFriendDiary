import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:logger/logger.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/models/pet_profile.dart';

/// Service for generating, saving, and sharing pet QR codes.
class QrCodeService {
  final Logger _logger = Logger();

  /// Generate human-readable QR data string from a pet profile.
  /// Only includes non-sensitive information for privacy.
  String generateQrDataString({
    required PetProfile pet,
    required AppLocalizations l10n,
  }) {
    final buffer = StringBuffer();

    // Header with emoji
    buffer.writeln('🐾 ${l10n.petInformation}');
    buffer.writeln('');

    // Pet name
    buffer.writeln('${l10n.name}: ${pet.name}');

    // Species (translated)
    buffer.writeln('${l10n.species}: ${_translateSpecies(pet.species, l10n)}');

    // Breed (if available)
    if (pet.breed != null && pet.breed!.isNotEmpty) {
      buffer.writeln('${l10n.breed}: ${pet.breed}');
    }

    // Age (calculated from birthday)
    final ageYears = _calculateAge(pet.birthday);
    if (ageYears != null && ageYears > 0) {
      final yearLabel = ageYears == 1 ? l10n.yearSingular : l10n.yearPlural;
      buffer.writeln('${l10n.ageLabel}: $ageYears $yearLabel');
    }

    // Generated date (localized)
    final dateFormat = DateFormat.yMMMd(l10n.localeName);
    buffer.writeln('${l10n.generated}: ${dateFormat.format(DateTime.now())}');

    return buffer.toString();
  }

  /// Calculate age in years from birthday.
  int? _calculateAge(DateTime? birthday) {
    if (birthday == null) return null;

    final now = DateTime.now();
    int ageYears = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      ageYears--;
    }
    return ageYears < 0 ? 0 : ageYears;
  }

  /// Translate species to localized string.
  String _translateSpecies(String species, AppLocalizations l10n) {
    switch (species.toLowerCase()) {
      case 'dog':
        return l10n.speciesDog;
      case 'cat':
        return l10n.speciesCat;
      case 'bird':
        return l10n.speciesBird;
      case 'rabbit':
        return l10n.speciesRabbit;
      case 'hamster':
        return l10n.speciesHamster;
      case 'guinea pig':
        return l10n.speciesGuineaPig;
      case 'fish':
        return l10n.speciesFish;
      case 'turtle':
        return l10n.speciesTurtle;
      case 'lizard':
        return l10n.speciesLizard;
      case 'snake':
        return l10n.speciesSnake;
      case 'ferret':
        return l10n.speciesFerret;
      case 'chinchilla':
        return l10n.speciesChinchilla;
      case 'rat':
        return l10n.speciesRat;
      case 'mouse':
        return l10n.speciesMouse;
      case 'gerbil':
        return l10n.speciesGerbil;
      case 'hedgehog':
        return l10n.speciesHedgehog;
      case 'parrot':
        return l10n.speciesParrot;
      case 'horse':
        return l10n.speciesHorse;
      case 'chicken':
        return l10n.speciesChicken;
      default:
        return species; // Return original if not found
    }
  }

  /// Save QR code image to local storage.
  /// Returns the file path of the saved image.
  Future<String> saveQrCodeImage(GlobalKey qrKey, String petName) async {
    try {
      final boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate QR image');
      }

      final pngBytes = byteData.buffer.asUint8List();

      // Get storage directory
      Directory? directory;
      try {
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        }
        directory ??= await getApplicationDocumentsDirectory();
      } catch (e) {
        _logger.w('[QR] Storage access failed, using temp: $e');
        directory = await getTemporaryDirectory();
      }

      // Create qr_codes subdirectory
      final qrDir = Directory('${directory.path}/qr_codes');
      if (!await qrDir.exists()) {
        await qrDir.create(recursive: true);
      }

      // Save the image with sanitized pet name
      final safeName = petName.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'qr_${safeName}_$timestamp.png';
      final file = File('${qrDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      _logger.d('[QR] Saved QR code to: ${file.path}');
      return file.path;
    } catch (e) {
      _logger.e('[QR] Failed to save QR code: $e');
      rethrow;
    }
  }

  /// Share QR code image using native share dialog.
  Future<void> shareQrCode(
    String filePath, {
    String? petName,
    String? text,
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: petName != null ? 'QR Code for $petName' : 'Pet QR Code',
        text: text,
      );
    } catch (e) {
      _logger.e('[QR] Failed to share QR code: $e');
      rethrow;
    }
  }
}
