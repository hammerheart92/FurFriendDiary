// lib/src/ui/screens/profile_setup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

// A Riverpod provider to manage the state of the profile setup form.
// It holds the form data in a simple Map.
final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, Map<String, dynamic>>((ref) {
  return ProfileSetupNotifier();
});

class ProfileSetupNotifier extends StateNotifier<Map<String, dynamic>> {
  ProfileSetupNotifier() : super({});

  // Update a specific field in the form state.
  void updateField(String key, dynamic value) {
    state = {...state, key: value};
  }
}

// The profile setup screen widget.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _imageFile;

  // Function to handle picking an image from the gallery.
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      // Save the image path to the state.
      ref
          .read(profileSetupProvider.notifier)
          .updateField('imagePath', pickedFile.path);
    }
  }

  // Function to save the pet's profile to Hive.
  Future<void> _saveProfile() async {
    // Validate the form first.
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Get the profile data from the Riverpod provider.
      final profileData = ref.read(profileSetupProvider);
      // Open the Hive box for pet profiles.
      final box = await Hive.openBox<Map>('pet_profiles');
      // Add the new profile map to the box.
      await box.add(profileData);
      // Navigate to the home screen after saving.
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Pet Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker section.
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  // Updated to Material 3 surface color.
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                      : null,
                  child: _imageFile == null
                      ? Icon(
                          Icons.pets,
                          size: 60,
                          // Updated to Material 3 onSurface color.
                          color: theme.colorScheme.onSurface,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Pet's name text field.
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s name';
                  }
                  return null;
                },
                onSaved: (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateField('name', value!),
              ),
              const SizedBox(height: 16),

              // Pet's type text field.
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Pet Type (e.g., Dog, Cat)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s type';
                  }
                  return null;
                },
                onSaved: (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateField('type', value!),
              ),
              const SizedBox(height: 16),

              // Pet's breed text field.
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s breed';
                  }
                  return null;
                },
                onSaved: (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateField('breed', value!),
              ),
              const SizedBox(height: 16),

              // Pet's age text field.
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Age (years)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateField('age', int.parse(value!)),
              ),
              const SizedBox(height: 16),

              // Pet's weight text field.
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateField('weight', double.parse(value!)),
              ),
              const SizedBox(height: 32),

              // Save button.
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium,
                ),
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
