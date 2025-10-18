import 'package:flutter/material.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

/// Bottom sheet for selecting photo source (camera or gallery)
class AddPhotoSheet extends StatelessWidget {
  const AddPhotoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseMultiplePhotos),
              onTap: () => Navigator.of(context).pop('gallery_multiple'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(l10n.cancel),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  /// Show the add photo sheet and return the selected option
  static Future<String?> show(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddPhotoSheet(),
    );
  }
}

/// Dialog for permission denied state
class PermissionDeniedDialog extends StatelessWidget {
  final String message;
  final bool isPermanentlyDenied;

  const PermissionDeniedDialog({
    super.key,
    required this.message,
    required this.isPermanentlyDenied,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.permissionDenied),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        if (isPermanentlyDenied)
          FilledButton(
            onPressed: () async {
              await openAppSettings();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n.openSettings),
          ),
      ],
    );
  }

  /// Show permission denied dialog
  static Future<void> show(
    BuildContext context, {
    required String message,
    required bool isPermanentlyDenied,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => PermissionDeniedDialog(
        message: message,
        isPermanentlyDenied: isPermanentlyDenied,
      ),
    );
  }
}
