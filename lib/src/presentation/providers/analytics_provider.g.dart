// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsServiceHash() => r'a83206491eb1366195b86b24fa7e813a2bcd18d2';

/// Provider for AnalyticsService instance
///
/// Copied from [analyticsService].
@ProviderFor(analyticsService)
final analyticsServiceProvider = AutoDisposeProvider<AnalyticsService>.internal(
  analyticsService,
  name: r'analyticsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AnalyticsServiceRef = AutoDisposeProviderRef<AnalyticsService>;
String _$healthScoreHash() => r'574aa1bf143a5b219ff43592e6e1305b0bbc9a62';

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

/// Provider for calculating health score for a pet over the last 30 days
///
/// Copied from [healthScore].
@ProviderFor(healthScore)
const healthScoreProvider = HealthScoreFamily();

/// Provider for calculating health score for a pet over the last 30 days
///
/// Copied from [healthScore].
class HealthScoreFamily extends Family<AsyncValue<double>> {
  /// Provider for calculating health score for a pet over the last 30 days
  ///
  /// Copied from [healthScore].
  const HealthScoreFamily();

  /// Provider for calculating health score for a pet over the last 30 days
  ///
  /// Copied from [healthScore].
  HealthScoreProvider call(
    String petId,
  ) {
    return HealthScoreProvider(
      petId,
    );
  }

  @override
  HealthScoreProvider getProviderOverride(
    covariant HealthScoreProvider provider,
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
  String? get name => r'healthScoreProvider';
}

/// Provider for calculating health score for a pet over the last 30 days
///
/// Copied from [healthScore].
class HealthScoreProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for calculating health score for a pet over the last 30 days
  ///
  /// Copied from [healthScore].
  HealthScoreProvider(
    String petId,
  ) : this._internal(
          (ref) => healthScore(
            ref as HealthScoreRef,
            petId,
          ),
          from: healthScoreProvider,
          name: r'healthScoreProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$healthScoreHash,
          dependencies: HealthScoreFamily._dependencies,
          allTransitiveDependencies:
              HealthScoreFamily._allTransitiveDependencies,
          petId: petId,
        );

  HealthScoreProvider._internal(
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
    FutureOr<double> Function(HealthScoreRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HealthScoreProvider._internal(
        (ref) => create(ref as HealthScoreRef),
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
  AutoDisposeFutureProviderElement<double> createElement() {
    return _HealthScoreProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HealthScoreProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HealthScoreRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _HealthScoreProviderElement
    extends AutoDisposeFutureProviderElement<double> with HealthScoreRef {
  _HealthScoreProviderElement(super.provider);

  @override
  String get petId => (origin as HealthScoreProvider).petId;
}

String _$medicationAdherenceHash() =>
    r'3bf3c14a0bbef4456ea25b5b2db6a8a480c3f472';

/// Provider for calculating medication adherence
///
/// Copied from [medicationAdherence].
@ProviderFor(medicationAdherence)
const medicationAdherenceProvider = MedicationAdherenceFamily();

/// Provider for calculating medication adherence
///
/// Copied from [medicationAdherence].
class MedicationAdherenceFamily extends Family<AsyncValue<double>> {
  /// Provider for calculating medication adherence
  ///
  /// Copied from [medicationAdherence].
  const MedicationAdherenceFamily();

  /// Provider for calculating medication adherence
  ///
  /// Copied from [medicationAdherence].
  MedicationAdherenceProvider call(
    ({int days, String petId}) params,
  ) {
    return MedicationAdherenceProvider(
      params,
    );
  }

  @override
  MedicationAdherenceProvider getProviderOverride(
    covariant MedicationAdherenceProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'medicationAdherenceProvider';
}

/// Provider for calculating medication adherence
///
/// Copied from [medicationAdherence].
class MedicationAdherenceProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for calculating medication adherence
  ///
  /// Copied from [medicationAdherence].
  MedicationAdherenceProvider(
    ({int days, String petId}) params,
  ) : this._internal(
          (ref) => medicationAdherence(
            ref as MedicationAdherenceRef,
            params,
          ),
          from: medicationAdherenceProvider,
          name: r'medicationAdherenceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$medicationAdherenceHash,
          dependencies: MedicationAdherenceFamily._dependencies,
          allTransitiveDependencies:
              MedicationAdherenceFamily._allTransitiveDependencies,
          params: params,
        );

  MedicationAdherenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final ({int days, String petId}) params;

  @override
  Override overrideWith(
    FutureOr<double> Function(MedicationAdherenceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MedicationAdherenceProvider._internal(
        (ref) => create(ref as MedicationAdherenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double> createElement() {
    return _MedicationAdherenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MedicationAdherenceProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MedicationAdherenceRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `params` of this provider.
  ({int days, String petId}) get params;
}

class _MedicationAdherenceProviderElement
    extends AutoDisposeFutureProviderElement<double>
    with MedicationAdherenceRef {
  _MedicationAdherenceProviderElement(super.provider);

  @override
  ({int days, String petId}) get params =>
      (origin as MedicationAdherenceProvider).params;
}

String _$activityLevelsHash() => r'84551ae9f120fc7823263bd6f2605da2b33f36a8';

/// Provider for activity levels
///
/// Copied from [activityLevels].
@ProviderFor(activityLevels)
const activityLevelsProvider = ActivityLevelsFamily();

/// Provider for activity levels
///
/// Copied from [activityLevels].
class ActivityLevelsFamily extends Family<AsyncValue<Map<String, double>>> {
  /// Provider for activity levels
  ///
  /// Copied from [activityLevels].
  const ActivityLevelsFamily();

  /// Provider for activity levels
  ///
  /// Copied from [activityLevels].
  ActivityLevelsProvider call(
    ({int days, String petId}) params,
  ) {
    return ActivityLevelsProvider(
      params,
    );
  }

  @override
  ActivityLevelsProvider getProviderOverride(
    covariant ActivityLevelsProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'activityLevelsProvider';
}

/// Provider for activity levels
///
/// Copied from [activityLevels].
class ActivityLevelsProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Provider for activity levels
  ///
  /// Copied from [activityLevels].
  ActivityLevelsProvider(
    ({int days, String petId}) params,
  ) : this._internal(
          (ref) => activityLevels(
            ref as ActivityLevelsRef,
            params,
          ),
          from: activityLevelsProvider,
          name: r'activityLevelsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activityLevelsHash,
          dependencies: ActivityLevelsFamily._dependencies,
          allTransitiveDependencies:
              ActivityLevelsFamily._allTransitiveDependencies,
          params: params,
        );

  ActivityLevelsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final ({int days, String petId}) params;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(ActivityLevelsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActivityLevelsProvider._internal(
        (ref) => create(ref as ActivityLevelsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _ActivityLevelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityLevelsProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ActivityLevelsRef on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `params` of this provider.
  ({int days, String petId}) get params;
}

class _ActivityLevelsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with ActivityLevelsRef {
  _ActivityLevelsProviderElement(super.provider);

  @override
  ({int days, String petId}) get params =>
      (origin as ActivityLevelsProvider).params;
}

String _$weightTrendHash() => r'd8481db73ec1d822b59fbcd205c78bfc0f890251';

/// Provider for weight trend analysis
///
/// Copied from [weightTrend].
@ProviderFor(weightTrend)
const weightTrendProvider = WeightTrendFamily();

/// Provider for weight trend analysis
///
/// Copied from [weightTrend].
class WeightTrendFamily extends Family<String> {
  /// Provider for weight trend analysis
  ///
  /// Copied from [weightTrend].
  const WeightTrendFamily();

  /// Provider for weight trend analysis
  ///
  /// Copied from [weightTrend].
  WeightTrendProvider call(
    String petId,
  ) {
    return WeightTrendProvider(
      petId,
    );
  }

  @override
  WeightTrendProvider getProviderOverride(
    covariant WeightTrendProvider provider,
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
  String? get name => r'weightTrendProvider';
}

/// Provider for weight trend analysis
///
/// Copied from [weightTrend].
class WeightTrendProvider extends AutoDisposeProvider<String> {
  /// Provider for weight trend analysis
  ///
  /// Copied from [weightTrend].
  WeightTrendProvider(
    String petId,
  ) : this._internal(
          (ref) => weightTrend(
            ref as WeightTrendRef,
            petId,
          ),
          from: weightTrendProvider,
          name: r'weightTrendProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$weightTrendHash,
          dependencies: WeightTrendFamily._dependencies,
          allTransitiveDependencies:
              WeightTrendFamily._allTransitiveDependencies,
          petId: petId,
        );

  WeightTrendProvider._internal(
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
    String Function(WeightTrendRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeightTrendProvider._internal(
        (ref) => create(ref as WeightTrendRef),
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
  AutoDisposeProviderElement<String> createElement() {
    return _WeightTrendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeightTrendProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WeightTrendRef on AutoDisposeProviderRef<String> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _WeightTrendProviderElement extends AutoDisposeProviderElement<String>
    with WeightTrendRef {
  _WeightTrendProviderElement(super.provider);

  @override
  String get petId => (origin as WeightTrendProvider).petId;
}

String _$totalExpensesHash() => r'922dc8f599e0c1dccd606bc95eb36a9c7ede1370';

/// Provider for total expenses in date range
///
/// Copied from [totalExpenses].
@ProviderFor(totalExpenses)
const totalExpensesProvider = TotalExpensesFamily();

/// Provider for total expenses in date range
///
/// Copied from [totalExpenses].
class TotalExpensesFamily extends Family<AsyncValue<double>> {
  /// Provider for total expenses in date range
  ///
  /// Copied from [totalExpenses].
  const TotalExpensesFamily();

  /// Provider for total expenses in date range
  ///
  /// Copied from [totalExpenses].
  TotalExpensesProvider call(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return TotalExpensesProvider(
      petId,
      startDate,
      endDate,
    );
  }

  @override
  TotalExpensesProvider getProviderOverride(
    covariant TotalExpensesProvider provider,
  ) {
    return call(
      provider.petId,
      provider.startDate,
      provider.endDate,
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
  String? get name => r'totalExpensesProvider';
}

/// Provider for total expenses in date range
///
/// Copied from [totalExpenses].
class TotalExpensesProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for total expenses in date range
  ///
  /// Copied from [totalExpenses].
  TotalExpensesProvider(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
          (ref) => totalExpenses(
            ref as TotalExpensesRef,
            petId,
            startDate,
            endDate,
          ),
          from: totalExpensesProvider,
          name: r'totalExpensesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$totalExpensesHash,
          dependencies: TotalExpensesFamily._dependencies,
          allTransitiveDependencies:
              TotalExpensesFamily._allTransitiveDependencies,
          petId: petId,
          startDate: startDate,
          endDate: endDate,
        );

  TotalExpensesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String petId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<double> Function(TotalExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TotalExpensesProvider._internal(
        (ref) => create(ref as TotalExpensesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double> createElement() {
    return _TotalExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalExpensesProvider &&
        other.petId == petId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TotalExpensesRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _TotalExpensesProviderElement
    extends AutoDisposeFutureProviderElement<double> with TotalExpensesRef {
  _TotalExpensesProviderElement(super.provider);

  @override
  String get petId => (origin as TotalExpensesProvider).petId;
  @override
  DateTime get startDate => (origin as TotalExpensesProvider).startDate;
  @override
  DateTime get endDate => (origin as TotalExpensesProvider).endDate;
}

String _$expenseBreakdownHash() => r'ea50caeb0445c3e7e1af036953d763e7178ec3b9';

/// Provider for expense breakdown by category
///
/// Copied from [expenseBreakdown].
@ProviderFor(expenseBreakdown)
const expenseBreakdownProvider = ExpenseBreakdownFamily();

/// Provider for expense breakdown by category
///
/// Copied from [expenseBreakdown].
class ExpenseBreakdownFamily extends Family<AsyncValue<Map<String, double>>> {
  /// Provider for expense breakdown by category
  ///
  /// Copied from [expenseBreakdown].
  const ExpenseBreakdownFamily();

  /// Provider for expense breakdown by category
  ///
  /// Copied from [expenseBreakdown].
  ExpenseBreakdownProvider call(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return ExpenseBreakdownProvider(
      petId,
      startDate,
      endDate,
    );
  }

  @override
  ExpenseBreakdownProvider getProviderOverride(
    covariant ExpenseBreakdownProvider provider,
  ) {
    return call(
      provider.petId,
      provider.startDate,
      provider.endDate,
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
  String? get name => r'expenseBreakdownProvider';
}

/// Provider for expense breakdown by category
///
/// Copied from [expenseBreakdown].
class ExpenseBreakdownProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Provider for expense breakdown by category
  ///
  /// Copied from [expenseBreakdown].
  ExpenseBreakdownProvider(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
          (ref) => expenseBreakdown(
            ref as ExpenseBreakdownRef,
            petId,
            startDate,
            endDate,
          ),
          from: expenseBreakdownProvider,
          name: r'expenseBreakdownProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$expenseBreakdownHash,
          dependencies: ExpenseBreakdownFamily._dependencies,
          allTransitiveDependencies:
              ExpenseBreakdownFamily._allTransitiveDependencies,
          petId: petId,
          startDate: startDate,
          endDate: endDate,
        );

  ExpenseBreakdownProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String petId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(ExpenseBreakdownRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpenseBreakdownProvider._internal(
        (ref) => create(ref as ExpenseBreakdownRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _ExpenseBreakdownProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseBreakdownProvider &&
        other.petId == petId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ExpenseBreakdownRef on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _ExpenseBreakdownProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with ExpenseBreakdownRef {
  _ExpenseBreakdownProviderElement(super.provider);

  @override
  String get petId => (origin as ExpenseBreakdownProvider).petId;
  @override
  DateTime get startDate => (origin as ExpenseBreakdownProvider).startDate;
  @override
  DateTime get endDate => (origin as ExpenseBreakdownProvider).endDate;
}

String _$averageWeeklyExpensesHash() =>
    r'2cfd2adf34ed197ec33191121254e923bbe77852';

/// Provider for average weekly expenses
///
/// Copied from [averageWeeklyExpenses].
@ProviderFor(averageWeeklyExpenses)
const averageWeeklyExpensesProvider = AverageWeeklyExpensesFamily();

/// Provider for average weekly expenses
///
/// Copied from [averageWeeklyExpenses].
class AverageWeeklyExpensesFamily extends Family<AsyncValue<double>> {
  /// Provider for average weekly expenses
  ///
  /// Copied from [averageWeeklyExpenses].
  const AverageWeeklyExpensesFamily();

  /// Provider for average weekly expenses
  ///
  /// Copied from [averageWeeklyExpenses].
  AverageWeeklyExpensesProvider call(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return AverageWeeklyExpensesProvider(
      petId,
      startDate,
      endDate,
    );
  }

  @override
  AverageWeeklyExpensesProvider getProviderOverride(
    covariant AverageWeeklyExpensesProvider provider,
  ) {
    return call(
      provider.petId,
      provider.startDate,
      provider.endDate,
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
  String? get name => r'averageWeeklyExpensesProvider';
}

/// Provider for average weekly expenses
///
/// Copied from [averageWeeklyExpenses].
class AverageWeeklyExpensesProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for average weekly expenses
  ///
  /// Copied from [averageWeeklyExpenses].
  AverageWeeklyExpensesProvider(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
          (ref) => averageWeeklyExpenses(
            ref as AverageWeeklyExpensesRef,
            petId,
            startDate,
            endDate,
          ),
          from: averageWeeklyExpensesProvider,
          name: r'averageWeeklyExpensesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$averageWeeklyExpensesHash,
          dependencies: AverageWeeklyExpensesFamily._dependencies,
          allTransitiveDependencies:
              AverageWeeklyExpensesFamily._allTransitiveDependencies,
          petId: petId,
          startDate: startDate,
          endDate: endDate,
        );

  AverageWeeklyExpensesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String petId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<double> Function(AverageWeeklyExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AverageWeeklyExpensesProvider._internal(
        (ref) => create(ref as AverageWeeklyExpensesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<double> createElement() {
    return _AverageWeeklyExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AverageWeeklyExpensesProvider &&
        other.petId == petId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AverageWeeklyExpensesRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _AverageWeeklyExpensesProviderElement
    extends AutoDisposeFutureProviderElement<double>
    with AverageWeeklyExpensesRef {
  _AverageWeeklyExpensesProviderElement(super.provider);

  @override
  String get petId => (origin as AverageWeeklyExpensesProvider).petId;
  @override
  DateTime get startDate => (origin as AverageWeeklyExpensesProvider).startDate;
  @override
  DateTime get endDate => (origin as AverageWeeklyExpensesProvider).endDate;
}

String _$monthlyExpensesHash() => r'77f48f6251088b83b38ce232ad788f65c1388dfb';

/// Provider for monthly expenses (current month)
///
/// Copied from [monthlyExpenses].
@ProviderFor(monthlyExpenses)
const monthlyExpensesProvider = MonthlyExpensesFamily();

/// Provider for monthly expenses (current month)
///
/// Copied from [monthlyExpenses].
class MonthlyExpensesFamily extends Family<AsyncValue<double>> {
  /// Provider for monthly expenses (current month)
  ///
  /// Copied from [monthlyExpenses].
  const MonthlyExpensesFamily();

  /// Provider for monthly expenses (current month)
  ///
  /// Copied from [monthlyExpenses].
  MonthlyExpensesProvider call(
    String petId,
  ) {
    return MonthlyExpensesProvider(
      petId,
    );
  }

  @override
  MonthlyExpensesProvider getProviderOverride(
    covariant MonthlyExpensesProvider provider,
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
  String? get name => r'monthlyExpensesProvider';
}

/// Provider for monthly expenses (current month)
///
/// Copied from [monthlyExpenses].
class MonthlyExpensesProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for monthly expenses (current month)
  ///
  /// Copied from [monthlyExpenses].
  MonthlyExpensesProvider(
    String petId,
  ) : this._internal(
          (ref) => monthlyExpenses(
            ref as MonthlyExpensesRef,
            petId,
          ),
          from: monthlyExpensesProvider,
          name: r'monthlyExpensesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyExpensesHash,
          dependencies: MonthlyExpensesFamily._dependencies,
          allTransitiveDependencies:
              MonthlyExpensesFamily._allTransitiveDependencies,
          petId: petId,
        );

  MonthlyExpensesProvider._internal(
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
    FutureOr<double> Function(MonthlyExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyExpensesProvider._internal(
        (ref) => create(ref as MonthlyExpensesRef),
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
  AutoDisposeFutureProviderElement<double> createElement() {
    return _MonthlyExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyExpensesProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonthlyExpensesRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _MonthlyExpensesProviderElement
    extends AutoDisposeFutureProviderElement<double> with MonthlyExpensesRef {
  _MonthlyExpensesProviderElement(super.provider);

  @override
  String get petId => (origin as MonthlyExpensesProvider).petId;
}

String _$expensesByCategoryHash() =>
    r'0d9ab434d9425b30bca62a4046a4be8a0f39cd6f';

/// Provider for expenses by category
///
/// Copied from [expensesByCategory].
@ProviderFor(expensesByCategory)
const expensesByCategoryProvider = ExpensesByCategoryFamily();

/// Provider for expenses by category
///
/// Copied from [expensesByCategory].
class ExpensesByCategoryFamily extends Family<AsyncValue<Map<String, double>>> {
  /// Provider for expenses by category
  ///
  /// Copied from [expensesByCategory].
  const ExpensesByCategoryFamily();

  /// Provider for expenses by category
  ///
  /// Copied from [expensesByCategory].
  ExpensesByCategoryProvider call(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return ExpensesByCategoryProvider(
      petId,
      startDate,
      endDate,
    );
  }

  @override
  ExpensesByCategoryProvider getProviderOverride(
    covariant ExpensesByCategoryProvider provider,
  ) {
    return call(
      provider.petId,
      provider.startDate,
      provider.endDate,
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
  String? get name => r'expensesByCategoryProvider';
}

/// Provider for expenses by category
///
/// Copied from [expensesByCategory].
class ExpensesByCategoryProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Provider for expenses by category
  ///
  /// Copied from [expensesByCategory].
  ExpensesByCategoryProvider(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
          (ref) => expensesByCategory(
            ref as ExpensesByCategoryRef,
            petId,
            startDate,
            endDate,
          ),
          from: expensesByCategoryProvider,
          name: r'expensesByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$expensesByCategoryHash,
          dependencies: ExpensesByCategoryFamily._dependencies,
          allTransitiveDependencies:
              ExpensesByCategoryFamily._allTransitiveDependencies,
          petId: petId,
          startDate: startDate,
          endDate: endDate,
        );

  ExpensesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String petId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(ExpensesByCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpensesByCategoryProvider._internal(
        (ref) => create(ref as ExpensesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _ExpensesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpensesByCategoryProvider &&
        other.petId == petId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ExpensesByCategoryRef
    on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _ExpensesByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with ExpensesByCategoryRef {
  _ExpensesByCategoryProviderElement(super.provider);

  @override
  String get petId => (origin as ExpensesByCategoryProvider).petId;
  @override
  DateTime get startDate => (origin as ExpensesByCategoryProvider).startDate;
  @override
  DateTime get endDate => (origin as ExpensesByCategoryProvider).endDate;
}

String _$averageMonthlyExpenseHash() =>
    r'f3fcd099c3ffdfab678204a40ab695dc4b5104dd';

/// Provider for average monthly expenses (last 6 months)
///
/// Copied from [averageMonthlyExpense].
@ProviderFor(averageMonthlyExpense)
const averageMonthlyExpenseProvider = AverageMonthlyExpenseFamily();

/// Provider for average monthly expenses (last 6 months)
///
/// Copied from [averageMonthlyExpense].
class AverageMonthlyExpenseFamily extends Family<AsyncValue<double>> {
  /// Provider for average monthly expenses (last 6 months)
  ///
  /// Copied from [averageMonthlyExpense].
  const AverageMonthlyExpenseFamily();

  /// Provider for average monthly expenses (last 6 months)
  ///
  /// Copied from [averageMonthlyExpense].
  AverageMonthlyExpenseProvider call(
    String petId,
  ) {
    return AverageMonthlyExpenseProvider(
      petId,
    );
  }

  @override
  AverageMonthlyExpenseProvider getProviderOverride(
    covariant AverageMonthlyExpenseProvider provider,
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
  String? get name => r'averageMonthlyExpenseProvider';
}

/// Provider for average monthly expenses (last 6 months)
///
/// Copied from [averageMonthlyExpense].
class AverageMonthlyExpenseProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for average monthly expenses (last 6 months)
  ///
  /// Copied from [averageMonthlyExpense].
  AverageMonthlyExpenseProvider(
    String petId,
  ) : this._internal(
          (ref) => averageMonthlyExpense(
            ref as AverageMonthlyExpenseRef,
            petId,
          ),
          from: averageMonthlyExpenseProvider,
          name: r'averageMonthlyExpenseProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$averageMonthlyExpenseHash,
          dependencies: AverageMonthlyExpenseFamily._dependencies,
          allTransitiveDependencies:
              AverageMonthlyExpenseFamily._allTransitiveDependencies,
          petId: petId,
        );

  AverageMonthlyExpenseProvider._internal(
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
    FutureOr<double> Function(AverageMonthlyExpenseRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AverageMonthlyExpenseProvider._internal(
        (ref) => create(ref as AverageMonthlyExpenseRef),
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
  AutoDisposeFutureProviderElement<double> createElement() {
    return _AverageMonthlyExpenseProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AverageMonthlyExpenseProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AverageMonthlyExpenseRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _AverageMonthlyExpenseProviderElement
    extends AutoDisposeFutureProviderElement<double>
    with AverageMonthlyExpenseRef {
  _AverageMonthlyExpenseProviderElement(super.provider);

  @override
  String get petId => (origin as AverageMonthlyExpenseProvider).petId;
}

String _$monthlyExpensesChartHash() =>
    r'e030d181e3159f831e30cbf80d07855932225f21';

/// Provider for monthly expenses chart data
///
/// Copied from [monthlyExpensesChart].
@ProviderFor(monthlyExpensesChart)
const monthlyExpensesChartProvider = MonthlyExpensesChartFamily();

/// Provider for monthly expenses chart data
///
/// Copied from [monthlyExpensesChart].
class MonthlyExpensesChartFamily
    extends Family<AsyncValue<Map<String, double>>> {
  /// Provider for monthly expenses chart data
  ///
  /// Copied from [monthlyExpensesChart].
  const MonthlyExpensesChartFamily();

  /// Provider for monthly expenses chart data
  ///
  /// Copied from [monthlyExpensesChart].
  MonthlyExpensesChartProvider call(
    String petId,
    int numberOfMonths,
  ) {
    return MonthlyExpensesChartProvider(
      petId,
      numberOfMonths,
    );
  }

  @override
  MonthlyExpensesChartProvider getProviderOverride(
    covariant MonthlyExpensesChartProvider provider,
  ) {
    return call(
      provider.petId,
      provider.numberOfMonths,
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
  String? get name => r'monthlyExpensesChartProvider';
}

/// Provider for monthly expenses chart data
///
/// Copied from [monthlyExpensesChart].
class MonthlyExpensesChartProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Provider for monthly expenses chart data
  ///
  /// Copied from [monthlyExpensesChart].
  MonthlyExpensesChartProvider(
    String petId,
    int numberOfMonths,
  ) : this._internal(
          (ref) => monthlyExpensesChart(
            ref as MonthlyExpensesChartRef,
            petId,
            numberOfMonths,
          ),
          from: monthlyExpensesChartProvider,
          name: r'monthlyExpensesChartProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthlyExpensesChartHash,
          dependencies: MonthlyExpensesChartFamily._dependencies,
          allTransitiveDependencies:
              MonthlyExpensesChartFamily._allTransitiveDependencies,
          petId: petId,
          numberOfMonths: numberOfMonths,
        );

  MonthlyExpensesChartProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.numberOfMonths,
  }) : super.internal();

  final String petId;
  final int numberOfMonths;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(MonthlyExpensesChartRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyExpensesChartProvider._internal(
        (ref) => create(ref as MonthlyExpensesChartRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        numberOfMonths: numberOfMonths,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _MonthlyExpensesChartProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyExpensesChartProvider &&
        other.petId == petId &&
        other.numberOfMonths == numberOfMonths;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, numberOfMonths.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonthlyExpensesChartRef
    on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `numberOfMonths` of this provider.
  int get numberOfMonths;
}

class _MonthlyExpensesChartProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with MonthlyExpensesChartRef {
  _MonthlyExpensesChartProviderElement(super.provider);

  @override
  String get petId => (origin as MonthlyExpensesChartProvider).petId;
  @override
  int get numberOfMonths =>
      (origin as MonthlyExpensesChartProvider).numberOfMonths;
}

String _$topExpenseCategoriesHash() =>
    r'b2069c0d45f0bb343bce545233e442f4aa4abccd';

/// Provider for top expense categories
///
/// Copied from [topExpenseCategories].
@ProviderFor(topExpenseCategories)
const topExpenseCategoriesProvider = TopExpenseCategoriesFamily();

/// Provider for top expense categories
///
/// Copied from [topExpenseCategories].
class TopExpenseCategoriesFamily extends Family<AsyncValue<List<String>>> {
  /// Provider for top expense categories
  ///
  /// Copied from [topExpenseCategories].
  const TopExpenseCategoriesFamily();

  /// Provider for top expense categories
  ///
  /// Copied from [topExpenseCategories].
  TopExpenseCategoriesProvider call(
    String petId,
  ) {
    return TopExpenseCategoriesProvider(
      petId,
    );
  }

  @override
  TopExpenseCategoriesProvider getProviderOverride(
    covariant TopExpenseCategoriesProvider provider,
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
  String? get name => r'topExpenseCategoriesProvider';
}

/// Provider for top expense categories
///
/// Copied from [topExpenseCategories].
class TopExpenseCategoriesProvider
    extends AutoDisposeFutureProvider<List<String>> {
  /// Provider for top expense categories
  ///
  /// Copied from [topExpenseCategories].
  TopExpenseCategoriesProvider(
    String petId,
  ) : this._internal(
          (ref) => topExpenseCategories(
            ref as TopExpenseCategoriesRef,
            petId,
          ),
          from: topExpenseCategoriesProvider,
          name: r'topExpenseCategoriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$topExpenseCategoriesHash,
          dependencies: TopExpenseCategoriesFamily._dependencies,
          allTransitiveDependencies:
              TopExpenseCategoriesFamily._allTransitiveDependencies,
          petId: petId,
        );

  TopExpenseCategoriesProvider._internal(
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
    FutureOr<List<String>> Function(TopExpenseCategoriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TopExpenseCategoriesProvider._internal(
        (ref) => create(ref as TopExpenseCategoriesRef),
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
    return _TopExpenseCategoriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TopExpenseCategoriesProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TopExpenseCategoriesRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _TopExpenseCategoriesProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with TopExpenseCategoriesRef {
  _TopExpenseCategoriesProviderElement(super.provider);

  @override
  String get petId => (origin as TopExpenseCategoriesProvider).petId;
}

String _$expenseTrendHash() => r'0ac83e6c120cb38aa4c089ce9962961e8c96580e';

/// Provider for expense trend
///
/// Copied from [expenseTrend].
@ProviderFor(expenseTrend)
const expenseTrendProvider = ExpenseTrendFamily();

/// Provider for expense trend
///
/// Copied from [expenseTrend].
class ExpenseTrendFamily extends Family<AsyncValue<String>> {
  /// Provider for expense trend
  ///
  /// Copied from [expenseTrend].
  const ExpenseTrendFamily();

  /// Provider for expense trend
  ///
  /// Copied from [expenseTrend].
  ExpenseTrendProvider call(
    String petId,
  ) {
    return ExpenseTrendProvider(
      petId,
    );
  }

  @override
  ExpenseTrendProvider getProviderOverride(
    covariant ExpenseTrendProvider provider,
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
  String? get name => r'expenseTrendProvider';
}

/// Provider for expense trend
///
/// Copied from [expenseTrend].
class ExpenseTrendProvider extends AutoDisposeFutureProvider<String> {
  /// Provider for expense trend
  ///
  /// Copied from [expenseTrend].
  ExpenseTrendProvider(
    String petId,
  ) : this._internal(
          (ref) => expenseTrend(
            ref as ExpenseTrendRef,
            petId,
          ),
          from: expenseTrendProvider,
          name: r'expenseTrendProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$expenseTrendHash,
          dependencies: ExpenseTrendFamily._dependencies,
          allTransitiveDependencies:
              ExpenseTrendFamily._allTransitiveDependencies,
          petId: petId,
        );

  ExpenseTrendProvider._internal(
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
    FutureOr<String> Function(ExpenseTrendRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExpenseTrendProvider._internal(
        (ref) => create(ref as ExpenseTrendRef),
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
  AutoDisposeFutureProviderElement<String> createElement() {
    return _ExpenseTrendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseTrendProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ExpenseTrendRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _ExpenseTrendProviderElement
    extends AutoDisposeFutureProviderElement<String> with ExpenseTrendRef {
  _ExpenseTrendProviderElement(super.provider);

  @override
  String get petId => (origin as ExpenseTrendProvider).petId;
}

String _$pdfExportServiceHash() => r'3a1fe23405684e5ca7bbdf1ea771ef7711aefb0b';

/// Provider for PDFExportService instance
///
/// Copied from [pdfExportService].
@ProviderFor(pdfExportService)
final pdfExportServiceProvider = AutoDisposeProvider<PDFExportService>.internal(
  pdfExportService,
  name: r'pdfExportServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pdfExportServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PdfExportServiceRef = AutoDisposeProviderRef<PDFExportService>;
String _$recommendationsServiceHash() =>
    r'a1ec88440148f2d5879b7824efab41e0028d4aa5';

/// Provider for RecommendationsService instance
///
/// Copied from [recommendationsService].
@ProviderFor(recommendationsService)
final recommendationsServiceProvider =
    AutoDisposeProvider<RecommendationsService>.internal(
  recommendationsService,
  name: r'recommendationsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recommendationsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecommendationsServiceRef
    = AutoDisposeProviderRef<RecommendationsService>;
String _$recommendationsHash() => r'd553788e99deaee0a7d3a860dbfec7467564c3b7';

/// Provider for pet recommendations
///
/// Copied from [recommendations].
@ProviderFor(recommendations)
const recommendationsProvider = RecommendationsFamily();

/// Provider for pet recommendations
///
/// Copied from [recommendations].
class RecommendationsFamily extends Family<AsyncValue<List<String>>> {
  /// Provider for pet recommendations
  ///
  /// Copied from [recommendations].
  const RecommendationsFamily();

  /// Provider for pet recommendations
  ///
  /// Copied from [recommendations].
  RecommendationsProvider call(
    String petId,
  ) {
    return RecommendationsProvider(
      petId,
    );
  }

  @override
  RecommendationsProvider getProviderOverride(
    covariant RecommendationsProvider provider,
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
  String? get name => r'recommendationsProvider';
}

/// Provider for pet recommendations
///
/// Copied from [recommendations].
class RecommendationsProvider extends AutoDisposeFutureProvider<List<String>> {
  /// Provider for pet recommendations
  ///
  /// Copied from [recommendations].
  RecommendationsProvider(
    String petId,
  ) : this._internal(
          (ref) => recommendations(
            ref as RecommendationsRef,
            petId,
          ),
          from: recommendationsProvider,
          name: r'recommendationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recommendationsHash,
          dependencies: RecommendationsFamily._dependencies,
          allTransitiveDependencies:
              RecommendationsFamily._allTransitiveDependencies,
          petId: petId,
        );

  RecommendationsProvider._internal(
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
    FutureOr<List<String>> Function(RecommendationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecommendationsProvider._internal(
        (ref) => create(ref as RecommendationsRef),
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
    return _RecommendationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendationsProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RecommendationsRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _RecommendationsProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with RecommendationsRef {
  _RecommendationsProviderElement(super.provider);

  @override
  String get petId => (origin as RecommendationsProvider).petId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
