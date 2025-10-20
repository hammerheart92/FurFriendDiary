import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/vet_profile.dart';
import '../providers/vet_provider.dart';
import '../../../l10n/app_localizations.dart';

class AddVetScreen extends ConsumerStatefulWidget {
  final String? vetId;

  const AddVetScreen({super.key, this.vetId});

  @override
  ConsumerState<AddVetScreen> createState() => _AddVetScreenState();
}

class _AddVetScreenState extends ConsumerState<AddVetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clinicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSpecialty;
  bool _isPreferred = false;
  bool _isCustomSpecialty = false;

  final List<String> _specialties = [
    'General Practice',
    'Emergency Medicine',
    'Cardiology',
    'Dermatology',
    'Surgery',
    'Orthopedics',
    'Oncology',
    'Ophthalmology',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVet();
      });
    }
  }

  void _loadVet() {
    final vet = ref.read(vetDetailProvider(widget.vetId!));
    if (vet != null) {
      setState(() {
        _nameController.text = vet.name;
        _clinicController.text = vet.clinicName;
        _phoneController.text = vet.phoneNumber ?? '';
        _emailController.text = vet.email ?? '';
        _addressController.text = vet.address ?? '';
        _websiteController.text = vet.website ?? '';
        _notesController.text = vet.notes ?? '';
        _isPreferred = vet.isPreferred;

        if (vet.specialty != null) {
          if (_specialties.contains(vet.specialty)) {
            _selectedSpecialty = vet.specialty;
          } else {
            _selectedSpecialty = 'Custom';
            _isCustomSpecialty = true;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clinicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    return null;
  }

  String? _validateWebsite(String? value) {
    if (value == null || value.isEmpty) return null;

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    if (!urlRegex.hasMatch(value)) {
      return AppLocalizations.of(context)!.invalidWebsite;
    }
    return null;
  }

  Future<void> _saveVet() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final repository = ref.read(vetRepositoryProvider);

      String? specialty = _selectedSpecialty;
      if (_isCustomSpecialty && _selectedSpecialty == 'Custom') {
        // For custom specialty, we could add another field, but for now we'll skip it
        specialty = null;
      }

      final vet = VetProfile(
        id: widget.vetId ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        clinicName: _clinicController.text.trim(),
        specialty: specialty,
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        isPreferred: _isPreferred,
        createdAt: DateTime.now(),
      );

      if (widget.vetId != null) {
        await repository.updateVet(vet);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.vetUpdated)),
          );
        }
      } else {
        await repository.addVet(vet);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.vetAdded)),
          );
        }
      }

      if (_isPreferred) {
        await repository.setPreferredVet(vet.id);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.vetId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editVet : l10n.addVet),
        actions: [
          TextButton(
            onPressed: _saveVet,
            child: Text(
              l10n.save,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n.vetName} *',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.vetNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clinicController,
              decoration: InputDecoration(
                labelText: '${l10n.clinicName} *',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.clinicNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              decoration: InputDecoration(
                labelText: l10n.specialty,
                border: const OutlineInputBorder(),
              ),
              items: _specialties.map((specialty) {
                String displayText;
                switch (specialty) {
                  case 'General Practice':
                    displayText = l10n.generalPractice;
                    break;
                  case 'Emergency Medicine':
                    displayText = l10n.emergencyMedicine;
                    break;
                  case 'Cardiology':
                    displayText = l10n.cardiology;
                    break;
                  case 'Dermatology':
                    displayText = l10n.dermatology;
                    break;
                  case 'Surgery':
                    displayText = l10n.surgery;
                    break;
                  case 'Orthopedics':
                    displayText = l10n.orthopedics;
                    break;
                  case 'Oncology':
                    displayText = l10n.oncology;
                    break;
                  case 'Ophthalmology':
                    displayText = l10n.ophthalmology;
                    break;
                  case 'Custom':
                    displayText = l10n.custom;
                    break;
                  default:
                    displayText = specialty;
                }
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(displayText),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSpecialty = value;
                  _isCustomSpecialty = value == 'Custom';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.address,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: l10n.website,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
              validator: _validateWebsite,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.setAsPreferred),
              subtitle: Text(l10n.preferredVet),
              value: _isPreferred,
              onChanged: (value) {
                setState(() {
                  _isPreferred = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
