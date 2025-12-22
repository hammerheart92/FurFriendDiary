import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// Result of the consent dialog interaction
enum ConsentDialogResult {
  accepted,
  declined,
  dismissed,
}

/// Data class to hold consent dialog result with "don't ask again" preference
class ConsentDialogResponse {
  final ConsentDialogResult result;
  final bool dontAskAgain;

  const ConsentDialogResponse({
    required this.result,
    required this.dontAskAgain,
  });
}

/// Shows the PDF export consent dialog
///
/// Returns null if dismissed, or a [ConsentDialogResponse] with the user's choice
Future<ConsentDialogResponse?> showPdfConsentDialog(BuildContext context) {
  return showDialog<ConsentDialogResponse>(
    context: context,
    barrierDismissible: false, // Prevent accidental dismissal
    builder: (context) {
      return const _PdfConsentDialog();
    },
  );
}

/// PDF Export Consent Dialog (GDPR Article 6(1)(a) compliant)
///
/// Displays information about data included in PDF exports and obtains
/// explicit user consent before allowing PDF generation.
class _PdfConsentDialog extends StatefulWidget {
  const _PdfConsentDialog();

  @override
  State<_PdfConsentDialog> createState() => _PdfConsentDialogState();
}

class _PdfConsentDialogState extends State<_PdfConsentDialog> {
  bool _dontAskAgain = true; // Default: checked

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DesignColors.highlightTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: DesignColors.highlightTeal,
              size: 22,
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              l10n.pdfConsentTitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scrollable content area (message + bullet points + privacy policy)
            // Use explicit height calculation to prevent overflow
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight *
                    0.4, // Reduced from 0.6 to leave room for checkbox and actions
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main consent message
                    Text(
                      l10n.pdfConsentMessage,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryText,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.md),

                    // Data included section title
                    Text(
                      l10n.pdfConsentDataIncludedTitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.sm),

                    // Bullet list of data types
                    _buildDataItem(l10n.pdfConsentDataProfile, isDark),
                    _buildDataItem(l10n.pdfConsentDataVaccinations, isDark),
                    _buildDataItem(l10n.pdfConsentDataMedications, isDark),
                    _buildDataItem(l10n.pdfConsentDataAppointments, isDark),
                    _buildDataItem(l10n.pdfConsentDataHealth, isDark),
                    _buildDataItem(l10n.pdfConsentDataActivity, isDark),
                    _buildDataItem(l10n.pdfConsentDataExpenses, isDark),
                    _buildDataItem(l10n.pdfConsentDataNotes, isDark),

                    SizedBox(height: DesignSpacing.md),

                    // Privacy policy link
                    _buildPrivacyPolicyLink(context, l10n, isDark),
                  ],
                ),
              ),
            ),

            SizedBox(height: DesignSpacing.sm),

            // "Don't ask again" checkbox (always visible, outside scroll area)
            CheckboxListTile(
              value: _dontAskAgain,
              onChanged: (value) {
                setState(() {
                  _dontAskAgain = value ?? true;
                });
              },
              activeColor: DesignColors.highlightTeal,
              checkColor: Colors.white,
              title: Text(
                l10n.pdfConsentDontAskAgain,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: primaryText,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true, // Make checkbox more compact
            ),
          ],
        ),
      ),
      actions: [
        // Decline button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              ConsentDialogResponse(
                result: ConsentDialogResult.declined,
                dontAskAgain: _dontAskAgain,
              ),
            );
          },
          child: Text(
            l10n.consentDecline,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: secondaryText,
            ),
          ),
        ),

        // Accept button (primary action)
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(
              ConsentDialogResponse(
                result: ConsentDialogResult.accepted,
                dontAskAgain: _dontAskAgain,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.highlightTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.sm,
            ),
          ),
          child: Text(
            l10n.consentAccept,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a bullet point item for the data list
  Widget _buildDataItem(String text, bool isDark) {
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Padding(
      padding: EdgeInsets.only(left: DesignSpacing.sm, bottom: DesignSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: DesignColors.highlightTeal,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the privacy policy link with locale detection
  Widget _buildPrivacyPolicyLink(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';

    // Privacy policy URLs
    final privacyPolicyUrl = isRomanian
        ? 'https://hammerheart92.github.io/furfrienddiary-legal/privacy-policy-ro.html'
        : 'https://hammerheart92.github.io/furfrienddiary-legal/privacy-policy.html';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${l10n.pdfConsentPrivacyNote} ',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: secondaryText,
          ),
        ),
        InkWell(
          onTap: () => _launchPrivacyPolicy(privacyPolicyUrl),
          child: Text(
            l10n.privacyPolicy,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: DesignColors.highlightTeal,
              decoration: TextDecoration.underline,
              decorationColor: DesignColors.highlightTeal,
            ),
          ),
        ),
      ],
    );
  }

  /// Launches the privacy policy URL
  Future<void> _launchPrivacyPolicy(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
