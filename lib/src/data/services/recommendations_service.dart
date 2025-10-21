import 'package:fur_friend_diary/src/data/services/analytics_service.dart';

/// Service for generating smart recommendations based on pet data
class RecommendationsService {
  final AnalyticsService analyticsService;

  RecommendationsService(this.analyticsService);

  /// Generate top 3 recommendations for a pet based on their health data
  Future<List<String>> generateRecommendations(String petId) async {
    final recommendations = <String>[];

    // Check medication adherence
    final adherence = await analyticsService.calculateMedicationAdherence(petId, 30);
    if (adherence < 80) {
      recommendations.add('Set more medication reminders to improve adherence');
    }

    // Check weight trend
    final weightTrend = analyticsService.analyzeWeightTrend(petId);
    if (weightTrend == 'gaining') {
      recommendations.add('Consider vet consultation about weight gain');
    } else if (weightTrend == 'losing') {
      recommendations.add('Consider vet consultation about weight loss');
    }

    // Check activity levels
    final activity = await analyticsService.calculateActivityLevels(petId, 30);
    final avgWalks = activity['avgWalks'] ?? 0.0;
    if (avgWalks < 1.0) {
      recommendations.add('Increase daily walks for better health');
    }

    // Check expense trend
    final expenseTrend = await analyticsService.getExpenseTrend(petId);
    if (expenseTrend == 'increasing') {
      recommendations.add('Review medication costs with your vet');
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
      recommendations.add('Health score is low - schedule a vet checkup');
    }

    // Return top 3 recommendations
    return recommendations.take(3).toList();
  }
}
