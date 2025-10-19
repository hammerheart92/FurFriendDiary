import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/hive_manager.dart';
import '../data/repositories/purchase_repository.dart';
import '../domain/models/medication_purchase.dart';
import '../domain/models/medication_entry.dart';
import '../providers/medications_provider.dart';

// Purchase Repository Provider
final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  final box = HiveManager.instance.medicationPurchaseBox;
  return PurchaseRepository(box);
});

// Purchase history provider for a specific medication - watches medicationsProvider for updates
final purchaseHistoryProvider =
    Provider.family<List<MedicationPurchase>, String>((ref, medicationId) {
  // Watch medicationsProvider to trigger updates when medications change
  ref.watch(medicationsProvider);
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getPurchasesForMedication(medicationId);
});

// Low stock medications provider for a specific pet - reactive to medication changes
final lowStockMedicationsProvider =
    Provider.family<List<MedicationEntry>, String>((ref, petId) {
  final medicationsAsync = ref.watch(medicationsProvider);

  return medicationsAsync.when(
    data: (medications) {
      return medications.where((medication) {
        return medication.petId == petId &&
            medication.isActive &&
            medication.stockQuantity != null &&
            medication.lowStockThreshold != null &&
            medication.stockQuantity! <= medication.lowStockThreshold!;
      }).toList()
        ..sort((a, b) {
          // Sort by urgency: lowest stock percentage first
          final aPercentage = (a.stockQuantity! /
              (a.lowStockThreshold! > 0 ? a.lowStockThreshold! : 1));
          final bPercentage = (b.stockQuantity! /
              (b.lowStockThreshold! > 0 ? b.lowStockThreshold! : 1));
          return aPercentage.compareTo(bPercentage);
        });
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Days until empty provider for a specific medication
final daysUntilEmptyProvider =
    Provider.family<int?, String>((ref, medicationId) {
  final medicationsAsync = ref.watch(medicationsProvider);
  return medicationsAsync.when(
    data: (medications) {
      final medication = medications.firstWhere(
        (m) => m.id == medicationId,
        orElse: () => medications.first, // Won't be called if not found
      );

      final medicationRepo = ref.read(medicationsRepositoryProvider);
      return medicationRepo.getDaysUntilEmpty(medication);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Total medication cost provider for a pet within a date range
class DateRange {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRange({this.startDate, this.endDate});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

class PetCostQuery {
  final String petId;
  final DateRange? dateRange;

  const PetCostQuery(this.petId, {this.dateRange});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetCostQuery &&
          runtimeType == other.runtimeType &&
          petId == other.petId &&
          dateRange == other.dateRange;

  @override
  int get hashCode => petId.hashCode ^ dateRange.hashCode;
}

final totalMedicationCostProvider =
    Provider.family<double, PetCostQuery>((ref, query) {
  // Watch medicationsProvider to trigger updates when medications change
  ref.watch(medicationsProvider);
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getTotalSpent(
    query.petId,
    startDate: query.dateRange?.startDate,
    endDate: query.dateRange?.endDate,
  );
});

// Average cost per unit for a medication
final averageCostPerUnitProvider =
    Provider.family<double?, String>((ref, medicationId) {
  // Watch medicationsProvider to trigger updates when medications change
  ref.watch(medicationsProvider);
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getAverageCostPerUnit(medicationId);
});

// Latest purchase for a medication
final latestPurchaseProvider =
    Provider.family<MedicationPurchase?, String>((ref, medicationId) {
  // Watch medicationsProvider to trigger updates when medications change
  ref.watch(medicationsProvider);
  final repository = ref.watch(purchaseRepositoryProvider);
  return repository.getLatestPurchase(medicationId);
});

// Medications with refill reminders approaching
final refillReminderMedicationsProvider =
    Provider.family<List<MedicationEntry>, String>((ref, petId) {
  final medicationsAsync = ref.watch(medicationsProvider);
  final medicationRepo = ref.read(medicationsRepositoryProvider);

  return medicationsAsync.when(
    data: (medications) {
      return medications.where((medication) {
        if (medication.petId != petId || !medication.isActive) {
          return false;
        }

        // Check if refill reminders are enabled
        if (medication.refillReminderDays == null ||
            medication.stockQuantity == null) {
          return false;
        }

        final daysUntilEmpty = medicationRepo.getDaysUntilEmpty(medication);

        // Alert if days until empty is less than or equal to reminder threshold
        if (daysUntilEmpty != null &&
            daysUntilEmpty <= medication.refillReminderDays!) {
          return true;
        }

        return false;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Stock status enum for UI
enum StockStatus {
  sufficient,
  low,
  critical,
  notTracked,
}

// Stock status provider for a medication
final stockStatusProvider =
    Provider.family<StockStatus, String>((ref, medicationId) {
  final medicationsAsync = ref.watch(medicationsProvider);
  final medicationRepo = ref.read(medicationsRepositoryProvider);

  return medicationsAsync.when(
    data: (medications) {
      final medication =
          medications.where((m) => m.id == medicationId).firstOrNull;

      if (medication == null) {
        return StockStatus.notTracked;
      }

      // Not tracked if no stock quantity
      if (medication.stockQuantity == null) {
        return StockStatus.notTracked;
      }

      // Critical if at or below low stock threshold
      if (medication.lowStockThreshold != null &&
          medication.stockQuantity! <= medication.lowStockThreshold!) {
        return StockStatus.critical;
      }

      // Low if 1-3 days until empty (if refill reminder is enabled)
      if (medication.refillReminderDays != null) {
        final daysUntilEmpty = medicationRepo.getDaysUntilEmpty(medication);
        if (daysUntilEmpty != null &&
            daysUntilEmpty <= medication.refillReminderDays! &&
            daysUntilEmpty > 0) {
          return StockStatus.low;
        }
      }

      return StockStatus.sufficient;
    },
    loading: () => StockStatus.notTracked,
    error: (_, __) => StockStatus.notTracked,
  );
});
