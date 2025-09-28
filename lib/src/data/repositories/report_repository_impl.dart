import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../domain/models/report_entry.dart';
import '../../domain/repositories/report_repository.dart';
import '../local/hive_boxes.dart';

part 'report_repository_impl.g.dart';

class ReportRepositoryImpl implements ReportRepository {
  final logger = Logger();

  @override
  Future<List<ReportEntry>> getAllReports() async {
    try {
      final box = HiveBoxes.getReports();
      final reports = box.values.toList();
      // Sort by creation date, newest first
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i("🔍 DEBUG: Retrieved ${reports.length} reports from Hive");
      return reports;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get all reports: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReportEntry>> getReportsByPetId(String petId) async {
    try {
      final box = HiveBoxes.getReports();
      final reports = box.values
          .where((report) => report.petId == petId)
          .toList();
      // Sort by creation date, newest first
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      logger.i("🔍 DEBUG: Retrieved ${reports.length} reports for pet $petId");
      return reports;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get reports for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<void> addReport(ReportEntry report) async {
    try {
      final box = HiveBoxes.getReports();
      await box.put(report.id, report);
      logger.i("✅ DEBUG: Added report '${report.reportType}' with ID ${report.id}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to add report '${report.reportType}': $e");
      rethrow;
    }
  }

  @override
  Future<void> updateReport(ReportEntry report) async {
    try {
      final box = HiveBoxes.getReports();
      await box.put(report.id, report);
      logger.i("✅ DEBUG: Updated report '${report.reportType}' with ID ${report.id}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to update report '${report.reportType}': $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      final box = HiveBoxes.getReports();
      final report = box.get(id);
      await box.delete(id);
      logger.i("✅ DEBUG: Deleted report with ID $id${report != null ? " ('${report.reportType}')" : ""}");
    } catch (e) {
      logger.e("🚨 ERROR: Failed to delete report with ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<ReportEntry?> getReportById(String id) async {
    try {
      final box = HiveBoxes.getReports();
      final report = box.get(id);
      if (report != null) {
        logger.i("🔍 DEBUG: Found report '${report.reportType}' with ID $id");
      } else {
        logger.w("⚠️ DEBUG: No report found with ID $id");
      }
      return report;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get report by ID $id: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReportEntry>> getReportsByDateRange(String petId, DateTime start, DateTime end) async {
    try {
      final box = HiveBoxes.getReports();
      final reports = box.values
          .where((report) =>
              report.petId == petId &&
              report.startDate.isAfter(start) &&
              report.endDate.isBefore(end))
          .toList();
      // Sort by generation date, newest first
      reports.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
      logger.i("🔍 DEBUG: Retrieved ${reports.length} reports for pet $petId in date range");
      return reports;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get reports by date range for pet $petId: $e");
      rethrow;
    }
  }

  @override
  Future<List<ReportEntry>> getReportsByType(String petId, String reportType) async {
    try {
      final box = HiveBoxes.getReports();
      final reports = box.values
          .where((report) => report.petId == petId && report.reportType == reportType)
          .toList();
      // Sort by generation date, newest first
      reports.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));
      logger.i("🔍 DEBUG: Retrieved ${reports.length} '$reportType' reports for pet $petId");
      return reports;
    } catch (e) {
      logger.e("🚨 ERROR: Failed to get '$reportType' reports for pet $petId: $e");
      rethrow;
    }
  }
}

@riverpod
ReportRepository reportRepository(ReportRepositoryRef ref) {
  return ReportRepositoryImpl();
}