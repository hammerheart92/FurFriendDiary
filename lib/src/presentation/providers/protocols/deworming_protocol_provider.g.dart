// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deworming_protocol_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dewormingProtocolsBySpeciesHash() =>
    r'f8b7908b78081f212284a3e4cd419582f8d4f2cb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Get deworming protocols filtered by pet species (Dog/Cat)
///
/// Returns both predefined and custom protocols for the specified species.
///
/// Usage:
/// ```dart
/// final dogProtocols = await ref.read(dewormingProtocolsBySpeciesProvider('Dog').future);
/// ```
///
/// Copied from [dewormingProtocolsBySpecies].
@ProviderFor(dewormingProtocolsBySpecies)
const dewormingProtocolsBySpeciesProvider = DewormingProtocolsBySpeciesFamily();

/// Get deworming protocols filtered by pet species (Dog/Cat)
///
/// Returns both predefined and custom protocols for the specified species.
///
/// Usage:
/// ```dart
/// final dogProtocols = await ref.read(dewormingProtocolsBySpeciesProvider('Dog').future);
/// ```
///
/// Copied from [dewormingProtocolsBySpecies].
class DewormingProtocolsBySpeciesFamily
    extends Family<AsyncValue<List<DewormingProtocol>>> {
  /// Get deworming protocols filtered by pet species (Dog/Cat)
  ///
  /// Returns both predefined and custom protocols for the specified species.
  ///
  /// Usage:
  /// ```dart
  /// final dogProtocols = await ref.read(dewormingProtocolsBySpeciesProvider('Dog').future);
  /// ```
  ///
  /// Copied from [dewormingProtocolsBySpecies].
  const DewormingProtocolsBySpeciesFamily();

  /// Get deworming protocols filtered by pet species (Dog/Cat)
  ///
  /// Returns both predefined and custom protocols for the specified species.
  ///
  /// Usage:
  /// ```dart
  /// final dogProtocols = await ref.read(dewormingProtocolsBySpeciesProvider('Dog').future);
  /// ```
  ///
  /// Copied from [dewormingProtocolsBySpecies].
  DewormingProtocolsBySpeciesProvider call(
    String species,
  ) {
    return DewormingProtocolsBySpeciesProvider(
      species,
    );
  }

  @override
  DewormingProtocolsBySpeciesProvider getProviderOverride(
    covariant DewormingProtocolsBySpeciesProvider provider,
  ) {
    return call(
      provider.species,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dewormingProtocolsBySpeciesProvider';
}

/// Get deworming protocols filtered by pet species (Dog/Cat)
///
/// Returns both predefined and custom protocols for the specified species.
///
/// Usage:
/// ```dart
/// final dogProtocols = await ref.read(dewormingProtocolsBySpeciesProvider('Dog').future);
/// ```
///
/// Copied from [dewormingProtocolsBySpecies].
class DewormingProtocolsBySpeciesProvider
    extends AutoDisposeFutureProvider<List<DewormingProtocol>> {
  /// Get deworming protocols filtered by pet species (Dog/Cat)
  ///
  /// Returns both predefined and custom protocols for the specified species.
  ///
  /// Usage:
  /// ```dart
  /// final dogProtocols = await ref.read(dewormingProtocolsBySpeciesProvider('Dog').future);
  /// ```
  ///
  /// Copied from [dewormingProtocolsBySpecies].
  DewormingProtocolsBySpeciesProvider(
    String species,
  ) : this._internal(
          (ref) => dewormingProtocolsBySpecies(
            ref as DewormingProtocolsBySpeciesRef,
            species,
          ),
          from: dewormingProtocolsBySpeciesProvider,
          name: r'dewormingProtocolsBySpeciesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dewormingProtocolsBySpeciesHash,
          dependencies: DewormingProtocolsBySpeciesFamily._dependencies,
          allTransitiveDependencies:
              DewormingProtocolsBySpeciesFamily._allTransitiveDependencies,
          species: species,
        );

  DewormingProtocolsBySpeciesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.species,
  }) : super.internal();

  final String species;

  @override
  Override overrideWith(
    FutureOr<List<DewormingProtocol>> Function(
            DewormingProtocolsBySpeciesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DewormingProtocolsBySpeciesProvider._internal(
        (ref) => create(ref as DewormingProtocolsBySpeciesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        species: species,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<DewormingProtocol>> createElement() {
    return _DewormingProtocolsBySpeciesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DewormingProtocolsBySpeciesProvider &&
        other.species == species;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, species.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DewormingProtocolsBySpeciesRef
    on AutoDisposeFutureProviderRef<List<DewormingProtocol>> {
  /// The parameter `species` of this provider.
  String get species;
}

class _DewormingProtocolsBySpeciesProviderElement
    extends AutoDisposeFutureProviderElement<List<DewormingProtocol>>
    with DewormingProtocolsBySpeciesRef {
  _DewormingProtocolsBySpeciesProviderElement(super.provider);

  @override
  String get species => (origin as DewormingProtocolsBySpeciesProvider).species;
}

String _$predefinedDewormingProtocolsHash() =>
    r'1a075b69ab8956b526d833aa0ded527507e8c4ff';

/// Get only predefined deworming protocols
///
/// These are the protocols loaded from JSON assets (deworming_protocols.json).
/// Includes ESCCAP-compliant internal and external parasite treatment schedules.
///
/// Usage:
/// ```dart
/// final predefinedProtocols = await ref.read(predefinedDewormingProtocolsProvider.future);
/// ```
///
/// Copied from [predefinedDewormingProtocols].
@ProviderFor(predefinedDewormingProtocols)
final predefinedDewormingProtocolsProvider =
    AutoDisposeFutureProvider<List<DewormingProtocol>>.internal(
  predefinedDewormingProtocols,
  name: r'predefinedDewormingProtocolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$predefinedDewormingProtocolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PredefinedDewormingProtocolsRef
    = AutoDisposeFutureProviderRef<List<DewormingProtocol>>;
String _$customDewormingProtocolsHash() =>
    r'302d0b2544181a310dcad68dadf621d45bca35a8';

/// Get only custom user-created deworming protocols
///
/// These are protocols created by the user and stored in Hive.
///
/// Usage:
/// ```dart
/// final customProtocols = await ref.read(customDewormingProtocolsProvider.future);
/// ```
///
/// Copied from [customDewormingProtocols].
@ProviderFor(customDewormingProtocols)
final customDewormingProtocolsProvider =
    AutoDisposeFutureProvider<List<DewormingProtocol>>.internal(
  customDewormingProtocols,
  name: r'customDewormingProtocolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customDewormingProtocolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CustomDewormingProtocolsRef
    = AutoDisposeFutureProviderRef<List<DewormingProtocol>>;
String _$dewormingProtocolByIdHash() =>
    r'af2be39d549531a1d4382aeaee26c4a91c416612';

/// Get a specific deworming protocol by ID
///
/// Returns null if protocol not found.
///
/// Usage:
/// ```dart
/// final protocol = await ref.read(dewormingProtocolByIdProvider('protocol-id').future);
/// ```
///
/// Copied from [dewormingProtocolById].
@ProviderFor(dewormingProtocolById)
const dewormingProtocolByIdProvider = DewormingProtocolByIdFamily();

/// Get a specific deworming protocol by ID
///
/// Returns null if protocol not found.
///
/// Usage:
/// ```dart
/// final protocol = await ref.read(dewormingProtocolByIdProvider('protocol-id').future);
/// ```
///
/// Copied from [dewormingProtocolById].
class DewormingProtocolByIdFamily
    extends Family<AsyncValue<DewormingProtocol?>> {
  /// Get a specific deworming protocol by ID
  ///
  /// Returns null if protocol not found.
  ///
  /// Usage:
  /// ```dart
  /// final protocol = await ref.read(dewormingProtocolByIdProvider('protocol-id').future);
  /// ```
  ///
  /// Copied from [dewormingProtocolById].
  const DewormingProtocolByIdFamily();

  /// Get a specific deworming protocol by ID
  ///
  /// Returns null if protocol not found.
  ///
  /// Usage:
  /// ```dart
  /// final protocol = await ref.read(dewormingProtocolByIdProvider('protocol-id').future);
  /// ```
  ///
  /// Copied from [dewormingProtocolById].
  DewormingProtocolByIdProvider call(
    String id,
  ) {
    return DewormingProtocolByIdProvider(
      id,
    );
  }

  @override
  DewormingProtocolByIdProvider getProviderOverride(
    covariant DewormingProtocolByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dewormingProtocolByIdProvider';
}

/// Get a specific deworming protocol by ID
///
/// Returns null if protocol not found.
///
/// Usage:
/// ```dart
/// final protocol = await ref.read(dewormingProtocolByIdProvider('protocol-id').future);
/// ```
///
/// Copied from [dewormingProtocolById].
class DewormingProtocolByIdProvider
    extends AutoDisposeFutureProvider<DewormingProtocol?> {
  /// Get a specific deworming protocol by ID
  ///
  /// Returns null if protocol not found.
  ///
  /// Usage:
  /// ```dart
  /// final protocol = await ref.read(dewormingProtocolByIdProvider('protocol-id').future);
  /// ```
  ///
  /// Copied from [dewormingProtocolById].
  DewormingProtocolByIdProvider(
    String id,
  ) : this._internal(
          (ref) => dewormingProtocolById(
            ref as DewormingProtocolByIdRef,
            id,
          ),
          from: dewormingProtocolByIdProvider,
          name: r'dewormingProtocolByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dewormingProtocolByIdHash,
          dependencies: DewormingProtocolByIdFamily._dependencies,
          allTransitiveDependencies:
              DewormingProtocolByIdFamily._allTransitiveDependencies,
          id: id,
        );

  DewormingProtocolByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<DewormingProtocol?> Function(DewormingProtocolByIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DewormingProtocolByIdProvider._internal(
        (ref) => create(ref as DewormingProtocolByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DewormingProtocol?> createElement() {
    return _DewormingProtocolByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DewormingProtocolByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DewormingProtocolByIdRef
    on AutoDisposeFutureProviderRef<DewormingProtocol?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _DewormingProtocolByIdProviderElement
    extends AutoDisposeFutureProviderElement<DewormingProtocol?>
    with DewormingProtocolByIdRef {
  _DewormingProtocolByIdProviderElement(super.provider);

  @override
  String get id => (origin as DewormingProtocolByIdProvider).id;
}

String _$dewormingProtocolsHash() =>
    r'74df4e7ece7ea5ef71c994dbec53c0d5a4764871';

/// Main deworming protocol provider - manages all protocols (predefined + custom)
///
/// This provider combines predefined protocols loaded from JSON assets with
/// custom user-created protocols stored in Hive. It automatically loads predefined
/// protocols on first build and merges them with custom protocols.
///
/// Usage:
/// ```dart
/// final protocols = await ref.read(dewormingProtocolsProvider.future);
/// ```
///
/// Copied from [DewormingProtocols].
@ProviderFor(DewormingProtocols)
final dewormingProtocolsProvider = AutoDisposeAsyncNotifierProvider<
    DewormingProtocols, List<DewormingProtocol>>.internal(
  DewormingProtocols.new,
  name: r'dewormingProtocolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dewormingProtocolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DewormingProtocols
    = AutoDisposeAsyncNotifier<List<DewormingProtocol>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
