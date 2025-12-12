import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../domain/models/pet_owner_tier.dart';
import '../../presentation/providers/pet_owner_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = ref.read(petOwnerProvider).value;
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final profile = ref.read(petOwnerProvider).value;
    if (profile == null) return;

    final hasChanges = _nameController.text != profile.name ||
        _emailController.text != (profile.email ?? '');

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(petOwnerProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileSaved)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingProfile),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileAsync = ref.watch(petOwnerProvider);
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final secondaryTextColor =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          l10n.editProfile,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.save,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignColors.highlightBlue,
                      ),
                    ),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: secondaryTextColor,
                  ),
                  SizedBox(height: DesignSpacing.md),
                  Text(
                    l10n.noProfileFound,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Section
                  Center(
                    child: _buildStyledAvatar(
                      context,
                      _nameController.text.isEmpty
                          ? profile.name
                          : _nameController.text,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.lg),

                  // Name Field
                  _buildStyledTextField(
                    context: context,
                    label: l10n.name,
                    icon: Icons.person_outline,
                    controller: _nameController,
                    hintText: l10n.enterYourName,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.nameRequired;
                      }
                      if (value.trim().length < 2) {
                        return l10n.nameTooShort;
                      }
                      return null;
                    },
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  SizedBox(height: DesignSpacing.md),

                  // Email Field
                  _buildStyledTextField(
                    context: context,
                    label: l10n.email,
                    icon: Icons.alternate_email,
                    controller: _emailController,
                    hintText: l10n.enterYourEmail,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // Basic email validation
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return l10n.invalidEmail;
                        }
                      }
                      return null;
                    },
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  SizedBox(height: DesignSpacing.lg),

                  // Subscription Status Section
                  _buildSubscriptionSection(context, profile.effectiveTier,
                      profile.premiumExpiryDate),
                  SizedBox(height: DesignSpacing.xl),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _hasChanges && !_isLoading ? _saveProfile : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColors.highlightBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            DesignColors.highlightBlue.withAlpha(128),
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.saveChanges,
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
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: DesignColors.highlightBlue,
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                l10n.errorLoadingProfile,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: secondaryTextColor,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(petOwnerProvider),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.highlightBlue,
                  side: BorderSide(color: DesignColors.highlightBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Generate initials from name (1-2 characters)
  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'PO';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'PO';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Build styled text field with blue label and icon
  Widget _buildStyledTextField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final borderColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;
    final textColor = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final hintColor = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blue label
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: DesignColors.highlightBlue,
          ),
        ),
        SizedBox(height: DesignSpacing.xs),
        // Styled text field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: hintColor,
            ),
            prefixIcon: Icon(
              icon,
              color: hintColor,
              size: 20,
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: DesignColors.highlightBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  /// Build styled avatar with blue border and decorative camera icon
  Widget _buildStyledAvatar(BuildContext context, String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = _getInitials(name);

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          // Avatar with blue border
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
              border: Border.all(
                color: DesignColors.highlightBlue,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: DesignColors.highlightBlue,
                ),
              ),
            ),
          ),
          // Camera icon overlay (decorative only)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DesignColors.highlightBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? DesignColors.dBackground
                      : DesignColors.lBackground,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(
    BuildContext context,
    PetOwnerTier tier,
    DateTime? expiryDate,
  ) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryTextColor =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final borderColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    // Determine badge color based on tier
    Color badgeColor;
    IconData badgeIcon;
    switch (tier) {
      case PetOwnerTier.premium:
        badgeColor = DesignColors.highlightYellow;
        badgeIcon = Icons.star;
        break;
      case PetOwnerTier.lifetime:
        badgeColor = DesignColors.highlightPurple;
        badgeIcon = Icons.diamond;
        break;
      case PetOwnerTier.free:
        badgeColor = DesignColors.highlightTeal;
        badgeIcon = Icons.person_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          l10n.subscriptionStatus,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        SizedBox(height: DesignSpacing.sm),
        // Styled container
        Container(
          padding: EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Styled tier badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.sm,
                      vertical: DesignSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(51), // 20% opacity
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: badgeColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badgeIcon,
                          size: 16,
                          color: badgeColor,
                        ),
                        SizedBox(width: DesignSpacing.xs),
                        Text(
                          tier.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (tier == PetOwnerTier.premium && expiryDate != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: secondaryTextColor,
                    ),
                    SizedBox(width: DesignSpacing.xs),
                    Text(
                      '${l10n.expiresOn} ${DateFormat.yMMMd().format(expiryDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
              if (tier == PetOwnerTier.free) ...[
                SizedBox(height: DesignSpacing.sm),
                Text(
                  l10n.freeTierDescription,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              ],
              if (tier == PetOwnerTier.lifetime) ...[
                SizedBox(height: DesignSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: DesignColors.highlightPurple,
                    ),
                    SizedBox(width: DesignSpacing.xs),
                    Text(
                      l10n.lifetimeAccess,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: DesignColors.highlightPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
