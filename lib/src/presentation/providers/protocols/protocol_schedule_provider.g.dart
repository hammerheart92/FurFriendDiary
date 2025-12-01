// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protocol_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upcomingCareHash() => r'd485b827729cc92894f0803ed6860dc8dc5d7826';

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

/// Unified upcoming care events provider - aggregates all types of care
///
/// This provider combines vaccination schedules, deworming schedules,
/// appointments, and medications into a single type-safe list sorted by date.
///
/// Usage:
/// ```dart
/// final upcomingEvents = await ref.read(upcomingCareProvider(
///   petId: 'pet-123',
///   daysAhead: 90,
/// ).future);
/// ```
///
/// Copied from [upcomingCare].
@ProviderFor(upcomingCare)
const upcomingCareProvider = UpcomingCareFamily();

/// Unified upcoming care events provider - aggregates all types of care
///
/// This provider combines vaccination schedules, deworming schedules,
/// appointments, and medications into a single type-safe list sorted by date.
///
/// Usage:
/// ```dart
/// final upcomingEvents = await ref.read(upcomingCareProvider(
///   petId: 'pet-123',
///   daysAhead: 90,
/// ).future);
/// ```
///
/// Copied from [upcomingCare].
class UpcomingCareFamily extends Family<AsyncValue<List<UpcomingCareEvent>>> {
  /// Unified upcoming care events provider - aggregates all types of care
  ///
  /// This provider combines vaccination schedules, deworming schedules,
  /// appointments, and medications into a single type-safe list sorted by date.
  ///
  /// Usage:
  /// ```dart
  /// final upcomingEvents = await ref.read(upcomingCareProvider(
  ///   petId: 'pet-123',
  ///   daysAhead: 90,
  /// ).future);
  /// ```
  ///
  /// Copied from [upcomingCare].
  const UpcomingCareFamily();

  /// Unified upcoming care events provider - aggregates all types of care
  ///
  /// This provider combines vaccination schedules, deworming schedules,
  /// appointments, and medications into a single type-safe list sorted by date.
  ///
  /// Usage:
  /// ```dart
  /// final upcomingEvents = await ref.read(upcomingCareProvider(
  ///   petId: 'pet-123',
  ///   daysAhead: 90,
  /// ).future);
  /// ```
  ///
  /// Copied from [upcomingCare].
  UpcomingCareProvider call({
    required String petId,
    int daysAhead = 365,
  }) {
    return UpcomingCareProvider(
      petId: petId,
      daysAhead: daysAhead,
    );
  }

  @override
  UpcomingCareProvider getProviderOverride(
    covariant UpcomingCareProvider provider,
  ) {
    return call(
      petId: provider.petId,
      daysAhead: provider.daysAhead,
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
  String? get name => r'upcomingCareProvider';
}

/// Unified upcoming care events provider - aggregates all types of care
///
/// This provider combines vaccination schedules, deworming schedules,
/// appointments, and medications into a single type-safe list sorted by date.
///
/// Usage:
/// ```dart
/// final upcomingEvents = await ref.read(upcomingCareProvider(
///   petId: 'pet-123',
///   daysAhead: 90,
/// ).future);
/// ```
///
/// Copied from [upcomingCare].
class UpcomingCareProvider
    extends AutoDisposeFutureProvider<List<UpcomingCareEvent>> {
  /// Unified upcoming care events provider - aggregates all types of care
  ///
  /// This provider combines vaccination schedules, deworming schedules,
  /// appointments, and medications into a single type-safe list sorted by date.
  ///
  /// Usage:
  /// ```dart
  /// final upcomingEvents = await ref.read(upcomingCareProvider(
  ///   petId: 'pet-123',
  ///   daysAhead: 90,
  /// ).future);
  /// ```
  ///
  /// Copied from [upcomingCare].
  UpcomingCareProvider({
    required String petId,
    int daysAhead = 365,
  }) : this._internal(
          (ref) => upcomingCare(
            ref as UpcomingCareRef,
            petId: petId,
            daysAhead: daysAhead,
          ),
          from: upcomingCareProvider,
          name: r'upcomingCareProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$upcomingCareHash,
          dependencies: UpcomingCareFamily._dependencies,
          allTransitiveDependencies:
              UpcomingCareFamily._allTransitiveDependencies,
          petId: petId,
          daysAhead: daysAhead,
        );

  UpcomingCareProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.daysAhead,
  }) : super.internal();

  final String petId;
  final int daysAhead;

  @override
  Override overrideWith(
    FutureOr<List<UpcomingCareEvent>> Function(UpcomingCareRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpcomingCareProvider._internal(
        (ref) => create(ref as UpcomingCareRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        daysAhead: daysAhead,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UpcomingCareEvent>> createElement() {
    return _UpcomingCareProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingCareProvider &&
        other.petId == petId &&
        other.daysAhead == daysAhead;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, daysAhead.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpcomingCareRef on AutoDisposeFutureProviderRef<List<UpcomingCareEvent>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `daysAhead` of this provider.
  int get daysAhead;
}

class _UpcomingCareProviderElement
    extends AutoDisposeFutureProviderElement<List<UpcomingCareEvent>>
    with UpcomingCareRef {
  _UpcomingCareProviderElement(super.provider);

  @override
  String get petId => (origin as UpcomingCareProvider).petId;
  @override
  int get daysAhead => (origin as UpcomingCareProvider).daysAhead;
}

String _$vaccinationScheduleHash() =>
    r'dfa588730676b3018ad78c86cadca2b101e1a6c9';

/// Generate vaccination schedule for a specific pet
///
/// Returns calculated vaccination dates based on the pet's assigned protocol.
/// Returns empty list if no protocol is assigned or pet not found.
///
/// Usage:
/// ```dart
/// final schedule = await ref.read(vaccinationScheduleProvider('pet-123').future);
/// ```
///
/// Copied from [vaccinationSchedule].
@ProviderFor(vaccinationSchedule)
const vaccinationScheduleProvider = VaccinationScheduleFamily();

/// Generate vaccination schedule for a specific pet
///
/// Returns calculated vaccination dates based on the pet's assigned protocol.
/// Returns empty list if no protocol is assigned or pet not found.
///
/// Usage:
/// ```dart
/// final schedule = await ref.read(vaccinationScheduleProvider('pet-123').future);
/// ```
///
/// Copied from [vaccinationSchedule].
class VaccinationScheduleFamily
    extends Family<AsyncValue<List<VaccinationScheduleEntry>>> {
  /// Generate vaccination schedule for a specific pet
  ///
  /// Returns calculated vaccination dates based on the pet's assigned protocol.
  /// Returns empty list if no protocol is assigned or pet not found.
  ///
  /// Usage:
  /// ```dart
  /// final schedule = await ref.read(vaccinationScheduleProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [vaccinationSchedule].
  const VaccinationScheduleFamily();

  /// Generate vaccination schedule for a specific pet
  ///
  /// Returns calculated vaccination dates based on the pet's assigned protocol.
  /// Returns empty list if no protocol is assigned or pet not found.
  ///
  /// Usage:
  /// ```dart
  /// final schedule = await ref.read(vaccinationScheduleProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [vaccinationSchedule].
  VaccinationScheduleProvider call(
    String petId,
  ) {
    return VaccinationScheduleProvider(
      petId,
    );
  }

  @override
  VaccinationScheduleProvider getProviderOverride(
    covariant VaccinationScheduleProvider provider,
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
  String? get name => r'vaccinationScheduleProvider';
}

/// Generate vaccination schedule for a specific pet
///
/// Returns calculated vaccination dates based on the pet's assigned protocol.
/// Returns empty list if no protocol is assigned or pet not found.
///
/// Usage:
/// ```dart
/// final schedule = await ref.read(vaccinationScheduleProvider('pet-123').future);
/// ```
///
/// Copied from [vaccinationSchedule].
class VaccinationScheduleProvider
    extends AutoDisposeFutureProvider<List<VaccinationScheduleEntry>> {
  /// Generate vaccination schedule for a specific pet
  ///
  /// Returns calculated vaccination dates based on the pet's assigned protocol.
  /// Returns empty list if no protocol is assigned or pet not found.
  ///
  /// Usage:
  /// ```dart
  /// final schedule = await ref.read(vaccinationScheduleProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [vaccinationSchedule].
  VaccinationScheduleProvider(
    String petId,
  ) : this._internal(
          (ref) => vaccinationSchedule(
            ref as VaccinationScheduleRef,
            petId,
          ),
          from: vaccinationScheduleProvider,
          name: r'vaccinationScheduleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$vaccinationScheduleHash,
          dependencies: VaccinationScheduleFamily._dependencies,
          allTransitiveDependencies:
              VaccinationScheduleFamily._allTransitiveDependencies,
          petId: petId,
        );

  VaccinationScheduleProvider._internal(
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
    FutureOr<List<VaccinationScheduleEntry>> Function(
            VaccinationScheduleRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VaccinationScheduleProvider._internal(
        (ref) => create(ref as VaccinationScheduleRef),
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
  AutoDisposeFutureProviderElement<List<VaccinationScheduleEntry>>
      createElement() {
    return _VaccinationScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VaccinationScheduleProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin VaccinationScheduleRef
    on AutoDisposeFutureProviderRef<List<VaccinationScheduleEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _VaccinationScheduleProviderElement
    extends AutoDisposeFutureProviderElement<List<VaccinationScheduleEntry>>
    with VaccinationScheduleRef {
  _VaccinationScheduleProviderElement(super.provider);

  @override
  String get petId => (origin as VaccinationScheduleProvider).petId;
}

String _$dewormingScheduleHash() => r'3d695c9a933dd08027ab9a473b95ec176d8faa1b';

/// Generate deworming schedule for a specific pet
///
/// Returns calculated deworming treatment dates based on the pet's assigned protocol.
/// Returns empty list if no protocol is assigned or pet not found.
///
/// Usage:
/// ```dart
/// final schedule = await ref.read(dewormingScheduleProvider('pet-123').future);
/// ```
///
/// Copied from [dewormingSchedule].
@ProviderFor(dewormingSchedule)
const dewormingScheduleProvider = DewormingScheduleFamily();

/// Generate deworming schedule for a specific pet
///
/// Returns calculated deworming treatment dates based on the pet's assigned protocol.
/// Returns empty list if no protocol is assigned or pet not found.
///
/// Usage:
/// ```dart
/// final schedule = await ref.read(dewormingScheduleProvider('pet-123').future);
/// ```
///
/// Copied from [dewormingSchedule].
class DewormingScheduleFamily
    extends Family<AsyncValue<List<DewormingScheduleEntry>>> {
  /// Generate deworming schedule for a specific pet
  ///
  /// Returns calculated deworming treatment dates based on the pet's assigned protocol.
  /// Returns empty list if no protocol is assigned or pet not found.
  ///
  /// Usage:
  /// ```dart
  /// final schedule = await ref.read(dewormingScheduleProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [dewormingSchedule].
  const DewormingScheduleFamily();

  /// Generate deworming schedule for a specific pet
  ///
  /// Returns calculated deworming treatment dates based on the pet's assigned protocol.
  /// Returns empty list if no protocol is assigned or pet not found.
  ///
  /// Usage:
  /// ```dart
  /// final schedule = await ref.read(dewormingScheduleProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [dewormingSchedule].
  DewormingScheduleProvider call(
    String petId,
  ) {
    return DewormingScheduleProvider(
      petId,
    );
  }

  @override
  DewormingScheduleProvider getProviderOverride(
    covariant DewormingScheduleProvider provider,
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
  String? get name => r'dewormingScheduleProvider';
}

/// Generate deworming schedule for a specific pet
///
/// Returns calculated deworming treatment dates based on the pet's assigned protocol.
/// Returns empty list if no protocol is assigned or pet not found.
///
/// Usage:
/// ```dart
/// final schedule = await ref.read(dewormingScheduleProvider('pet-123').future);
/// ```
///
/// Copied from [dewormingSchedule].
class DewormingScheduleProvider
    extends AutoDisposeFutureProvider<List<DewormingScheduleEntry>> {
  /// Generate deworming schedule for a specific pet
  ///
  /// Returns calculated deworming treatment dates based on the pet's assigned protocol.
  /// Returns empty list if no protocol is assigned or pet not found.
  ///
  /// Usage:
  /// ```dart
  /// final schedule = await ref.read(dewormingScheduleProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [dewormingSchedule].
  DewormingScheduleProvider(
    String petId,
  ) : this._internal(
          (ref) => dewormingSchedule(
            ref as DewormingScheduleRef,
            petId,
          ),
          from: dewormingScheduleProvider,
          name: r'dewormingScheduleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dewormingScheduleHash,
          dependencies: DewormingScheduleFamily._dependencies,
          allTransitiveDependencies:
              DewormingScheduleFamily._allTransitiveDependencies,
          petId: petId,
        );

  DewormingScheduleProvider._internal(
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
    FutureOr<List<DewormingScheduleEntry>> Function(
            DewormingScheduleRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DewormingScheduleProvider._internal(
        (ref) => create(ref as DewormingScheduleRef),
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
  AutoDisposeFutureProviderElement<List<DewormingScheduleEntry>>
      createElement() {
    return _DewormingScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DewormingScheduleProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DewormingScheduleRef
    on AutoDisposeFutureProviderRef<List<DewormingScheduleEntry>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _DewormingScheduleProviderElement
    extends AutoDisposeFutureProviderElement<List<DewormingScheduleEntry>>
    with DewormingScheduleRef {
  _DewormingScheduleProviderElement(super.provider);

  @override
  String get petId => (origin as DewormingScheduleProvider).petId;
}

String _$appointmentSuggestionsHash() =>
    r'dae401d6a73d8b56b2e7dafec7e954a04f0e53c9';

/// Generate appointment suggestions for a specific pet
///
/// Analyzes due protocols and suggests consolidated vet appointments.
/// Groups multiple protocols that are due around the same time.
///
/// Usage:
/// ```dart
/// final suggestions = await ref.read(appointmentSuggestionsProvider('pet-123').future);
/// ```
///
/// Copied from [appointmentSuggestions].
@ProviderFor(appointmentSuggestions)
const appointmentSuggestionsProvider = AppointmentSuggestionsFamily();

/// Generate appointment suggestions for a specific pet
///
/// Analyzes due protocols and suggests consolidated vet appointments.
/// Groups multiple protocols that are due around the same time.
///
/// Usage:
/// ```dart
/// final suggestions = await ref.read(appointmentSuggestionsProvider('pet-123').future);
/// ```
///
/// Copied from [appointmentSuggestions].
class AppointmentSuggestionsFamily
    extends Family<AsyncValue<List<AppointmentSuggestion>>> {
  /// Generate appointment suggestions for a specific pet
  ///
  /// Analyzes due protocols and suggests consolidated vet appointments.
  /// Groups multiple protocols that are due around the same time.
  ///
  /// Usage:
  /// ```dart
  /// final suggestions = await ref.read(appointmentSuggestionsProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [appointmentSuggestions].
  const AppointmentSuggestionsFamily();

  /// Generate appointment suggestions for a specific pet
  ///
  /// Analyzes due protocols and suggests consolidated vet appointments.
  /// Groups multiple protocols that are due around the same time.
  ///
  /// Usage:
  /// ```dart
  /// final suggestions = await ref.read(appointmentSuggestionsProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [appointmentSuggestions].
  AppointmentSuggestionsProvider call(
    String petId,
  ) {
    return AppointmentSuggestionsProvider(
      petId,
    );
  }

  @override
  AppointmentSuggestionsProvider getProviderOverride(
    covariant AppointmentSuggestionsProvider provider,
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
  String? get name => r'appointmentSuggestionsProvider';
}

/// Generate appointment suggestions for a specific pet
///
/// Analyzes due protocols and suggests consolidated vet appointments.
/// Groups multiple protocols that are due around the same time.
///
/// Usage:
/// ```dart
/// final suggestions = await ref.read(appointmentSuggestionsProvider('pet-123').future);
/// ```
///
/// Copied from [appointmentSuggestions].
class AppointmentSuggestionsProvider
    extends AutoDisposeFutureProvider<List<AppointmentSuggestion>> {
  /// Generate appointment suggestions for a specific pet
  ///
  /// Analyzes due protocols and suggests consolidated vet appointments.
  /// Groups multiple protocols that are due around the same time.
  ///
  /// Usage:
  /// ```dart
  /// final suggestions = await ref.read(appointmentSuggestionsProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [appointmentSuggestions].
  AppointmentSuggestionsProvider(
    String petId,
  ) : this._internal(
          (ref) => appointmentSuggestions(
            ref as AppointmentSuggestionsRef,
            petId,
          ),
          from: appointmentSuggestionsProvider,
          name: r'appointmentSuggestionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$appointmentSuggestionsHash,
          dependencies: AppointmentSuggestionsFamily._dependencies,
          allTransitiveDependencies:
              AppointmentSuggestionsFamily._allTransitiveDependencies,
          petId: petId,
        );

  AppointmentSuggestionsProvider._internal(
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
    FutureOr<List<AppointmentSuggestion>> Function(
            AppointmentSuggestionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AppointmentSuggestionsProvider._internal(
        (ref) => create(ref as AppointmentSuggestionsRef),
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
  AutoDisposeFutureProviderElement<List<AppointmentSuggestion>>
      createElement() {
    return _AppointmentSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppointmentSuggestionsProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AppointmentSuggestionsRef
    on AutoDisposeFutureProviderRef<List<AppointmentSuggestion>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _AppointmentSuggestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<AppointmentSuggestion>>
    with AppointmentSuggestionsRef {
  _AppointmentSuggestionsProviderElement(super.provider);

  @override
  String get petId => (origin as AppointmentSuggestionsProvider).petId;
}

String _$upcomingCareByTypeHash() =>
    r'da02806fe7f7bb9e76a303e2111cd6deb8c413a3';

/// Get upcoming care events filtered by event type
///
/// Usage:
/// ```dart
/// final vaccinations = await ref.read(upcomingCareByTypeProvider(
///   petId: 'pet-123',
///   eventType: 'vaccination',
/// ).future);
/// ```
///
/// Copied from [upcomingCareByType].
@ProviderFor(upcomingCareByType)
const upcomingCareByTypeProvider = UpcomingCareByTypeFamily();

/// Get upcoming care events filtered by event type
///
/// Usage:
/// ```dart
/// final vaccinations = await ref.read(upcomingCareByTypeProvider(
///   petId: 'pet-123',
///   eventType: 'vaccination',
/// ).future);
/// ```
///
/// Copied from [upcomingCareByType].
class UpcomingCareByTypeFamily
    extends Family<AsyncValue<List<UpcomingCareEvent>>> {
  /// Get upcoming care events filtered by event type
  ///
  /// Usage:
  /// ```dart
  /// final vaccinations = await ref.read(upcomingCareByTypeProvider(
  ///   petId: 'pet-123',
  ///   eventType: 'vaccination',
  /// ).future);
  /// ```
  ///
  /// Copied from [upcomingCareByType].
  const UpcomingCareByTypeFamily();

  /// Get upcoming care events filtered by event type
  ///
  /// Usage:
  /// ```dart
  /// final vaccinations = await ref.read(upcomingCareByTypeProvider(
  ///   petId: 'pet-123',
  ///   eventType: 'vaccination',
  /// ).future);
  /// ```
  ///
  /// Copied from [upcomingCareByType].
  UpcomingCareByTypeProvider call({
    required String petId,
    required String eventType,
    int daysAhead = 365,
  }) {
    return UpcomingCareByTypeProvider(
      petId: petId,
      eventType: eventType,
      daysAhead: daysAhead,
    );
  }

  @override
  UpcomingCareByTypeProvider getProviderOverride(
    covariant UpcomingCareByTypeProvider provider,
  ) {
    return call(
      petId: provider.petId,
      eventType: provider.eventType,
      daysAhead: provider.daysAhead,
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
  String? get name => r'upcomingCareByTypeProvider';
}

/// Get upcoming care events filtered by event type
///
/// Usage:
/// ```dart
/// final vaccinations = await ref.read(upcomingCareByTypeProvider(
///   petId: 'pet-123',
///   eventType: 'vaccination',
/// ).future);
/// ```
///
/// Copied from [upcomingCareByType].
class UpcomingCareByTypeProvider
    extends AutoDisposeFutureProvider<List<UpcomingCareEvent>> {
  /// Get upcoming care events filtered by event type
  ///
  /// Usage:
  /// ```dart
  /// final vaccinations = await ref.read(upcomingCareByTypeProvider(
  ///   petId: 'pet-123',
  ///   eventType: 'vaccination',
  /// ).future);
  /// ```
  ///
  /// Copied from [upcomingCareByType].
  UpcomingCareByTypeProvider({
    required String petId,
    required String eventType,
    int daysAhead = 365,
  }) : this._internal(
          (ref) => upcomingCareByType(
            ref as UpcomingCareByTypeRef,
            petId: petId,
            eventType: eventType,
            daysAhead: daysAhead,
          ),
          from: upcomingCareByTypeProvider,
          name: r'upcomingCareByTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$upcomingCareByTypeHash,
          dependencies: UpcomingCareByTypeFamily._dependencies,
          allTransitiveDependencies:
              UpcomingCareByTypeFamily._allTransitiveDependencies,
          petId: petId,
          eventType: eventType,
          daysAhead: daysAhead,
        );

  UpcomingCareByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.eventType,
    required this.daysAhead,
  }) : super.internal();

  final String petId;
  final String eventType;
  final int daysAhead;

  @override
  Override overrideWith(
    FutureOr<List<UpcomingCareEvent>> Function(UpcomingCareByTypeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpcomingCareByTypeProvider._internal(
        (ref) => create(ref as UpcomingCareByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        eventType: eventType,
        daysAhead: daysAhead,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UpcomingCareEvent>> createElement() {
    return _UpcomingCareByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingCareByTypeProvider &&
        other.petId == petId &&
        other.eventType == eventType &&
        other.daysAhead == daysAhead;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, eventType.hashCode);
    hash = _SystemHash.combine(hash, daysAhead.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpcomingCareByTypeRef
    on AutoDisposeFutureProviderRef<List<UpcomingCareEvent>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `eventType` of this provider.
  String get eventType;

  /// The parameter `daysAhead` of this provider.
  int get daysAhead;
}

class _UpcomingCareByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<UpcomingCareEvent>>
    with UpcomingCareByTypeRef {
  _UpcomingCareByTypeProviderElement(super.provider);

  @override
  String get petId => (origin as UpcomingCareByTypeProvider).petId;
  @override
  String get eventType => (origin as UpcomingCareByTypeProvider).eventType;
  @override
  int get daysAhead => (origin as UpcomingCareByTypeProvider).daysAhead;
}

String _$overdueCareHash() => r'966876526a1eeaccf0f5efb675295d99016036a9';

/// Get only overdue care events
///
/// Usage:
/// ```dart
/// final overdueEvents = await ref.read(overdueCareProvider('pet-123').future);
/// ```
///
/// Copied from [overdueCare].
@ProviderFor(overdueCare)
const overdueCareProvider = OverdueCareFamily();

/// Get only overdue care events
///
/// Usage:
/// ```dart
/// final overdueEvents = await ref.read(overdueCareProvider('pet-123').future);
/// ```
///
/// Copied from [overdueCare].
class OverdueCareFamily extends Family<AsyncValue<List<UpcomingCareEvent>>> {
  /// Get only overdue care events
  ///
  /// Usage:
  /// ```dart
  /// final overdueEvents = await ref.read(overdueCareProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [overdueCare].
  const OverdueCareFamily();

  /// Get only overdue care events
  ///
  /// Usage:
  /// ```dart
  /// final overdueEvents = await ref.read(overdueCareProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [overdueCare].
  OverdueCareProvider call(
    String petId,
  ) {
    return OverdueCareProvider(
      petId,
    );
  }

  @override
  OverdueCareProvider getProviderOverride(
    covariant OverdueCareProvider provider,
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
  String? get name => r'overdueCareProvider';
}

/// Get only overdue care events
///
/// Usage:
/// ```dart
/// final overdueEvents = await ref.read(overdueCareProvider('pet-123').future);
/// ```
///
/// Copied from [overdueCare].
class OverdueCareProvider
    extends AutoDisposeFutureProvider<List<UpcomingCareEvent>> {
  /// Get only overdue care events
  ///
  /// Usage:
  /// ```dart
  /// final overdueEvents = await ref.read(overdueCareProvider('pet-123').future);
  /// ```
  ///
  /// Copied from [overdueCare].
  OverdueCareProvider(
    String petId,
  ) : this._internal(
          (ref) => overdueCare(
            ref as OverdueCareRef,
            petId,
          ),
          from: overdueCareProvider,
          name: r'overdueCareProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$overdueCareHash,
          dependencies: OverdueCareFamily._dependencies,
          allTransitiveDependencies:
              OverdueCareFamily._allTransitiveDependencies,
          petId: petId,
        );

  OverdueCareProvider._internal(
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
    FutureOr<List<UpcomingCareEvent>> Function(OverdueCareRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OverdueCareProvider._internal(
        (ref) => create(ref as OverdueCareRef),
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
  AutoDisposeFutureProviderElement<List<UpcomingCareEvent>> createElement() {
    return _OverdueCareProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OverdueCareProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin OverdueCareRef on AutoDisposeFutureProviderRef<List<UpcomingCareEvent>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _OverdueCareProviderElement
    extends AutoDisposeFutureProviderElement<List<UpcomingCareEvent>>
    with OverdueCareRef {
  _OverdueCareProviderElement(super.provider);

  @override
  String get petId => (origin as OverdueCareProvider).petId;
}

String _$dueSoonCareHash() => r'2458649dc8a24f7025bfa4290b38a15fda676374';

/// Get care events due soon (within specified days)
///
/// Usage:
/// ```dart
/// final dueSoon = await ref.read(dueSoonCareProvider(
///   petId: 'pet-123',
///   daysAhead: 7,
/// ).future);
/// ```
///
/// Copied from [dueSoonCare].
@ProviderFor(dueSoonCare)
const dueSoonCareProvider = DueSoonCareFamily();

/// Get care events due soon (within specified days)
///
/// Usage:
/// ```dart
/// final dueSoon = await ref.read(dueSoonCareProvider(
///   petId: 'pet-123',
///   daysAhead: 7,
/// ).future);
/// ```
///
/// Copied from [dueSoonCare].
class DueSoonCareFamily extends Family<AsyncValue<List<UpcomingCareEvent>>> {
  /// Get care events due soon (within specified days)
  ///
  /// Usage:
  /// ```dart
  /// final dueSoon = await ref.read(dueSoonCareProvider(
  ///   petId: 'pet-123',
  ///   daysAhead: 7,
  /// ).future);
  /// ```
  ///
  /// Copied from [dueSoonCare].
  const DueSoonCareFamily();

  /// Get care events due soon (within specified days)
  ///
  /// Usage:
  /// ```dart
  /// final dueSoon = await ref.read(dueSoonCareProvider(
  ///   petId: 'pet-123',
  ///   daysAhead: 7,
  /// ).future);
  /// ```
  ///
  /// Copied from [dueSoonCare].
  DueSoonCareProvider call({
    required String petId,
    int daysAhead = 7,
  }) {
    return DueSoonCareProvider(
      petId: petId,
      daysAhead: daysAhead,
    );
  }

  @override
  DueSoonCareProvider getProviderOverride(
    covariant DueSoonCareProvider provider,
  ) {
    return call(
      petId: provider.petId,
      daysAhead: provider.daysAhead,
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
  String? get name => r'dueSoonCareProvider';
}

/// Get care events due soon (within specified days)
///
/// Usage:
/// ```dart
/// final dueSoon = await ref.read(dueSoonCareProvider(
///   petId: 'pet-123',
///   daysAhead: 7,
/// ).future);
/// ```
///
/// Copied from [dueSoonCare].
class DueSoonCareProvider
    extends AutoDisposeFutureProvider<List<UpcomingCareEvent>> {
  /// Get care events due soon (within specified days)
  ///
  /// Usage:
  /// ```dart
  /// final dueSoon = await ref.read(dueSoonCareProvider(
  ///   petId: 'pet-123',
  ///   daysAhead: 7,
  /// ).future);
  /// ```
  ///
  /// Copied from [dueSoonCare].
  DueSoonCareProvider({
    required String petId,
    int daysAhead = 7,
  }) : this._internal(
          (ref) => dueSoonCare(
            ref as DueSoonCareRef,
            petId: petId,
            daysAhead: daysAhead,
          ),
          from: dueSoonCareProvider,
          name: r'dueSoonCareProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dueSoonCareHash,
          dependencies: DueSoonCareFamily._dependencies,
          allTransitiveDependencies:
              DueSoonCareFamily._allTransitiveDependencies,
          petId: petId,
          daysAhead: daysAhead,
        );

  DueSoonCareProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.daysAhead,
  }) : super.internal();

  final String petId;
  final int daysAhead;

  @override
  Override overrideWith(
    FutureOr<List<UpcomingCareEvent>> Function(DueSoonCareRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DueSoonCareProvider._internal(
        (ref) => create(ref as DueSoonCareRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        daysAhead: daysAhead,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UpcomingCareEvent>> createElement() {
    return _DueSoonCareProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DueSoonCareProvider &&
        other.petId == petId &&
        other.daysAhead == daysAhead;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, daysAhead.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DueSoonCareRef on AutoDisposeFutureProviderRef<List<UpcomingCareEvent>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `daysAhead` of this provider.
  int get daysAhead;
}

class _DueSoonCareProviderElement
    extends AutoDisposeFutureProviderElement<List<UpcomingCareEvent>>
    with DueSoonCareRef {
  _DueSoonCareProviderElement(super.provider);

  @override
  String get petId => (origin as DueSoonCareProvider).petId;
  @override
  int get daysAhead => (origin as DueSoonCareProvider).daysAhead;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
