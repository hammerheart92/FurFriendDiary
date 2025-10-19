import '../models/report_entry.dart';

abstract class ReportRepository {
  Future<List<ReportEntry>> getAllReports();
  Future<List<ReportEntry>> getReportsByPetId(String petId);
  Future<void> addReport(ReportEntry report);
  Future<void> updateReport(ReportEntry report);
  Future<void> deleteReport(String id);
  Future<ReportEntry?> getReportById(String id);
  Future<List<ReportEntry>> getReportsByDateRange(
      String petId, DateTime start, DateTime end);
  Future<List<ReportEntry>> getReportsByType(String petId, String reportType);
}
