import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/src/services/profile_picture_service.dart';

class PetProfileSetupScreen extends ConsumerStatefulWidget {
  const PetProfileSetupScreen({super.key});

  @override
  ConsumerState<PetProfileSetupScreen> createState() => _PetProfileSetupScreenState();
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
      final imagePath = await _profilePictureService.selectProfilePicture(context);
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
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
      helpText: 'Select pet birthday',
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
        logger.d("[PROFILE_PIC] Checking if saved image file exists: ${await imageFile.exists()}");
        if (await imageFile.exists()) {
          logger.d("[PROFILE_PIC] Image file confirmed at path: $_savedImagePath");
        } else {
          logger.e("[PROFILE_PIC] ERROR: Image file does NOT exist at path: $_savedImagePath");
        }
      } else {
        logger.d("[PROFILE_PIC] No image path to save (null)");
      }

      final profile = PetProfile(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
        birthday: _selectedBirthday,
        photoPath: _savedImagePath,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      logger.d("[PROFILE_SETUP] Created profile object - Name: ${profile.name}, Species: ${profile.species}, ID: ${profile.id}");
      logger.d("[PROFILE_SETUP] Profile photoPath: ${profile.photoPath}");

      logger.d("[PROFILE_SETUP] Calling provider to save profile");
      await ref.read(petProfilesProvider.notifier).createOrUpdate(profile);
      logger.d("[PROFILE_SETUP] Provider save completed successfully");

      if (mounted) {
        logger.d("[PROFILE_SETUP] Attempting navigation to home screen");
        // Navigate to main screen after successful save
        context.go('/');
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Pet Profile'),
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_savedImagePath != null ? 'Change Photo' : 'Add Photo'),
                ),
              ),
              const SizedBox(height: 24),

              // Pet name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your pet\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Species field
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Species *',
                  hintText: 'e.g., Dog, Cat, Bird',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your pet\'s species';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Breed field (optional)
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed (optional)',
                  hintText: 'e.g., Golden Retriever, Persian',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Birthday picker
              InkWell(
                onTap: _selectBirthday,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birthday (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedBirthday != null
                        ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}'
                        : 'Tap to select birthday',
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
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Any special notes about your pet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
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
                    : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

