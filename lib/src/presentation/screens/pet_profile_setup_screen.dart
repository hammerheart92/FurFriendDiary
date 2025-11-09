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

  // Common pet species list
  static const List<String> _commonSpecies = [
    'Dog',
    'Cat',
    'Bird',
    'Rabbit',
    'Hamster',
    'Guinea Pig',
    'Fish',
    'Turtle',
    'Lizard',
    'Snake',
    'Ferret',
    'Chinchilla',
    'Rat',
    'Mouse',
    'Gerbil',
    'Hedgehog',
    'Parrot',
    'Horse',
    'Chicken',
    'Other (Custom)',
  ];

  // Breed lists by species
  static const Map<String, List<String>> _breedsBySpecies = {
    'Dog': [
      'Labrador Retriever',
      'Golden Retriever',
      'German Shepherd',
      'Bulldog',
      'Beagle',
      'Poodle',
      'Rottweiler',
      'Yorkshire Terrier',
      'Boxer',
      'Dachshund',
      'Siberian Husky',
      'Chihuahua',
      'Shih Tzu',
      'Doberman Pinscher',
      'Great Dane',
      'Pomeranian',
      'Border Collie',
      'Cocker Spaniel',
      'Maltese',
      'Mixed Breed',
      'Other (Custom)',
    ],
    'Cat': [
      'Persian',
      'Maine Coon',
      'Siamese',
      'Ragdoll',
      'British Shorthair',
      'Sphynx',
      'Bengal',
      'Scottish Fold',
      'Russian Blue',
      'Abyssinian',
      'American Shorthair',
      'Birman',
      'Norwegian Forest',
      'Domestic Shorthair',
      'Mixed Breed',
      'Other (Custom)',
    ],
    'Bird': [
      'Parakeet',
      'Cockatiel',
      'Canary',
      'Parrot',
      'Lovebird',
      'Finch',
      'Cockatoo',
      'Macaw',
      'Conure',
      'African Grey',
      'Other (Custom)',
    ],
    'Rabbit': [
      'Holland Lop',
      'Netherland Dwarf',
      'Mini Rex',
      'Lionhead',
      'Flemish Giant',
      'English Angora',
      'Dutch',
      'Mixed Breed',
      'Other (Custom)',
    ],
  };

  String? _selectedSpecies; // null means "Other (Custom)" selected
  bool _showCustomSpeciesField = false;
  String? _selectedBreed; // Selected from dropdown
  bool _showCustomBreedField = false; // Show text field for custom breed

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

            // Check if species is in common list
            if (_commonSpecies.contains(profile.species)) {
              _selectedSpecies = profile.species;
              _showCustomSpeciesField = false;
            } else {
              // Custom species
              _selectedSpecies = null;
              _showCustomSpeciesField = true;
              _speciesController.text = profile.species;
            }

            // Handle breed
            final availableBreeds = _getBreedsForSpecies(profile.species);
            if (availableBreeds != null && profile.breed != null) {
              // Species has breed list
              if (availableBreeds.contains(profile.breed)) {
                // Breed is in the list
                _selectedBreed = profile.breed;
                _showCustomBreedField = false;
                logger.d(
                    "[BREED] Edit mode - Pre-selected breed from dropdown: ${profile.breed}");
              } else {
                // Custom breed
                _selectedBreed = null;
                _showCustomBreedField = true;
                _breedController.text = profile.breed!;
                logger.d(
                    "[BREED] Edit mode - Loaded custom breed: ${profile.breed}");
              }
            } else if (profile.breed != null) {
              // No breed list for this species, use text field
              _breedController.text = profile.breed!;
              logger.d(
                  "[BREED] Edit mode - Loaded breed for species without dropdown: ${profile.breed}");
            } else {
              logger.d("[BREED] Edit mode - No breed specified for this pet");
            }
          });
          logger.d(
              "[PROFILE_SETUP] Edit mode - Pre-filled with existing pet data");
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

  /// Get localized species name
  String _getLocalizedSpecies(String species, AppLocalizations l10n) {
    switch (species) {
      case 'Dog':
        return l10n.speciesDog;
      case 'Cat':
        return l10n.speciesCat;
      case 'Bird':
        return l10n.speciesBird;
      case 'Rabbit':
        return l10n.speciesRabbit;
      case 'Hamster':
        return l10n.speciesHamster;
      case 'Guinea Pig':
        return l10n.speciesGuineaPig;
      case 'Fish':
        return l10n.speciesFish;
      case 'Turtle':
        return l10n.speciesTurtle;
      case 'Lizard':
        return l10n.speciesLizard;
      case 'Snake':
        return l10n.speciesSnake;
      case 'Ferret':
        return l10n.speciesFerret;
      case 'Chinchilla':
        return l10n.speciesChinchilla;
      case 'Rat':
        return l10n.speciesRat;
      case 'Mouse':
        return l10n.speciesMouse;
      case 'Gerbil':
        return l10n.speciesGerbil;
      case 'Hedgehog':
        return l10n.speciesHedgehog;
      case 'Parrot':
        return l10n.speciesParrot;
      case 'Horse':
        return l10n.speciesHorse;
      case 'Chicken':
        return l10n.speciesChicken;
      case 'Other (Custom)':
        return l10n.speciesOther;
      default:
        return species;
    }
  }

  /// Get localized breed name
  String _getLocalizedBreed(String breed, AppLocalizations l10n) {
    switch (breed) {
      case 'Labrador Retriever':
        return l10n.breedLabradorRetriever;
      case 'Golden Retriever':
        return l10n.breedGoldenRetriever;
      case 'German Shepherd':
        return l10n.breedGermanShepherd;
      case 'Bulldog':
        return l10n.breedBulldog;
      case 'Beagle':
        return l10n.breedBeagle;
      case 'Poodle':
        return l10n.breedPoodle;
      case 'Rottweiler':
        return l10n.breedRottweiler;
      case 'Yorkshire Terrier':
        return l10n.breedYorkshireTerrier;
      case 'Boxer':
        return l10n.breedBoxer;
      case 'Dachshund':
        return l10n.breedDachshund;
      case 'Siberian Husky':
        return l10n.breedSiberianHusky;
      case 'Chihuahua':
        return l10n.breedChihuahua;
      case 'Shih Tzu':
        return l10n.breedShihTzu;
      case 'Doberman Pinscher':
        return l10n.breedDobermanPinscher;
      case 'Great Dane':
        return l10n.breedGreatDane;
      case 'Pomeranian':
        return l10n.breedPomeranian;
      case 'Border Collie':
        return l10n.breedBorderCollie;
      case 'Cocker Spaniel':
        return l10n.breedCockerSpaniel;
      case 'Maltese':
        return l10n.breedMaltese;
      case 'Mixed Breed':
        return l10n.breedMixedBreed;
      case 'Persian':
        return l10n.breedPersian;
      case 'Maine Coon':
        return l10n.breedMaineCoon;
      case 'Siamese':
        return l10n.breedSiamese;
      case 'Ragdoll':
        return l10n.breedRagdoll;
      case 'British Shorthair':
        return l10n.breedBritishShorthair;
      case 'Sphynx':
        return l10n.breedSphynx;
      case 'Bengal':
        return l10n.breedBengal;
      case 'Scottish Fold':
        return l10n.breedScottishFold;
      case 'Russian Blue':
        return l10n.breedRussianBlue;
      case 'Abyssinian':
        return l10n.breedAbyssinian;
      case 'American Shorthair':
        return l10n.breedAmericanShorthair;
      case 'Birman':
        return l10n.breedBirman;
      case 'Norwegian Forest':
        return l10n.breedNorwegianForest;
      case 'Domestic Shorthair':
        return l10n.breedDomesticShorthair;
      case 'Parakeet':
        return l10n.breedParakeet;
      case 'Cockatiel':
        return l10n.breedCockatiel;
      case 'Canary':
        return l10n.breedCanary;
      case 'Parrot':
        return l10n.breedParrot;
      case 'Lovebird':
        return l10n.breedLovebird;
      case 'Finch':
        return l10n.breedFinch;
      case 'Cockatoo':
        return l10n.breedCockatoo;
      case 'Macaw':
        return l10n.breedMacaw;
      case 'Conure':
        return l10n.breedConure;
      case 'African Grey':
        return l10n.breedAfricanGrey;
      case 'Holland Lop':
        return l10n.breedHollandLop;
      case 'Netherland Dwarf':
        return l10n.breedNetherlandDwarf;
      case 'Mini Rex':
        return l10n.breedMiniRex;
      case 'Lionhead':
        return l10n.breedLionhead;
      case 'Flemish Giant':
        return l10n.breedFlemishGiant;
      case 'English Angora':
        return l10n.breedEnglishAngora;
      case 'Dutch':
        return l10n.breedDutch;
      case 'Other (Custom)':
        return l10n.breedOther;
      default:
        return breed;
    }
  }

  /// Get available breeds for the selected species
  List<String>? _getBreedsForSpecies(String? species) {
    if (species == null) {
      logger.d("[BREED] No species selected, no breed list available");
      return null;
    }

    final breeds = _breedsBySpecies[species];
    if (breeds != null) {
      logger
          .d("[BREED] Retrieved ${breeds.length} breeds for species: $species");
    } else {
      logger.d(
          "[BREED] No breed list defined for species: $species (will use text field)");
    }

    return breeds;
  }

  Future<void> _saveProfile() async {
    logger.d("[PROFILE_SETUP] Save button pressed in setup screen");
    logger.d("[BREED] Current state:");
    logger.d("  - Selected species: $_selectedSpecies");
    logger.d("  - Selected breed: $_selectedBreed");
    logger.d("  - Custom breed text: ${_breedController.text}");
    logger.d("  - Show custom field: $_showCustomBreedField");

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

      // Log breed information before save
      if (_selectedBreed != null) {
        logger
            .d("[BREED] Saving with dropdown-selected breed: $_selectedBreed");
      } else if (_breedController.text.trim().isNotEmpty) {
        logger.d(
            "[BREED] Saving with custom breed: ${_breedController.text.trim()}");
      } else {
        logger.d("[BREED] Saving with no breed specified");
      }

      logger.d(
          "[BREED] Final breed value for save: ${_selectedBreed ?? _breedController.text.trim()}");

      final profile = _isEditMode && _existingProfile != null
          ? _existingProfile!.copyWith(
              name: _nameController.text.trim(),
              species: _selectedSpecies ?? _speciesController.text.trim(),
              breed: _selectedBreed ??
                  (_breedController.text.trim().isEmpty
                      ? null
                      : _breedController.text.trim()),
              birthday: _selectedBirthday,
              photoPath: _savedImagePath,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            )
          : PetProfile(
              name: _nameController.text.trim(),
              species: _selectedSpecies ?? _speciesController.text.trim(),
              breed: _selectedBreed ??
                  (_breedController.text.trim().isEmpty
                      ? null
                      : _breedController.text.trim()),
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
      logger.d("[BREED] Saved pet profile with:");
      logger.d("  - Species: ${profile.species}");
      logger.d("  - Breed: ${profile.breed ?? 'None'}");
      logger.d(
          "  - Breed source: ${_selectedBreed != null ? 'Dropdown' : _breedController.text.isNotEmpty ? 'Custom text' : 'Not specified'}");

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
                  label: Text(_savedImagePath != null
                      ? l10n.changePhoto
                      : l10n.addPhoto),
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

              // Species dropdown
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: InputDecoration(
                  labelText: '${l10n.species} *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _commonSpecies.map((species) {
                  return DropdownMenuItem(
                    value: species == 'Other (Custom)' ? null : species,
                    child: Text(_getLocalizedSpecies(species, l10n)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value;
                    _showCustomSpeciesField = (value == null);
                    if (value != null) {
                      // If user selected from dropdown, clear custom field
                      _speciesController.clear();
                      logger.d("[SPECIES] Selected from dropdown: $value");
                    } else {
                      logger.d(
                          "[SPECIES] Selected 'Other (Custom)' - showing text field");
                    }

                    // Reset breed selection when species changes
                    final hadBreed = _selectedBreed != null ||
                        _breedController.text.isNotEmpty;
                    _selectedBreed = null;
                    _showCustomBreedField = false;
                    _breedController.clear();

                    if (hadBreed) {
                      logger.d(
                          "[BREED] Reset breed selection due to species change");
                    }

                    // Log available breeds for new species
                    final availableBreeds = _getBreedsForSpecies(value);
                    if (availableBreeds != null) {
                      logger.d(
                          "[BREED] Species $value has ${availableBreeds.length} breeds available in dropdown");
                    } else {
                      logger.d(
                          "[BREED] Species $value will use text field for breed input");
                    }
                  });
                },
                validator: (value) {
                  // If dropdown has value, it's valid
                  if (value != null) return null;

                  // If "Other" is selected, check the text field
                  if (_showCustomSpeciesField &&
                      _speciesController.text.trim().isEmpty) {
                    return l10n.pleaseEnterSpecies;
                  }

                  return null;
                },
              ),

              // Show custom text field if "Other" is selected
              if (_showCustomSpeciesField) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _speciesController,
                  decoration: InputDecoration(
                    labelText: l10n.customSpecies,
                    hintText: l10n.enterCustomSpecies,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  validator: (value) {
                    if (_showCustomSpeciesField &&
                        (value == null || value.trim().isEmpty)) {
                      return l10n.pleaseEnterSpecies;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Dynamic breed field based on selected species
              if (_getBreedsForSpecies(_selectedSpecies) != null) ...[
                // Show dropdown for species with breed lists
                DropdownButtonFormField<String>(
                  value: _selectedBreed,
                  decoration: InputDecoration(
                    labelText: l10n.breedOptional,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.info_outline),
                  ),
                  items: _getBreedsForSpecies(_selectedSpecies)!.map((breed) {
                    return DropdownMenuItem(
                      value: breed == 'Other (Custom)' ? null : breed,
                      child: Text(_getLocalizedBreed(breed, l10n)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBreed = value;
                      _showCustomBreedField = (value == null);
                      if (value != null) {
                        // If user selected from dropdown, clear custom field
                        _breedController.clear();
                        logger.d("[BREED] Selected from dropdown: $value");
                      } else {
                        logger.d(
                            "[BREED] Selected 'Other (Custom)' - showing custom breed text field");
                      }
                    });
                  },
                ),

                // Show custom breed text field if "Other" is selected
                if (_showCustomBreedField) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _breedController,
                    decoration: InputDecoration(
                      labelText: l10n.customBreed,
                      hintText: l10n.enterCustomBreed,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        logger.d("[BREED] Custom breed entered: $value");
                      }
                    },
                  ),
                ],
              ] else ...[
                // Show text field only for species without breed lists
                TextFormField(
                  controller: _breedController,
                  decoration: InputDecoration(
                    labelText: l10n.breedOptional,
                    hintText: l10n.breedHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.info_outline),
                  ),
                ),
              ],
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
