import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Package import (preferred)
import 'package:fur_friend_diary/features/walks/walks_screen.dart' as walks;
// Relative import fallback: import '../../../features/walks/walks_screen.dart' as walks;
import 'package:fur_friend_diary/features/walks/walks_state.dart';
// Relative import fallback: import '../../../features/walks/walks_state.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/src/providers/providers.dart';

class WalksScreen extends ConsumerStatefulWidget {
  const WalksScreen({super.key});

  @override
  ConsumerState<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends ConsumerState<WalksScreen>
    with AutomaticKeepAliveClientMixin {
  WalksController? _controller;
  String? _currentPetId;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the current pet ID from the provider
    final currentPet = ref.watch(currentPetProfileProvider);
    final petId = currentPet?.id;

    // Initialize or reinitialize controller if pet ID changed
    if (petId != null && petId != _currentPetId) {
      _controller?.dispose();
      _controller = WalksController(petId);
      _currentPetId = petId;

      // Migrate any walks with default-pet-id to the actual pet ID
      final walksRepository = ref.read(walksRepositoryProvider);
      walksRepository.migrateDefaultPetIdWalks(petId);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final controller = _controller;

    // If no controller yet (no pet selected), show empty state
    if (controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return WalksScope(
      notifier: controller,
      child: const walks.WalksScreen(),
    );
  }
}
