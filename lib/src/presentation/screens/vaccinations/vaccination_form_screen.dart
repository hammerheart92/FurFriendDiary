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
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';
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

class _VaccinationFormScreenState extends ConsumerState<VaccinationFormScreen> {
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
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existingEvent != null;

    // Design tokens
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    // Get current pet to determine species for vaccine types
    final currentPet = ref.watch(currentPetProfileProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        title: Text(
          isEditing ? l10n.editVaccination : l10n.addVaccination,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveVaccination,
            child: Text(
              l10n.save,
              style: GoogleFonts.inter(
                color: _isLoading
                    ? DesignColors.highlightPurple.withOpacity(0.5)
                    : DesignColors.highlightPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: DesignColors.highlightPurple,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(DesignSpacing.md),
                children: [
                  // Basic Information Card
                  _buildBasicInformationCard(theme, l10n, isDark, currentPet),
                  SizedBox(height: DesignSpacing.md),

                  // Dates Card
                  _buildDatesCard(theme, l10n, isDark),
                  SizedBox(height: DesignSpacing.md),

                  // Veterinary Details Card
                  _buildVeterinaryDetailsCard(theme, l10n, isDark),
                  SizedBox(height: DesignSpacing.md),

                  // Certificate Photos Card
                  _buildCertificatePhotosCard(theme, l10n, isDark),
                  SizedBox(height: DesignSpacing.md),

                  // Notes Card
                  _buildNotesCard(theme, l10n, isDark),
                  SizedBox(height: DesignSpacing.xl),

                  // Save Button
                  _buildSaveButton(theme, l10n, isDark, isEditing),
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
    bool isDark,
    PetProfile? currentPet,
  ) {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

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

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DesignColors.highlightPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.vaccines,
                    color: DesignColors.highlightPurple,
                    size: 24,
                  ),
                ),
                SizedBox(width: DesignSpacing.sm),
                Text(
                  l10n.vaccinationInformation,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.md),

            // Vaccine Type Dropdown (Required)
            DropdownButtonFormField<String>(
              value: _selectedVaccineType,
              decoration: InputDecoration(
                labelText: l10n.vaccineType,
                labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                hintText: l10n.selectVaccineType,
                prefixIcon: Icon(
                  Icons.medical_services,
                  color: DesignColors.highlightPurple,
                ),
                filled: true,
                fillColor: surfaceColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: disabledColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: DesignColors.highlightPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? DesignColors.dDanger : DesignColors.lDanger),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? DesignColors.dDanger : DesignColors.lDanger, width: 2),
                ),
              ),
              isExpanded: true,
              items: availableVaccineTypes.map((type) {
                final locale = Localizations.localeOf(context);
                final displayName = VaccineTypeTranslations.getDisplayName(
                  type,
                  locale.languageCode,
                );
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    displayName,
                    style: GoogleFonts.inter(color: primaryText),
                  ),
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
              SizedBox(height: DesignSpacing.sm),
              Semantics(
                label: '${l10n.petSpecies}: ${currentPet.species}',
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignSpacing.sm,
                    vertical: DesignSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColors.highlightTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 16,
                        color: DesignColors.highlightTeal,
                      ),
                      SizedBox(width: DesignSpacing.xs),
                      Text(
                        '${l10n.vaccinesFor} ${currentPet.species}s',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: DesignColors.highlightTeal,
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

  Widget _buildDatesCard(ThemeData theme, AppLocalizations l10n, bool isDark) {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dates,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.md),

            // Administered Date (Required)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: disabledColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm),
                leading: Icon(
                  Icons.calendar_today,
                  color: DesignColors.highlightPurple,
                ),
                title: Text(
                  l10n.administeredDate,
                  style: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                ),
                subtitle: Text(
                  DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                      .format(_administeredDate),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryText,
                  ),
                ),
                trailing: Icon(Icons.edit, size: 20, color: secondaryText),
                onTap: _selectAdministeredDate,
              ),
            ),

            SizedBox(height: DesignSpacing.sm),

            // Next Due Date (Optional)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: disabledColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm),
                leading: Icon(
                  Icons.event_available,
                  color: _nextDueDate != null
                      ? DesignColors.highlightPurple
                      : secondaryText,
                ),
                title: Text(
                  l10n.nextDueDate,
                  style: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                ),
                subtitle: _nextDueDate != null
                    ? Text(
                        DateFormat.yMMMd(
                                Localizations.localeOf(context).languageCode)
                            .format(_nextDueDate!),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: primaryText,
                        ),
                      )
                    : Text(
                        l10n.optional,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                trailing: _nextDueDate != null
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20, color: secondaryText),
                        onPressed: () {
                          setState(() {
                            _nextDueDate = null;
                          });
                        },
                      )
                    : Icon(Icons.add, size: 20, color: secondaryText),
                onTap: _selectNextDueDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinaryDetailsCard(ThemeData theme, AppLocalizations l10n, bool isDark) {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    InputDecoration buildInputDecoration({
      required String label,
      required String hint,
      required IconData prefixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: DesignColors.highlightPurple),
        filled: true,
        fillColor: surfaceColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DesignColors.highlightPurple, width: 2),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.veterinaryDetails,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.xs),
            Text(
              l10n.optionalFields,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: DesignSpacing.md),

            // Batch Number
            TextFormField(
              controller: _batchNumberController,
              style: GoogleFonts.inter(color: primaryText),
              decoration: buildInputDecoration(
                label: l10n.batchNumber,
                hint: l10n.batchNumberHint,
                prefixIcon: Icons.qr_code_2,
              ),
            ),
            SizedBox(height: DesignSpacing.md),

            // Veterinarian Name
            TextFormField(
              controller: _veterinarianNameController,
              style: GoogleFonts.inter(color: primaryText),
              decoration: buildInputDecoration(
                label: l10n.veterinarianName,
                hint: l10n.veterinarianNameHint,
                prefixIcon: Icons.person_outline,
              ),
            ),
            SizedBox(height: DesignSpacing.md),

            // Clinic Name
            TextFormField(
              controller: _clinicNameController,
              style: GoogleFonts.inter(color: primaryText),
              decoration: buildInputDecoration(
                label: l10n.clinicName,
                hint: l10n.clinicNameHint,
                prefixIcon: Icons.local_hospital_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatePhotosCard(ThemeData theme, AppLocalizations l10n, bool isDark) {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: DesignColors.highlightPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: DesignColors.highlightPurple,
                    size: 24,
                  ),
                ),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.certificatePhotos,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _pickCertificatePhoto,
                  icon: Icon(Icons.add_a_photo, size: 18, color: DesignColors.highlightPurple),
                  label: Text(
                    l10n.addPhoto,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: DesignColors.highlightPurple,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: DesignColors.highlightPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm,
                      vertical: DesignSpacing.xs,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.optionalCertificateHint,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: secondaryText,
              ),
            ),

            // Display selected photos
            if (_certificatePhotoPaths.isNotEmpty) ...[
              SizedBox(height: DesignSpacing.md),
              Wrap(
                spacing: DesignSpacing.sm,
                runSpacing: DesignSpacing.sm,
                children: _certificatePhotoPaths.asMap().entries.map((entry) {
                  final index = entry.key;
                  final path = entry.value;
                  return _buildPhotoThumbnail(path, index, isDark);
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(String path, int index, bool isDark) {
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: disabledColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                  color: dangerColor,
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

  Widget _buildNotesCard(ThemeData theme, AppLocalizations l10n, bool isDark) {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.additionalNotes,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              style: GoogleFonts.inter(color: primaryText),
              decoration: InputDecoration(
                hintText: l10n.vaccinationNotesHint,
                hintStyle: GoogleFonts.inter(color: secondaryText),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.note_outlined, color: DesignColors.highlightPurple),
                ),
                filled: true,
                fillColor: surfaceColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: disabledColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: DesignColors.highlightPurple, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
      ThemeData theme, AppLocalizations l10n, bool isDark, bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveVaccination,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignColors.highlightPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isEditing ? l10n.updateVaccination : l10n.saveVaccination,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
    // Default to current date when no next due date is set
    final now = DateTime.now();
    final initialDate = _nextDueDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
        certificatePhotoUrls:
            _certificatePhotoPaths.isEmpty ? null : _certificatePhotoPaths,
        isFromProtocol: widget.existingEvent?.isFromProtocol ?? false,
        protocolId: widget.existingEvent?.protocolId,
        protocolStepIndex: widget.existingEvent?.protocolStepIndex,
        createdAt: widget.existingEvent?.createdAt,
        updatedAt: widget.existingEvent != null ? DateTime.now() : null,
      );

      if (widget.existingEvent != null) {
        // Update existing event
        await ref
            .read(vaccinationProviderProvider.notifier)
            .updateVaccination(event);
        // Invalidate the pet-specific provider to refresh the timeline list
        ref.invalidate(vaccinationsByPetIdProvider(widget.petId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.vaccinationUpdatedSuccessfully),
              backgroundColor: DesignColors.lSuccess,
            ),
          );
        }
      } else {
        // Add new event
        await ref
            .read(vaccinationProviderProvider.notifier)
            .addVaccination(event);
        // Invalidate the pet-specific provider to refresh the timeline list
        ref.invalidate(vaccinationsByPetIdProvider(widget.petId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.vaccinationAddedSuccessfully),
              backgroundColor: DesignColors.lSuccess,
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
            backgroundColor: DesignColors.lDanger,
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
