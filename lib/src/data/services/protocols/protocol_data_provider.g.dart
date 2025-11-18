// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$protocolDataProviderHash() =>
    r'72fabe365fb58ad4007eba2ba7feb9e9f80ddd8e';

/// Riverpod provider for ProtocolDataProvider
///
/// Usage:
/// ```dart
/// final protocolProvider = ref.read(protocolDataProviderProvider);
/// final protocols = await protocolProvider.loadVaccinationProtocols();
/// ```
///
/// Copied from [protocolDataProvider].
@ProviderFor(protocolDataProvider)
final protocolDataProviderProvider =
    AutoDisposeProvider<ProtocolDataProvider>.internal(
  protocolDataProvider,
  name: r'protocolDataProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$protocolDataProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProtocolDataProviderRef = AutoDisposeProviderRef<ProtocolDataProvider>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
