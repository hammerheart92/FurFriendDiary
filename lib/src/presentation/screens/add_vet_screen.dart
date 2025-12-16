import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/vet_profile.dart';
import '../providers/vet_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        // Invalidate providers to refresh list
        ref.invalidate(vetsProvider);
        ref.invalidate(filteredVetsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.vetUpdated),
              backgroundColor: DesignColors.highlightTeal,
            ),
          );
        }
      } else {
        await repository.addVet(vet);
        // Invalidate providers to refresh list
        ref.invalidate(vetsProvider);
        ref.invalidate(filteredVetsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.vetAdded),
              backgroundColor: DesignColors.highlightTeal,
            ),
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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final disabledColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    final isEditing = widget.vetId != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          isEditing ? l10n.editVet : l10n.addVet,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveVet,
            child: Text(
              l10n.save,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DesignColors.highlightYellow,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(DesignSpacing.md),
          children: [
            // Basic Information Section
            _buildSectionCard(
              isDark: isDark,
              surfaceColor: surfaceColor,
              primaryText: primaryText,
              icon: Icons.person,
              title: l10n.basicInformation,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: '${l10n.vetName} *',
                  icon: Icons.person,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.vetNameRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: DesignSpacing.md),
                _buildTextField(
                  controller: _clinicController,
                  label: '${l10n.clinicName} *',
                  icon: Icons.local_hospital,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.clinicNameRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: DesignSpacing.md),
                _buildSpecialtyDropdown(
                  l10n, primaryText, secondaryText, surfaceColor, disabledColor),
              ],
            ),

            SizedBox(height: DesignSpacing.md),

            // Contact Information Section
            _buildSectionCard(
              isDark: isDark,
              surfaceColor: surfaceColor,
              primaryText: primaryText,
              icon: Icons.contact_phone,
              title: l10n.contactInformation,
              children: [
                _buildTextField(
                  controller: _phoneController,
                  label: l10n.phoneNumber,
                  icon: Icons.phone,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: DesignSpacing.md),
                _buildTextField(
                  controller: _emailController,
                  label: l10n.email,
                  icon: Icons.email,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: DesignSpacing.md),
                _buildTextField(
                  controller: _websiteController,
                  label: l10n.website,
                  icon: Icons.language,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                  keyboardType: TextInputType.url,
                  validator: _validateWebsite,
                ),
              ],
            ),

            SizedBox(height: DesignSpacing.md),

            // Location Section
            _buildSectionCard(
              isDark: isDark,
              surfaceColor: surfaceColor,
              primaryText: primaryText,
              icon: Icons.location_on,
              title: l10n.address,
              children: [
                _buildTextField(
                  controller: _addressController,
                  label: l10n.address,
                  icon: Icons.location_on,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                  maxLines: 3,
                ),
              ],
            ),

            SizedBox(height: DesignSpacing.md),

            // Notes Section
            _buildSectionCard(
              isDark: isDark,
              surfaceColor: surfaceColor,
              primaryText: primaryText,
              icon: Icons.note,
              title: l10n.notes,
              children: [
                _buildTextField(
                  controller: _notesController,
                  label: l10n.notes,
                  icon: Icons.note,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  surfaceColor: surfaceColor,
                  disabledColor: disabledColor,
                  maxLines: 4,
                ),
              ],
            ),

            SizedBox(height: DesignSpacing.md),

            // Preferred Vet Toggle
            Container(
              padding: EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: DesignColors.highlightYellow,
                title: Text(
                  l10n.setAsPreferred,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryText,
                  ),
                ),
                subtitle: Text(
                  l10n.preferredVet,
                  style: GoogleFonts.inter(fontSize: 14, color: secondaryText),
                ),
                secondary: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: DesignColors.highlightYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.star, color: DesignColors.highlightYellow),
                ),
                value: _isPreferred,
                onChanged: (value) {
                  setState(() {
                    _isPreferred = value;
                  });
                },
              ),
            ),

            SizedBox(height: DesignSpacing.xl),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _saveVet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.highlightYellow,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? l10n.save : l10n.addVet,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required Color surfaceColor,
    required Color primaryText,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DesignColors.highlightYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: DesignColors.highlightYellow),
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primaryText,
    required Color secondaryText,
    required Color surfaceColor,
    required Color disabledColor,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 16, color: primaryText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(icon, color: DesignColors.highlightYellow),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DesignColors.highlightYellow, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSpecialtyDropdown(
    AppLocalizations l10n,
    Color primaryText,
    Color secondaryText,
    Color surfaceColor,
    Color disabledColor,
  ) {
    return DropdownButtonFormField<String>(
      value: _selectedSpecialty,
      style: GoogleFonts.inter(fontSize: 16, color: primaryText),
      decoration: InputDecoration(
        labelText: l10n.specialty,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: secondaryText),
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(Icons.medical_services, color: DesignColors.highlightYellow),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: disabledColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DesignColors.highlightYellow, width: 2),
        ),
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
    );
  }
}
