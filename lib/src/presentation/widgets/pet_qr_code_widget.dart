import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Widget that displays a QR code with pet information.
class PetQrCodeWidget extends StatelessWidget {
  /// Human-readable text data for the QR code.
  final String qrData;

  /// Pet name displayed below the QR code.
  final String petName;

  /// Pet species displayed below the QR code.
  final String petSpecies;

  final double size;
  final GlobalKey? repaintKey;

  const PetQrCodeWidget({
    super.key,
    required this.qrData,
    required this.petName,
    required this.petSpecies,
    this.size = 200,
    this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final qrWidget = QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Colors.black,
      ),
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );

    // Wrap in RepaintBoundary for screenshot/save functionality
    if (repaintKey != null) {
      return RepaintBoundary(
        key: repaintKey,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              qrWidget,
              const SizedBox(height: 12),
              Text(
                petName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                petSpecies,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return qrWidget;
  }
}
