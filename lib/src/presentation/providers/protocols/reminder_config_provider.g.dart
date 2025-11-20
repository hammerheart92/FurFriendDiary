// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reminderConfigByPetIdAndEventTypeHash() =>
    r'db5a426e258beb36f2668fc49b0542c6ce6317e5';

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

/// Get reminder configuration for a specific pet and event type
///
/// Returns null if no configuration exists. Use `getOrCreateDefault` on the
/// main provider to get or create a default configuration.
///
/// Usage:
/// ```dart
/// final config = await ref.read(reminderConfigByPetIdAndEventTypeProvider(
///   petId: 'pet-123',
///   eventType: 'vaccination',
/// ).future);
/// ```
///
/// Copied from [reminderConfigByPetIdAndEventType].
@ProviderFor(reminderConfigByPetIdAndEventType)
const reminderConfigByPetIdAndEventTypeProvider =
    ReminderConfigByPetIdAndEventTypeFamily();

/// Get reminder configuration for a specific pet and event type
///
/// Returns null if no configuration exists. Use `getOrCreateDefault` on the
/// main provider to get or create a default configuration.
///
/// Usage:
/// ```dart
/// final config = await ref.read(reminderConfigByPetIdAndEventTypeProvider(
///   petId: 'pet-123',
///   eventType: 'vaccination',
/// ).future);
/// ```
///
/// Copied from [reminderConfigByPetIdAndEventType].
class ReminderConfigByPetIdAndEventTypeFamily
    extends Family<AsyncValue<ReminderConfig?>> {
  /// Get reminder configuration for a specific pet and event type
  ///
  /// Returns null if no configuration exists. Use `getOrCreateDefault` on the
  /// main provider to get or create a default configuration.
  ///
  /// Usage:
  /// ```dart
  /// final config = await ref.read(reminderConfigByPetIdAndEventTypeProvider(
  ///   petId: 'pet-123',
  ///   eventType: 'vaccination',
  /// ).future);
  /// ```
  ///
  /// Copied from [reminderConfigByPetIdAndEventType].
  const ReminderConfigByPetIdAndEventTypeFamily();

  /// Get reminder configuration for a specific pet and event type
  ///
  /// Returns null if no configuration exists. Use `getOrCreateDefault` on the
  /// main provider to get or create a default configuration.
  ///
  /// Usage:
  /// ```dart
  /// final config = await ref.read(reminderConfigByPetIdAndEventTypeProvider(
  ///   petId: 'pet-123',
  ///   eventType: 'vaccination',
  /// ).future);
  /// ```
  ///
  /// Copied from [reminderConfigByPetIdAndEventType].
  ReminderConfigByPetIdAndEventTypeProvider call({
    required String petId,
    required String eventType,
  }) {
    return ReminderConfigByPetIdAndEventTypeProvider(
      petId: petId,
      eventType: eventType,
    );
  }

  @override
  ReminderConfigByPetIdAndEventTypeProvider getProviderOverride(
    covariant ReminderConfigByPetIdAndEventTypeProvider provider,
  ) {
    return call(
      petId: provider.petId,
      eventType: provider.eventType,
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
  String? get name => r'reminderConfigByPetIdAndEventTypeProvider';
}

/// Get reminder configuration for a specific pet and event type
///
/// Returns null if no configuration exists. Use `getOrCreateDefault` on the
/// main provider to get or create a default configuration.
///
/// Usage:
/// ```dart
/// final config = await ref.read(reminderConfigByPetIdAndEventTypeProvider(
///   petId: 'pet-123',
///   eventType: 'vaccination',
/// ).future);
/// ```
///
/// Copied from [reminderConfigByPetIdAndEventType].
class ReminderConfigByPetIdAndEventTypeProvider
    extends AutoDisposeFutureProvider<ReminderConfig?> {
  /// Get reminder configuration for a specific pet and event type
  ///
  /// Returns null if no configuration exists. Use `getOrCreateDefault` on the
  /// main provider to get or create a default configuration.
  ///
  /// Usage:
  /// ```dart
  /// final config = await ref.read(reminderConfigByPetIdAndEventTypeProvider(
  ///   petId: 'pet-123',
  ///   eventType: 'vaccination',
  /// ).future);
  /// ```
  ///
  /// Copied from [reminderConfigByPetIdAndEventType].
  ReminderConfigByPetIdAndEventTypeProvider({
    required String petId,
    required String eventType,
  }) : this._internal(
          (ref) => reminderConfigByPetIdAndEventType(
            ref as ReminderConfigByPetIdAndEventTypeRef,
            petId: petId,
            eventType: eventType,
          ),
          from: reminderConfigByPetIdAndEventTypeProvider,
          name: r'reminderConfigByPetIdAndEventTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reminderConfigByPetIdAndEventTypeHash,
          dependencies: ReminderConfigByPetIdAndEventTypeFamily._dependencies,
          allTransitiveDependencies: ReminderConfigByPetIdAndEventTypeFamily
              ._allTransitiveDependencies,
          petId: petId,
          eventType: eventType,
        );

  ReminderConfigByPetIdAndEventTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.eventType,
  }) : super.internal();

  final String petId;
  final String eventType;

  @override
  Override overrideWith(
    FutureOr<ReminderConfig?> Function(
            ReminderConfigByPetIdAndEventTypeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReminderConfigByPetIdAndEventTypeProvider._internal(
        (ref) => create(ref as ReminderConfigByPetIdAndEventTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        eventType: eventType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ReminderConfig?> createElement() {
    return _ReminderConfigByPetIdAndEventTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderConfigByPetIdAndEventTypeProvider &&
        other.petId == petId &&
        other.eventType == eventType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, eventType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReminderConfigByPetIdAndEventTypeRef
    on AutoDisposeFutureProviderRef<ReminderConfig?> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `eventType` of this provider.
  String get eventType;
}

class _ReminderConfigByPetIdAndEventTypeProviderElement
    extends AutoDisposeFutureProviderElement<ReminderConfig?>
    with ReminderConfigByPetIdAndEventTypeRef {
  _ReminderConfigByPetIdAndEventTypeProviderElement(super.provider);

  @override
  String get petId =>
      (origin as ReminderConfigByPetIdAndEventTypeProvider).petId;
  @override
  String get eventType =>
      (origin as ReminderConfigByPetIdAndEventTypeProvider).eventType;
}

String _$reminderConfigsByEventTypeHash() =>
    r'dc45501d358eadf855088d8e337558336935f835';

/// Get all reminder configurations for a specific event type
///
/// Usage:
/// ```dart
/// final vaccinationConfigs = await ref.read(
///   reminderConfigsByEventTypeProvider('vaccination').future
/// );
/// ```
///
/// Copied from [reminderConfigsByEventType].
@ProviderFor(reminderConfigsByEventType)
const reminderConfigsByEventTypeProvider = ReminderConfigsByEventTypeFamily();

/// Get all reminder configurations for a specific event type
///
/// Usage:
/// ```dart
/// final vaccinationConfigs = await ref.read(
///   reminderConfigsByEventTypeProvider('vaccination').future
/// );
/// ```
///
/// Copied from [reminderConfigsByEventType].
class ReminderConfigsByEventTypeFamily
    extends Family<AsyncValue<List<ReminderConfig>>> {
  /// Get all reminder configurations for a specific event type
  ///
  /// Usage:
  /// ```dart
  /// final vaccinationConfigs = await ref.read(
  ///   reminderConfigsByEventTypeProvider('vaccination').future
  /// );
  /// ```
  ///
  /// Copied from [reminderConfigsByEventType].
  const ReminderConfigsByEventTypeFamily();

  /// Get all reminder configurations for a specific event type
  ///
  /// Usage:
  /// ```dart
  /// final vaccinationConfigs = await ref.read(
  ///   reminderConfigsByEventTypeProvider('vaccination').future
  /// );
  /// ```
  ///
  /// Copied from [reminderConfigsByEventType].
  ReminderConfigsByEventTypeProvider call(
    String eventType,
  ) {
    return ReminderConfigsByEventTypeProvider(
      eventType,
    );
  }

  @override
  ReminderConfigsByEventTypeProvider getProviderOverride(
    covariant ReminderConfigsByEventTypeProvider provider,
  ) {
    return call(
      provider.eventType,
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
  String? get name => r'reminderConfigsByEventTypeProvider';
}

/// Get all reminder configurations for a specific event type
///
/// Usage:
/// ```dart
/// final vaccinationConfigs = await ref.read(
///   reminderConfigsByEventTypeProvider('vaccination').future
/// );
/// ```
///
/// Copied from [reminderConfigsByEventType].
class ReminderConfigsByEventTypeProvider
    extends AutoDisposeFutureProvider<List<ReminderConfig>> {
  /// Get all reminder configurations for a specific event type
  ///
  /// Usage:
  /// ```dart
  /// final vaccinationConfigs = await ref.read(
  ///   reminderConfigsByEventTypeProvider('vaccination').future
  /// );
  /// ```
  ///
  /// Copied from [reminderConfigsByEventType].
  ReminderConfigsByEventTypeProvider(
    String eventType,
  ) : this._internal(
          (ref) => reminderConfigsByEventType(
            ref as ReminderConfigsByEventTypeRef,
            eventType,
          ),
          from: reminderConfigsByEventTypeProvider,
          name: r'reminderConfigsByEventTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reminderConfigsByEventTypeHash,
          dependencies: ReminderConfigsByEventTypeFamily._dependencies,
          allTransitiveDependencies:
              ReminderConfigsByEventTypeFamily._allTransitiveDependencies,
          eventType: eventType,
        );

  ReminderConfigsByEventTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventType,
  }) : super.internal();

  final String eventType;

  @override
  Override overrideWith(
    FutureOr<List<ReminderConfig>> Function(
            ReminderConfigsByEventTypeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReminderConfigsByEventTypeProvider._internal(
        (ref) => create(ref as ReminderConfigsByEventTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventType: eventType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ReminderConfig>> createElement() {
    return _ReminderConfigsByEventTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderConfigsByEventTypeProvider &&
        other.eventType == eventType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReminderConfigsByEventTypeRef
    on AutoDisposeFutureProviderRef<List<ReminderConfig>> {
  /// The parameter `eventType` of this provider.
  String get eventType;
}

class _ReminderConfigsByEventTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<ReminderConfig>>
    with ReminderConfigsByEventTypeRef {
  _ReminderConfigsByEventTypeProviderElement(super.provider);

  @override
  String get eventType =>
      (origin as ReminderConfigsByEventTypeProvider).eventType;
}

String _$reminderConfigsByPetIdHash() =>
    r'3110d927ec973f162e02b63abccc539765fb7776';

/// Get all reminder configurations for a specific pet
///
/// Usage:
/// ```dart
/// final petConfigs = await ref.read(
///   reminderConfigsByPetIdProvider('pet-123').future
/// );
/// ```
///
/// Copied from [reminderConfigsByPetId].
@ProviderFor(reminderConfigsByPetId)
const reminderConfigsByPetIdProvider = ReminderConfigsByPetIdFamily();

/// Get all reminder configurations for a specific pet
///
/// Usage:
/// ```dart
/// final petConfigs = await ref.read(
///   reminderConfigsByPetIdProvider('pet-123').future
/// );
/// ```
///
/// Copied from [reminderConfigsByPetId].
class ReminderConfigsByPetIdFamily
    extends Family<AsyncValue<List<ReminderConfig>>> {
  /// Get all reminder configurations for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final petConfigs = await ref.read(
  ///   reminderConfigsByPetIdProvider('pet-123').future
  /// );
  /// ```
  ///
  /// Copied from [reminderConfigsByPetId].
  const ReminderConfigsByPetIdFamily();

  /// Get all reminder configurations for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final petConfigs = await ref.read(
  ///   reminderConfigsByPetIdProvider('pet-123').future
  /// );
  /// ```
  ///
  /// Copied from [reminderConfigsByPetId].
  ReminderConfigsByPetIdProvider call(
    String petId,
  ) {
    return ReminderConfigsByPetIdProvider(
      petId,
    );
  }

  @override
  ReminderConfigsByPetIdProvider getProviderOverride(
    covariant ReminderConfigsByPetIdProvider provider,
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
  String? get name => r'reminderConfigsByPetIdProvider';
}

/// Get all reminder configurations for a specific pet
///
/// Usage:
/// ```dart
/// final petConfigs = await ref.read(
///   reminderConfigsByPetIdProvider('pet-123').future
/// );
/// ```
///
/// Copied from [reminderConfigsByPetId].
class ReminderConfigsByPetIdProvider
    extends AutoDisposeFutureProvider<List<ReminderConfig>> {
  /// Get all reminder configurations for a specific pet
  ///
  /// Usage:
  /// ```dart
  /// final petConfigs = await ref.read(
  ///   reminderConfigsByPetIdProvider('pet-123').future
  /// );
  /// ```
  ///
  /// Copied from [reminderConfigsByPetId].
  ReminderConfigsByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => reminderConfigsByPetId(
            ref as ReminderConfigsByPetIdRef,
            petId,
          ),
          from: reminderConfigsByPetIdProvider,
          name: r'reminderConfigsByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reminderConfigsByPetIdHash,
          dependencies: ReminderConfigsByPetIdFamily._dependencies,
          allTransitiveDependencies:
              ReminderConfigsByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  ReminderConfigsByPetIdProvider._internal(
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
    FutureOr<List<ReminderConfig>> Function(ReminderConfigsByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReminderConfigsByPetIdProvider._internal(
        (ref) => create(ref as ReminderConfigsByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<ReminderConfig>> createElement() {
    return _ReminderConfigsByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderConfigsByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReminderConfigsByPetIdRef
    on AutoDisposeFutureProviderRef<List<ReminderConfig>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _ReminderConfigsByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<ReminderConfig>>
    with ReminderConfigsByPetIdRef {
  _ReminderConfigsByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as ReminderConfigsByPetIdProvider).petId;
}

String _$reminderConfigByIdHash() =>
    r'0364aa0c60e1e02175f5fc2dd19e24e9277970a8';

/// Get a specific reminder configuration by ID
///
/// Returns null if configuration not found.
///
/// Usage:
/// ```dart
/// final config = await ref.read(reminderConfigByIdProvider('config-id').future);
/// ```
///
/// Copied from [reminderConfigById].
@ProviderFor(reminderConfigById)
const reminderConfigByIdProvider = ReminderConfigByIdFamily();

/// Get a specific reminder configuration by ID
///
/// Returns null if configuration not found.
///
/// Usage:
/// ```dart
/// final config = await ref.read(reminderConfigByIdProvider('config-id').future);
/// ```
///
/// Copied from [reminderConfigById].
class ReminderConfigByIdFamily extends Family<AsyncValue<ReminderConfig?>> {
  /// Get a specific reminder configuration by ID
  ///
  /// Returns null if configuration not found.
  ///
  /// Usage:
  /// ```dart
  /// final config = await ref.read(reminderConfigByIdProvider('config-id').future);
  /// ```
  ///
  /// Copied from [reminderConfigById].
  const ReminderConfigByIdFamily();

  /// Get a specific reminder configuration by ID
  ///
  /// Returns null if configuration not found.
  ///
  /// Usage:
  /// ```dart
  /// final config = await ref.read(reminderConfigByIdProvider('config-id').future);
  /// ```
  ///
  /// Copied from [reminderConfigById].
  ReminderConfigByIdProvider call(
    String id,
  ) {
    return ReminderConfigByIdProvider(
      id,
    );
  }

  @override
  ReminderConfigByIdProvider getProviderOverride(
    covariant ReminderConfigByIdProvider provider,
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
  String? get name => r'reminderConfigByIdProvider';
}

/// Get a specific reminder configuration by ID
///
/// Returns null if configuration not found.
///
/// Usage:
/// ```dart
/// final config = await ref.read(reminderConfigByIdProvider('config-id').future);
/// ```
///
/// Copied from [reminderConfigById].
class ReminderConfigByIdProvider
    extends AutoDisposeFutureProvider<ReminderConfig?> {
  /// Get a specific reminder configuration by ID
  ///
  /// Returns null if configuration not found.
  ///
  /// Usage:
  /// ```dart
  /// final config = await ref.read(reminderConfigByIdProvider('config-id').future);
  /// ```
  ///
  /// Copied from [reminderConfigById].
  ReminderConfigByIdProvider(
    String id,
  ) : this._internal(
          (ref) => reminderConfigById(
            ref as ReminderConfigByIdRef,
            id,
          ),
          from: reminderConfigByIdProvider,
          name: r'reminderConfigByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reminderConfigByIdHash,
          dependencies: ReminderConfigByIdFamily._dependencies,
          allTransitiveDependencies:
              ReminderConfigByIdFamily._allTransitiveDependencies,
          id: id,
        );

  ReminderConfigByIdProvider._internal(
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
    FutureOr<ReminderConfig?> Function(ReminderConfigByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReminderConfigByIdProvider._internal(
        (ref) => create(ref as ReminderConfigByIdRef),
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
  AutoDisposeFutureProviderElement<ReminderConfig?> createElement() {
    return _ReminderConfigByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderConfigByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReminderConfigByIdRef on AutoDisposeFutureProviderRef<ReminderConfig?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ReminderConfigByIdProviderElement
    extends AutoDisposeFutureProviderElement<ReminderConfig?>
    with ReminderConfigByIdRef {
  _ReminderConfigByIdProviderElement(super.provider);

  @override
  String get id => (origin as ReminderConfigByIdProvider).id;
}

String _$defaultReminderOffsetsHash() =>
    r'19cb693075a6c0b0e60bded407a93fbe69ffd503';

/// Get default reminder offsets based on event type
///
/// Provides sensible defaults for different event types:
/// - Vaccinations: [1, 7, 14] days before
/// - Deworming: [1, 7, 14] days before
/// - Appointments: [1, 3, 7] days before (more urgent)
/// - Medications: [1, 3] days before (most urgent)
///
/// Usage:
/// ```dart
/// final offsets = ref.read(defaultReminderOffsetsProvider('vaccination'));
/// ```
///
/// Copied from [defaultReminderOffsets].
@ProviderFor(defaultReminderOffsets)
const defaultReminderOffsetsProvider = DefaultReminderOffsetsFamily();

/// Get default reminder offsets based on event type
///
/// Provides sensible defaults for different event types:
/// - Vaccinations: [1, 7, 14] days before
/// - Deworming: [1, 7, 14] days before
/// - Appointments: [1, 3, 7] days before (more urgent)
/// - Medications: [1, 3] days before (most urgent)
///
/// Usage:
/// ```dart
/// final offsets = ref.read(defaultReminderOffsetsProvider('vaccination'));
/// ```
///
/// Copied from [defaultReminderOffsets].
class DefaultReminderOffsetsFamily extends Family<List<int>> {
  /// Get default reminder offsets based on event type
  ///
  /// Provides sensible defaults for different event types:
  /// - Vaccinations: [1, 7, 14] days before
  /// - Deworming: [1, 7, 14] days before
  /// - Appointments: [1, 3, 7] days before (more urgent)
  /// - Medications: [1, 3] days before (most urgent)
  ///
  /// Usage:
  /// ```dart
  /// final offsets = ref.read(defaultReminderOffsetsProvider('vaccination'));
  /// ```
  ///
  /// Copied from [defaultReminderOffsets].
  const DefaultReminderOffsetsFamily();

  /// Get default reminder offsets based on event type
  ///
  /// Provides sensible defaults for different event types:
  /// - Vaccinations: [1, 7, 14] days before
  /// - Deworming: [1, 7, 14] days before
  /// - Appointments: [1, 3, 7] days before (more urgent)
  /// - Medications: [1, 3] days before (most urgent)
  ///
  /// Usage:
  /// ```dart
  /// final offsets = ref.read(defaultReminderOffsetsProvider('vaccination'));
  /// ```
  ///
  /// Copied from [defaultReminderOffsets].
  DefaultReminderOffsetsProvider call(
    String eventType,
  ) {
    return DefaultReminderOffsetsProvider(
      eventType,
    );
  }

  @override
  DefaultReminderOffsetsProvider getProviderOverride(
    covariant DefaultReminderOffsetsProvider provider,
  ) {
    return call(
      provider.eventType,
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
  String? get name => r'defaultReminderOffsetsProvider';
}

/// Get default reminder offsets based on event type
///
/// Provides sensible defaults for different event types:
/// - Vaccinations: [1, 7, 14] days before
/// - Deworming: [1, 7, 14] days before
/// - Appointments: [1, 3, 7] days before (more urgent)
/// - Medications: [1, 3] days before (most urgent)
///
/// Usage:
/// ```dart
/// final offsets = ref.read(defaultReminderOffsetsProvider('vaccination'));
/// ```
///
/// Copied from [defaultReminderOffsets].
class DefaultReminderOffsetsProvider extends AutoDisposeProvider<List<int>> {
  /// Get default reminder offsets based on event type
  ///
  /// Provides sensible defaults for different event types:
  /// - Vaccinations: [1, 7, 14] days before
  /// - Deworming: [1, 7, 14] days before
  /// - Appointments: [1, 3, 7] days before (more urgent)
  /// - Medications: [1, 3] days before (most urgent)
  ///
  /// Usage:
  /// ```dart
  /// final offsets = ref.read(defaultReminderOffsetsProvider('vaccination'));
  /// ```
  ///
  /// Copied from [defaultReminderOffsets].
  DefaultReminderOffsetsProvider(
    String eventType,
  ) : this._internal(
          (ref) => defaultReminderOffsets(
            ref as DefaultReminderOffsetsRef,
            eventType,
          ),
          from: defaultReminderOffsetsProvider,
          name: r'defaultReminderOffsetsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$defaultReminderOffsetsHash,
          dependencies: DefaultReminderOffsetsFamily._dependencies,
          allTransitiveDependencies:
              DefaultReminderOffsetsFamily._allTransitiveDependencies,
          eventType: eventType,
        );

  DefaultReminderOffsetsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventType,
  }) : super.internal();

  final String eventType;

  @override
  Override overrideWith(
    List<int> Function(DefaultReminderOffsetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DefaultReminderOffsetsProvider._internal(
        (ref) => create(ref as DefaultReminderOffsetsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventType: eventType,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<int>> createElement() {
    return _DefaultReminderOffsetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DefaultReminderOffsetsProvider &&
        other.eventType == eventType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DefaultReminderOffsetsRef on AutoDisposeProviderRef<List<int>> {
  /// The parameter `eventType` of this provider.
  String get eventType;
}

class _DefaultReminderOffsetsProviderElement
    extends AutoDisposeProviderElement<List<int>>
    with DefaultReminderOffsetsRef {
  _DefaultReminderOffsetsProviderElement(super.provider);

  @override
  String get eventType => (origin as DefaultReminderOffsetsProvider).eventType;
}

String _$reminderConfigsHash() => r'ab64f97d47448379a04d1a496c7c33118ef0f5b4';

/// Main reminder config provider - manages all reminder configurations
///
/// Reminder configurations control when and how notifications are sent for
/// upcoming care events (vaccinations, deworming, appointments, medications).
///
/// Usage:
/// ```dart
/// final configs = await ref.read(reminderConfigsProvider.future);
/// ```
///
/// Copied from [ReminderConfigs].
@ProviderFor(ReminderConfigs)
final reminderConfigsProvider = AutoDisposeAsyncNotifierProvider<
    ReminderConfigs, List<ReminderConfig>>.internal(
  ReminderConfigs.new,
  name: r'reminderConfigsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reminderConfigsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReminderConfigs = AutoDisposeAsyncNotifier<List<ReminderConfig>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
