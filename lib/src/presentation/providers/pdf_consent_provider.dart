import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

import '../../domain/models/pdf_consent.dart';
import '../../domain/repositories/pdf_consent_repository.dart';
import '../../data/repositories/pdf_consent_repository_impl.dart';
import '../widgets/pdf_consent_dialog.dart';

part 'pdf_consent_provider.g.dart';

/// Service for managing PDF export consent with UI interactions
///
/// Handles:
/// - Checking consent before PDF export
/// - Showing consent dialog when needed
/// - Managing consent state (grant/revoke)
/// - Displaying user feedback via SnackBars
@riverpod
class PdfConsentService extends _$PdfConsentService {
  PdfConsentRepository get _repository =>
      ref.read(pdfConsentRepositoryProvider);

  @override
  Future<PdfConsent?> build() async {
    final consent = await _repository.getConsent();
    return consent;
  }

  /// Checks consent before PDF export and handles all 3 cases:
  /// 1. Consent granted → return true immediately
  /// 2. Consent declined with "don't ask again" → show SnackBar, return false
  /// 3. No decision made → show dialog, return based on user's choice
  ///
  /// Returns true if PDF export can proceed, false otherwise
  Future<bool> checkConsentBeforeExport(BuildContext context) async {
    if (!context.mounted) {
      return false;
    }

    final consent = await _repository.getConsent();

    // Case 1: Consent already granted
    if (consent != null && consent.consentGiven) {
      return true;
    }

    // Case 2: User previously declined with "don't ask again"
    if (consent != null && !consent.consentGiven && consent.dontAskAgain) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.consentRequired),
            action: SnackBarAction(
              label: l10n.settings,
              onPressed: () {
                // User can navigate to settings manually
                // Navigation handled by caller if needed
              },
            ),
          ),
        );
      }
      return false;
    }

    // Case 3: No decision made or declined without "don't ask again" → show dialog
    if (context.mounted) {
      final result = await showPdfConsentDialog(context);

      if (result == null) {
        // Dialog dismissed (shouldn't happen with barrierDismissible: false)
        return false;
      }

      if (result.result == ConsentDialogResult.accepted) {
        // User accepted consent
        await _saveConsent(
          PdfConsent.granted(dontAskAgain: result.dontAskAgain),
        );
        return true;
      } else {
        // User declined consent
        await _saveConsent(
          PdfConsent.declined(dontAskAgain: result.dontAskAgain),
        );

        if (context.mounted && result.dontAskAgain) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.consentDeclinedMessage)),
          );
        }

        return false;
      }
    }

    return false;
  }

  /// Grant consent (called from Settings)
  Future<void> grantConsent() async {
    final consent = PdfConsent.granted(dontAskAgain: true);
    await _saveConsent(consent);
  }

  /// Revoke consent (called from Settings after confirmation)
  /// Deletes the consent record entirely so dialog appears on next export attempt
  Future<void> revokeConsent() async {
    await resetConsent();
  }

  /// Reset consent decision (for testing/debugging)
  Future<void> resetConsent() async {
    await _repository.deleteConsent();
    state = const AsyncValue.data(null);
  }

  /// Internal helper to save consent and update state
  Future<void> _saveConsent(PdfConsent consent) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveConsent(consent);
      state = AsyncValue.data(consent);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
