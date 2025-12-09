// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_consent_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pdfConsentRepositoryHash() =>
    r'66bd41d8e911f3b820a487606252d6540445b874';

/// Riverpod provider for PdfConsentRepository
///
/// Copied from [pdfConsentRepository].
@ProviderFor(pdfConsentRepository)
final pdfConsentRepositoryProvider =
    AutoDisposeProvider<PdfConsentRepository>.internal(
  pdfConsentRepository,
  name: r'pdfConsentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pdfConsentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PdfConsentRepositoryRef = AutoDisposeProviderRef<PdfConsentRepository>;
String _$hasPdfConsentGrantedHash() =>
    r'edc3fdc6e088d67349bed3161d905d65ae2b0dc2';

/// Provider to check if consent is granted (async)
///
/// Copied from [hasPdfConsentGranted].
@ProviderFor(hasPdfConsentGranted)
final hasPdfConsentGrantedProvider = AutoDisposeFutureProvider<bool>.internal(
  hasPdfConsentGranted,
  name: r'hasPdfConsentGrantedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasPdfConsentGrantedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasPdfConsentGrantedRef = AutoDisposeFutureProviderRef<bool>;
String _$currentPdfConsentHash() => r'526d1de64cb5b6d289d496f161ef75156c0f175a';

/// Provider to get current consent record
///
/// Copied from [currentPdfConsent].
@ProviderFor(currentPdfConsent)
final currentPdfConsentProvider =
    AutoDisposeFutureProvider<PdfConsent?>.internal(
  currentPdfConsent,
  name: r'currentPdfConsentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPdfConsentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentPdfConsentRef = AutoDisposeFutureProviderRef<PdfConsent?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
