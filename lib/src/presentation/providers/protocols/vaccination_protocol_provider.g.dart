// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_protocol_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vaccinationProtocolsBySpeciesHash() =>
    r'75a0e166e50dd27741723a73f7a3b4db9965b6a2';

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

/// Get vaccination protocols filtered by pet species (Dog/Cat)
///
/// Returns both predefined and custom protocols for the specified species.
///
/// Usage:
/// ```dart
/// final dogProtocols = await ref.read(vaccinationProtocolsBySpeciesProvider('Dog').future);
/// ```
///
/// Copied from [vaccinationProtocolsBySpecies].
@ProviderFor(vaccinationProtocolsBySpecies)
const vaccinationProtocolsBySpeciesProvider =
    VaccinationProtocolsBySpeciesFamily();

/// Get vaccination protocols filtered by pet species (Dog/Cat)
///
/// Returns both predefined and custom protocols for the specified species.
///
/// Usage:
/// ```dart
/// final dogProtocols = await ref.read(vaccinationProtocolsBySpeciesProvider('Dog').future);
/// ```
///
/// Copied from [vaccinationProtocolsBySpecies].
class VaccinationProtocolsBySpeciesFamily
    extends Family<AsyncValue<List<VaccinationProtocol>>> {
  /// Get vaccination protocols filtered by pet species (Dog/Cat)
  ///
  /// Returns both predefined and custom protocols for the specified species.
  ///
  /// Usage:
  /// ```dart
  /// final dogProtocols = await ref.read(vaccinationProtocolsBySpeciesProvider('Dog').future);
  /// ```
  ///
  /// Copied from [vaccinationProtocolsBySpecies].
  const VaccinationProtocolsBySpeciesFamily();

  /// Get vaccination protocols filtered by pet species (Dog/Cat)
  ///
  /// Returns both predefined and custom protocols for the specified species.
  ///
  /// Usage:
  /// ```dart
  /// final dogProtocols = await ref.read(vaccinationProtocolsBySpeciesProvider('Dog').future);
  /// ```
  ///
  /// Copied from [vaccinationProtocolsBySpecies].
  VaccinationProtocolsBySpeciesProvider call(
    String species,
  ) {
    return VaccinationProtocolsBySpeciesProvider(
      species,
    );
  }

  @override
  VaccinationProtocolsBySpeciesProvider getProviderOverride(
    covariant VaccinationProtocolsBySpeciesProvider provider,
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
  String? get name => r'vaccinationProtocolsBySpeciesProvider';
}

/// Get vaccination protocols filtered by pet species (Dog/Cat)
///
/// Returns both predefined and custom protocols for the specified species.
///
/// Usage:
/// ```dart
/// final dogProtocols = await ref.read(vaccinationProtocolsBySpeciesProvider('Dog').future);
/// ```
///
/// Copied from [vaccinationProtocolsBySpecies].
class VaccinationProtocolsBySpeciesProvider
    extends AutoDisposeFutureProvider<List<VaccinationProtocol>> {
  /// Get vaccination protocols filtered by pet species (Dog/Cat)
  ///
  /// Returns both predefined and custom protocols for the specified species.
  ///
  /// Usage:
  /// ```dart
  /// final dogProtocols = await ref.read(vaccinationProtocolsBySpeciesProvider('Dog').future);
  /// ```
  ///
  /// Copied from [vaccinationProtocolsBySpecies].
  VaccinationProtocolsBySpeciesProvider(
    String species,
  ) : this._internal(
          (ref) => vaccinationProtocolsBySpecies(
            ref as VaccinationProtocolsBySpeciesRef,
            species,
          ),
          from: vaccinationProtocolsBySpeciesProvider,
          name: r'vaccinationProtocolsBySpeciesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaccinationProtocolsBySpeciesHash,
          dependencies: VaccinationProtocolsBySpeciesFamily._dependencies,
          allTransitiveDependencies:
              VaccinationProtocolsBySpeciesFamily._allTransitiveDependencies,
          species: species,
        );

  VaccinationProtocolsBySpeciesProvider._internal(
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
    FutureOr<List<VaccinationProtocol>> Function(
            VaccinationProtocolsBySpeciesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaccinationProtocolsBySpeciesProvider._internal(
        (ref) => create(ref as VaccinationProtocolsBySpeciesRef),
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
  AutoDisposeFutureProviderElement<List<VaccinationProtocol>> createElement() {
    return _VaccinationProtocolsBySpeciesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaccinationProtocolsBySpeciesProvider &&
        other.species == species;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, species.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaccinationProtocolsBySpeciesRef
    on AutoDisposeFutureProviderRef<List<VaccinationProtocol>> {
  /// The parameter `species` of this provider.
  String get species;
}

class _VaccinationProtocolsBySpeciesProviderElement
    extends AutoDisposeFutureProviderElement<List<VaccinationProtocol>>
    with VaccinationProtocolsBySpeciesRef {
  _VaccinationProtocolsBySpeciesProviderElement(super.provider);

  @override
  String get species =>
      (origin as VaccinationProtocolsBySpeciesProvider).species;
}

String _$predefinedVaccinationProtocolsHash() =>
    r'4f18fccd52f56d46d9074389d5c03a199074b9ad';

/// Get only predefined vaccination protocols
///
/// These are the protocols loaded from JSON assets (vaccination_protocols.json).
/// Includes WSAVA-compliant core and extended vaccination schedules.
///
/// Usage:
/// ```dart
/// final predefinedProtocols = await ref.read(predefinedVaccinationProtocolsProvider.future);
/// ```
///
/// Copied from [predefinedVaccinationProtocols].
@ProviderFor(predefinedVaccinationProtocols)
final predefinedVaccinationProtocolsProvider =
    AutoDisposeFutureProvider<List<VaccinationProtocol>>.internal(
  predefinedVaccinationProtocols,
  name: r'predefinedVaccinationProtocolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$predefinedVaccinationProtocolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PredefinedVaccinationProtocolsRef
    = AutoDisposeFutureProviderRef<List<VaccinationProtocol>>;
String _$customVaccinationProtocolsHash() =>
    r'644a79479bf106dc08700a4cfb2d6b163b703aa7';

/// Get only custom user-created vaccination protocols
///
/// These are protocols created by the user and stored in Hive.
///
/// Usage:
/// ```dart
/// final customProtocols = await ref.read(customVaccinationProtocolsProvider.future);
/// ```
///
/// Copied from [customVaccinationProtocols].
@ProviderFor(customVaccinationProtocols)
final customVaccinationProtocolsProvider =
    AutoDisposeFutureProvider<List<VaccinationProtocol>>.internal(
  customVaccinationProtocols,
  name: r'customVaccinationProtocolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customVaccinationProtocolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CustomVaccinationProtocolsRef
    = AutoDisposeFutureProviderRef<List<VaccinationProtocol>>;
String _$vaccinationProtocolByIdHash() =>
    r'a119668308a5c0e4556aabf723cf501d49c62c86';

/// Get a specific vaccination protocol by ID
///
/// Returns null if protocol not found.
///
/// Usage:
/// ```dart
/// final protocol = await ref.read(vaccinationProtocolByIdProvider('protocol-id').future);
/// ```
///
/// Copied from [vaccinationProtocolById].
@ProviderFor(vaccinationProtocolById)
const vaccinationProtocolByIdProvider = VaccinationProtocolByIdFamily();

/// Get a specific vaccination protocol by ID
///
/// Returns null if protocol not found.
///
/// Usage:
/// ```dart
/// final protocol = await ref.read(vaccinationProtocolByIdProvider('protocol-id').future);
/// ```
///
/// Copied from [vaccinationProtocolById].
class VaccinationProtocolByIdFamily
    extends Family<AsyncValue<VaccinationProtocol?>> {
  /// Get a specific vaccination protocol by ID
  ///
  /// Returns null if protocol not found.
  ///
  /// Usage:
  /// ```dart
  /// final protocol = await ref.read(vaccinationProtocolByIdProvider('protocol-id').future);
  /// ```
  ///
  /// Copied from [vaccinationProtocolById].
  const VaccinationProtocolByIdFamily();

  /// Get a specific vaccination protocol by ID
  ///
  /// Returns null if protocol not found.
  ///
  /// Usage:
  /// ```dart
  /// final protocol = await ref.read(vaccinationProtocolByIdProvider('protocol-id').future);
  /// ```
  ///
  /// Copied from [vaccinationProtocolById].
  VaccinationProtocolByIdProvider call(
    String id,
  ) {
    return VaccinationProtocolByIdProvider(
      id,
    );
  }

  @override
  VaccinationProtocolByIdProvider getProviderOverride(
    covariant VaccinationProtocolByIdProvider provider,
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
  String? get name => r'vaccinationProtocolByIdProvider';
}

/// Get a specific vaccination protocol by ID
///
/// Returns null if protocol not found.
///
/// Usage:
/// ```dart
/// final protocol = await ref.read(vaccinationProtocolByIdProvider('protocol-id').future);
/// ```
///
/// Copied from [vaccinationProtocolById].
class VaccinationProtocolByIdProvider
    extends AutoDisposeFutureProvider<VaccinationProtocol?> {
  /// Get a specific vaccination protocol by ID
  ///
  /// Returns null if protocol not found.
  ///
  /// Usage:
  /// ```dart
  /// final protocol = await ref.read(vaccinationProtocolByIdProvider('protocol-id').future);
  /// ```
  ///
  /// Copied from [vaccinationProtocolById].
  VaccinationProtocolByIdProvider(
    String id,
  ) : this._internal(
          (ref) => vaccinationProtocolById(
            ref as VaccinationProtocolByIdRef,
            id,
          ),
          from: vaccinationProtocolByIdProvider,
          name: r'vaccinationProtocolByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaccinationProtocolByIdHash,
          dependencies: VaccinationProtocolByIdFamily._dependencies,
          allTransitiveDependencies:
              VaccinationProtocolByIdFamily._allTransitiveDependencies,
          id: id,
        );

  VaccinationProtocolByIdProvider._internal(
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
    FutureOr<VaccinationProtocol?> Function(VaccinationProtocolByIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaccinationProtocolByIdProvider._internal(
        (ref) => create(ref as VaccinationProtocolByIdRef),
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
  AutoDisposeFutureProviderElement<VaccinationProtocol?> createElement() {
    return _VaccinationProtocolByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaccinationProtocolByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaccinationProtocolByIdRef
    on AutoDisposeFutureProviderRef<VaccinationProtocol?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _VaccinationProtocolByIdProviderElement
    extends AutoDisposeFutureProviderElement<VaccinationProtocol?>
    with VaccinationProtocolByIdRef {
  _VaccinationProtocolByIdProviderElement(super.provider);

  @override
  String get id => (origin as VaccinationProtocolByIdProvider).id;
}

String _$vaccinationProtocolsHash() =>
    r'323a75b0f361b5a6a10380e04b79c46e86a6a393';

/// Main vaccination protocol provider - manages all protocols (predefined + custom)
///
/// This provider combines predefined protocols loaded from JSON assets with
/// custom user-created protocols stored in Hive. It automatically loads predefined
/// protocols on first build and merges them with custom protocols.
///
/// Usage:
/// ```dart
/// final protocols = await ref.read(vaccinationProtocolsProvider.future);
/// ```
///
/// Copied from [VaccinationProtocols].
@ProviderFor(VaccinationProtocols)
final vaccinationProtocolsProvider = AutoDisposeAsyncNotifierProvider<
    VaccinationProtocols, List<VaccinationProtocol>>.internal(
  VaccinationProtocols.new,
  name: r'vaccinationProtocolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vaccinationProtocolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VaccinationProtocols
    = AutoDisposeAsyncNotifier<List<VaccinationProtocol>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
