import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/data/services/analytics_service.dart';

/// Service for generating and sharing PDF reports
class PDFExportService {
  final AnalyticsService analyticsService;

  PDFExportService({required this.analyticsService});

  /// Generate a full health report PDF for a pet
  Future<String> generateHealthReport({
    required PetProfile pet,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    // Calculate analytics data
    final healthScore = await analyticsService.calculateHealthScore(
      pet.id,
      startDate,
      endDate,
    );
    final activityLevels = await analyticsService.calculateActivityLevels(
      pet.id,
      endDate.difference(startDate).inDays,
    );
    final medicationAdherence =
        await analyticsService.calculateMedicationAdherence(
      pet.id,
      endDate.difference(startDate).inDays,
    );
    final weightTrend = analyticsService.analyzeWeightTrend(pet.id);
    final totalExpenses = await analyticsService.calculateTotalExpenses(
      pet.id,
      startDate,
      endDate,
    );

    // Build PDF content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Pet Health Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Pet Information
              _buildSection('Pet Information', [
                _buildInfoRow('Name', pet.name),
                _buildInfoRow('Species', pet.species),
                _buildInfoRow('Breed', pet.breed ?? 'Unknown'),
                _buildInfoRow(
                    'Age',
                    pet.birthday != null
                        ? '${_calculateAge(pet.birthday!)} years'
                        : 'Unknown'),
              ]),
              pw.SizedBox(height: 20),

              // Report Period
              _buildSection('Report Period', [
                _buildInfoRow(
                  'From',
                  '${startDate.day}/${startDate.month}/${startDate.year}',
                ),
                _buildInfoRow(
                  'To',
                  '${endDate.day}/${endDate.month}/${endDate.year}',
                ),
              ]),
              pw.SizedBox(height: 20),

              // Health Metrics
              _buildSection('Health Metrics', [
                _buildInfoRow('Overall Health Score',
                    '${healthScore.toStringAsFixed(0)}/100'),
                _buildInfoRow('Medication Adherence',
                    '${medicationAdherence.toStringAsFixed(0)}%'),
                _buildInfoRow('Weight Trend', _formatWeightTrend(weightTrend)),
              ]),
              pw.SizedBox(height: 20),

              // Activity Summary
              _buildSection('Activity Summary', [
                _buildInfoRow('Total Feedings',
                    activityLevels['totalFeedings']?.toInt().toString() ?? '0'),
                _buildInfoRow('Total Walks',
                    activityLevels['totalWalks']?.toInt().toString() ?? '0'),
                _buildInfoRow('Avg Feedings/Day',
                    activityLevels['avgFeedings']?.toStringAsFixed(1) ?? '0.0'),
                _buildInfoRow('Avg Walks/Day',
                    activityLevels['avgWalks']?.toStringAsFixed(1) ?? '0.0'),
              ]),
              pw.SizedBox(height: 20),

              // Expenses
              _buildSection('Expenses', [
                _buildInfoRow(
                    'Total Expenses', '\$${totalExpenses.toStringAsFixed(2)}'),
              ]),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                'FurFriend Diary - Pet Health Management',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    return await _savePDF(pdf,
        'health_report_${pet.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// Generate a veterinary summary PDF (last 30 days)
  Future<String> generateVetSummary({
    required PetProfile pet,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));

    final pdf = pw.Document();

    // Calculate analytics data
    final healthScore = await analyticsService.calculateHealthScore(
      pet.id,
      startDate,
      endDate,
    );
    final activityLevels =
        await analyticsService.calculateActivityLevels(pet.id, 30);
    final medicationAdherence =
        await analyticsService.calculateMedicationAdherence(pet.id, 30);
    final weightTrend = analyticsService.analyzeWeightTrend(pet.id);

    // Build PDF content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Veterinary Summary',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Pet Information
              _buildSection('Pet Information', [
                _buildInfoRow('Name', pet.name),
                _buildInfoRow('Species', pet.species),
                _buildInfoRow('Breed', pet.breed ?? 'Unknown'),
                _buildInfoRow(
                    'Age',
                    pet.birthday != null
                        ? '${_calculateAge(pet.birthday!)} years'
                        : 'Unknown'),
              ]),
              pw.SizedBox(height: 20),

              // Summary Period
              pw.Text(
                'Last 30 Days Summary',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Health Status
              _buildSection('Health Status', [
                _buildInfoRow(
                    'Health Score', '${healthScore.toStringAsFixed(0)}/100'),
                _buildInfoRow('Medication Compliance',
                    '${medicationAdherence.toStringAsFixed(0)}%'),
                _buildInfoRow('Weight Trend', _formatWeightTrend(weightTrend)),
              ]),
              pw.SizedBox(height: 20),

              // Activity Overview
              _buildSection('Activity Overview', [
                _buildInfoRow('Daily Feedings (Avg)',
                    activityLevels['avgFeedings']?.toStringAsFixed(1) ?? '0.0'),
                _buildInfoRow('Daily Walks (Avg)',
                    activityLevels['avgWalks']?.toStringAsFixed(1) ?? '0.0'),
              ]),
              pw.SizedBox(height: 20),

              // Notes section
              _buildSection('Notes', [
                pw.Text(
                  'Please review the attached health data and discuss any concerns during the appointment.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ]),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
              pw.Text(
                'FurFriend Diary - Pet Health Management',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    return await _savePDF(pdf,
        'vet_summary_${pet.name}_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// Share a PDF file using the native share dialog
  Future<void> shareReport(String filePath) async {
    final file = XFile(filePath);
    await Share.shareXFiles(
      [file],
      subject: 'Pet Health Report',
      text: 'Here is the health report for my pet.',
    );
  }

  /// Generate a text summary for sharing
  Future<String> generateTextSummary({
    required PetProfile pet,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final healthScore = await analyticsService.calculateHealthScore(
      pet.id,
      startDate,
      endDate,
    );
    final activityLevels = await analyticsService.calculateActivityLevels(
      pet.id,
      endDate.difference(startDate).inDays,
    );
    final medicationAdherence =
        await analyticsService.calculateMedicationAdherence(
      pet.id,
      endDate.difference(startDate).inDays,
    );
    final weightTrend = analyticsService.analyzeWeightTrend(pet.id);

    final buffer = StringBuffer();
    buffer.writeln('🐾 Pet Health Summary');
    buffer.writeln('');
    buffer.writeln('Pet: ${pet.name} (${pet.breed ?? pet.species})');
    buffer.writeln(
        'Age: ${pet.birthday != null ? '${_calculateAge(pet.birthday!)} years' : 'Unknown'}');
    buffer.writeln('');
    buffer.writeln('Health Score: ${healthScore.toStringAsFixed(0)}/100');
    buffer.writeln(
        'Medication Adherence: ${medicationAdherence.toStringAsFixed(0)}%');
    buffer.writeln('Weight Trend: ${_formatWeightTrend(weightTrend)}');
    buffer.writeln('');
    buffer.writeln(
        'Activity (${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}):');
    buffer.writeln(
        '- Avg Feedings/Day: ${activityLevels['avgFeedings']?.toStringAsFixed(1) ?? '0.0'}');
    buffer.writeln(
        '- Avg Walks/Day: ${activityLevels['avgWalks']?.toStringAsFixed(1) ?? '0.0'}');
    buffer.writeln('');
    buffer.writeln('Generated by FurFriend Diary');

    return buffer.toString();
  }

  /// Share text summary
  Future<void> shareTextSummary(String summary) async {
    await Share.share(
      summary,
      subject: 'Pet Health Summary',
    );
  }

  // Helper methods

  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        ...children,
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  int _calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String _formatWeightTrend(String trend) {
    switch (trend) {
      case 'stable':
        return 'Stable';
      case 'gaining':
        return 'Gaining';
      case 'losing':
        return 'Losing';
      default:
        return 'Unknown';
    }
  }

  Future<String> _savePDF(pw.Document pdf, String fileName) async {
    // Get the Downloads directory (or Documents on iOS)
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    // Create reports subdirectory
    final reportsDir = Directory('${directory.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    // Save the PDF
    final file = File('${reportsDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
