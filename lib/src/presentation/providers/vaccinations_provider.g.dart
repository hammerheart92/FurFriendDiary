// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccinations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vaccinationsByPetIdHash() =>
    r'2cdaf96b940532ec4c9ad0cd825bb0771fbb539b';

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

/// Get all vaccinations for a specific pet
///
/// Copied from [vaccinationsByPetId].
@ProviderFor(vaccinationsByPetId)
const vaccinationsByPetIdProvider = VaccinationsByPetIdFamily();

/// Get all vaccinations for a specific pet
///
/// Copied from [vaccinationsByPetId].
class VaccinationsByPetIdFamily
    extends Family<AsyncValue<List<VaccinationEvent>>> {
  /// Get all vaccinations for a specific pet
  ///
  /// Copied from [vaccinationsByPetId].
  const VaccinationsByPetIdFamily();

  /// Get all vaccinations for a specific pet
  ///
  /// Copied from [vaccinationsByPetId].
  VaccinationsByPetIdProvider call(
    String petId,
  ) {
    return VaccinationsByPetIdProvider(
      petId,
    );
  }

  @override
  VaccinationsByPetIdProvider getProviderOverride(
    covariant VaccinationsByPetIdProvider provider,
  ) {
    return call(
      provider.petId,
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
  String? get name => r'vaccinationsByPetIdProvider';
}

/// Get all vaccinations for a specific pet
///
/// Copied from [vaccinationsByPetId].
class VaccinationsByPetIdProvider
    extends AutoDisposeFutureProvider<List<VaccinationEvent>> {
  /// Get all vaccinations for a specific pet
  ///
  /// Copied from [vaccinationsByPetId].
  VaccinationsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => vaccinationsByPetId(
            ref as VaccinationsByPetIdRef,
            petId,
          ),
          from: vaccinationsByPetIdProvider,
          name: r'vaccinationsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaccinationsByPetIdHash,
          dependencies: VaccinationsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              VaccinationsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  VaccinationsByPetIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
  }) : super.internal();

  final String petId;

  @override
  Override overrideWith(
    FutureOr<List<VaccinationEvent>> Function(VaccinationsByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaccinationsByPetIdProvider._internal(
        (ref) => create(ref as VaccinationsByPetIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VaccinationEvent>> createElement() {
    return _VaccinationsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaccinationsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaccinationsByPetIdRef
    on AutoDisposeFutureProviderRef<List<VaccinationEvent>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _VaccinationsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<VaccinationEvent>>
    with VaccinationsByPetIdRef {
  _VaccinationsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as VaccinationsByPetIdProvider).petId;
}

String _$upcomingVaccinationsByPetIdHash() =>
    r'f04398691c4926d956abb9aef46775f959172c9c';

/// Get upcoming vaccinations for a specific pet (due today or in the future)
///
/// Copied from [upcomingVaccinationsByPetId].
@ProviderFor(upcomingVaccinationsByPetId)
const upcomingVaccinationsByPetIdProvider = UpcomingVaccinationsByPetIdFamily();

/// Get upcoming vaccinations for a specific pet (due today or in the future)
///
/// Copied from [upcomingVaccinationsByPetId].
class UpcomingVaccinationsByPetIdFamily
    extends Family<AsyncValue<List<VaccinationEvent>>> {
  /// Get upcoming vaccinations for a specific pet (due today or in the future)
  ///
  /// Copied from [upcomingVaccinationsByPetId].
  const UpcomingVaccinationsByPetIdFamily();

  /// Get upcoming vaccinations for a specific pet (due today or in the future)
  ///
  /// Copied from [upcomingVaccinationsByPetId].
  UpcomingVaccinationsByPetIdProvider call(
    String petId,
  ) {
    return UpcomingVaccinationsByPetIdProvider(
      petId,
    );
  }

  @override
  UpcomingVaccinationsByPetIdProvider getProviderOverride(
    covariant UpcomingVaccinationsByPetIdProvider provider,
  ) {
    return call(
      provider.petId,
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
  String? get name => r'upcomingVaccinationsByPetIdProvider';
}

/// Get upcoming vaccinations for a specific pet (due today or in the future)
///
/// Copied from [upcomingVaccinationsByPetId].
class UpcomingVaccinationsByPetIdProvider
    extends AutoDisposeFutureProvider<List<VaccinationEvent>> {
  /// Get upcoming vaccinations for a specific pet (due today or in the future)
  ///
  /// Copied from [upcomingVaccinationsByPetId].
  UpcomingVaccinationsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => upcomingVaccinationsByPetId(
            ref as UpcomingVaccinationsByPetIdRef,
            petId,
          ),
          from: upcomingVaccinationsByPetIdProvider,
          name: r'upcomingVaccinationsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$upcomingVaccinationsByPetIdHash,
          dependencies: UpcomingVaccinationsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              UpcomingVaccinationsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  UpcomingVaccinationsByPetIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
  }) : super.internal();

  final String petId;

  @override
  Override overrideWith(
    FutureOr<List<VaccinationEvent>> Function(
            UpcomingVaccinationsByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpcomingVaccinationsByPetIdProvider._internal(
        (ref) => create(ref as UpcomingVaccinationsByPetIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VaccinationEvent>> createElement() {
    return _UpcomingVaccinationsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingVaccinationsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpcomingVaccinationsByPetIdRef
    on AutoDisposeFutureProviderRef<List<VaccinationEvent>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _UpcomingVaccinationsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<VaccinationEvent>>
    with UpcomingVaccinationsByPetIdRef {
  _UpcomingVaccinationsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as UpcomingVaccinationsByPetIdProvider).petId;
}

String _$overdueVaccinationsByPetIdHash() =>
    r'941287e1d58f5f7d9372e09c7c35105c1458dcad';

/// Get overdue vaccinations for a specific pet (past due date)
///
/// Copied from [overdueVaccinationsByPetId].
@ProviderFor(overdueVaccinationsByPetId)
const overdueVaccinationsByPetIdProvider = OverdueVaccinationsByPetIdFamily();

/// Get overdue vaccinations for a specific pet (past due date)
///
/// Copied from [overdueVaccinationsByPetId].
class OverdueVaccinationsByPetIdFamily
    extends Family<AsyncValue<List<VaccinationEvent>>> {
  /// Get overdue vaccinations for a specific pet (past due date)
  ///
  /// Copied from [overdueVaccinationsByPetId].
  const OverdueVaccinationsByPetIdFamily();

  /// Get overdue vaccinations for a specific pet (past due date)
  ///
  /// Copied from [overdueVaccinationsByPetId].
  OverdueVaccinationsByPetIdProvider call(
    String petId,
  ) {
    return OverdueVaccinationsByPetIdProvider(
      petId,
    );
  }

  @override
  OverdueVaccinationsByPetIdProvider getProviderOverride(
    covariant OverdueVaccinationsByPetIdProvider provider,
  ) {
    return call(
      provider.petId,
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
  String? get name => r'overdueVaccinationsByPetIdProvider';
}

/// Get overdue vaccinations for a specific pet (past due date)
///
/// Copied from [overdueVaccinationsByPetId].
class OverdueVaccinationsByPetIdProvider
    extends AutoDisposeFutureProvider<List<VaccinationEvent>> {
  /// Get overdue vaccinations for a specific pet (past due date)
  ///
  /// Copied from [overdueVaccinationsByPetId].
  OverdueVaccinationsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => overdueVaccinationsByPetId(
            ref as OverdueVaccinationsByPetIdRef,
            petId,
          ),
          from: overdueVaccinationsByPetIdProvider,
          name: r'overdueVaccinationsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$overdueVaccinationsByPetIdHash,
          dependencies: OverdueVaccinationsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              OverdueVaccinationsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  OverdueVaccinationsByPetIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
  }) : super.internal();

  final String petId;

  @override
  Override overrideWith(
    FutureOr<List<VaccinationEvent>> Function(
            OverdueVaccinationsByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OverdueVaccinationsByPetIdProvider._internal(
        (ref) => create(ref as OverdueVaccinationsByPetIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VaccinationEvent>> createElement() {
    return _OverdueVaccinationsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OverdueVaccinationsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin OverdueVaccinationsByPetIdRef
    on AutoDisposeFutureProviderRef<List<VaccinationEvent>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _OverdueVaccinationsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<VaccinationEvent>>
    with OverdueVaccinationsByPetIdRef {
  _OverdueVaccinationsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as OverdueVaccinationsByPetIdProvider).petId;
}

String _$vaccinationsByDateRangeHash() =>
    r'707700ee785afcbba47acaf6685e7ae83d951aed';

/// Get vaccinations within a date range for a specific pet
///
/// Copied from [vaccinationsByDateRange].
@ProviderFor(vaccinationsByDateRange)
const vaccinationsByDateRangeProvider = VaccinationsByDateRangeFamily();

/// Get vaccinations within a date range for a specific pet
///
/// Copied from [vaccinationsByDateRange].
class VaccinationsByDateRangeFamily
    extends Family<AsyncValue<List<VaccinationEvent>>> {
  /// Get vaccinations within a date range for a specific pet
  ///
  /// Copied from [vaccinationsByDateRange].
  const VaccinationsByDateRangeFamily();

  /// Get vaccinations within a date range for a specific pet
  ///
  /// Copied from [vaccinationsByDateRange].
  VaccinationsByDateRangeProvider call(
    String petId,
    DateTime start,
    DateTime end,
  ) {
    return VaccinationsByDateRangeProvider(
      petId,
      start,
      end,
    );
  }

  @override
  VaccinationsByDateRangeProvider getProviderOverride(
    covariant VaccinationsByDateRangeProvider provider,
  ) {
    return call(
      provider.petId,
      provider.start,
      provider.end,
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
  String? get name => r'vaccinationsByDateRangeProvider';
}

/// Get vaccinations within a date range for a specific pet
///
/// Copied from [vaccinationsByDateRange].
class VaccinationsByDateRangeProvider
    extends AutoDisposeFutureProvider<List<VaccinationEvent>> {
  /// Get vaccinations within a date range for a specific pet
  ///
  /// Copied from [vaccinationsByDateRange].
  VaccinationsByDateRangeProvider(
    String petId,
    DateTime start,
    DateTime end,
  ) : this._internal(
          (ref) => vaccinationsByDateRange(
            ref as VaccinationsByDateRangeRef,
            petId,
            start,
            end,
          ),
          from: vaccinationsByDateRangeProvider,
          name: r'vaccinationsByDateRangeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaccinationsByDateRangeHash,
          dependencies: VaccinationsByDateRangeFamily._dependencies,
          allTransitiveDependencies:
              VaccinationsByDateRangeFamily._allTransitiveDependencies,
          petId: petId,
          start: start,
          end: end,
        );

  VaccinationsByDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.start,
    required this.end,
  }) : super.internal();

  final String petId;
  final DateTime start;
  final DateTime end;

  @override
  Override overrideWith(
    FutureOr<List<VaccinationEvent>> Function(
            VaccinationsByDateRangeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaccinationsByDateRangeProvider._internal(
        (ref) => create(ref as VaccinationsByDateRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        start: start,
        end: end,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VaccinationEvent>> createElement() {
    return _VaccinationsByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaccinationsByDateRangeProvider &&
        other.petId == petId &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, start.hashCode);
    hash = _SystemHash.combine(hash, end.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaccinationsByDateRangeRef
    on AutoDisposeFutureProviderRef<List<VaccinationEvent>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _VaccinationsByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<VaccinationEvent>>
    with VaccinationsByDateRangeRef {
  _VaccinationsByDateRangeProviderElement(super.provider);

  @override
  String get petId => (origin as VaccinationsByDateRangeProvider).petId;
  @override
  DateTime get start => (origin as VaccinationsByDateRangeProvider).start;
  @override
  DateTime get end => (origin as VaccinationsByDateRangeProvider).end;
}

String _$vaccinationsByProtocolIdHash() =>
    r'6597f675917d32a53682ea46c86659068a197f31';

/// Get vaccinations linked to a specific protocol
///
/// Copied from [vaccinationsByProtocolId].
@ProviderFor(vaccinationsByProtocolId)
const vaccinationsByProtocolIdProvider = VaccinationsByProtocolIdFamily();

/// Get vaccinations linked to a specific protocol
///
/// Copied from [vaccinationsByProtocolId].
class VaccinationsByProtocolIdFamily
    extends Family<AsyncValue<List<VaccinationEvent>>> {
  /// Get vaccinations linked to a specific protocol
  ///
  /// Copied from [vaccinationsByProtocolId].
  const VaccinationsByProtocolIdFamily();

  /// Get vaccinations linked to a specific protocol
  ///
  /// Copied from [vaccinationsByProtocolId].
  VaccinationsByProtocolIdProvider call(
    String protocolId,
  ) {
    return VaccinationsByProtocolIdProvider(
      protocolId,
    );
  }

  @override
  VaccinationsByProtocolIdProvider getProviderOverride(
    covariant VaccinationsByProtocolIdProvider provider,
  ) {
    return call(
      provider.protocolId,
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
  String? get name => r'vaccinationsByProtocolIdProvider';
}

/// Get vaccinations linked to a specific protocol
///
/// Copied from [vaccinationsByProtocolId].
class VaccinationsByProtocolIdProvider
    extends AutoDisposeFutureProvider<List<VaccinationEvent>> {
  /// Get vaccinations linked to a specific protocol
  ///
  /// Copied from [vaccinationsByProtocolId].
  VaccinationsByProtocolIdProvider(
    String protocolId,
  ) : this._internal(
          (ref) => vaccinationsByProtocolId(
            ref as VaccinationsByProtocolIdRef,
            protocolId,
          ),
          from: vaccinationsByProtocolIdProvider,
          name: r'vaccinationsByProtocolIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaccinationsByProtocolIdHash,
          dependencies: VaccinationsByProtocolIdFamily._dependencies,
          allTransitiveDependencies:
              VaccinationsByProtocolIdFamily._allTransitiveDependencies,
          protocolId: protocolId,
        );

  VaccinationsByProtocolIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.protocolId,
  }) : super.internal();

  final String protocolId;

  @override
  Override overrideWith(
    FutureOr<List<VaccinationEvent>> Function(
            VaccinationsByProtocolIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaccinationsByProtocolIdProvider._internal(
        (ref) => create(ref as VaccinationsByProtocolIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        protocolId: protocolId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<VaccinationEvent>> createElement() {
    return _VaccinationsByProtocolIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaccinationsByProtocolIdProvider &&
        other.protocolId == protocolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, protocolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaccinationsByProtocolIdRef
    on AutoDisposeFutureProviderRef<List<VaccinationEvent>> {
  /// The parameter `protocolId` of this provider.
  String get protocolId;
}

class _VaccinationsByProtocolIdProviderElement
    extends AutoDisposeFutureProviderElement<List<VaccinationEvent>>
    with VaccinationsByProtocolIdRef {
  _VaccinationsByProtocolIdProviderElement(super.provider);

  @override
  String get protocolId =>
      (origin as VaccinationsByProtocolIdProvider).protocolId;
}

String _$lastVaccinationByTypeHash() =>
    r'0504f1474d9811afe1b8446bd997193b8fa0479f';

/// Get the most recent vaccination of a specific type for a pet
///
/// Copied from [lastVaccinationByType].
@ProviderFor(lastVaccinationByType)
const lastVaccinationByTypeProvider = LastVaccinationByTypeFamily();

/// Get the most recent vaccination of a specific type for a pet
///
/// Copied from [lastVaccinationByType].
class LastVaccinationByTypeFamily
    extends Family<AsyncValue<VaccinationEvent?>> {
  /// Get the most recent vaccination of a specific type for a pet
  ///
  /// Copied from [lastVaccinationByType].
  const LastVaccinationByTypeFamily();

  /// Get the most recent vaccination of a specific type for a pet
  ///
  /// Copied from [lastVaccinationByType].
  LastVaccinationByTypeProvider call(
    String petId,
    String vaccineType,
  ) {
    return LastVaccinationByTypeProvider(
      petId,
      vaccineType,
    );
  }

  @override
  LastVaccinationByTypeProvider getProviderOverride(
    covariant LastVaccinationByTypeProvider provider,
  ) {
    return call(
      provider.petId,
      provider.vaccineType,
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
  String? get name => r'lastVaccinationByTypeProvider';
}

/// Get the most recent vaccination of a specific type for a pet
///
/// Copied from [lastVaccinationByType].
class LastVaccinationByTypeProvider
    extends AutoDisposeFutureProvider<VaccinationEvent?> {
  /// Get the most recent vaccination of a specific type for a pet
  ///
  /// Copied from [lastVaccinationByType].
  LastVaccinationByTypeProvider(
    String petId,
    String vaccineType,
  ) : this._internal(
          (ref) => lastVaccinationByType(
            ref as LastVaccinationByTypeRef,
            petId,
            vaccineType,
          ),
          from: lastVaccinationByTypeProvider,
          name: r'lastVaccinationByTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lastVaccinationByTypeHash,
          dependencies: LastVaccinationByTypeFamily._dependencies,
          allTransitiveDependencies:
              LastVaccinationByTypeFamily._allTransitiveDependencies,
          petId: petId,
          vaccineType: vaccineType,
        );

  LastVaccinationByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.vaccineType,
  }) : super.internal();

  final String petId;
  final String vaccineType;

  @override
  Override overrideWith(
    FutureOr<VaccinationEvent?> Function(LastVaccinationByTypeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LastVaccinationByTypeProvider._internal(
        (ref) => create(ref as LastVaccinationByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        vaccineType: vaccineType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<VaccinationEvent?> createElement() {
    return _LastVaccinationByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LastVaccinationByTypeProvider &&
        other.petId == petId &&
        other.vaccineType == vaccineType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, vaccineType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LastVaccinationByTypeRef
    on AutoDisposeFutureProviderRef<VaccinationEvent?> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `vaccineType` of this provider.
  String get vaccineType;
}

class _LastVaccinationByTypeProviderElement
    extends AutoDisposeFutureProviderElement<VaccinationEvent?>
    with LastVaccinationByTypeRef {
  _LastVaccinationByTypeProviderElement(super.provider);

  @override
  String get petId => (origin as LastVaccinationByTypeProvider).petId;
  @override
  String get vaccineType =>
      (origin as LastVaccinationByTypeProvider).vaccineType;
}

String _$vaccinationSummaryHash() =>
    r'cda0c0805b7d10829485c3ac646d14132a00edf2';

/// Get vaccination summary statistics for a pet
///
/// Copied from [vaccinationSummary].
@ProviderFor(vaccinationSummary)
const vaccinationSummaryProvider = VaccinationSummaryFamily();

/// Get vaccination summary statistics for a pet
///
/// Copied from [vaccinationSummary].
class VaccinationSummaryFamily extends Family<AsyncValue<VaccinationSummary>> {
  /// Get vaccination summary statistics for a pet
  ///
  /// Copied from [vaccinationSummary].
  const VaccinationSummaryFamily();

  /// Get vaccination summary statistics for a pet
  ///
  /// Copied from [vaccinationSummary].
  VaccinationSummaryProvider call(
    String petId,
  ) {
    return VaccinationSummaryProvider(
      petId,
    );
  }

  @override
  VaccinationSummaryProvider getProviderOverride(
    covariant VaccinationSummaryProvider provider,
  ) {
    return call(
      provider.petId,
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
  String? get name => r'vaccinationSummaryProvider';
}

/// Get vaccination summary statistics for a pet
///
/// Copied from [vaccinationSummary].
class VaccinationSummaryProvider
    extends AutoDisposeFutureProvider<VaccinationSummary> {
  /// Get vaccination summary statistics for a pet
  ///
  /// Copied from [vaccinationSummary].
  VaccinationSummaryProvider(
    String petId,
  ) : this._internal(
          (ref) => vaccinationSummary(
            ref as VaccinationSummaryRef,
            petId,
          ),
          from: vaccinationSummaryProvider,
          name: r'vaccinationSummaryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaccinationSummaryHash,
          dependencies: VaccinationSummaryFamily._dependencies,
          allTransitiveDependencies:
              VaccinationSummaryFamily._allTransitiveDependencies,
          petId: petId,
        );

  VaccinationSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
  }) : super.internal();

  final String petId;

  @override
  Override overrideWith(
    FutureOr<VaccinationSummary> Function(VaccinationSummaryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaccinationSummaryProvider._internal(
        (ref) => create(ref as VaccinationSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<VaccinationSummary> createElement() {
    return _VaccinationSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaccinationSummaryProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaccinationSummaryRef
    on AutoDisposeFutureProviderRef<VaccinationSummary> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _VaccinationSummaryProviderElement
    extends AutoDisposeFutureProviderElement<VaccinationSummary>
    with VaccinationSummaryRef {
  _VaccinationSummaryProviderElement(super.provider);

  @override
  String get petId => (origin as VaccinationSummaryProvider).petId;
}

String _$isVaccineDueHash() => r'2b638016faab78f9c073d8337dbcea851e19101a';

/// Check if a specific vaccine type is due for a pet
///
/// Copied from [isVaccineDue].
@ProviderFor(isVaccineDue)
const isVaccineDueProvider = IsVaccineDueFamily();

/// Check if a specific vaccine type is due for a pet
///
/// Copied from [isVaccineDue].
class IsVaccineDueFamily extends Family<AsyncValue<bool>> {
  /// Check if a specific vaccine type is due for a pet
  ///
  /// Copied from [isVaccineDue].
  const IsVaccineDueFamily();

  /// Check if a specific vaccine type is due for a pet
  ///
  /// Copied from [isVaccineDue].
  IsVaccineDueProvider call(
    String petId,
    String vaccineType,
  ) {
    return IsVaccineDueProvider(
      petId,
      vaccineType,
    );
  }

  @override
  IsVaccineDueProvider getProviderOverride(
    covariant IsVaccineDueProvider provider,
  ) {
    return call(
      provider.petId,
      provider.vaccineType,
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
  String? get name => r'isVaccineDueProvider';
}

/// Check if a specific vaccine type is due for a pet
///
/// Copied from [isVaccineDue].
class IsVaccineDueProvider extends AutoDisposeFutureProvider<bool> {
  /// Check if a specific vaccine type is due for a pet
  ///
  /// Copied from [isVaccineDue].
  IsVaccineDueProvider(
    String petId,
    String vaccineType,
  ) : this._internal(
          (ref) => isVaccineDue(
            ref as IsVaccineDueRef,
            petId,
            vaccineType,
          ),
          from: isVaccineDueProvider,
          name: r'isVaccineDueProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isVaccineDueHash,
          dependencies: IsVaccineDueFamily._dependencies,
          allTransitiveDependencies:
              IsVaccineDueFamily._allTransitiveDependencies,
          petId: petId,
          vaccineType: vaccineType,
        );

  IsVaccineDueProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.vaccineType,
  }) : super.internal();

  final String petId;
  final String vaccineType;

  @override
  Override overrideWith(
    FutureOr<bool> Function(IsVaccineDueRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsVaccineDueProvider._internal(
        (ref) => create(ref as IsVaccineDueRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        vaccineType: vaccineType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsVaccineDueProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsVaccineDueProvider &&
        other.petId == petId &&
        other.vaccineType == vaccineType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, vaccineType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsVaccineDueRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `vaccineType` of this provider.
  String get vaccineType;
}

class _IsVaccineDueProviderElement
    extends AutoDisposeFutureProviderElement<bool> with IsVaccineDueRef {
  _IsVaccineDueProviderElement(super.provider);

  @override
  String get petId => (origin as IsVaccineDueProvider).petId;
  @override
  String get vaccineType => (origin as IsVaccineDueProvider).vaccineType;
}

String _$vaccineTypesForPetHash() =>
    r'bc4c3ea0d4cda877e0d0253c8f347d56c956ed64';

/// Get all vaccine types that have been administered to a pet
///
/// Copied from [vaccineTypesForPet].
@ProviderFor(vaccineTypesForPet)
const vaccineTypesForPetProvider = VaccineTypesForPetFamily();

/// Get all vaccine types that have been administered to a pet
///
/// Copied from [vaccineTypesForPet].
class VaccineTypesForPetFamily extends Family<AsyncValue<List<String>>> {
  /// Get all vaccine types that have been administered to a pet
  ///
  /// Copied from [vaccineTypesForPet].
  const VaccineTypesForPetFamily();

  /// Get all vaccine types that have been administered to a pet
  ///
  /// Copied from [vaccineTypesForPet].
  VaccineTypesForPetProvider call(
    String petId,
  ) {
    return VaccineTypesForPetProvider(
      petId,
    );
  }

  @override
  VaccineTypesForPetProvider getProviderOverride(
    covariant VaccineTypesForPetProvider provider,
  ) {
    return call(
      provider.petId,
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
  String? get name => r'vaccineTypesForPetProvider';
}

/// Get all vaccine types that have been administered to a pet
///
/// Copied from [vaccineTypesForPet].
class VaccineTypesForPetProvider
    extends AutoDisposeFutureProvider<List<String>> {
  /// Get all vaccine types that have been administered to a pet
  ///
  /// Copied from [vaccineTypesForPet].
  VaccineTypesForPetProvider(
    String petId,
  ) : this._internal(
          (ref) => vaccineTypesForPet(
            ref as VaccineTypesForPetRef,
            petId,
          ),
          from: vaccineTypesForPetProvider,
          name: r'vaccineTypesForPetProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaccineTypesForPetHash,
          dependencies: VaccineTypesForPetFamily._dependencies,
          allTransitiveDependencies:
              VaccineTypesForPetFamily._allTransitiveDependencies,
          petId: petId,
        );

  VaccineTypesForPetProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
  }) : super.internal();

  final String petId;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(VaccineTypesForPetRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaccineTypesForPetProvider._internal(
        (ref) => create(ref as VaccineTypesForPetRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _VaccineTypesForPetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaccineTypesForPetProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaccineTypesForPetRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _VaccineTypesForPetProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with VaccineTypesForPetRef {
  _VaccineTypesForPetProviderElement(super.provider);

  @override
  String get petId => (origin as VaccineTypesForPetProvider).petId;
}

String _$vaccinationProviderHash() =>
    r'1607eddb0dd20d181b037b58c5caa9bd823fb618';

/// See also [VaccinationProvider].
@ProviderFor(VaccinationProvider)
final vaccinationProviderProvider = AutoDisposeAsyncNotifierProvider<
    VaccinationProvider, List<VaccinationEvent>>.internal(
  VaccinationProvider.new,
  name: r'vaccinationProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vaccinationProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$VaccinationProvider
    = AutoDisposeAsyncNotifier<List<VaccinationEvent>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
