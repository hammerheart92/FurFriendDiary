import 'package:flutter/material.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

enum ExportOption {
  fullReport,
  vetSummary,
  textSummary,
}

/// Dialog for selecting export options
class ExportOptionsDialog extends StatelessWidget {
  const ExportOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.exportOptions),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(l10n.fullReport),
            subtitle: Text(l10n.fullReportDescription),
            onTap: () => Navigator.of(context).pop(ExportOption.fullReport),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.medical_information),
            title: Text(l10n.vetSummary),
            subtitle: Text(l10n.vetSummaryDescription),
            onTap: () => Navigator.of(context).pop(ExportOption.vetSummary),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.text_snippet),
            title: Text(l10n.shareText),
            subtitle: Text(l10n.shareTextDescription),
            onTap: () => Navigator.of(context).pop(ExportOption.textSummary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}

/// Show export options dialog and return selected option
Future<ExportOption?> showExportOptionsDialog(BuildContext context) async {
  return await showDialog<ExportOption>(
    context: context,
    builder: (context) => const ExportOptionsDialog(),
  );
}
