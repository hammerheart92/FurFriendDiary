// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasCompletedSetupHash() => r'27e838a69b98ea4c0880b98d87f877d36d958184';

/// See also [hasCompletedSetup].
@ProviderFor(hasCompletedSetup)
final hasCompletedSetupProvider = AutoDisposeFutureProvider<bool>.internal(
  hasCompletedSetup,
  name: r'hasCompletedSetupProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasCompletedSetupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasCompletedSetupRef = AutoDisposeFutureProviderRef<bool>;
String _$currentActivePetHash() => r'b02cbeedc239841c720500bfa93b49082d2bba5b';

/// See also [currentActivePet].
@ProviderFor(currentActivePet)
final currentActivePetProvider =
    AutoDisposeFutureProvider<PetProfile?>.internal(
  currentActivePet,
  name: r'currentActivePetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentActivePetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentActivePetRef = AutoDisposeFutureProviderRef<PetProfile?>;
String _$appStateHash() => r'de509282ad5562921ac2402deaeb446101f008a6';

/// See also [AppState].
@ProviderFor(AppState)
final appStateProvider =
    AutoDisposeNotifierProvider<AppState, AppStateModel>.internal(
  AppState.new,
  name: r'appStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppState = AutoDisposeNotifier<AppStateModel>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
