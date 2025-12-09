import 'package:flutter/material.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
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
  print('🎭 [DIALOG] showPdfConsentDialog() called');
  return showDialog<ConsentDialogResponse>(
    context: context,
    barrierDismissible: false, // Prevent accidental dismissal
    builder: (context) {
      print('🎭 [DIALOG] Builder function called, creating dialog');
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
    print('🎭 [DIALOG] _PdfConsentDialog.build() called');
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n.pdfConsentTitle),
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
                maxHeight: screenHeight * 0.4, // Reduced from 0.6 to leave room for checkbox and actions
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main consent message
                    Text(
                      l10n.pdfConsentMessage,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Data included section title
                    Text(
                      l10n.pdfConsentDataIncludedTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Bullet list of data types
                    _buildDataItem(l10n.pdfConsentDataProfile, theme),
                    _buildDataItem(l10n.pdfConsentDataVaccinations, theme),
                    _buildDataItem(l10n.pdfConsentDataMedications, theme),
                    _buildDataItem(l10n.pdfConsentDataAppointments, theme),
                    _buildDataItem(l10n.pdfConsentDataHealth, theme),
                    _buildDataItem(l10n.pdfConsentDataActivity, theme),
                    _buildDataItem(l10n.pdfConsentDataExpenses, theme),
                    _buildDataItem(l10n.pdfConsentDataNotes, theme),

                    const SizedBox(height: 16),

                    // Privacy policy link
                    _buildPrivacyPolicyLink(context, l10n, theme),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // "Don't ask again" checkbox (always visible, outside scroll area)
            CheckboxListTile(
              value: _dontAskAgain,
              onChanged: (value) {
                setState(() {
                  _dontAskAgain = value ?? true;
                });
              },
              title: Text(
                l10n.pdfConsentDontAskAgain,
                style: theme.textTheme.bodyMedium,
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
            print('🚫 [DIALOG] User clicked Decline button');
            print('  - dontAskAgain: $_dontAskAgain');
            Navigator.of(context).pop(
              ConsentDialogResponse(
                result: ConsentDialogResult.declined,
                dontAskAgain: _dontAskAgain,
              ),
            );
          },
          child: Text(l10n.consentDecline),
        ),

        // Accept button (primary action)
        FilledButton(
          onPressed: () {
            print('✅ [DIALOG] User clicked Accept button');
            print('  - dontAskAgain: $_dontAskAgain');
            Navigator.of(context).pop(
              ConsentDialogResponse(
                result: ConsentDialogResult.accepted,
                dontAskAgain: _dontAskAgain,
              ),
            );
          },
          child: Text(l10n.consentAccept),
        ),
      ],
    );
  }

  /// Builds a bullet point item for the data list
  Widget _buildDataItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
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
    ThemeData theme,
  ) {
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
          style: theme.textTheme.bodySmall,
        ),
        InkWell(
          onTap: () => _launchPrivacyPolicy(privacyPolicyUrl),
          child: Text(
            l10n.privacyPolicy,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
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
