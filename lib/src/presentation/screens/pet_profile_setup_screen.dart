import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/src/services/profile_picture_service.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

class PetProfileSetupScreen extends ConsumerStatefulWidget {
  final String? petId; // null = create new, non-null = edit existing

  const PetProfileSetupScreen({super.key, this.petId});

  @override
  ConsumerState<PetProfileSetupScreen> createState() =>
      _PetProfileSetupScreenState();
}

class _PetProfileSetupScreenState extends ConsumerState<PetProfileSetupScreen> {
  final logger = Logger();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _notesController = TextEditingController();
  final _profilePictureService = ProfilePictureService();

  DateTime? _selectedBirthday;
  String? _savedImagePath;
  bool _isLoading = false;
  bool _isEditMode = false;
  PetProfile? _existingProfile;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    if (widget.petId != null) {
      // Edit mode - load existing pet data
      final profilesAsync = ref.read(petProfilesProvider);
      profilesAsync.whenData((profiles) {
        final profile = profiles.where((p) => p.id == widget.petId).firstOrNull;
        if (profile != null) {
          setState(() {
            _isEditMode = true;
            _existingProfile = profile;
            _nameController.text = profile.name;
            _speciesController.text = profile.species;
            _breedController.text = profile.breed ?? '';
            _notesController.text = profile.notes ?? '';
            _selectedBirthday = profile.birthday;
            _savedImagePath = profile.photoPath;
          });
          logger.d("[PROFILE_SETUP] Edit mode - Pre-filled with existing pet data");
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final imagePath =
          await _profilePictureService.selectProfilePicture(context);
      if (imagePath != null) {
        setState(() {
          _savedImagePath = imagePath;
        });
        logger.d('[PROFILE_PIC] Image saved to permanent location: $imagePath');
      }
    } catch (e) {
      logger.e('[PROFILE_PIC] ERROR: Failed to pick image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _selectBirthday() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
      helpText: l10n.selectPetBirthday,
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    logger.d("[PROFILE_SETUP] Save button pressed in setup screen");

    if (!_formKey.currentState!.validate()) {
      logger.d("[PROFILE_SETUP] Form validation failed");
      return;
    }

    logger.d("[PROFILE_SETUP] Form validation passed");

    setState(() {
      _isLoading = true;
    });

    try {
      logger.d("[PROFILE_PIC] Starting profile save");
      logger.d("[PROFILE_PIC] _savedImagePath value: $_savedImagePath");

      if (_savedImagePath != null) {
        final imageFile = File(_savedImagePath!);
        logger.d(
            "[PROFILE_PIC] Checking if saved image file exists: ${await imageFile.exists()}");
        if (await imageFile.exists()) {
          logger.d(
              "[PROFILE_PIC] Image file confirmed at path: $_savedImagePath");
        } else {
          logger.e(
              "[PROFILE_PIC] ERROR: Image file does NOT exist at path: $_savedImagePath");
        }
      } else {
        logger.d("[PROFILE_PIC] No image path to save (null)");
      }

      final profile = _isEditMode && _existingProfile != null
          ? _existingProfile!.copyWith(
              name: _nameController.text.trim(),
              species: _speciesController.text.trim(),
              breed: _breedController.text.trim().isEmpty
                  ? null
                  : _breedController.text.trim(),
              birthday: _selectedBirthday,
              photoPath: _savedImagePath,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            )
          : PetProfile(
              name: _nameController.text.trim(),
              species: _speciesController.text.trim(),
              breed: _breedController.text.trim().isEmpty
                  ? null
                  : _breedController.text.trim(),
              birthday: _selectedBirthday,
              photoPath: _savedImagePath,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );

      logger.d(
          "[PROFILE_SETUP] ${_isEditMode ? 'Updating' : 'Creating'} profile object - Name: ${profile.name}, Species: ${profile.species}, ID: ${profile.id}");
      logger.d("[PROFILE_SETUP] Profile photoPath: ${profile.photoPath}");

      logger.d("[PROFILE_SETUP] Calling provider to save profile");
      await ref.read(petProfilesProvider.notifier).createOrUpdate(profile);
      logger.d("[PROFILE_SETUP] Provider save completed successfully");

      if (mounted) {
        logger.d("[PROFILE_SETUP] Attempting navigation back");
        // Navigate back after successful save
        if (_isEditMode) {
          context.pop(); // Go back to previous screen (pet profiles)
        } else {
          context.go('/'); // First pet setup - go to home
        }
        logger.d("[PROFILE_SETUP] Navigation initiated");
      }
    } catch (e) {
      logger.e("[PROFILE_SETUP] ERROR: Save operation failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? l10n.editPetProfile : l10n.setupPetProfile),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: _savedImagePath != null
                        ? ClipOval(
                            child: Image.file(
                              File(_savedImagePath!),
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          )
                        : Icon(
                            Icons.pets,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                      _savedImagePath != null ? l10n.changePhoto : l10n.addPhoto),
                ),
              ),
              const SizedBox(height: 24),

              // Pet name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${l10n.petName} *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterPetName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Species field
              TextFormField(
                controller: _speciesController,
                decoration: InputDecoration(
                  labelText: '${l10n.species} *',
                  hintText: l10n.speciesHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterSpecies;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Breed field (optional)
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: l10n.breedOptional,
                  hintText: l10n.breedHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Birthday picker
              InkWell(
                onTap: _selectBirthday,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.birthdayOptional,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.cake),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedBirthday != null
                        ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}'
                        : l10n.tapToSelectBirthday,
                    style: _selectedBirthday != null
                        ? null
                        : TextStyle(color: theme.hintColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notesOptional,
                  hintText: l10n.petNotesHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? l10n.updateProfile : l10n.saveProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
