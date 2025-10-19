import 'package:hive/hive.dart';
import 'package:fur_friend_diary/src/domain/models/medication_purchase.dart';

class PurchaseRepository {
  final Box<MedicationPurchase> _box;

  PurchaseRepository(this._box);

  /// Add a new purchase
  Future<void> addPurchase(MedicationPurchase purchase) async {
    await _box.put(purchase.id, purchase);
  }

  /// Delete a purchase by ID
  Future<void> deletePurchase(String id) async {
    await _box.delete(id);
  }

  /// Get all purchases for a specific medication
  List<MedicationPurchase> getPurchasesForMedication(String medicationId) {
    return _box.values
        .where((purchase) => purchase.medicationId == medicationId)
        .toList()
      ..sort((a, b) =>
          b.purchaseDate.compareTo(a.purchaseDate)); // Most recent first
  }

  /// Get all purchases for a specific pet within an optional date range
  List<MedicationPurchase> getPurchasesForPet(
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _box.values.where((purchase) {
      if (purchase.petId != petId) return false;

      if (startDate != null && purchase.purchaseDate.isBefore(startDate)) {
        return false;
      }

      if (endDate != null && purchase.purchaseDate.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) =>
          b.purchaseDate.compareTo(a.purchaseDate)); // Most recent first
  }

  /// Get purchases as a stream for real-time updates
  Stream<List<MedicationPurchase>> getPurchasesStream(String medicationId) {
    return _box.watch().map((_) => getPurchasesForMedication(medicationId));
  }

  /// Get the latest (most recent) purchase for a medication
  MedicationPurchase? getLatestPurchase(String medicationId) {
    final purchases = getPurchasesForMedication(medicationId);
    return purchases.isNotEmpty ? purchases.first : null;
  }

  /// Get total spent on a medication
  double getTotalSpentOnMedication(String medicationId) {
    final purchases = getPurchasesForMedication(medicationId);
    return purchases.fold(0.0, (sum, purchase) => sum + purchase.cost);
  }

  /// Get total spent for a pet within an optional date range
  double getTotalSpent(
    String petId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final purchases = getPurchasesForPet(
      petId,
      startDate: startDate,
      endDate: endDate,
    );
    return purchases.fold(0.0, (sum, purchase) => sum + purchase.cost);
  }

  /// Get average cost per unit for a medication
  /// Returns null if no purchases found
  double? getAverageCostPerUnit(String medicationId) {
    final purchases = getPurchasesForMedication(medicationId);
    if (purchases.isEmpty) return null;

    final totalCost = purchases.fold(0.0, (sum, p) => sum + p.cost);
    final totalQuantity = purchases.fold(0, (sum, p) => sum + p.quantity);

    if (totalQuantity == 0) return null;
    return totalCost / totalQuantity;
  }

  /// Get total quantity purchased for a medication
  int getTotalQuantityPurchased(String medicationId) {
    final purchases = getPurchasesForMedication(medicationId);
    return purchases.fold(0, (sum, purchase) => sum + purchase.quantity);
  }

  /// Get all purchases across all medications
  List<MedicationPurchase> getAllPurchases() {
    return _box.values.toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
  }

  /// Delete all purchases for a specific medication
  Future<void> deletePurchasesForMedication(String medicationId) async {
    final purchases = getPurchasesForMedication(medicationId);
    for (final purchase in purchases) {
      await _box.delete(purchase.id);
    }
  }

  /// Delete all purchases for a specific pet
  Future<void> deletePurchasesForPet(String petId) async {
    final purchases = getPurchasesForPet(petId);
    for (final purchase in purchases) {
      await _box.delete(purchase.id);
    }
  }

  /// Get purchase count for a medication
  int getPurchaseCount(String medicationId) {
    return getPurchasesForMedication(medicationId).length;
  }
}
