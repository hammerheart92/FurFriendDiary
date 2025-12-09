import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/pdf_consent.dart';
import '../../domain/repositories/pdf_consent_repository.dart';
import '../local/hive_boxes.dart';

part 'pdf_consent_repository_impl.g.dart';

/// Implementation of PDF consent repository using Hive app_prefs box
class PdfConsentRepositoryImpl implements PdfConsentRepository {
  static const String _consentKey = 'pdf_export_consent';

  @override
  Future<PdfConsent?> getConsent() async {
    print('🗄️ [REPOSITORY] getConsent() called');
    final box = HiveBoxes.getAppPrefs();
    final consent = box.get(_consentKey) as PdfConsent?;
    print('🗄️ [REPOSITORY] Retrieved consent: ${consent != null ? "exists" : "null"}');
    if (consent != null) {
      print('  - consentGiven: ${consent.consentGiven}');
      print('  - dontAskAgain: ${consent.dontAskAgain}');
      print('  - timestamp: ${consent.timestamp}');
    }
    return consent;
  }

  @override
  Future<void> saveConsent(PdfConsent consent) async {
    print('💾 [REPOSITORY] saveConsent() called');
    print('  - consentGiven: ${consent.consentGiven}');
    print('  - dontAskAgain: ${consent.dontAskAgain}');
    final box = HiveBoxes.getAppPrefs();
    await box.put(_consentKey, consent);
    print('✅ [REPOSITORY] Consent saved successfully');
  }

  @override
  Future<void> deleteConsent() async {
    print('🗑️ [REPOSITORY] deleteConsent() called');
    final box = HiveBoxes.getAppPrefs();
    await box.delete(_consentKey);
    print('✅ [REPOSITORY] Consent deleted successfully');
  }

  @override
  Future<bool> hasGrantedConsent() async {
    final consent = await getConsent();
    return consent != null && consent.consentGiven;
  }

  @override
  Future<bool> hasConsentDecision() async {
    final consent = await getConsent();
    return consent != null && consent.dontAskAgain;
  }
}

/// Riverpod provider for PdfConsentRepository
@riverpod
PdfConsentRepository pdfConsentRepository(PdfConsentRepositoryRef ref) {
  return PdfConsentRepositoryImpl();
}

/// Provider to check if consent is granted (async)
@riverpod
Future<bool> hasPdfConsentGranted(HasPdfConsentGrantedRef ref) async {
  final repository = ref.watch(pdfConsentRepositoryProvider);
  return await repository.hasGrantedConsent();
}

/// Provider to get current consent record
@riverpod
Future<PdfConsent?> currentPdfConsent(CurrentPdfConsentRef ref) async {
  final repository = ref.watch(pdfConsentRepositoryProvider);
  return await repository.getConsent();
}
