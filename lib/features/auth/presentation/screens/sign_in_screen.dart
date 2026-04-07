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
import '../widgets/floating_animation.dart';

/// The Sign In screen for FurFriendDiary.
///
/// Displays a gradient background with a floating cat illustration,
/// email and password fields, and navigation to the Sign Up screen.
/// This is a pure UI screen — no backend calls or validation logic.
/// The password field includes an eye toggle for visibility.
///
/// Navigation:
/// - "Sign Up" link navigates to `/sign-up` via [GoRouter].
/// - "Sign-In" button is a placeholder (`onPressed: null`) pending
///   backend auth integration.
class SignInScreen extends StatefulWidget {
  /// Creates a [SignInScreen].
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isShort = constraints.maxHeight < 675;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: isShort ? DesignSpacing.md : DesignSpacing.xxl,
                    ),

                    // Floating cat illustration
                    FloatingAnimation(
                      child: SizedBox(
                        height: isShort
                            ? screenSize.width * 0.3
                            : screenSize.width * 0.5,
                        width: isShort
                            ? screenSize.width * 0.3
                            : screenSize.width * 0.5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer blob shape
                            SvgPicture.asset(
                              'assets/illustrations/background_shape.svg',
                              width: isShort
                                  ? screenSize.width * 0.3
                                  : screenSize.width * 0.5,
                              height: isShort
                                  ? screenSize.width * 0.3
                                  : screenSize.width * 0.5,
                              colorFilter: ColorFilter.mode(
                                isDark
                                    ? DesignColors.dSurfaces
                                    : DesignColors.lSurfaces,
                                BlendMode.srcIn,
                              ),
                            ),
                            // Inner blob (primary tinted)
                            SvgPicture.asset(
                              'assets/illustrations/background_shape.svg',
                              width: isShort
                                  ? screenSize.width * 0.25
                                  : screenSize.width * 0.42,
                              height: isShort
                                  ? screenSize.width * 0.25
                                  : screenSize.width * 0.42,
                              colorFilter: ColorFilter.mode(
                                DesignColors.highlightBlue.withOpacity(0.3),
                                BlendMode.srcIn,
                              ),
                            ),
                            // Sleepy cat
                            SvgPicture.asset(
                              'assets/illustrations/sleepy_cat.svg',
                              width: isShort
                                  ? screenSize.width * 0.22
                                  : screenSize.width * 0.35,
                              height: isShort
                                  ? screenSize.width * 0.22
                                  : screenSize.width * 0.35,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: isShort ? DesignSpacing.md : DesignSpacing.lg,
                    ),

                    // "Welcome Back!" heading
                    Text(
                      'Welcome Back!',
                      style: DesignTypography.headingLarge.copyWith(
                        color: isDark
                            ? DesignColors.dPrimaryText
                            : DesignColors.lPrimaryText,
                      ),
                    ),

                    SizedBox(
                      height: isShort ? DesignSpacing.lg : DesignSpacing.xl,
                    ),

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

                    const SizedBox(height: DesignSpacing.sm),

                    // "Forgot password?" link
                    Align(
                      alignment: Alignment.centerRight,
                      child: AnimatedTextButton(
                        // TODO: implement forgot password
                        onPressed: null,
                        child: Text(
                          'Forgot password?',
                          style: DesignTypography.bodyRegular.copyWith(
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: isShort ? DesignSpacing.md : DesignSpacing.lg,
                    ),

                    // "Sign-In 🐾" button
                    const AnimatedElevatedButton(
                      // TODO: navigate to home after auth
                      onPressed: null,
                      child: Text(
                        'Sign-In 🐾',
                        style: DesignTypography.buttonText,
                      ),
                    ),

                    const SizedBox(height: DesignSpacing.lg),

                    // "Don't have an account? Sign Up" link
                    AnimatedTextButton(
                      onPressed: () => context.go('/sign-up'),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: DesignTypography.bodyRegular.copyWith(
                                color: isDark
                                    ? DesignColors.dSecondaryText
                                    : DesignColors.lSecondaryText,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign Up',
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
