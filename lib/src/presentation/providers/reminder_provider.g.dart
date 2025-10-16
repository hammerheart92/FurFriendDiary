// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reminderRepositoryHash() =>
    r'1e8e5852d4d2ab1653a0ab12a971ed8dc435f260';

/// See also [reminderRepository].
@ProviderFor(reminderRepository)
final reminderRepositoryProvider =
    AutoDisposeProvider<ReminderRepository>.internal(
  reminderRepository,
  name: r'reminderRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reminderRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ReminderRepositoryRef = AutoDisposeProviderRef<ReminderRepository>;
String _$remindersByPetIdHash() => r'087e015af05c37592740169f83c3bf08253773a9';

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

/// See also [remindersByPetId].
@ProviderFor(remindersByPetId)
const remindersByPetIdProvider = RemindersByPetIdFamily();

/// See also [remindersByPetId].
class RemindersByPetIdFamily extends Family<AsyncValue<List<Reminder>>> {
  /// See also [remindersByPetId].
  const RemindersByPetIdFamily();

  /// See also [remindersByPetId].
  RemindersByPetIdProvider call(
    String petId,
  ) {
    return RemindersByPetIdProvider(
      petId,
    );
  }

  @override
  RemindersByPetIdProvider getProviderOverride(
    covariant RemindersByPetIdProvider provider,
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
  String? get name => r'remindersByPetIdProvider';
}

/// See also [remindersByPetId].
class RemindersByPetIdProvider
    extends AutoDisposeFutureProvider<List<Reminder>> {
  /// See also [remindersByPetId].
  RemindersByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => remindersByPetId(
            ref as RemindersByPetIdRef,
            petId,
          ),
          from: remindersByPetIdProvider,
          name: r'remindersByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$remindersByPetIdHash,
          dependencies: RemindersByPetIdFamily._dependencies,
          allTransitiveDependencies:
              RemindersByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  RemindersByPetIdProvider._internal(
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
    FutureOr<List<Reminder>> Function(RemindersByPetIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RemindersByPetIdProvider._internal(
        (ref) => create(ref as RemindersByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<Reminder>> createElement() {
    return _RemindersByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RemindersByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RemindersByPetIdRef on AutoDisposeFutureProviderRef<List<Reminder>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _RemindersByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<Reminder>>
    with RemindersByPetIdRef {
  _RemindersByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as RemindersByPetIdProvider).petId;
}

String _$activeRemindersByPetIdHash() =>
    r'a449d349bf6c14716d8b5aa76275aa5f236c68f9';

/// See also [activeRemindersByPetId].
@ProviderFor(activeRemindersByPetId)
const activeRemindersByPetIdProvider = ActiveRemindersByPetIdFamily();

/// See also [activeRemindersByPetId].
class ActiveRemindersByPetIdFamily extends Family<AsyncValue<List<Reminder>>> {
  /// See also [activeRemindersByPetId].
  const ActiveRemindersByPetIdFamily();

  /// See also [activeRemindersByPetId].
  ActiveRemindersByPetIdProvider call(
    String petId,
  ) {
    return ActiveRemindersByPetIdProvider(
      petId,
    );
  }

  @override
  ActiveRemindersByPetIdProvider getProviderOverride(
    covariant ActiveRemindersByPetIdProvider provider,
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
  String? get name => r'activeRemindersByPetIdProvider';
}

/// See also [activeRemindersByPetId].
class ActiveRemindersByPetIdProvider
    extends AutoDisposeFutureProvider<List<Reminder>> {
  /// See also [activeRemindersByPetId].
  ActiveRemindersByPetIdProvider(
    String petId,
  ) : this._internal(
          (ref) => activeRemindersByPetId(
            ref as ActiveRemindersByPetIdRef,
            petId,
          ),
          from: activeRemindersByPetIdProvider,
          name: r'activeRemindersByPetIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activeRemindersByPetIdHash,
          dependencies: ActiveRemindersByPetIdFamily._dependencies,
          allTransitiveDependencies:
              ActiveRemindersByPetIdFamily._allTransitiveDependencies,
          petId: petId,
        );

  ActiveRemindersByPetIdProvider._internal(
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
    FutureOr<List<Reminder>> Function(ActiveRemindersByPetIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActiveRemindersByPetIdProvider._internal(
        (ref) => create(ref as ActiveRemindersByPetIdRef),
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
  AutoDisposeFutureProviderElement<List<Reminder>> createElement() {
    return _ActiveRemindersByPetIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveRemindersByPetIdProvider && other.petId == petId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ActiveRemindersByPetIdRef
    on AutoDisposeFutureProviderRef<List<Reminder>> {
  /// The parameter `petId` of this provider.
  String get petId;
}

class _ActiveRemindersByPetIdProviderElement
    extends AutoDisposeFutureProviderElement<List<Reminder>>
    with ActiveRemindersByPetIdRef {
  _ActiveRemindersByPetIdProviderElement(super.provider);

  @override
  String get petId => (origin as ActiveRemindersByPetIdProvider).petId;
}

String _$remindersByTypeHash() => r'0bfacfa76a9e8a4cba7c557b6a3f4ee0bf305484';

/// See also [remindersByType].
@ProviderFor(remindersByType)
const remindersByTypeProvider = RemindersByTypeFamily();

/// See also [remindersByType].
class RemindersByTypeFamily extends Family<AsyncValue<List<Reminder>>> {
  /// See also [remindersByType].
  const RemindersByTypeFamily();

  /// See also [remindersByType].
  RemindersByTypeProvider call(
    String petId,
    ReminderType type,
  ) {
    return RemindersByTypeProvider(
      petId,
      type,
    );
  }

  @override
  RemindersByTypeProvider getProviderOverride(
    covariant RemindersByTypeProvider provider,
  ) {
    return call(
      provider.petId,
      provider.type,
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
  String? get name => r'remindersByTypeProvider';
}

/// See also [remindersByType].
class RemindersByTypeProvider
    extends AutoDisposeFutureProvider<List<Reminder>> {
  /// See also [remindersByType].
  RemindersByTypeProvider(
    String petId,
    ReminderType type,
  ) : this._internal(
          (ref) => remindersByType(
            ref as RemindersByTypeRef,
            petId,
            type,
          ),
          from: remindersByTypeProvider,
          name: r'remindersByTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$remindersByTypeHash,
          dependencies: RemindersByTypeFamily._dependencies,
          allTransitiveDependencies:
              RemindersByTypeFamily._allTransitiveDependencies,
          petId: petId,
          type: type,
        );

  RemindersByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.petId,
    required this.type,
  }) : super.internal();

  final String petId;
  final ReminderType type;

  @override
  Override overrideWith(
    FutureOr<List<Reminder>> Function(RemindersByTypeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RemindersByTypeProvider._internal(
        (ref) => create(ref as RemindersByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        petId: petId,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Reminder>> createElement() {
    return _RemindersByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RemindersByTypeProvider &&
        other.petId == petId &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, petId.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RemindersByTypeRef on AutoDisposeFutureProviderRef<List<Reminder>> {
  /// The parameter `petId` of this provider.
  String get petId;

  /// The parameter `type` of this provider.
  ReminderType get type;
}

class _RemindersByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<Reminder>>
    with RemindersByTypeRef {
  _RemindersByTypeProviderElement(super.provider);

  @override
  String get petId => (origin as RemindersByTypeProvider).petId;
  @override
  ReminderType get type => (origin as RemindersByTypeProvider).type;
}

String _$remindersByLinkedEntityHash() =>
    r'f5bbf71e2d10c1d6e1272005c9944602f0ae2d58';

/// See also [remindersByLinkedEntity].
@ProviderFor(remindersByLinkedEntity)
const remindersByLinkedEntityProvider = RemindersByLinkedEntityFamily();

/// See also [remindersByLinkedEntity].
class RemindersByLinkedEntityFamily extends Family<AsyncValue<List<Reminder>>> {
  /// See also [remindersByLinkedEntity].
  const RemindersByLinkedEntityFamily();

  /// See also [remindersByLinkedEntity].
  RemindersByLinkedEntityProvider call(
    String linkedEntityId,
  ) {
    return RemindersByLinkedEntityProvider(
      linkedEntityId,
    );
  }

  @override
  RemindersByLinkedEntityProvider getProviderOverride(
    covariant RemindersByLinkedEntityProvider provider,
  ) {
    return call(
      provider.linkedEntityId,
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
  String? get name => r'remindersByLinkedEntityProvider';
}

/// See also [remindersByLinkedEntity].
class RemindersByLinkedEntityProvider
    extends AutoDisposeFutureProvider<List<Reminder>> {
  /// See also [remindersByLinkedEntity].
  RemindersByLinkedEntityProvider(
    String linkedEntityId,
  ) : this._internal(
          (ref) => remindersByLinkedEntity(
            ref as RemindersByLinkedEntityRef,
            linkedEntityId,
          ),
          from: remindersByLinkedEntityProvider,
          name: r'remindersByLinkedEntityProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$remindersByLinkedEntityHash,
          dependencies: RemindersByLinkedEntityFamily._dependencies,
          allTransitiveDependencies:
              RemindersByLinkedEntityFamily._allTransitiveDependencies,
          linkedEntityId: linkedEntityId,
        );

  RemindersByLinkedEntityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.linkedEntityId,
  }) : super.internal();

  final String linkedEntityId;

  @override
  Override overrideWith(
    FutureOr<List<Reminder>> Function(RemindersByLinkedEntityRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RemindersByLinkedEntityProvider._internal(
        (ref) => create(ref as RemindersByLinkedEntityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        linkedEntityId: linkedEntityId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Reminder>> createElement() {
    return _RemindersByLinkedEntityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RemindersByLinkedEntityProvider &&
        other.linkedEntityId == linkedEntityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, linkedEntityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RemindersByLinkedEntityRef
    on AutoDisposeFutureProviderRef<List<Reminder>> {
  /// The parameter `linkedEntityId` of this provider.
  String get linkedEntityId;
}

class _RemindersByLinkedEntityProviderElement
    extends AutoDisposeFutureProviderElement<List<Reminder>>
    with RemindersByLinkedEntityRef {
  _RemindersByLinkedEntityProviderElement(super.provider);

  @override
  String get linkedEntityId =>
      (origin as RemindersByLinkedEntityProvider).linkedEntityId;
}

String _$reminderByIdHash() => r'840ed40042c675f5230260836b0d1b7bc12911ee';

/// See also [reminderById].
@ProviderFor(reminderById)
const reminderByIdProvider = ReminderByIdFamily();

/// See also [reminderById].
class ReminderByIdFamily extends Family<AsyncValue<Reminder?>> {
  /// See also [reminderById].
  const ReminderByIdFamily();

  /// See also [reminderById].
  ReminderByIdProvider call(
    String reminderId,
  ) {
    return ReminderByIdProvider(
      reminderId,
    );
  }

  @override
  ReminderByIdProvider getProviderOverride(
    covariant ReminderByIdProvider provider,
  ) {
    return call(
      provider.reminderId,
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
  String? get name => r'reminderByIdProvider';
}

/// See also [reminderById].
class ReminderByIdProvider extends AutoDisposeFutureProvider<Reminder?> {
  /// See also [reminderById].
  ReminderByIdProvider(
    String reminderId,
  ) : this._internal(
          (ref) => reminderById(
            ref as ReminderByIdRef,
            reminderId,
          ),
          from: reminderByIdProvider,
          name: r'reminderByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reminderByIdHash,
          dependencies: ReminderByIdFamily._dependencies,
          allTransitiveDependencies:
              ReminderByIdFamily._allTransitiveDependencies,
          reminderId: reminderId,
        );

  ReminderByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reminderId,
  }) : super.internal();

  final String reminderId;

  @override
  Override overrideWith(
    FutureOr<Reminder?> Function(ReminderByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReminderByIdProvider._internal(
        (ref) => create(ref as ReminderByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reminderId: reminderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Reminder?> createElement() {
    return _ReminderByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReminderByIdProvider && other.reminderId == reminderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reminderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReminderByIdRef on AutoDisposeFutureProviderRef<Reminder?> {
  /// The parameter `reminderId` of this provider.
  String get reminderId;
}

class _ReminderByIdProviderElement
    extends AutoDisposeFutureProviderElement<Reminder?> with ReminderByIdRef {
  _ReminderByIdProviderElement(super.provider);

  @override
  String get reminderId => (origin as ReminderByIdProvider).reminderId;
}

String _$reminderNotifierHash() => r'e2e67bee848e027aca8226e74bd4925a511a5e42';

/// See also [ReminderNotifier].
@ProviderFor(ReminderNotifier)
final reminderNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ReminderNotifier, List<Reminder>>.internal(
  ReminderNotifier.new,
  name: r'reminderNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reminderNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReminderNotifier = AutoDisposeAsyncNotifier<List<Reminder>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
