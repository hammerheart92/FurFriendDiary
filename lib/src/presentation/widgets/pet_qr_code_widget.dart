import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

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

  /// Whether to show the styled border around the QR card.
  final bool showBorder;

  /// Whether the app is in dark mode (for shadow selection).
  final bool isDark;

  const PetQrCodeWidget({
    super.key,
    required this.qrData,
    required this.petName,
    required this.petSpecies,
    this.size = 200,
    this.repaintKey,
    this.showBorder = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.all(DesignSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white, // ALWAYS white for QR code visibility
            borderRadius: BorderRadius.circular(16),
            boxShadow: showBorder
                ? (isDark ? DesignShadows.darkMd : DesignShadows.md)
                : null,
            border: showBorder
                ? Border.all(
                    color: DesignColors.highlightBlue.withOpacity(0.2),
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              qrWidget,
              SizedBox(height: DesignSpacing.md),
              // Divider
              Container(
                height: 1,
                color: Colors.black12,
              ),
              SizedBox(height: DesignSpacing.md),
              // Pet Name - ALWAYS dark on white card
              Text(
                petName,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: DesignSpacing.xs),
              // Pet Species - ALWAYS gray on white card
              Text(
                petSpecies,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
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
