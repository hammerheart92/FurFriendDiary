import 'package:fur_friend_diary/src/domain/repositories/medication_repository.dart';
import 'package:fur_friend_diary/src/data/repositories/weight_repository.dart';
import 'package:fur_friend_diary/src/data/repositories/purchase_repository.dart';
import 'package:fur_friend_diary/src/domain/repositories/feeding_repository.dart';
import 'package:fur_friend_diary/src/data/repositories/walks_repository.dart';
import 'package:fur_friend_diary/src/domain/repositories/appointment_repository.dart';

/// Service for calculating pet health analytics and metrics
class AnalyticsService {
  final MedicationRepository medicationRepository;
  final WeightRepository weightRepository;
  final PurchaseRepository purchaseRepository;
  final FeedingRepository feedingRepository;
  final WalksRepository walksRepository;
  final AppointmentRepository appointmentRepository;

  AnalyticsService({
    required this.medicationRepository,
    required this.weightRepository,
    required this.purchaseRepository,
    required this.feedingRepository,
    required this.walksRepository,
    required this.appointmentRepository,
  });

  /// Calculate overall health score (0-100)
  /// Health Score = Weight stability (30%) + Med adherence (30%) + Activity (40%)
  Future<double> calculateHealthScore(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    double weightScore = 0.0;
    double medAdherenceScore = 0.0;
    double activityScore = 0.0;

    // Weight stability score (30%)
    final weightTrend = analyzeWeightTrend(petId);
    if (weightTrend == 'stable') {
      weightScore = 30.0;
    } else if (weightTrend == 'gaining' || weightTrend == 'losing') {
      weightScore = 20.0; // Some change, but tracked
    }

    // Medication adherence score (30%)
    final days = endDate.difference(startDate).inDays;
    final adherence = await calculateMedicationAdherence(petId, days);
    medAdherenceScore = (adherence / 100) * 30;

    // Activity score (40%)
    final activityLevels = await calculateActivityLevels(petId, days);
    final avgFeedings = activityLevels['avgFeedings'] ?? 0.0;
    final avgWalks = activityLevels['avgWalks'] ?? 0.0;

    // Ideal: 2-3 feedings, 1-2 walks per day
    final feedingScore =
        (avgFeedings >= 2.0 && avgFeedings <= 3.0) ? 20.0 : 10.0;
    final walkScore = (avgWalks >= 1.0 && avgWalks <= 2.0) ? 20.0 : 10.0;
    activityScore = feedingScore + walkScore;

    final totalScore = weightScore + medAdherenceScore + activityScore;
    return totalScore.clamp(0.0, 100.0);
  }

  /// Calculate medication adherence percentage
  /// Returns percentage (0-100) of medication compliance
  Future<double> calculateMedicationAdherence(String petId, int days) async {
    // Placeholder: Return dummy value for now
    // TODO: Implement actual adherence tracking based on scheduled vs administered doses
    return 85.0;
  }

  /// Calculate activity levels: feedings + walks per day average
  Future<Map<String, double>> calculateActivityLevels(
    String petId,
    int days,
  ) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    // Get feedings in date range
    final feedings = await feedingRepository.getFeedingsByDateRange(
      petId,
      startDate,
      endDate,
    );

    // Get walks in date range
    final walks = walksRepository.getWalksForPet(petId).where((walk) {
      return walk.startTime.isAfter(startDate) &&
          walk.startTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    final avgFeedings = days > 0 ? feedings.length / days : 0.0;
    final avgWalks = days > 0 ? walks.length / days : 0.0;

    return {
      'avgFeedings': avgFeedings,
      'avgWalks': avgWalks,
      'totalFeedings': feedings.length.toDouble(),
      'totalWalks': walks.length.toDouble(),
    };
  }

  /// Analyze weight trend: "stable", "gaining", "losing"
  String analyzeWeightTrend(String petId) {
    final entries = weightRepository.getWeightEntriesForPet(petId);

    if (entries.length < 2) {
      return 'stable'; // Not enough data
    }

    // Compare first vs last weight entry (sorted most recent first)
    final latestWeight = entries.first.weight;
    final earliestWeight = entries.last.weight;

    final difference = latestWeight - earliestWeight;
    final percentageChange = (difference / earliestWeight) * 100;

    if (percentageChange > 5.0) {
      return 'gaining';
    } else if (percentageChange < -5.0) {
      return 'losing';
    } else {
      return 'stable';
    }
  }

  /// Calculate total expenses from purchases in date range
  Future<double> calculateTotalExpenses(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return purchaseRepository.getTotalSpent(
      petId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get expense breakdown by category
  /// Categories: Medications, Appointments, Food, Other
  Future<Map<String, double>> getExpenseBreakdown(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final expenses =
        await calculateExpensesByCategory(petId, startDate, endDate);
    return expenses;
  }

  /// Calculate expenses by category with detailed breakdown
  /// Categories: Medications, Appointments, Food, Other
  Future<Map<String, double>> calculateExpensesByCategory(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Medication expenses
    final purchases = purchaseRepository.getPurchasesForPet(
      petId,
      startDate: startDate,
      endDate: endDate,
    );
    final medicationExpenses = purchases.fold(0.0, (sum, p) => sum + p.cost);

    // Appointment expenses
    // Note: AppointmentEntry doesn't track costs, so this is a placeholder
    const appointmentExpenses = 0.0;

    // Food expenses (estimated from feeding entries)
    // Note: This is a placeholder - could be enhanced with actual food purchase tracking
    const foodExpenses = 0.0;

    // Other expenses placeholder
    const otherExpenses = 0.0;

    final result = <String, double>{};

    if (medicationExpenses > 0) result['Medications'] = medicationExpenses;
    if (appointmentExpenses > 0) result['Appointments'] = appointmentExpenses;
    if (foodExpenses > 0) result['Food'] = foodExpenses;
    if (otherExpenses > 0) result['Other'] = otherExpenses;

    return result;
  }

  /// Calculate average weekly expenses
  Future<double> calculateAverageWeeklyExpenses(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final totalExpenses =
        await calculateTotalExpenses(petId, startDate, endDate);
    final days = endDate.difference(startDate).inDays;
    final weeks = days / 7.0;

    return weeks > 0 ? totalExpenses / weeks : 0.0;
  }

  /// Calculate average monthly expenses
  Future<double> calculateAverageMonthlyExpense(String petId) async {
    // Calculate for last 6 months
    final endDate = DateTime.now();
    final startDate = DateTime(
      endDate.year,
      endDate.month - 6,
      endDate.day,
    );

    final totalExpenses =
        await calculateTotalExpenses(petId, startDate, endDate);
    const months = 6.0;

    return totalExpenses / months;
  }

  /// Get monthly expense breakdown for charting
  Future<Map<String, double>> getMonthlyExpenses(
    String petId,
    int numberOfMonths,
  ) async {
    final endDate = DateTime.now();
    final monthlyExpenses = <String, double>{};

    for (int i = numberOfMonths - 1; i >= 0; i--) {
      final monthDate = DateTime(
        endDate.year,
        endDate.month - i,
        1,
      );
      final monthEnd = DateTime(
        monthDate.year,
        monthDate.month + 1,
        0,
        23,
        59,
        59,
      );

      final expenses = await calculateTotalExpenses(
        petId,
        monthDate,
        monthEnd,
      );

      // Format as "Jan", "Feb", etc.
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final monthKey = monthNames[monthDate.month - 1];

      monthlyExpenses[monthKey] = expenses;
    }

    return monthlyExpenses;
  }

  /// Get most expensive category
  Future<String> getMostExpensiveCategory(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final breakdown = await getExpenseBreakdown(petId, startDate, endDate);

    if (breakdown.isEmpty) return 'none';

    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }

  /// Get top expense categories sorted by amount
  Future<List<String>> getTopExpenseCategories(String petId) async {
    final endDate = DateTime.now();
    final startDate = DateTime(
      endDate.year,
      endDate.month - 3, // Last 3 months
      endDate.day,
    );

    final breakdown = await calculateExpensesByCategory(
      petId,
      startDate,
      endDate,
    );

    if (breakdown.isEmpty) return [];

    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).toList();
  }

  /// Get expense trend (increasing, decreasing, stable)
  Future<String> getExpenseTrend(String petId) async {
    final now = DateTime.now();

    // Get last month expenses
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    final lastMonthExpenses = await calculateTotalExpenses(
      petId,
      lastMonthStart,
      lastMonthEnd,
    );

    // Get previous month expenses
    final prevMonthStart = DateTime(now.year, now.month - 2, 1);
    final prevMonthEnd = DateTime(now.year, now.month - 1, 0);
    final prevMonthExpenses = await calculateTotalExpenses(
      petId,
      prevMonthStart,
      prevMonthEnd,
    );

    if (prevMonthExpenses == 0) return 'stable';

    final percentChange =
        ((lastMonthExpenses - prevMonthExpenses) / prevMonthExpenses) * 100;

    if (percentChange > 15) {
      return 'increasing';
    } else if (percentChange < -15) {
      return 'decreasing';
    } else {
      return 'stable';
    }
  }
}
