import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/local/hive_manager.dart';
import '../../data/repositories/photo_repository.dart';
import '../../data/services/image_service.dart';
import '../../domain/models/pet_photo.dart';
import 'pet_profile_provider.dart';

part 'photo_provider.g.dart';

/// Provider for ImageService
@riverpod
ImageService imageService(ImageServiceRef ref) {
  return ImageService();
}

/// Provider for PhotoRepository
@riverpod
PhotoRepository photoRepository(PhotoRepositoryRef ref) {
  final box = HiveManager.instance.petPhotoBox;
  return PhotoRepository(box);
}

/// Provider for photos of the current pet
@riverpod
Future<List<PetPhoto>> photosForCurrentPet(PhotosForCurrentPetRef ref) async {
  final currentPet = ref.watch(currentPetProfileProvider);

  if (currentPet == null) {
    return [];
  }

  final repository = ref.watch(photoRepositoryProvider);
  return repository.getPhotosForPet(currentPet.id);
}

/// Provider for a specific photo by ID
@riverpod
PetPhoto? photoDetail(PhotoDetailRef ref, String photoId) {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.getPhoto(photoId);
}

/// Provider for total storage used by all photos
@riverpod
Future<int> totalStorageUsed(TotalStorageUsedRef ref) async {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.getTotalStorageUsed();
}

/// Provider for storage used by current pet's photos
@riverpod
Future<int> storageUsedByCurrentPet(StorageUsedByCurrentPetRef ref) async {
  final currentPet = ref.watch(currentPetProfileProvider);

  if (currentPet == null) {
    return 0;
  }

  final repository = ref.watch(photoRepositoryProvider);
  return repository.getStorageUsedForPet(currentPet.id);
}

/// Provider for photo count of current pet
@riverpod
Future<int> photoCountForCurrentPet(PhotoCountForCurrentPetRef ref) async {
  final currentPet = ref.watch(currentPetProfileProvider);

  if (currentPet == null) {
    return 0;
  }

  final repository = ref.watch(photoRepositoryProvider);
  return repository.getPhotoCount(currentPet.id);
}
