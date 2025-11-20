// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment_plan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$treatmentPlansByPetIdHash() =>
    r'd2c7406c56ebda9118703e3c26bdaefbac7dc5a7';

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

/// Get treatment plans for a specific pet
///
/// Returns all treatment plans (active and completed) for the given pet ID.
///
/// Usage:
/// ```dart
/// final petPlans = await ref.read(treatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [treatmentPlansByPetId].
@ProviderFor(treatmentPlansByPetId)
const treatmentPlansByPetIdProvider = TreatmentPlansByPetIdFamily();

/// Get treatment plans for a specific pet
///
/// Returns all treatment plans (active and completed) for the given pet ID.
///
/// Usage:
/// ```dart
/// final petPlans = await ref.read(treatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [treatmentPlansByPetId].
class TreatmentPlansByPetIdFamily
    extends Family<AsyncValue<List<TreatmentPlan>>> {
  /// Get treatment plans for a specific pet
  ///
  /// Returns all treatment plans (active and completed) for the given pet ID.
  ///
  /// Usage:
  /// ```dart
  /// final petPlans = await ref.read(treatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [treatmentPlansByPetId].
  const TreatmentPlansByPetIdFamily();

  /// Get treatment plans for a specific pet
  ///
  /// Returns all treatment plans (active and completed) for the given pet ID.
  ///
  /// Usage:
  /// ```dart
  /// final petPlans = await ref.read(treatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [treatmentPlansByPetId].
  TreatmentPlansByPetIdProvider call(
    String petId,
  ) {
    return TreatmentPlansByPetIdProvider(
      petId,
    );
  }

  @override
  TreatmentPlansByPetIdProvider getProviderOverride(
    covariant TreatmentPlansByPetIdProvider provider,
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
  String? get name => r'treatmentPlansByPetIdProvider';
}

/// Get treatment plans for a specific pet
///
/// Returns all treatment plans (active and completed) for the given pet ID.
///
/// Usage:
/// ```dart
/// final petPlans = await ref.read(treatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [treatmentPlansByPetId].
class TreatmentPlansByPetIdProvider
    extends AutoDisposeFutureProvider<List<TreatmentPlan>> {
  /// Get treatment plans for a specific pet
  ///
  /// Returns all treatment plans (active and completed) for the given pet ID.
  ///
  /// Usage:
  /// ```dart
  /// final petPlans = await ref.read(treatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [treatmentPlansByPetId].
  TreatmentPlansByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => treatmentPlansByPetId(
            ref as TreatmentPlansByPetIdRef,
            petId,
          ),
          from: treatmentPlansByPetIdProvider,
          name: r'treatmentPlansByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$treatmentPlansByPetIdHash,
          dependencies: TreatmentPlansByPetIdFamily._dependencies,
          allTransitiveDependencies:
              TreatmentPlansByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  TreatmentPlansByPetIdProvider._internal(
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
    FutureOr<List<TreatmentPlan>> Function(TreatmentPlansByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TreatmentPlansByPetIdProvider._internal(
        (ref) => create(ref as TreatmentPlansByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<TreatmentPlan>> createElement() {
    return _TreatmentPlansByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TreatmentPlansByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TreatmentPlansByPetIdRef
    on AutoDisposeFutureProviderRef<List<TreatmentPlan>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _TreatmentPlansByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<TreatmentPlan>>
    with TreatmentPlansByPetIdRef {
  _TreatmentPlansByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as TreatmentPlansByPetIdProvider).petId;
}

String _$activeTreatmentPlansByPetIdHash() =>
    r'31969d494abee2c446286044729052f0ff36ad63';

/// Get active (non-completed) treatment plans for a specific pet
///
/// Usage:
/// ```dart
/// final activePlans = await ref.read(activeTreatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [activeTreatmentPlansByPetId].
@ProviderFor(activeTreatmentPlansByPetId)
const activeTreatmentPlansByPetIdProvider = ActiveTreatmentPlansByPetIdFamily();

/// Get active (non-completed) treatment plans for a specific pet
///
/// Usage:
/// ```dart
/// final activePlans = await ref.read(activeTreatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [activeTreatmentPlansByPetId].
class ActiveTreatmentPlansByPetIdFamily
    extends Family<AsyncValue<List<TreatmentPlan>>> {
  /// Get active (non-completed) treatment plans for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final activePlans = await ref.read(activeTreatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [activeTreatmentPlansByPetId].
  const ActiveTreatmentPlansByPetIdFamily();

  /// Get active (non-completed) treatment plans for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final activePlans = await ref.read(activeTreatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [activeTreatmentPlansByPetId].
  ActiveTreatmentPlansByPetIdProvider call(
    String petId,
  ) {
    return ActiveTreatmentPlansByPetIdProvider(
      petId,
    );
  }

  @override
  ActiveTreatmentPlansByPetIdProvider getProviderOverride(
    covariant ActiveTreatmentPlansByPetIdProvider provider,
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
  String? get name => r'activeTreatmentPlansByPetIdProvider';
}

/// Get active (non-completed) treatment plans for a specific pet
///
/// Usage:
/// ```dart
/// final activePlans = await ref.read(activeTreatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [activeTreatmentPlansByPetId].
class ActiveTreatmentPlansByPetIdProvider
    extends AutoDisposeFutureProvider<List<TreatmentPlan>> {
  /// Get active (non-completed) treatment plans for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final activePlans = await ref.read(activeTreatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [activeTreatmentPlansByPetId].
  ActiveTreatmentPlansByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => activeTreatmentPlansByPetId(
            ref as ActiveTreatmentPlansByPetIdRef,
            petId,
          ),
          from: activeTreatmentPlansByPetIdProvider,
          name: r'activeTreatmentPlansByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activeTreatmentPlansByPetIdHash,
          dependencies: ActiveTreatmentPlansByPetIdFamily._dependencies,
          allTransitiveDependencies:
              ActiveTreatmentPlansByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  ActiveTreatmentPlansByPetIdProvider._internal(
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
    FutureOr<List<TreatmentPlan>> Function(
            ActiveTreatmentPlansByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveTreatmentPlansByPetIdProvider._internal(
        (ref) => create(ref as ActiveTreatmentPlansByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<TreatmentPlan>> createElement() {
    return _ActiveTreatmentPlansByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveTreatmentPlansByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ActiveTreatmentPlansByPetIdRef
    on AutoDisposeFutureProviderRef<List<TreatmentPlan>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _ActiveTreatmentPlansByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<TreatmentPlan>>
    with ActiveTreatmentPlansByPetIdRef {
  _ActiveTreatmentPlansByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as ActiveTreatmentPlansByPetIdProvider).petId;
}

String _$completedTreatmentPlansByPetIdHash() =>
    r'601c4119f56fba9f5571f06257921982af28fe53';

/// Get completed treatment plans for a specific pet
///
/// Usage:
/// ```dart
/// final completedPlans = await ref.read(completedTreatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [completedTreatmentPlansByPetId].
@ProviderFor(completedTreatmentPlansByPetId)
const completedTreatmentPlansByPetIdProvider =
    CompletedTreatmentPlansByPetIdFamily();

/// Get completed treatment plans for a specific pet
///
/// Usage:
/// ```dart
/// final completedPlans = await ref.read(completedTreatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [completedTreatmentPlansByPetId].
class CompletedTreatmentPlansByPetIdFamily
    extends Family<AsyncValue<List<TreatmentPlan>>> {
  /// Get completed treatment plans for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final completedPlans = await ref.read(completedTreatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [completedTreatmentPlansByPetId].
  const CompletedTreatmentPlansByPetIdFamily();

  /// Get completed treatment plans for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final completedPlans = await ref.read(completedTreatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [completedTreatmentPlansByPetId].
  CompletedTreatmentPlansByPetIdProvider call(
    String petId,
  ) {
    return CompletedTreatmentPlansByPetIdProvider(
      petId,
    );
  }

  @override
  CompletedTreatmentPlansByPetIdProvider getProviderOverride(
    covariant CompletedTreatmentPlansByPetIdProvider provider,
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
  String? get name => r'completedTreatmentPlansByPetIdProvider';
}

/// Get completed treatment plans for a specific pet
///
/// Usage:
/// ```dart
/// final completedPlans = await ref.read(completedTreatmentPlansByPetIdProvider('pet-id').future);
/// ```
///
/// Copied from [completedTreatmentPlansByPetId].
class CompletedTreatmentPlansByPetIdProvider
    extends AutoDisposeFutureProvider<List<TreatmentPlan>> {
  /// Get completed treatment plans for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final completedPlans = await ref.read(completedTreatmentPlansByPetIdProvider('pet-id').future);
  /// ```
  ///
  /// Copied from [completedTreatmentPlansByPetId].
  CompletedTreatmentPlansByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => completedTreatmentPlansByPetId(
            ref as CompletedTreatmentPlansByPetIdRef,
            petId,
          ),
          from: completedTreatmentPlansByPetIdProvider,
          name: r'completedTreatmentPlansByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$completedTreatmentPlansByPetIdHash,
          dependencies: CompletedTreatmentPlansByPetIdFamily._dependencies,
          allTransitiveDependencies:
              CompletedTreatmentPlansByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  CompletedTreatmentPlansByPetIdProvider._internal(
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
    FutureOr<List<TreatmentPlan>> Function(
            CompletedTreatmentPlansByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CompletedTreatmentPlansByPetIdProvider._internal(
        (ref) => create(ref as CompletedTreatmentPlansByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<TreatmentPlan>> createElement() {
    return _CompletedTreatmentPlansByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletedTreatmentPlansByPetIdProvider &&
        other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CompletedTreatmentPlansByPetIdRef
    on AutoDisposeFutureProviderRef<List<TreatmentPlan>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _CompletedTreatmentPlansByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<TreatmentPlan>>
    with CompletedTreatmentPlansByPetIdRef {
  _CompletedTreatmentPlansByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as CompletedTreatmentPlansByPetIdProvider).petId;
}

String _$treatmentPlanByIdHash() => r'0d228645ac94503f5f35ecd0c75765a5497060f5';

/// Get a specific treatment plan by ID
///
/// Returns null if plan not found.
///
/// Usage:
/// ```dart
/// final plan = await ref.read(treatmentPlanByIdProvider('plan-id').future);
/// ```
///
/// Copied from [treatmentPlanById].
@ProviderFor(treatmentPlanById)
const treatmentPlanByIdProvider = TreatmentPlanByIdFamily();

/// Get a specific treatment plan by ID
///
/// Returns null if plan not found.
///
/// Usage:
/// ```dart
/// final plan = await ref.read(treatmentPlanByIdProvider('plan-id').future);
/// ```
///
/// Copied from [treatmentPlanById].
class TreatmentPlanByIdFamily extends Family<AsyncValue<TreatmentPlan?>> {
  /// Get a specific treatment plan by ID
  ///
  /// Returns null if plan not found.
  ///
  /// Usage:
  /// ```dart
  /// final plan = await ref.read(treatmentPlanByIdProvider('plan-id').future);
  /// ```
  ///
  /// Copied from [treatmentPlanById].
  const TreatmentPlanByIdFamily();

  /// Get a specific treatment plan by ID
  ///
  /// Returns null if plan not found.
  ///
  /// Usage:
  /// ```dart
  /// final plan = await ref.read(treatmentPlanByIdProvider('plan-id').future);
  /// ```
  ///
  /// Copied from [treatmentPlanById].
  TreatmentPlanByIdProvider call(
    String id,
  ) {
    return TreatmentPlanByIdProvider(
      id,
    );
  }

  @override
  TreatmentPlanByIdProvider getProviderOverride(
    covariant TreatmentPlanByIdProvider provider,
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
  String? get name => r'treatmentPlanByIdProvider';
}

/// Get a specific treatment plan by ID
///
/// Returns null if plan not found.
///
/// Usage:
/// ```dart
/// final plan = await ref.read(treatmentPlanByIdProvider('plan-id').future);
/// ```
///
/// Copied from [treatmentPlanById].
class TreatmentPlanByIdProvider
    extends AutoDisposeFutureProvider<TreatmentPlan?> {
  /// Get a specific treatment plan by ID
  ///
  /// Returns null if plan not found.
  ///
  /// Usage:
  /// ```dart
  /// final plan = await ref.read(treatmentPlanByIdProvider('plan-id').future);
  /// ```
  ///
  /// Copied from [treatmentPlanById].
  TreatmentPlanByIdProvider(
    String id,
  ) : this._internal(
          (ref) => treatmentPlanById(
            ref as TreatmentPlanByIdRef,
            id,
          ),
          from: treatmentPlanByIdProvider,
          name: r'treatmentPlanByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$treatmentPlanByIdHash,
          dependencies: TreatmentPlanByIdFamily._dependencies,
          allTransitiveDependencies:
              TreatmentPlanByIdFamily._allTransitiveDependencies,
          id: id,
        );

  TreatmentPlanByIdProvider._internal(
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
    FutureOr<TreatmentPlan?> Function(TreatmentPlanByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TreatmentPlanByIdProvider._internal(
        (ref) => create(ref as TreatmentPlanByIdRef),
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
  AutoDisposeFutureProviderElement<TreatmentPlan?> createElement() {
    return _TreatmentPlanByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TreatmentPlanByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TreatmentPlanByIdRef on AutoDisposeFutureProviderRef<TreatmentPlan?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TreatmentPlanByIdProviderElement
    extends AutoDisposeFutureProviderElement<TreatmentPlan?>
    with TreatmentPlanByIdRef {
  _TreatmentPlanByIdProviderElement(super.provider);

  @override
  String get id => (origin as TreatmentPlanByIdProvider).id;
}

String _$treatmentPlanStatsHash() =>
    r'71dd89933d8c07a4ec6104a30ebdaaf9cbd47df5';

/// Get treatment plan completion statistics for a pet
///
/// Returns a map with completion stats:
/// - 'total': Total number of treatment plans
/// - 'completed': Number of completed plans
/// - 'active': Number of active plans
/// - 'completionRate': Percentage of completed plans (0-100)
///
/// Usage:
/// ```dart
/// final stats = await ref.read(treatmentPlanStatsProvider('pet-id').future);
/// print('Completion rate: ${stats['completionRate']}%');
/// ```
///
/// Copied from [treatmentPlanStats].
@ProviderFor(treatmentPlanStats)
const treatmentPlanStatsProvider = TreatmentPlanStatsFamily();

/// Get treatment plan completion statistics for a pet
///
/// Returns a map with completion stats:
/// - 'total': Total number of treatment plans
/// - 'completed': Number of completed plans
/// - 'active': Number of active plans
/// - 'completionRate': Percentage of completed plans (0-100)
///
/// Usage:
/// ```dart
/// final stats = await ref.read(treatmentPlanStatsProvider('pet-id').future);
/// print('Completion rate: ${stats['completionRate']}%');
/// ```
///
/// Copied from [treatmentPlanStats].
class TreatmentPlanStatsFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Get treatment plan completion statistics for a pet
  ///
  /// Returns a map with completion stats:
  /// - 'total': Total number of treatment plans
  /// - 'completed': Number of completed plans
  /// - 'active': Number of active plans
  /// - 'completionRate': Percentage of completed plans (0-100)
  ///
  /// Usage:
  /// ```dart
  /// final stats = await ref.read(treatmentPlanStatsProvider('pet-id').future);
  /// print('Completion rate: ${stats['completionRate']}%');
  /// ```
  ///
  /// Copied from [treatmentPlanStats].
  const TreatmentPlanStatsFamily();

  /// Get treatment plan completion statistics for a pet
  ///
  /// Returns a map with completion stats:
  /// - 'total': Total number of treatment plans
  /// - 'completed': Number of completed plans
  /// - 'active': Number of active plans
  /// - 'completionRate': Percentage of completed plans (0-100)
  ///
  /// Usage:
  /// ```dart
  /// final stats = await ref.read(treatmentPlanStatsProvider('pet-id').future);
  /// print('Completion rate: ${stats['completionRate']}%');
  /// ```
  ///
  /// Copied from [treatmentPlanStats].
  TreatmentPlanStatsProvider call(
    String petId,
  ) {
    return TreatmentPlanStatsProvider(
      petId,
    );
  }

  @override
  TreatmentPlanStatsProvider getProviderOverride(
    covariant TreatmentPlanStatsProvider provider,
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
  String? get name => r'treatmentPlanStatsProvider';
}

/// Get treatment plan completion statistics for a pet
///
/// Returns a map with completion stats:
/// - 'total': Total number of treatment plans
/// - 'completed': Number of completed plans
/// - 'active': Number of active plans
/// - 'completionRate': Percentage of completed plans (0-100)
///
/// Usage:
/// ```dart
/// final stats = await ref.read(treatmentPlanStatsProvider('pet-id').future);
/// print('Completion rate: ${stats['completionRate']}%');
/// ```
///
/// Copied from [treatmentPlanStats].
class TreatmentPlanStatsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Get treatment plan completion statistics for a pet
  ///
  /// Returns a map with completion stats:
  /// - 'total': Total number of treatment plans
  /// - 'completed': Number of completed plans
  /// - 'active': Number of active plans
  /// - 'completionRate': Percentage of completed plans (0-100)
  ///
  /// Usage:
  /// ```dart
  /// final stats = await ref.read(treatmentPlanStatsProvider('pet-id').future);
  /// print('Completion rate: ${stats['completionRate']}%');
  /// ```
  ///
  /// Copied from [treatmentPlanStats].
  TreatmentPlanStatsProvider(
    String petId,
  ) : this._internal(
          (ref) => treatmentPlanStats(
            ref as TreatmentPlanStatsRef,
            petId,
          ),
          from: treatmentPlanStatsProvider,
          name: r'treatmentPlanStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$treatmentPlanStatsHash,
          dependencies: TreatmentPlanStatsFamily._dependencies,
          allTransitiveDependencies:
              TreatmentPlanStatsFamily._allTransitiveDependencies,
          petId: petId,
        );

  TreatmentPlanStatsProvider._internal(
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
    FutureOr<Map<String, dynamic>> Function(TreatmentPlanStatsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TreatmentPlanStatsProvider._internal(
        (ref) => create(ref as TreatmentPlanStatsRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _TreatmentPlanStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TreatmentPlanStatsProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TreatmentPlanStatsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _TreatmentPlanStatsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with TreatmentPlanStatsRef {
  _TreatmentPlanStatsProviderElement(super.provider);

  @override
  String get petId => (origin as TreatmentPlanStatsProvider).petId;
}

String _$treatmentPlansHash() => r'a5d56e81359839fe309cc98fb5ac66b2391f096e';

/// Main treatment plan provider - manages all treatment plans
///
/// Treatment plans are digital representations of veterinarian-prescribed
/// treatment protocols with task checklists for pet owners to follow.
///
/// Usage:
/// ```dart
/// final plans = await ref.read(treatmentPlansProvider.future);
/// ```
///
/// Copied from [TreatmentPlans].
@ProviderFor(TreatmentPlans)
final treatmentPlansProvider = AutoDisposeAsyncNotifierProvider<TreatmentPlans,
    List<TreatmentPlan>>.internal(
  TreatmentPlans.new,
  name: r'treatmentPlansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$treatmentPlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TreatmentPlans = AutoDisposeAsyncNotifier<List<TreatmentPlan>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
