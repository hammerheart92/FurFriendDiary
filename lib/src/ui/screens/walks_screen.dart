import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Package import (preferred)
import 'package:fur_friend_diary/features/walks/walks_screen.dart' as walks;
// Relative import fallback: import '../../../features/walks/walks_screen.dart' as walks;
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/src/providers/providers.dart';

class WalksScreen extends ConsumerStatefulWidget {
  const WalksScreen({super.key});

  @override
  ConsumerState<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends ConsumerState<WalksScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Get the current pet ID from the provider
    final currentPet = ref.watch(currentPetProfileProvider);
    final petId = currentPet?.id;

    // If no pet selected, show loading state
    if (petId == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Migrate any walks with default-pet-id to the actual pet ID (one-time migration)
    ref.listen(currentPetProfileProvider, (previous, next) {
      if (next?.id != null && next?.id != previous?.id) {
        final walksRepository = ref.read(walksRepositoryProvider);
        walksRepository.migrateDefaultPetIdWalks(next!.id);
      }
    });

    // Pass the pet ID directly to the feature screen
    return walks.WalksScreen(petId: petId);
  }
}
