// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_consent_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pdfConsentServiceHash() => r'b4d6e115b09992d926f1fc6e96d71e786e467473';

/// Service for managing PDF export consent with UI interactions
///
/// Handles:
/// - Checking consent before PDF export
/// - Showing consent dialog when needed
/// - Managing consent state (grant/revoke)
/// - Displaying user feedback via SnackBars
///
/// Copied from [PdfConsentService].
@ProviderFor(PdfConsentService)
final pdfConsentServiceProvider =
    AutoDisposeAsyncNotifierProvider<PdfConsentService, PdfConsent?>.internal(
  PdfConsentService.new,
  name: r'pdfConsentServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pdfConsentServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PdfConsentService = AutoDisposeAsyncNotifier<PdfConsent?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
