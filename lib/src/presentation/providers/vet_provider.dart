import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/vet_profile.dart';
import '../../data/repositories/vet_repository.dart';

// Repository provider
final vetRepositoryProvider = Provider<VetRepository>((ref) {
  final box = Hive.box<VetProfile>('vet_profiles');
  return VetRepository(box);
});

// Stream provider for all vets
final vetsProvider = StreamProvider<List<VetProfile>>((ref) {
  final repository = ref.watch(vetRepositoryProvider);
  return repository.getVetsStream();
});

// Provider for preferred vet
final preferredVetProvider = Provider<VetProfile?>((ref) {
  final vetsAsync = ref.watch(vetsProvider);
  return vetsAsync.when(
    data: (vets) => vets.where((v) => v.isPreferred).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Family provider for vet detail by ID
final vetDetailProvider = Provider.family<VetProfile?, String>((ref, vetId) {
  final vetsAsync = ref.watch(vetsProvider);
  return vetsAsync.when(
    data: (vets) => vets.where((v) => v.id == vetId).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Family provider for vets by specialty
final vetsBySpecialtyProvider =
    Provider.family<List<VetProfile>, String>((ref, specialty) {
  final vetsAsync = ref.watch(vetsProvider);
  return vetsAsync.when(
    data: (vets) => vets.where((v) => v.specialty == specialty).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for vet count
final vetCountProvider = Provider<int>((ref) {
  final vetsAsync = ref.watch(vetsProvider);
  return vetsAsync.when(
    data: (vets) => vets.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Search provider - state provider for search query
final vetSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered vets based on search
final filteredVetsProvider = Provider<List<VetProfile>>((ref) {
  final vetsAsync = ref.watch(vetsProvider);
  final searchQuery = ref.watch(vetSearchQueryProvider);

  return vetsAsync.when(
    data: (vets) {
      if (searchQuery.isEmpty) {
        return vets;
      }
      final lowerQuery = searchQuery.toLowerCase();
      return vets.where((vet) {
        final nameLower = vet.name.toLowerCase();
        final clinicLower = vet.clinicName.toLowerCase();
        return nameLower.contains(lowerQuery) ||
            clinicLower.contains(lowerQuery);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
