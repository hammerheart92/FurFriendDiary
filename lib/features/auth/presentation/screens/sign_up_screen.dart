import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/typography.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
import '../widgets/animated_elevated_button.dart';
import '../widgets/animated_icon_button.dart';
import '../widgets/animated_text_button.dart';
import '../widgets/animated_paw.dart';

/// The Sign Up screen for FurFriendDiary.
///
/// Displays a gradient background with decorative animated paw prints
/// around the heading, a cat climbing illustration overlaid on the
/// username field, and four input fields for registration.
/// This is a pure UI screen — no backend calls or validation logic.
///
/// Navigation:
/// - "Sign In" link navigates to `/sign-in` via [GoRouter].
/// - "Sign-Up" button is a placeholder (`onPressed: null`) pending
///   backend auth integration.
class SignUpScreen extends StatefulWidget {
  /// Creates a [SignUpScreen].
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? DesignColors.dBackground : DesignColors.highlightBlue,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DesignColors.dSurfaces,
                    DesignColors.dBackground,
                  ],
                )
              : RadialGradient(
                  center: const Alignment(0.0, -0.4),
                  radius: 1.2,
                  colors: [
                    DesignColors.highlightBlue.withOpacity(0.6),
                    DesignColors.highlightBlue,
                  ],
                ),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isShort = constraints.maxHeight < 675;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: isShort ? DesignSpacing.md : DesignSpacing.xxl,
                    ),

                    // Title block with paw decorations
                    _buildTitleBlock(isDark, isShort),

                    SizedBox(
                      height: isShort ? DesignSpacing.lg : DesignSpacing.xxxl,
                    ),

                    // Username field with cat climb overlay
                    _buildUsernameFieldWithCat(isDark),

                    const SizedBox(height: DesignSpacing.lg),

                    // Email field
                    _buildTextField(
                      hintText: 'Email address',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                    ),

                    const SizedBox(height: DesignSpacing.md),

                    // Password field
                    _buildTextField(
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      isDark: isDark,
                      suffixIcon: AnimatedIconButton(
                        icon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: DesignSpacing.md),

                    // Confirm Password field
                    _buildTextField(
                      hintText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      isDark: isDark,
                      suffixIcon: AnimatedIconButton(
                        icon: _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: isShort ? DesignSpacing.md : DesignSpacing.lg,
                    ),

                    // "Sign-Up 🐾" button
                    const AnimatedElevatedButton(
                      // TODO: implement registration
                      onPressed: null,
                      child: Text(
                        'Sign-Up 🐾',
                        style: DesignTypography.buttonText,
                      ),
                    ),

                    const SizedBox(height: DesignSpacing.lg),

                    // "Already have an account? Sign In" link
                    AnimatedTextButton(
                      onPressed: () => context.go('/sign-in'),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: DesignTypography.bodyRegular.copyWith(
                                color: isDark
                                    ? DesignColors.dSecondaryText
                                    : DesignColors.lSecondaryText,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: DesignTypography.ctaBold.copyWith(
                                color: isDark
                                    ? DesignColors.highlightBlue
                                    : DesignColors.lPrimaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: DesignSpacing.lg),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the title block with "Create an account", subtitle, and
  /// decorative [AnimatedPaw] widgets positioned around the text.
  Widget _buildTitleBlock(bool isDark, bool isShort) {
    final pawColor = isDark
        ? DesignColors.dSecondaryText.withOpacity(0.4)
        : DesignColors.lSecondaryText.withOpacity(0.4);

    return SizedBox(
      height:
          isShort ? DesignSpacing.xxxl : DesignSpacing.xxxl + DesignSpacing.lg,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top-left paw
          Positioned(
            left: -DesignSpacing.sm,
            top: -DesignSpacing.sm,
            child: AnimatedPaw(
              size: DesignSpacing.lg,
              rotationDegrees: -30,
              delay: const Duration(milliseconds: 200),
              color: pawColor,
            ),
          ),
          // Top-right paw
          Positioned(
            right: -DesignSpacing.sm,
            top: DesignSpacing.xs,
            child: AnimatedPaw(
              size: DesignSpacing.xl,
              rotationDegrees: 25,
              delay: const Duration(milliseconds: 400),
              color: pawColor,
            ),
          ),
          // Bottom-left paw
          Positioned(
            left: DesignSpacing.xl,
            bottom: -DesignSpacing.xs,
            child: AnimatedPaw(
              size: DesignSpacing.md,
              rotationDegrees: 15,
              delay: const Duration(milliseconds: 600),
              color: pawColor,
            ),
          ),
          // Center heading text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create an account',
                  style: DesignTypography.headingLarge.copyWith(
                    color: isDark
                        ? DesignColors.dPrimaryText
                        : DesignColors.lPrimaryText,
                  ),
                ),
                const SizedBox(height: DesignSpacing.xs),
                Text(
                  'Sign up to get started!',
                  style: DesignTypography.bodyRegular.copyWith(
                    color: isDark
                        ? DesignColors.dSecondaryText
                        : DesignColors.lSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the username text field with a [cat_climb.svg] illustration
  /// overlaid at the bottom-right corner, matching the PetiCare design.
  Widget _buildUsernameFieldWithCat(bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildTextField(
          hintText: 'Username',
          prefixIcon: Icons.person_outline,
          isDark: isDark,
        ),
        Positioned(
          right: -DesignSpacing.md,
          top: -(DesignSpacing.xxxl + DesignSpacing.xxl) + DesignSpacing.md,
          child: SvgPicture.asset(
            'assets/illustrations/cat_climb.svg',
            width: DesignSpacing.xxxl * 1.8,
            height: DesignSpacing.xxxl * 1.8,
          ),
        ),
      ],
    );
  }

  /// Builds a styled text field matching the auth screen design.
  ///
  /// Uses [DesignColors] for fill and text colors, [DesignSpacing] for
  /// border radius and padding, and [DesignShadows] for elevation.
  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
        borderRadius: BorderRadius.circular(DesignSpacing.md),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: DesignTypography.bodyRegular.copyWith(
          color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: DesignTypography.bodyRegular.copyWith(
            color: isDark ? DesignColors.dDisabled : DesignColors.lDisabled,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: isDark
                ? DesignColors.dSecondaryText
                : DesignColors.lSecondaryText,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.md,
          ),
        ),
      ),
    );
  }
}
