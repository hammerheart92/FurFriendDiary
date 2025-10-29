import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/data/services/analytics_service.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

/// Service for generating and sharing PDF reports
class PDFExportService {
  final AnalyticsService analyticsService;

  // Cached fonts to avoid reloading on every PDF generation
  pw.Font? _regularFont;
  pw.Font? _boldFont;

  PDFExportService({required this.analyticsService});

  /// Load fonts from assets (supports Romanian diacritics: ă, â, î, ș, ț)
  /// Falls back to built-in fonts if custom fonts fail to load
  Future<void> _loadFonts() async {
    if (_regularFont == null || _boldFont == null) {
      try {
        // Try to load custom fonts from assets
        final regularData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
        final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

        _regularFont = pw.Font.ttf(regularData);
        _boldFont = pw.Font.ttf(boldData);
      } catch (e) {
        // Fallback to built-in fonts if custom fonts fail
        // Note: Built-in fonts don't support Romanian diacritics (ă, â, î, ș, ț)
        _regularFont = pw.Font.helvetica();
        _boldFont = pw.Font.helveticaBold();
      }
    }
  }

  /// Generate a full health report PDF for a pet
  Future<String> generateHealthReport({
    required PetProfile pet,
    required DateTime startDate,
    required DateTime endDate,
    required AppLocalizations l10n,
  }) async {
    // Load fonts with Romanian character support
    await _loadFonts();

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
                l10n.pdfPetHealthReport,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: _boldFont,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Pet Information
              _buildSection(l10n.pdfPetInformation, [
                _buildInfoRow(l10n.pdfName, pet.name),
                _buildInfoRow(l10n.pdfSpecies, _translateSpecies(pet.species, l10n)),
                _buildInfoRow(l10n.pdfBreed, pet.breed ?? l10n.pdfUnknown),
                _buildInfoRow(
                    l10n.pdfAge,
                    pet.birthday != null
                        ? '${_calculateAge(pet.birthday!)} ${l10n.pdfYears}'
                        : l10n.pdfUnknown),
              ]),
              pw.SizedBox(height: 20),

              // Report Period
              _buildSection(l10n.pdfReportPeriod, [
                _buildInfoRow(
                  l10n.pdfFrom,
                  '${startDate.day}/${startDate.month}/${startDate.year}',
                ),
                _buildInfoRow(
                  l10n.pdfTo,
                  '${endDate.day}/${endDate.month}/${endDate.year}',
                ),
              ]),
              pw.SizedBox(height: 20),

              // Health Metrics
              _buildSection(l10n.pdfHealthMetrics, [
                _buildInfoRow(l10n.pdfOverallHealthScore,
                    '${healthScore.toStringAsFixed(0)}/100'),
                _buildInfoRow(l10n.pdfMedicationAdherence,
                    '${medicationAdherence.toStringAsFixed(0)}%'),
                _buildInfoRow(l10n.pdfWeightTrend, _formatWeightTrend(weightTrend, l10n)),
              ]),
              pw.SizedBox(height: 20),

              // Activity Summary
              _buildSection(l10n.pdfActivitySummary, [
                _buildInfoRow(l10n.pdfTotalFeedings,
                    activityLevels['totalFeedings']?.toInt().toString() ?? '0'),
                _buildInfoRow(l10n.pdfTotalWalks,
                    activityLevels['totalWalks']?.toInt().toString() ?? '0'),
                _buildInfoRow(l10n.pdfAvgFeedingsPerDay,
                    activityLevels['avgFeedings']?.toStringAsFixed(1) ?? '0.0'),
                _buildInfoRow(l10n.pdfAvgWalksPerDay,
                    activityLevels['avgWalks']?.toStringAsFixed(1) ?? '0.0'),
              ]),
              pw.SizedBox(height: 20),

              // Expenses
              _buildSection(l10n.pdfExpenses, [
                _buildInfoRow(
                    l10n.pdfTotalExpenses, '\$${totalExpenses.toStringAsFixed(2)}'),
              ]),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                '${l10n.pdfGeneratedOn} ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey, font: _regularFont),
              ),
              pw.Text(
                l10n.pdfFooter,
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey, font: _regularFont),
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
    required AppLocalizations l10n,
  }) async {
    // Load fonts with Romanian character support
    await _loadFonts();

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
                l10n.pdfVeterinarySummary,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: _boldFont,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Pet Information
              _buildSection(l10n.pdfPetInformation, [
                _buildInfoRow(l10n.pdfName, pet.name),
                _buildInfoRow(l10n.pdfSpecies, _translateSpecies(pet.species, l10n)),
                _buildInfoRow(l10n.pdfBreed, pet.breed ?? l10n.pdfUnknown),
                _buildInfoRow(
                    l10n.pdfAge,
                    pet.birthday != null
                        ? '${_calculateAge(pet.birthday!)} ${l10n.pdfYears}'
                        : l10n.pdfUnknown),
              ]),
              pw.SizedBox(height: 20),

              // Summary Period
              pw.Text(
                l10n.pdfLast30DaysSummary,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: _boldFont,
                ),
              ),
              pw.SizedBox(height: 10),

              // Health Status
              _buildSection(l10n.pdfHealthStatus, [
                _buildInfoRow(
                    l10n.pdfHealthScore, '${healthScore.toStringAsFixed(0)}/100'),
                _buildInfoRow(l10n.pdfMedicationCompliance,
                    '${medicationAdherence.toStringAsFixed(0)}%'),
                _buildInfoRow(l10n.pdfWeightTrend, _formatWeightTrend(weightTrend, l10n)),
              ]),
              pw.SizedBox(height: 20),

              // Activity Overview
              _buildSection(l10n.pdfActivityOverview, [
                _buildInfoRow(l10n.pdfDailyFeedingsAvg,
                    activityLevels['avgFeedings']?.toStringAsFixed(1) ?? '0.0'),
                _buildInfoRow(l10n.pdfDailyWalksAvg,
                    activityLevels['avgWalks']?.toStringAsFixed(1) ?? '0.0'),
              ]),
              pw.SizedBox(height: 20),

              // Notes section
              _buildSection(l10n.pdfNotes, [
                pw.Text(
                  l10n.pdfNotesText,
                  style: pw.TextStyle(fontSize: 12, font: _regularFont),
                ),
              ]),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                '${l10n.pdfGeneratedOn} ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey, font: _regularFont),
              ),
              pw.Text(
                l10n.pdfFooter,
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey, font: _regularFont),
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
  Future<void> shareReport(
    String filePath, {
    String? subject,
    String? text,
  }) async {
    final file = XFile(filePath);
    await Share.shareXFiles(
      [file],
      subject: subject ?? 'Pet Health Report',
      text: text ?? 'Here is the health report for my pet.',
    );
  }

  /// Generate a text summary for sharing
  Future<String> generateTextSummary({
    required PetProfile pet,
    required DateTime startDate,
    required DateTime endDate,
    required AppLocalizations l10n,
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
    buffer.writeln('Weight Trend: ${_formatWeightTrend(weightTrend, l10n)}');
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
  Future<void> shareTextSummary(String summary, {String? subject}) async {
    await Share.share(
      summary,
      subject: subject ?? 'Pet Health Summary',
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
            font: _boldFont,
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
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: _boldFont),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(value, style: pw.TextStyle(font: _regularFont)),
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

  String _formatWeightTrend(String trend, AppLocalizations l10n) {
    switch (trend) {
      case 'stable':
        return l10n.pdfStable;
      case 'gaining':
        return l10n.pdfGaining;
      case 'losing':
        return l10n.pdfLosing;
      default:
        return l10n.pdfUnknown;
    }
  }

  String _translateSpecies(String species, AppLocalizations l10n) {
    switch (species.toLowerCase()) {
      case 'cat':
        return l10n.pdfCat;
      case 'dog':
        return l10n.pdfDog;
      default:
        return species;
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
