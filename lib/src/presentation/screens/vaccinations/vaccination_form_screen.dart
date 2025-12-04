// File: lib/src/presentation/screens/vaccinations/vaccination_form_screen.dart
// Purpose: Form screen for adding or editing vaccination events
//
// Features:
// - Add new vaccination records
// - Edit existing vaccination records
// - Species-specific vaccine type dropdown (dogs vs cats)
// - Optional fields: batch number, vet name, clinic, notes, certificate photo
// - Date pickers for administered and next due dates
// - Image picker for certificate photos
// - Form validation with helpful error messages
// - Loading states during save operations

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../domain/models/vaccination_event.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/constants/vaccine_type_translations.dart';
import '../../providers/vaccinations_provider.dart';
import '../../providers/pet_profile_provider.dart';
import '../../../data/services/exif_stripper_service.dart';

/// Vaccination Form Screen - Add or edit vaccination events
///
/// **Usage:**
/// - Add mode: VaccinationFormScreen(petId: 'pet-uuid')
/// - Edit mode: VaccinationFormScreen(petId: 'pet-uuid', existingEvent: event)
///
/// **Vaccine Types by Species:**
/// - Dogs: DHPPiL, Rabies, Bordetella
/// - Cats: FVRCP, Rabies, FeLV
///
/// **Validation:**
/// - Vaccine type is required
/// - All other fields are optional
///
/// **State Management:**
/// - Uses vaccinationProviderProvider for CRUD operations
/// - Invalidates provider after mutations
class VaccinationFormScreen extends ConsumerStatefulWidget {
  final String petId;
  final VaccinationEvent? existingEvent;

  const VaccinationFormScreen({
    super.key,
    required this.petId,
    this.existingEvent,
  });

  @override
  ConsumerState<VaccinationFormScreen> createState() =>
      _VaccinationFormScreenState();
}

class _VaccinationFormScreenState
    extends ConsumerState<VaccinationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _batchNumberController = TextEditingController();
  final _veterinarianNameController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedVaccineType;
  DateTime _administeredDate = DateTime.now();
  DateTime? _nextDueDate;
  bool _isLoading = false;
  final List<String> _certificatePhotoPaths = [];

  // Species-specific vaccine types
  final Map<String, List<String>> _vaccineTypesBySpecies = {
    'Dog': ['DHPPiL', 'Rabies', 'Bordetella'],
    'Cat': ['FVRCP', 'Rabies', 'FeLV'],
  };

  @override
  void initState() {
    super.initState();
    _prefillFormIfEditing();
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _veterinarianNameController.dispose();
    _clinicNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Pre-fill form fields when editing an existing vaccination
  void _prefillFormIfEditing() {
    final event = widget.existingEvent;
    if (event != null) {
      _selectedVaccineType = event.vaccineType;
      _administeredDate = event.administeredDate;
      _nextDueDate = event.nextDueDate;
      _batchNumberController.text = event.batchNumber ?? '';
      _veterinarianNameController.text = event.veterinarianName ?? '';
      _clinicNameController.text = event.clinicName ?? '';
      _notesController.text = event.notes ?? '';
      if (event.certificatePhotoUrls != null) {
        _certificatePhotoPaths.addAll(event.certificatePhotoUrls!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existingEvent != null;

    // Get current pet to determine species for vaccine types
    final currentPet = ref.watch(currentPetProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editVaccination : l10n.addVaccination,
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveVaccination,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: _isLoading
                    ? theme.colorScheme.onPrimary.withOpacity(0.5)
                    : theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Basic Information Card
                  _buildBasicInformationCard(theme, l10n, currentPet),
                  const SizedBox(height: 16),

                  // Dates Card
                  _buildDatesCard(theme, l10n),
                  const SizedBox(height: 16),

                  // Veterinary Details Card
                  _buildVeterinaryDetailsCard(theme, l10n),
                  const SizedBox(height: 16),

                  // Certificate Photos Card
                  _buildCertificatePhotosCard(theme, l10n),
                  const SizedBox(height: 16),

                  // Notes Card
                  _buildNotesCard(theme, l10n),
                  const SizedBox(height: 32),

                  // Save Button
                  _buildSaveButton(theme, l10n, isEditing),
                ],
              ),
            ),
    );
  }

  // ========================================================================
  // CARD BUILDERS
  // ========================================================================

  Widget _buildBasicInformationCard(
    ThemeData theme,
    AppLocalizations l10n,
    PetProfile? currentPet,
  ) {
    // Determine vaccine types based on pet species
    final List<String> availableVaccineTypes = currentPet != null &&
            _vaccineTypesBySpecies.containsKey(currentPet.species)
        ? _vaccineTypesBySpecies[currentPet.species]!
        : [
            'DHPPiL',
            'Rabies',
            'Bordetella',
            'FVRCP',
            'FeLV'
          ]; // Fallback to all

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vaccines,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.vaccinationInformation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vaccine Type Dropdown (Required)
            // ISSUE 3 FIX: Display translated vaccine type names but store English values
            DropdownButtonFormField<String>(
              value: _selectedVaccineType,
              decoration: InputDecoration(
                labelText: l10n.vaccineType,
                hintText: l10n.selectVaccineType,
                prefixIcon: Icon(
                  Icons.medical_services,
                  color: theme.colorScheme.primary,
                ),
                border: const OutlineInputBorder(),
              ),
              isExpanded: true,
              items: availableVaccineTypes.map((type) {
                // Get locale for display name translation
                final locale = Localizations.localeOf(context);
                final displayName = VaccineTypeTranslations.getDisplayName(
                  type,
                  locale.languageCode,
                );
                return DropdownMenuItem(
                  value: type, // Store English value in database
                  child: Text(displayName), // Display translated name
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVaccineType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseSelectVaccineType;
                }
                return null;
              },
            ),

            // Pet species indicator (helpful context)
            if (currentPet != null) ...[
              const SizedBox(height: 8),
              Semantics(
                label: '${l10n.petSpecies}: ${currentPet.species}',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${l10n.vaccinesFor} ${currentPet.species}s',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatesCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dates,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Administered Date (Required)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.administeredDate),
              subtitle: Text(
                DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                    .format(_administeredDate),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(Icons.edit, size: 20),
              onTap: _selectAdministeredDate,
            ),

            const Divider(),

            // Next Due Date (Optional)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.event_available,
                color: _nextDueDate != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              title: Text(l10n.nextDueDate),
              subtitle: _nextDueDate != null
                  ? Text(
                      DateFormat.yMMMd(
                              Localizations.localeOf(context).languageCode)
                          .format(_nextDueDate!),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Text(
                      l10n.optional,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
              trailing: _nextDueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _nextDueDate = null;
                        });
                      },
                    )
                  : const Icon(Icons.add, size: 20),
              onTap: _selectNextDueDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinaryDetailsCard(
      ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.veterinaryDetails,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.optionalFields,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Batch Number
            TextFormField(
              controller: _batchNumberController,
              decoration: InputDecoration(
                labelText: l10n.batchNumber,
                hintText: l10n.batchNumberHint,
                prefixIcon: Icon(Icons.qr_code_2),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Veterinarian Name
            TextFormField(
              controller: _veterinarianNameController,
              decoration: InputDecoration(
                labelText: l10n.veterinarianName,
                hintText: l10n.veterinarianNameHint,
                prefixIcon: Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Clinic Name
            TextFormField(
              controller: _clinicNameController,
              decoration: InputDecoration(
                labelText: l10n.clinicName,
                hintText: l10n.clinicNameHint,
                prefixIcon: Icon(Icons.local_hospital),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatePhotosCard(
      ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_library,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.certificatePhotos,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _pickCertificatePhoto,
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: Text(l10n.addPhoto),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.optionalCertificateHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            // Display selected photos
            if (_certificatePhotoPaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _certificatePhotoPaths.asMap().entries.map((entry) {
                  final index = entry.key;
                  final path = entry.value;
                  return _buildPhotoThumbnail(path, index, theme);
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(String path, int index, ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeCertificatePhoto(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.additionalNotes,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.vaccinationNotesHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
      ThemeData theme, AppLocalizations l10n, bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveVaccination,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isEditing ? l10n.updateVaccination : l10n.saveVaccination,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // ========================================================================
  // DATE PICKERS
  // ========================================================================

  Future<void> _selectAdministeredDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _administeredDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _administeredDate = picked;
      });
    }
  }

  Future<void> _selectNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? _administeredDate.add(const Duration(days: 365)),
      firstDate: _administeredDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  // ========================================================================
  // IMAGE PICKER
  // ========================================================================

  Future<void> _pickCertificatePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      // Strip EXIF metadata for GDPR compliance (data minimization)
      final exifStripper = ExifStripperService();
      final cleanedPath = await exifStripper.stripExifFromFile(image.path);

      // Delete original cached file with EXIF data for GDPR compliance
      try {
        final originalFile = File(image.path);
        if (await originalFile.exists()) {
          await originalFile.delete();
        }
      } catch (_) {
        // Ignore cleanup errors - original may already be deleted
      }

      setState(() {
        _certificatePhotoPaths.add(cleanedPath);
      });
    }
  }

  void _removeCertificatePhoto(int index) {
    setState(() {
      _certificatePhotoPaths.removeAt(index);
    });
  }

  // ========================================================================
  // SAVE LOGIC
  // ========================================================================

  Future<void> _saveVaccination() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final event = VaccinationEvent(
        id: widget.existingEvent?.id,
        petId: widget.petId,
        vaccineType: _selectedVaccineType!,
        administeredDate: _administeredDate,
        nextDueDate: _nextDueDate,
        batchNumber: _batchNumberController.text.trim().isEmpty
            ? null
            : _batchNumberController.text.trim(),
        veterinarianName: _veterinarianNameController.text.trim().isEmpty
            ? null
            : _veterinarianNameController.text.trim(),
        clinicName: _clinicNameController.text.trim().isEmpty
            ? null
            : _clinicNameController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        certificatePhotoUrls: _certificatePhotoPaths.isEmpty
            ? null
            : _certificatePhotoPaths,
        isFromProtocol: widget.existingEvent?.isFromProtocol ?? false,
        protocolId: widget.existingEvent?.protocolId,
        protocolStepIndex: widget.existingEvent?.protocolStepIndex,
        createdAt: widget.existingEvent?.createdAt,
        updatedAt: widget.existingEvent != null ? DateTime.now() : null,
      );

      if (widget.existingEvent != null) {
        // Update existing event
        await ref.read(vaccinationProviderProvider.notifier).updateVaccination(event);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.vaccinationUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new event
        await ref.read(vaccinationProviderProvider.notifier).addVaccination(event);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.vaccinationAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingEvent != null
                  ? l10n.failedToUpdateVaccination(error.toString())
                  : l10n.failedToAddVaccination(error.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
