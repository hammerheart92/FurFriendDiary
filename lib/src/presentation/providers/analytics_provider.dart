import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fur_friend_diary/src/data/services/analytics_service.dart';
import 'package:fur_friend_diary/src/data/services/pdf_export_service.dart';
import 'package:fur_friend_diary/src/data/services/recommendations_service.dart';
import 'package:fur_friend_diary/src/data/repositories/medication_repository_impl.dart';
import 'package:fur_friend_diary/src/data/repositories/feeding_repository_impl.dart';
import 'package:fur_friend_diary/src/data/repositories/appointment_repository_impl.dart';
import 'package:fur_friend_diary/src/presentation/providers/weight_provider.dart';
import 'package:fur_friend_diary/src/providers/inventory_providers.dart';
import 'package:fur_friend_diary/src/providers/providers.dart';

part 'analytics_provider.g.dart';

/// Provider for AnalyticsService instance
@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  final medicationRepository = ref.watch(medicationRepositoryProvider);
  final weightRepository = ref.watch(weightRepositoryProvider);
  final purchaseRepository = ref.watch(purchaseRepositoryProvider);
  final feedingRepository = ref.watch(feedingRepositoryProvider);
  final walksRepository = ref.watch(walksRepositoryProvider);
  final appointmentRepository = ref.watch(appointmentRepositoryProvider);

  return AnalyticsService(
    medicationRepository: medicationRepository,
    weightRepository: weightRepository,
    purchaseRepository: purchaseRepository,
    feedingRepository: feedingRepository,
    walksRepository: walksRepository,
    appointmentRepository: appointmentRepository,
  );
}

/// Provider for calculating health score for a pet over the last 30 days
@riverpod
Future<double> healthScore(HealthScoreRef ref, String petId) async {
  final service = ref.watch(analyticsServiceProvider);
  final endDate = DateTime.now();
  final startDate = endDate.subtract(const Duration(days: 30));

  return await service.calculateHealthScore(petId, startDate, endDate);
}

/// Provider for calculating medication adherence
@riverpod
Future<double> medicationAdherence(
  MedicationAdherenceRef ref,
  ({String petId, int days}) params,
) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.calculateMedicationAdherence(params.petId, params.days);
}

/// Provider for activity levels
@riverpod
Future<Map<String, double>> activityLevels(
  ActivityLevelsRef ref,
  ({String petId, int days}) params,
) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.calculateActivityLevels(params.petId, params.days);
}

/// Provider for weight trend analysis
@riverpod
String weightTrend(WeightTrendRef ref, String petId) {
  final service = ref.watch(analyticsServiceProvider);
  return service.analyzeWeightTrend(petId);
}

/// Provider for total expenses in date range
@riverpod
Future<double> totalExpenses(
  TotalExpensesRef ref,
  String petId,
  DateTime startDate,
  DateTime endDate,
) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.calculateTotalExpenses(petId, startDate, endDate);
}

/// Provider for expense breakdown by category
@riverpod
Future<Map<String, double>> expenseBreakdown(
  ExpenseBreakdownRef ref,
  String petId,
  DateTime startDate,
  DateTime endDate,
) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getExpenseBreakdown(petId, startDate, endDate);
}

/// Provider for average weekly expenses
@riverpod
Future<double> averageWeeklyExpenses(
  AverageWeeklyExpensesRef ref,
  String petId,
  DateTime startDate,
  DateTime endDate,
) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.calculateAverageWeeklyExpenses(
      petId, startDate, endDate);
}

/// Provider for monthly expenses (current month)
@riverpod
Future<double> monthlyExpenses(MonthlyExpensesRef ref, String petId) async {
  final service = ref.watch(analyticsServiceProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  return await service.calculateTotalExpenses(petId, startOfMonth, now);
}

/// Provider for expenses by category
@riverpod
Future<Map<String, double>> expensesByCategory(
  ExpensesByCategoryRef ref,
  String petId,
  DateTime startDate,
  DateTime endDate,
) async {
  try {
    final service = ref.watch(analyticsServiceProvider);
    final expenses = await service
        .calculateExpensesByCategory(petId, startDate, endDate)
        .timeout(const Duration(seconds: 5));
    return expenses;
  } catch (e) {
    // Return empty map on error - don't block UI
    return <String, double>{};
  }
}

/// Provider for average monthly expenses (last 6 months)
@riverpod
Future<double> averageMonthlyExpense(
  AverageMonthlyExpenseRef ref,
  String petId,
) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.calculateAverageMonthlyExpense(petId);
}

/// Provider for monthly expenses chart data
@riverpod
Future<Map<String, double>> monthlyExpensesChart(
  MonthlyExpensesChartRef ref,
  String petId,
  int numberOfMonths,
) async {
  try {
    final service = ref.watch(analyticsServiceProvider);
    final expenses = await service
        .getMonthlyExpenses(petId, numberOfMonths)
        .timeout(const Duration(seconds: 5));
    return expenses;
  } catch (e) {
    // Return empty map on error - don't block UI
    return <String, double>{};
  }
}

/// Provider for top expense categories
@riverpod
Future<List<String>> topExpenseCategories(
  TopExpenseCategoriesRef ref,
  String petId,
) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getTopExpenseCategories(petId);
}

/// Provider for expense trend
@riverpod
Future<String> expenseTrend(ExpenseTrendRef ref, String petId) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getExpenseTrend(petId);
}

/// Provider for PDFExportService instance
@riverpod
PDFExportService pdfExportService(PdfExportServiceRef ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return PDFExportService(analyticsService: analyticsService);
}

/// Provider for RecommendationsService instance
@riverpod
RecommendationsService recommendationsService(RecommendationsServiceRef ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return RecommendationsService(analyticsService);
}

/// Provider for pet recommendations
@riverpod
Future<List<String>> recommendations(
  RecommendationsRef ref,
  String petId,
) async {
  try {
    final service = ref.watch(recommendationsServiceProvider);
    final recommendations = await service
        .generateRecommendations(petId)
        .timeout(const Duration(seconds: 10));
    return recommendations;
  } catch (e) {
    // Return empty list on error - don't block UI
    return <String>[];
  }
}
