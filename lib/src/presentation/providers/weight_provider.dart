import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/domain/models/weight_entry.dart';
import 'package:fur_friend_diary/src/data/repositories/weight_repository.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/src/data/local/hive_manager.dart';

final _logger = Logger();

/// Repository provider
final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  final box = HiveManager.instance.weightBox;
  return WeightRepository(box);
});

/// Weight entries for current pet (reactive stream)
final weightEntriesProvider =
    StreamProvider.autoDispose<List<WeightEntry>>((ref) {
  final repository = ref.watch(weightRepositoryProvider);
  final currentPet = ref.watch(currentPetProfileProvider);

  if (currentPet == null) {
    _logger.d('[WEIGHT_PROVIDER] No current pet, returning empty stream');
    return Stream.value([]);
  }

  _logger.d(
      '[WEIGHT_PROVIDER] Listening to weight entries stream for pet: ${currentPet.id}');
  return repository.getWeightEntriesStream(currentPet.id);
});

/// Weight entries for a specific pet (synchronous)
final weightEntriesForPetProvider =
    Provider.family<List<WeightEntry>, String>((ref, petId) {
  final repository = ref.watch(weightRepositoryProvider);
  return repository.getWeightEntriesForPet(petId);
});

/// Latest weight for current pet
final latestWeightProvider = Provider.autoDispose<WeightEntry?>((ref) {
  final entriesAsync = ref.watch(weightEntriesProvider);
  final entries = entriesAsync.when(
    data: (data) => data,
    loading: () => <WeightEntry>[],
    error: (_, __) => <WeightEntry>[],
  );
  return entries.isNotEmpty ? entries.first : null;
});

/// Latest weight for a specific pet
final latestWeightForPetProvider =
    Provider.family<WeightEntry?, String>((ref, petId) {
  final repository = ref.watch(weightRepositoryProvider);
  return repository.getLatestWeight(petId);
});

/// Weight change (difference between latest and earliest) for current pet
final weightChangeProvider = Provider.autoDispose<double?>((ref) {
  final entriesAsync = ref.watch(weightEntriesProvider);
  final entries = entriesAsync.when(
    data: (data) => data,
    loading: () => <WeightEntry>[],
    error: (_, __) => <WeightEntry>[],
  );
  if (entries.length < 2) return null;

  final latest = entries.first.weight;
  final earliest = entries.last.weight;
  return latest - earliest;
});

/// Weight change for a specific pet
final weightChangeForPetProvider =
    Provider.family<double?, String>((ref, petId) {
  final repository = ref.watch(weightRepositoryProvider);
  return repository.getWeightChange(petId);
});

/// Weight unit preference provider (default: kilograms)
final weightUnitProvider =
    StateProvider<WeightUnit>((ref) => WeightUnit.kilograms);

/// Period filter for weight chart
enum WeightPeriod { week, month, all }

/// Selected period for weight chart filter
final weightPeriodProvider =
    StateProvider<WeightPeriod>((ref) => WeightPeriod.all);

/// Filtered weight entries based on selected period (for chart display)
final filteredWeightEntriesProvider =
    Provider.autoDispose<List<WeightEntry>>((ref) {
  final entriesAsync = ref.watch(weightEntriesProvider);
  final period = ref.watch(weightPeriodProvider);

  // Properly handle AsyncValue - use .when() to extract data
  final entries = entriesAsync.when(
    data: (data) => data,
    loading: () => <WeightEntry>[],
    error: (_, __) => <WeightEntry>[],
  );

  if (period == WeightPeriod.all || entries.isEmpty) {
    return entries;
  }

  final now = DateTime.now();
  final DateTime cutoff;

  switch (period) {
    case WeightPeriod.week:
      cutoff = now.subtract(const Duration(days: 7));
      break;
    case WeightPeriod.month:
      cutoff = DateTime(now.year, now.month - 1, now.day);
      break;
    case WeightPeriod.all:
      return entries;
  }

  return entries.where((e) => e.date.isAfter(cutoff)).toList();
});

/// Convert weight between units
double convertWeight(double weight, WeightUnit from, WeightUnit to) {
  if (from == to) return weight;

  if (from == WeightUnit.kilograms && to == WeightUnit.pounds) {
    return weight * 2.20462; // kg to lbs
  } else if (from == WeightUnit.pounds && to == WeightUnit.kilograms) {
    return weight / 2.20462; // lbs to kg
  }

  return weight;
}

/// Format weight with unit
String formatWeight(double weight, WeightUnit unit) {
  final unitStr = unit == WeightUnit.kilograms ? 'kg' : 'lbs';
  return '${weight.toStringAsFixed(1)} $unitStr';
}
