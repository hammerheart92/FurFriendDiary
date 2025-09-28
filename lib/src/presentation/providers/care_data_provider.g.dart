// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'care_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedingsByPetIdHash() => r'8eace3c5f13d5bd7a9661719bad40a931a470cd4';

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

/// See also [feedingsByPetId].
@ProviderFor(feedingsByPetId)
const feedingsByPetIdProvider = FeedingsByPetIdFamily();

/// See also [feedingsByPetId].
class FeedingsByPetIdFamily extends Family<AsyncValue<List<FeedingEntry>>> {
  /// See also [feedingsByPetId].
  const FeedingsByPetIdFamily();

  /// See also [feedingsByPetId].
  FeedingsByPetIdProvider call(
    String petId,
  ) {
    return FeedingsByPetIdProvider(
      petId,
    );
  }

  @override
  FeedingsByPetIdProvider getProviderOverride(
    covariant FeedingsByPetIdProvider provider,
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
  String? get name => r'feedingsByPetIdProvider';
}

/// See also [feedingsByPetId].
class FeedingsByPetIdProvider
    extends AutoDisposeFutureProvider<List<FeedingEntry>> {
  /// See also [feedingsByPetId].
  FeedingsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => feedingsByPetId(
            ref as FeedingsByPetIdRef,
            petId,
          ),
          from: feedingsByPetIdProvider,
          name: r'feedingsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$feedingsByPetIdHash,
          dependencies: FeedingsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              FeedingsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  FeedingsByPetIdProvider._internal(
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
    FutureOr<List<FeedingEntry>> Function(FeedingsByPetIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeedingsByPetIdProvider._internal(
        (ref) => create(ref as FeedingsByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<FeedingEntry>> createElement() {
    return _FeedingsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedingsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FeedingsByPetIdRef on AutoDisposeFutureProviderRef<List<FeedingEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _FeedingsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<FeedingEntry>>
    with FeedingsByPetIdRef {
  _FeedingsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as FeedingsByPetIdProvider).petId;
}

String _$feedingsByDateRangeHash() =>
    r'75b6527a6f57bcff13fe6ff291fc622af2b6a56b';

/// See also [feedingsByDateRange].
@ProviderFor(feedingsByDateRange)
const feedingsByDateRangeProvider = FeedingsByDateRangeFamily();

/// See also [feedingsByDateRange].
class FeedingsByDateRangeFamily extends Family<AsyncValue<List<FeedingEntry>>> {
  /// See also [feedingsByDateRange].
  const FeedingsByDateRangeFamily();

  /// See also [feedingsByDateRange].
  FeedingsByDateRangeProvider call(
    String petId,
    DateTime start,
    DateTime end,
  ) {
    return FeedingsByDateRangeProvider(
      petId,
      start,
      end,
    );
  }

  @override
  FeedingsByDateRangeProvider getProviderOverride(
    covariant FeedingsByDateRangeProvider provider,
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
  String? get name => r'feedingsByDateRangeProvider';
}

/// See also [feedingsByDateRange].
class FeedingsByDateRangeProvider
    extends AutoDisposeFutureProvider<List<FeedingEntry>> {
  /// See also [feedingsByDateRange].
  FeedingsByDateRangeProvider(
    String petId,
    DateTime start,
    DateTime end,
  ) : this._internal(
          (ref) => feedingsByDateRange(
            ref as FeedingsByDateRangeRef,
            petId,
            start,
            end,
          ),
          from: feedingsByDateRangeProvider,
          name: r'feedingsByDateRangeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$feedingsByDateRangeHash,
          dependencies: FeedingsByDateRangeFamily._dependencies,
          allTransitiveDependencies:
              FeedingsByDateRangeFamily._allTransitiveDependencies,
          petId: petId,
          start: start,
          end: end,
        );

  FeedingsByDateRangeProvider._internal(
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
    FutureOr<List<FeedingEntry>> Function(FeedingsByDateRangeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeedingsByDateRangeProvider._internal(
        (ref) => create(ref as FeedingsByDateRangeRef),
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
  AutoDisposeFutureProviderElement<List<FeedingEntry>> createElement() {
    return _FeedingsByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedingsByDateRangeProvider &&
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

mixin FeedingsByDateRangeRef
    on AutoDisposeFutureProviderRef<List<FeedingEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _FeedingsByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<FeedingEntry>>
    with FeedingsByDateRangeRef {
  _FeedingsByDateRangeProviderElement(super.provider);

  @override
  String get petId => (origin as FeedingsByDateRangeProvider).petId;
  @override
  DateTime get start => (origin as FeedingsByDateRangeProvider).start;
  @override
  DateTime get end => (origin as FeedingsByDateRangeProvider).end;
}

String _$medicationsByPetIdHash() =>
    r'62561127077c5f4a8335f7a5c1a5cb97809c671d';

/// See also [medicationsByPetId].
@ProviderFor(medicationsByPetId)
const medicationsByPetIdProvider = MedicationsByPetIdFamily();

/// See also [medicationsByPetId].
class MedicationsByPetIdFamily
    extends Family<AsyncValue<List<MedicationEntry>>> {
  /// See also [medicationsByPetId].
  const MedicationsByPetIdFamily();

  /// See also [medicationsByPetId].
  MedicationsByPetIdProvider call(
    String petId,
  ) {
    return MedicationsByPetIdProvider(
      petId,
    );
  }

  @override
  MedicationsByPetIdProvider getProviderOverride(
    covariant MedicationsByPetIdProvider provider,
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
  String? get name => r'medicationsByPetIdProvider';
}

/// See also [medicationsByPetId].
class MedicationsByPetIdProvider
    extends AutoDisposeFutureProvider<List<MedicationEntry>> {
  /// See also [medicationsByPetId].
  MedicationsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => medicationsByPetId(
            ref as MedicationsByPetIdRef,
            petId,
          ),
          from: medicationsByPetIdProvider,
          name: r'medicationsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$medicationsByPetIdHash,
          dependencies: MedicationsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              MedicationsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  MedicationsByPetIdProvider._internal(
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
    FutureOr<List<MedicationEntry>> Function(MedicationsByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MedicationsByPetIdProvider._internal(
        (ref) => create(ref as MedicationsByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<MedicationEntry>> createElement() {
    return _MedicationsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MedicationsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MedicationsByPetIdRef
    on AutoDisposeFutureProviderRef<List<MedicationEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _MedicationsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<MedicationEntry>>
    with MedicationsByPetIdRef {
  _MedicationsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as MedicationsByPetIdProvider).petId;
}

String _$activeMedicationsByPetIdHash() =>
    r'ac17960ffcea930e06adfc6a4d6965002a80dfe7';

/// See also [activeMedicationsByPetId].
@ProviderFor(activeMedicationsByPetId)
const activeMedicationsByPetIdProvider = ActiveMedicationsByPetIdFamily();

/// See also [activeMedicationsByPetId].
class ActiveMedicationsByPetIdFamily
    extends Family<AsyncValue<List<MedicationEntry>>> {
  /// See also [activeMedicationsByPetId].
  const ActiveMedicationsByPetIdFamily();

  /// See also [activeMedicationsByPetId].
  ActiveMedicationsByPetIdProvider call(
    String petId,
  ) {
    return ActiveMedicationsByPetIdProvider(
      petId,
    );
  }

  @override
  ActiveMedicationsByPetIdProvider getProviderOverride(
    covariant ActiveMedicationsByPetIdProvider provider,
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
  String? get name => r'activeMedicationsByPetIdProvider';
}

/// See also [activeMedicationsByPetId].
class ActiveMedicationsByPetIdProvider
    extends AutoDisposeFutureProvider<List<MedicationEntry>> {
  /// See also [activeMedicationsByPetId].
  ActiveMedicationsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => activeMedicationsByPetId(
            ref as ActiveMedicationsByPetIdRef,
            petId,
          ),
          from: activeMedicationsByPetIdProvider,
          name: r'activeMedicationsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activeMedicationsByPetIdHash,
          dependencies: ActiveMedicationsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              ActiveMedicationsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  ActiveMedicationsByPetIdProvider._internal(
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
    FutureOr<List<MedicationEntry>> Function(
            ActiveMedicationsByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveMedicationsByPetIdProvider._internal(
        (ref) => create(ref as ActiveMedicationsByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<MedicationEntry>> createElement() {
    return _ActiveMedicationsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveMedicationsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ActiveMedicationsByPetIdRef
    on AutoDisposeFutureProviderRef<List<MedicationEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _ActiveMedicationsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<MedicationEntry>>
    with ActiveMedicationsByPetIdRef {
  _ActiveMedicationsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as ActiveMedicationsByPetIdProvider).petId;
}

String _$inactiveMedicationsByPetIdHash() =>
    r'd88770620be7f6d253e59cdce82d976cc1b67180';

/// See also [inactiveMedicationsByPetId].
@ProviderFor(inactiveMedicationsByPetId)
const inactiveMedicationsByPetIdProvider = InactiveMedicationsByPetIdFamily();

/// See also [inactiveMedicationsByPetId].
class InactiveMedicationsByPetIdFamily
    extends Family<AsyncValue<List<MedicationEntry>>> {
  /// See also [inactiveMedicationsByPetId].
  const InactiveMedicationsByPetIdFamily();

  /// See also [inactiveMedicationsByPetId].
  InactiveMedicationsByPetIdProvider call(
    String petId,
  ) {
    return InactiveMedicationsByPetIdProvider(
      petId,
    );
  }

  @override
  InactiveMedicationsByPetIdProvider getProviderOverride(
    covariant InactiveMedicationsByPetIdProvider provider,
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
  String? get name => r'inactiveMedicationsByPetIdProvider';
}

/// See also [inactiveMedicationsByPetId].
class InactiveMedicationsByPetIdProvider
    extends AutoDisposeFutureProvider<List<MedicationEntry>> {
  /// See also [inactiveMedicationsByPetId].
  InactiveMedicationsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => inactiveMedicationsByPetId(
            ref as InactiveMedicationsByPetIdRef,
            petId,
          ),
          from: inactiveMedicationsByPetIdProvider,
          name: r'inactiveMedicationsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inactiveMedicationsByPetIdHash,
          dependencies: InactiveMedicationsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              InactiveMedicationsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  InactiveMedicationsByPetIdProvider._internal(
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
    FutureOr<List<MedicationEntry>> Function(
            InactiveMedicationsByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InactiveMedicationsByPetIdProvider._internal(
        (ref) => create(ref as InactiveMedicationsByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<MedicationEntry>> createElement() {
    return _InactiveMedicationsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InactiveMedicationsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InactiveMedicationsByPetIdRef
    on AutoDisposeFutureProviderRef<List<MedicationEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _InactiveMedicationsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<MedicationEntry>>
    with InactiveMedicationsByPetIdRef {
  _InactiveMedicationsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as InactiveMedicationsByPetIdProvider).petId;
}

String _$appointmentsByPetIdHash() =>
    r'd13c2d0e24d37aa1a6ef3e2bd624b12db444e5f8';

/// See also [appointmentsByPetId].
@ProviderFor(appointmentsByPetId)
const appointmentsByPetIdProvider = AppointmentsByPetIdFamily();

/// See also [appointmentsByPetId].
class AppointmentsByPetIdFamily
    extends Family<AsyncValue<List<AppointmentEntry>>> {
  /// See also [appointmentsByPetId].
  const AppointmentsByPetIdFamily();

  /// See also [appointmentsByPetId].
  AppointmentsByPetIdProvider call(
    String petId,
  ) {
    return AppointmentsByPetIdProvider(
      petId,
    );
  }

  @override
  AppointmentsByPetIdProvider getProviderOverride(
    covariant AppointmentsByPetIdProvider provider,
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
  String? get name => r'appointmentsByPetIdProvider';
}

/// See also [appointmentsByPetId].
class AppointmentsByPetIdProvider
    extends AutoDisposeFutureProvider<List<AppointmentEntry>> {
  /// See also [appointmentsByPetId].
  AppointmentsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => appointmentsByPetId(
            ref as AppointmentsByPetIdRef,
            petId,
          ),
          from: appointmentsByPetIdProvider,
          name: r'appointmentsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$appointmentsByPetIdHash,
          dependencies: AppointmentsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              AppointmentsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  AppointmentsByPetIdProvider._internal(
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
    FutureOr<List<AppointmentEntry>> Function(AppointmentsByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AppointmentsByPetIdProvider._internal(
        (ref) => create(ref as AppointmentsByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<AppointmentEntry>> createElement() {
    return _AppointmentsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppointmentsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AppointmentsByPetIdRef
    on AutoDisposeFutureProviderRef<List<AppointmentEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _AppointmentsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<AppointmentEntry>>
    with AppointmentsByPetIdRef {
  _AppointmentsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as AppointmentsByPetIdProvider).petId;
}

String _$appointmentsByDateRangeHash() =>
    r'0011dd699a0d00cc6f00f214546e3de996494f91';

/// See also [appointmentsByDateRange].
@ProviderFor(appointmentsByDateRange)
const appointmentsByDateRangeProvider = AppointmentsByDateRangeFamily();

/// See also [appointmentsByDateRange].
class AppointmentsByDateRangeFamily
    extends Family<AsyncValue<List<AppointmentEntry>>> {
  /// See also [appointmentsByDateRange].
  const AppointmentsByDateRangeFamily();

  /// See also [appointmentsByDateRange].
  AppointmentsByDateRangeProvider call(
    String petId,
    DateTime start,
    DateTime end,
  ) {
    return AppointmentsByDateRangeProvider(
      petId,
      start,
      end,
    );
  }

  @override
  AppointmentsByDateRangeProvider getProviderOverride(
    covariant AppointmentsByDateRangeProvider provider,
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
  String? get name => r'appointmentsByDateRangeProvider';
}

/// See also [appointmentsByDateRange].
class AppointmentsByDateRangeProvider
    extends AutoDisposeFutureProvider<List<AppointmentEntry>> {
  /// See also [appointmentsByDateRange].
  AppointmentsByDateRangeProvider(
    String petId,
    DateTime start,
    DateTime end,
  ) : this._internal(
          (ref) => appointmentsByDateRange(
            ref as AppointmentsByDateRangeRef,
            petId,
            start,
            end,
          ),
          from: appointmentsByDateRangeProvider,
          name: r'appointmentsByDateRangeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$appointmentsByDateRangeHash,
          dependencies: AppointmentsByDateRangeFamily._dependencies,
          allTransitiveDependencies:
              AppointmentsByDateRangeFamily._allTransitiveDependencies,
          petId: petId,
          start: start,
          end: end,
        );

  AppointmentsByDateRangeProvider._internal(
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
    FutureOr<List<AppointmentEntry>> Function(
            AppointmentsByDateRangeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AppointmentsByDateRangeProvider._internal(
        (ref) => create(ref as AppointmentsByDateRangeRef),
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
  AutoDisposeFutureProviderElement<List<AppointmentEntry>> createElement() {
    return _AppointmentsByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppointmentsByDateRangeProvider &&
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

mixin AppointmentsByDateRangeRef
    on AutoDisposeFutureProviderRef<List<AppointmentEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _AppointmentsByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<AppointmentEntry>>
    with AppointmentsByDateRangeRef {
  _AppointmentsByDateRangeProviderElement(super.provider);

  @override
  String get petId => (origin as AppointmentsByDateRangeProvider).petId;
  @override
  DateTime get start => (origin as AppointmentsByDateRangeProvider).start;
  @override
  DateTime get end => (origin as AppointmentsByDateRangeProvider).end;
}

String _$reportsByPetIdHash() => r'a1cd96508a1f0a55bd6908d6614424bcc44b80ae';

/// See also [reportsByPetId].
@ProviderFor(reportsByPetId)
const reportsByPetIdProvider = ReportsByPetIdFamily();

/// See also [reportsByPetId].
class ReportsByPetIdFamily extends Family<AsyncValue<List<ReportEntry>>> {
  /// See also [reportsByPetId].
  const ReportsByPetIdFamily();

  /// See also [reportsByPetId].
  ReportsByPetIdProvider call(
    String petId,
  ) {
    return ReportsByPetIdProvider(
      petId,
    );
  }

  @override
  ReportsByPetIdProvider getProviderOverride(
    covariant ReportsByPetIdProvider provider,
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
  String? get name => r'reportsByPetIdProvider';
}

/// See also [reportsByPetId].
class ReportsByPetIdProvider
    extends AutoDisposeFutureProvider<List<ReportEntry>> {
  /// See also [reportsByPetId].
  ReportsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => reportsByPetId(
            ref as ReportsByPetIdRef,
            petId,
          ),
          from: reportsByPetIdProvider,
          name: r'reportsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportsByPetIdHash,
          dependencies: ReportsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              ReportsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  ReportsByPetIdProvider._internal(
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
    FutureOr<List<ReportEntry>> Function(ReportsByPetIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportsByPetIdProvider._internal(
        (ref) => create(ref as ReportsByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<ReportEntry>> createElement() {
    return _ReportsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReportsByPetIdRef on AutoDisposeFutureProviderRef<List<ReportEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _ReportsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<ReportEntry>>
    with ReportsByPetIdRef {
  _ReportsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as ReportsByPetIdProvider).petId;
}

String _$reportsByDateRangeHash() =>
    r'6191fdd866197470105b8e06032bfb1438dd1e5f';

/// See also [reportsByDateRange].
@ProviderFor(reportsByDateRange)
const reportsByDateRangeProvider = ReportsByDateRangeFamily();

/// See also [reportsByDateRange].
class ReportsByDateRangeFamily extends Family<AsyncValue<List<ReportEntry>>> {
  /// See also [reportsByDateRange].
  const ReportsByDateRangeFamily();

  /// See also [reportsByDateRange].
  ReportsByDateRangeProvider call(
    String petId,
    DateTime start,
    DateTime end,
  ) {
    return ReportsByDateRangeProvider(
      petId,
      start,
      end,
    );
  }

  @override
  ReportsByDateRangeProvider getProviderOverride(
    covariant ReportsByDateRangeProvider provider,
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
  String? get name => r'reportsByDateRangeProvider';
}

/// See also [reportsByDateRange].
class ReportsByDateRangeProvider
    extends AutoDisposeFutureProvider<List<ReportEntry>> {
  /// See also [reportsByDateRange].
  ReportsByDateRangeProvider(
    String petId,
    DateTime start,
    DateTime end,
  ) : this._internal(
          (ref) => reportsByDateRange(
            ref as ReportsByDateRangeRef,
            petId,
            start,
            end,
          ),
          from: reportsByDateRangeProvider,
          name: r'reportsByDateRangeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportsByDateRangeHash,
          dependencies: ReportsByDateRangeFamily._dependencies,
          allTransitiveDependencies:
              ReportsByDateRangeFamily._allTransitiveDependencies,
          petId: petId,
          start: start,
          end: end,
        );

  ReportsByDateRangeProvider._internal(
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
    FutureOr<List<ReportEntry>> Function(ReportsByDateRangeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportsByDateRangeProvider._internal(
        (ref) => create(ref as ReportsByDateRangeRef),
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
  AutoDisposeFutureProviderElement<List<ReportEntry>> createElement() {
    return _ReportsByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsByDateRangeProvider &&
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

mixin ReportsByDateRangeRef on AutoDisposeFutureProviderRef<List<ReportEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `start` of this provider.
  DateTime get start;

  /// The parameter `end` of this provider.
  DateTime get end;
}

class _ReportsByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<ReportEntry>>
    with ReportsByDateRangeRef {
  _ReportsByDateRangeProviderElement(super.provider);

  @override
  String get petId => (origin as ReportsByDateRangeProvider).petId;
  @override
  DateTime get start => (origin as ReportsByDateRangeProvider).start;
  @override
  DateTime get end => (origin as ReportsByDateRangeProvider).end;
}

String _$reportsByTypeHash() => r'7944c4543dea88f40e4d8fa0232ee7351cce7bc1';

/// See also [reportsByType].
@ProviderFor(reportsByType)
const reportsByTypeProvider = ReportsByTypeFamily();

/// See also [reportsByType].
class ReportsByTypeFamily extends Family<AsyncValue<List<ReportEntry>>> {
  /// See also [reportsByType].
  const ReportsByTypeFamily();

  /// See also [reportsByType].
  ReportsByTypeProvider call(
    String petId,
    String reportType,
  ) {
    return ReportsByTypeProvider(
      petId,
      reportType,
    );
  }

  @override
  ReportsByTypeProvider getProviderOverride(
    covariant ReportsByTypeProvider provider,
  ) {
    return call(
      provider.petId,
      provider.reportType,
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
  String? get name => r'reportsByTypeProvider';
}

/// See also [reportsByType].
class ReportsByTypeProvider
    extends AutoDisposeFutureProvider<List<ReportEntry>> {
  /// See also [reportsByType].
  ReportsByTypeProvider(
    String petId,
    String reportType,
  ) : this._internal(
          (ref) => reportsByType(
            ref as ReportsByTypeRef,
            petId,
            reportType,
          ),
          from: reportsByTypeProvider,
          name: r'reportsByTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportsByTypeHash,
          dependencies: ReportsByTypeFamily._dependencies,
          allTransitiveDependencies:
              ReportsByTypeFamily._allTransitiveDependencies,
          petId: petId,
          reportType: reportType,
        );

  ReportsByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.reportType,
  }) : super.internal();

  final String petId;
  final String reportType;

  @override
  Override overrideWith(
    FutureOr<List<ReportEntry>> Function(ReportsByTypeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportsByTypeProvider._internal(
        (ref) => create(ref as ReportsByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        reportType: reportType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ReportEntry>> createElement() {
    return _ReportsByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsByTypeProvider &&
        other.petId == petId &&
        other.reportType == reportType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, reportType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReportsByTypeRef on AutoDisposeFutureProviderRef<List<ReportEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `reportType` of this provider.
  String get reportType;
}

class _ReportsByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<ReportEntry>>
    with ReportsByTypeRef {
  _ReportsByTypeProviderElement(super.provider);

  @override
  String get petId => (origin as ReportsByTypeProvider).petId;
  @override
  String get reportType => (origin as ReportsByTypeProvider).reportType;
}

String _$feedingProviderHash() => r'943cc51ee106ccdad560573be3d9b0c9042a5b06';

/// See also [FeedingProvider].
@ProviderFor(FeedingProvider)
final feedingProviderProvider = AutoDisposeAsyncNotifierProvider<
    FeedingProvider, List<FeedingEntry>>.internal(
  FeedingProvider.new,
  name: r'feedingProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedingProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FeedingProvider = AutoDisposeAsyncNotifier<List<FeedingEntry>>;
String _$medicationProviderHash() =>
    r'2c59ad717d4bb3d022948b9f1637862629f1e476';

/// See also [MedicationProvider].
@ProviderFor(MedicationProvider)
final medicationProviderProvider = AutoDisposeAsyncNotifierProvider<
    MedicationProvider, List<MedicationEntry>>.internal(
  MedicationProvider.new,
  name: r'medicationProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$medicationProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MedicationProvider = AutoDisposeAsyncNotifier<List<MedicationEntry>>;
String _$appointmentProviderHash() =>
    r'723e9cfd74ea2ef73d9633cfe8437a65a3d3ca52';

/// See also [AppointmentProvider].
@ProviderFor(AppointmentProvider)
final appointmentProviderProvider = AutoDisposeAsyncNotifierProvider<
    AppointmentProvider, List<AppointmentEntry>>.internal(
  AppointmentProvider.new,
  name: r'appointmentProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appointmentProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppointmentProvider
    = AutoDisposeAsyncNotifier<List<AppointmentEntry>>;
String _$reportProviderHash() => r'b422649e1dc565ccc5390483358777949a4bfe94';

/// See also [ReportProvider].
@ProviderFor(ReportProvider)
final reportProviderProvider = AutoDisposeAsyncNotifierProvider<ReportProvider,
    List<ReportEntry>>.internal(
  ReportProvider.new,
  name: r'reportProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReportProvider = AutoDisposeAsyncNotifier<List<ReportEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
