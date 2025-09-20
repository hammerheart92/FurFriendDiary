import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/pet_profile.dart';
import '../../data/repositories/pet_profile_repository.dart';

part 'app_state_provider.g.dart';

@riverpod
class AppState extends _$AppState {
  @override
  AppStateModel build() {
    return const AppStateModel();
  }

  void setCurrentPet(PetProfile pet) {
    state = state.copyWith(currentPet: pet);
  }

  void clearCurrentPet() {
    state = state.copyWith(currentPet: null);
  }

  void setHasCompletedSetup(bool hasCompleted) {
    state = state.copyWith(hasCompletedSetup: hasCompleted);
  }

  void setIsLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}

@riverpod
Future<bool> hasCompletedSetup(HasCompletedSetupRef ref) async {
  final repository = PetProfileRepository();
  await repository.init();
  return repository.hasCompletedSetup();
}

@riverpod
Future<PetProfile?> currentActivePet(CurrentActivePetRef ref) async {
  final repository = PetProfileRepository();
  await repository.init();
  return repository.getCurrentProfile();
}

class AppStateModel {
  final PetProfile? currentPet;
  final bool hasCompletedSetup;
  final bool isLoading;

  const AppStateModel({
    this.currentPet,
    this.hasCompletedSetup = false,
    this.isLoading = false,
  });

  AppStateModel copyWith({
    PetProfile? currentPet,
    bool? hasCompletedSetup,
    bool? isLoading,
  }) {
    return AppStateModel(
      currentPet: currentPet ?? this.currentPet,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
