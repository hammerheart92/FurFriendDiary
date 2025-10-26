import 'package:fur_friend_diary/src/data/services/analytics_service.dart';

/// Recommendation key constants for localization
class RecommendationKeys {
  static const setMedicationReminders = 'recSetMedicationReminders';
  static const considerVetWeightGain = 'recConsiderVetWeightGain';
  static const considerVetWeightLoss = 'recConsiderVetWeightLoss';
  static const increaseDailyWalks = 'recIncreaseDailyWalks';
  static const reviewMedicationCosts = 'recReviewMedicationCosts';
  static const scheduleVetCheckup = 'recScheduleVetCheckup';
}

/// Service for generating smart recommendations based on pet data
class RecommendationsService {
  final AnalyticsService analyticsService;

  RecommendationsService(this.analyticsService);

  /// Generate top 3 recommendations for a pet based on their health data
  /// Returns recommendation keys that should be translated in the UI layer
  Future<List<String>> generateRecommendations(String petId) async {
    final recommendations = <String>[];

    // Check medication adherence
    final adherence =
        await analyticsService.calculateMedicationAdherence(petId, 30);
    if (adherence < 80) {
      recommendations.add(RecommendationKeys.setMedicationReminders);
    }

    // Check weight trend
    final weightTrend = analyticsService.analyzeWeightTrend(petId);
    if (weightTrend == 'gaining') {
      recommendations.add(RecommendationKeys.considerVetWeightGain);
    } else if (weightTrend == 'losing') {
      recommendations.add(RecommendationKeys.considerVetWeightLoss);
    }

    // Check activity levels
    final activity = await analyticsService.calculateActivityLevels(petId, 30);
    final avgWalks = activity['avgWalks'] ?? 0.0;
    if (avgWalks < 1.0) {
      recommendations.add(RecommendationKeys.increaseDailyWalks);
    }

    // Check expense trend
    final expenseTrend = await analyticsService.getExpenseTrend(petId);
    if (expenseTrend == 'increasing') {
      recommendations.add(RecommendationKeys.reviewMedicationCosts);
    }

    // Check health score
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final healthScore = await analyticsService.calculateHealthScore(
      petId,
      startDate,
      endDate,
    );

    if (healthScore < 60) {
      recommendations.add(RecommendationKeys.scheduleVetCheckup);
    }

    // Return top 3 recommendations
    return recommendations.take(3).toList();
  }
}
