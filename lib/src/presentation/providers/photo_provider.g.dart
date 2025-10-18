// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageServiceHash() => r'5227ccccdfc6f900651dff7e55ce791bae15378b';

/// Provider for ImageService
///
/// Copied from [imageService].
@ProviderFor(imageService)
final imageServiceProvider = AutoDisposeProvider<ImageService>.internal(
  imageService,
  name: r'imageServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$imageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ImageServiceRef = AutoDisposeProviderRef<ImageService>;
String _$photoRepositoryHash() => r'd9d15f634ae39d7246df3d02e5e7a5606bf1be58';

/// Provider for PhotoRepository
///
/// Copied from [photoRepository].
@ProviderFor(photoRepository)
final photoRepositoryProvider = AutoDisposeProvider<PhotoRepository>.internal(
  photoRepository,
  name: r'photoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$photoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PhotoRepositoryRef = AutoDisposeProviderRef<PhotoRepository>;
String _$photosForCurrentPetHash() =>
    r'617cab5aa8e8b9a211d74f95e51174904ea6e656';

/// Provider for photos of the current pet
///
/// Copied from [photosForCurrentPet].
@ProviderFor(photosForCurrentPet)
final photosForCurrentPetProvider =
    AutoDisposeFutureProvider<List<PetPhoto>>.internal(
  photosForCurrentPet,
  name: r'photosForCurrentPetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$photosForCurrentPetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PhotosForCurrentPetRef = AutoDisposeFutureProviderRef<List<PetPhoto>>;
String _$photoDetailHash() => r'5b467b64e8e9bc61e20e677a770c9aab6184553a';

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

/// Provider for a specific photo by ID
///
/// Copied from [photoDetail].
@ProviderFor(photoDetail)
const photoDetailProvider = PhotoDetailFamily();

/// Provider for a specific photo by ID
///
/// Copied from [photoDetail].
class PhotoDetailFamily extends Family<PetPhoto?> {
  /// Provider for a specific photo by ID
  ///
  /// Copied from [photoDetail].
  const PhotoDetailFamily();

  /// Provider for a specific photo by ID
  ///
  /// Copied from [photoDetail].
  PhotoDetailProvider call(
    String photoId,
  ) {
    return PhotoDetailProvider(
      photoId,
    );
  }

  @override
  PhotoDetailProvider getProviderOverride(
    covariant PhotoDetailProvider provider,
  ) {
    return call(
      provider.photoId,
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
  String? get name => r'photoDetailProvider';
}

/// Provider for a specific photo by ID
///
/// Copied from [photoDetail].
class PhotoDetailProvider extends AutoDisposeProvider<PetPhoto?> {
  /// Provider for a specific photo by ID
  ///
  /// Copied from [photoDetail].
  PhotoDetailProvider(
    String photoId,
  ) : this._internal(
          (ref) => photoDetail(
            ref as PhotoDetailRef,
            photoId,
          ),
          from: photoDetailProvider,
          name: r'photoDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$photoDetailHash,
          dependencies: PhotoDetailFamily._dependencies,
          allTransitiveDependencies:
              PhotoDetailFamily._allTransitiveDependencies,
          photoId: photoId,
        );

  PhotoDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.photoId,
  }) : super.internal();

  final String photoId;

  @override
  Override overrideWith(
    PetPhoto? Function(PhotoDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PhotoDetailProvider._internal(
        (ref) => create(ref as PhotoDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        photoId: photoId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<PetPhoto?> createElement() {
    return _PhotoDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PhotoDetailProvider && other.photoId == photoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, photoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PhotoDetailRef on AutoDisposeProviderRef<PetPhoto?> {
  /// The parameter `photoId` of this provider.
  String get photoId;
}

class _PhotoDetailProviderElement extends AutoDisposeProviderElement<PetPhoto?>
    with PhotoDetailRef {
  _PhotoDetailProviderElement(super.provider);

  @override
  String get photoId => (origin as PhotoDetailProvider).photoId;
}

String _$totalStorageUsedHash() => r'2488b3f65206d1eb441f938e9e040908b747587e';

/// Provider for total storage used by all photos
///
/// Copied from [totalStorageUsed].
@ProviderFor(totalStorageUsed)
final totalStorageUsedProvider = AutoDisposeFutureProvider<int>.internal(
  totalStorageUsed,
  name: r'totalStorageUsedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalStorageUsedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalStorageUsedRef = AutoDisposeFutureProviderRef<int>;
String _$storageUsedByCurrentPetHash() =>
    r'c7619e57cd8f968fb02130dbdc17a155da9c6c07';

/// Provider for storage used by current pet's photos
///
/// Copied from [storageUsedByCurrentPet].
@ProviderFor(storageUsedByCurrentPet)
final storageUsedByCurrentPetProvider = AutoDisposeFutureProvider<int>.internal(
  storageUsedByCurrentPet,
  name: r'storageUsedByCurrentPetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageUsedByCurrentPetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef StorageUsedByCurrentPetRef = AutoDisposeFutureProviderRef<int>;
String _$photoCountForCurrentPetHash() =>
    r'c6ad9253542364a684557df77a5db09be2a34b4b';

/// Provider for photo count of current pet
///
/// Copied from [photoCountForCurrentPet].
@ProviderFor(photoCountForCurrentPet)
final photoCountForCurrentPetProvider = AutoDisposeFutureProvider<int>.internal(
  photoCountForCurrentPet,
  name: r'photoCountForCurrentPetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$photoCountForCurrentPetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PhotoCountForCurrentPetRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
