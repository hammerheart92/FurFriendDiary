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

String _$upcomingMedicationsHash() =>
    r'df4cd532ea4f9bf5035bd3f02ea3f4dbc8b649f5';

/// See also [upcomingMedications].
@ProviderFor(upcomingMedications)
const upcomingMedicationsProvider = UpcomingMedicationsFamily();

/// See also [upcomingMedications].
class UpcomingMedicationsFamily
    extends Family<AsyncValue<List<MedicationEntry>>> {
  /// See also [upcomingMedications].
  const UpcomingMedicationsFamily();

  /// See also [upcomingMedications].
  UpcomingMedicationsProvider call(
    String petId,
  ) {
    return UpcomingMedicationsProvider(
      petId,
    );
  }

  @override
  UpcomingMedicationsProvider getProviderOverride(
    covariant UpcomingMedicationsProvider provider,
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
  String? get name => r'upcomingMedicationsProvider';
}

/// See also [upcomingMedications].
class UpcomingMedicationsProvider
    extends AutoDisposeFutureProvider<List<MedicationEntry>> {
  /// See also [upcomingMedications].
  UpcomingMedicationsProvider(
    String petId,
  ) : this._internal(
          (ref) => upcomingMedications(
            ref as UpcomingMedicationsRef,
            petId,
          ),
          from: upcomingMedicationsProvider,
          name: r'upcomingMedicationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$upcomingMedicationsHash,
          dependencies: UpcomingMedicationsFamily._dependencies,
          allTransitiveDependencies:
              UpcomingMedicationsFamily._allTransitiveDependencies,
          petId: petId,
        );

  UpcomingMedicationsProvider._internal(
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
    FutureOr<List<MedicationEntry>> Function(UpcomingMedicationsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpcomingMedicationsProvider._internal(
        (ref) => create(ref as UpcomingMedicationsRef),
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
    return _UpcomingMedicationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingMedicationsProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpcomingMedicationsRef
    on AutoDisposeFutureProviderRef<List<MedicationEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _UpcomingMedicationsProviderElement
    extends AutoDisposeFutureProviderElement<List<MedicationEntry>>
    with UpcomingMedicationsRef {
  _UpcomingMedicationsProviderElement(super.provider);

  @override
  String get petId => (origin as UpcomingMedicationsProvider).petId;
}

String _$overdueMedicationsHash() =>
    r'a287cb3017388f57fb2436008c5a4fc869b0aaae';

/// See also [overdueMedications].
@ProviderFor(overdueMedications)
const overdueMedicationsProvider = OverdueMedicationsFamily();

/// See also [overdueMedications].
class OverdueMedicationsFamily
    extends Family<AsyncValue<List<MedicationEntry>>> {
  /// See also [overdueMedications].
  const OverdueMedicationsFamily();

  /// See also [overdueMedications].
  OverdueMedicationsProvider call(
    String petId,
  ) {
    return OverdueMedicationsProvider(
      petId,
    );
  }

  @override
  OverdueMedicationsProvider getProviderOverride(
    covariant OverdueMedicationsProvider provider,
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
  String? get name => r'overdueMedicationsProvider';
}

/// See also [overdueMedications].
class OverdueMedicationsProvider
    extends AutoDisposeFutureProvider<List<MedicationEntry>> {
  /// See also [overdueMedications].
  OverdueMedicationsProvider(
    String petId,
  ) : this._internal(
          (ref) => overdueMedications(
            ref as OverdueMedicationsRef,
            petId,
          ),
          from: overdueMedicationsProvider,
          name: r'overdueMedicationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$overdueMedicationsHash,
          dependencies: OverdueMedicationsFamily._dependencies,
          allTransitiveDependencies:
              OverdueMedicationsFamily._allTransitiveDependencies,
          petId: petId,
        );

  OverdueMedicationsProvider._internal(
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
    FutureOr<List<MedicationEntry>> Function(OverdueMedicationsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OverdueMedicationsProvider._internal(
        (ref) => create(ref as OverdueMedicationsRef),
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
    return _OverdueMedicationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OverdueMedicationsProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin OverdueMedicationsRef
    on AutoDisposeFutureProviderRef<List<MedicationEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _OverdueMedicationsProviderElement
    extends AutoDisposeFutureProviderElement<List<MedicationEntry>>
    with OverdueMedicationsRef {
  _OverdueMedicationsProviderElement(super.provider);

  @override
  String get petId => (origin as OverdueMedicationsProvider).petId;
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

String _$upcomingAppointmentsHash() =>
    r'77e08e0c327164060ed6ed37f4548feec014c332';

/// See also [upcomingAppointments].
@ProviderFor(upcomingAppointments)
const upcomingAppointmentsProvider = UpcomingAppointmentsFamily();

/// See also [upcomingAppointments].
class UpcomingAppointmentsFamily
    extends Family<AsyncValue<List<AppointmentEntry>>> {
  /// See also [upcomingAppointments].
  const UpcomingAppointmentsFamily();

  /// See also [upcomingAppointments].
  UpcomingAppointmentsProvider call(
    String petId,
  ) {
    return UpcomingAppointmentsProvider(
      petId,
    );
  }

  @override
  UpcomingAppointmentsProvider getProviderOverride(
    covariant UpcomingAppointmentsProvider provider,
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
  String? get name => r'upcomingAppointmentsProvider';
}

/// See also [upcomingAppointments].
class UpcomingAppointmentsProvider
    extends AutoDisposeFutureProvider<List<AppointmentEntry>> {
  /// See also [upcomingAppointments].
  UpcomingAppointmentsProvider(
    String petId,
  ) : this._internal(
          (ref) => upcomingAppointments(
            ref as UpcomingAppointmentsRef,
            petId,
          ),
          from: upcomingAppointmentsProvider,
          name: r'upcomingAppointmentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$upcomingAppointmentsHash,
          dependencies: UpcomingAppointmentsFamily._dependencies,
          allTransitiveDependencies:
              UpcomingAppointmentsFamily._allTransitiveDependencies,
          petId: petId,
        );

  UpcomingAppointmentsProvider._internal(
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
    FutureOr<List<AppointmentEntry>> Function(UpcomingAppointmentsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpcomingAppointmentsProvider._internal(
        (ref) => create(ref as UpcomingAppointmentsRef),
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
    return _UpcomingAppointmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingAppointmentsProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpcomingAppointmentsRef
    on AutoDisposeFutureProviderRef<List<AppointmentEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _UpcomingAppointmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<AppointmentEntry>>
    with UpcomingAppointmentsRef {
  _UpcomingAppointmentsProviderElement(super.provider);

  @override
  String get petId => (origin as UpcomingAppointmentsProvider).petId;
}

String _$completedAppointmentsHash() =>
    r'3d50911a6bffee3be16c018c1a1274fd604bff0f';

/// See also [completedAppointments].
@ProviderFor(completedAppointments)
const completedAppointmentsProvider = CompletedAppointmentsFamily();

/// See also [completedAppointments].
class CompletedAppointmentsFamily
    extends Family<AsyncValue<List<AppointmentEntry>>> {
  /// See also [completedAppointments].
  const CompletedAppointmentsFamily();

  /// See also [completedAppointments].
  CompletedAppointmentsProvider call(
    String petId,
  ) {
    return CompletedAppointmentsProvider(
      petId,
    );
  }

  @override
  CompletedAppointmentsProvider getProviderOverride(
    covariant CompletedAppointmentsProvider provider,
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
  String? get name => r'completedAppointmentsProvider';
}

/// See also [completedAppointments].
class CompletedAppointmentsProvider
    extends AutoDisposeFutureProvider<List<AppointmentEntry>> {
  /// See also [completedAppointments].
  CompletedAppointmentsProvider(
    String petId,
  ) : this._internal(
          (ref) => completedAppointments(
            ref as CompletedAppointmentsRef,
            petId,
          ),
          from: completedAppointmentsProvider,
          name: r'completedAppointmentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$completedAppointmentsHash,
          dependencies: CompletedAppointmentsFamily._dependencies,
          allTransitiveDependencies:
              CompletedAppointmentsFamily._allTransitiveDependencies,
          petId: petId,
        );

  CompletedAppointmentsProvider._internal(
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
    FutureOr<List<AppointmentEntry>> Function(CompletedAppointmentsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CompletedAppointmentsProvider._internal(
        (ref) => create(ref as CompletedAppointmentsRef),
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
    return _CompletedAppointmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletedAppointmentsProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CompletedAppointmentsRef
    on AutoDisposeFutureProviderRef<List<AppointmentEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _CompletedAppointmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<AppointmentEntry>>
    with CompletedAppointmentsRef {
  _CompletedAppointmentsProviderElement(super.provider);

  @override
  String get petId => (origin as CompletedAppointmentsProvider).petId;
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
