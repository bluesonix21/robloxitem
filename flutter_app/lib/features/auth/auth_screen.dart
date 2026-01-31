import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';

/// Modern Auth Screen with glassmorphism and beautiful animations
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _errorMessage = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context);
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.message, l10n);
      });
    } catch (e) {
      setState(() {
        _errorMessage = l10n.auth_errorGeneric;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context);
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signUp(
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        data: {
          'display_name': _registerNameController.text.trim(),
        },
      );

      if (mounted) {
        _showSuccessSnackbar(l10n.auth_registerSuccess);
        _tabController.animateTo(0);
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.message, l10n);
      });
    } catch (e) {
      setState(() {
        _errorMessage = l10n.auth_errorGeneric;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.robloxugc://login-callback',
      );
    } catch (e) {
      setState(() {
        _errorMessage = l10n.auth_errorGoogle;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.robloxugc://login-callback',
      );
    } catch (e) {
      setState(() {
        _errorMessage = l10n.auth_errorApple;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error, AppLocalizations l10n) {
    if (error.contains('Invalid login credentials')) {
      return l10n.auth_errorInvalidCredentials;
    }
    if (error.contains('Email not confirmed')) {
      return l10n.auth_errorEmailNotConfirmed;
    }
    if (error.contains('User already registered')) {
      return l10n.auth_errorUserAlreadyRegistered;
    }
    if (error.contains('Password should be')) {
      return l10n.auth_errorPasswordTooShort;
    }
    return error;
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF8F5),
                Colors.white,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background orbs
              Positioned(
                top: -size.width * 0.5,
                right: -size.width * 0.3,
                child: Container(
                  width: size.width,
                  height: size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.width * 0.3,
                left: -size.width * 0.2,
                child: Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.1),
                        AppColors.secondary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: topPadding > 0 ? 0 : 20),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xl),

                        // Logo & Title
                        _buildHeader(l10n),

                        const SizedBox(height: AppSpacing.xl + 8),

                        // Tab Bar
                        _buildTabBar(l10n),

                        const SizedBox(height: AppSpacing.lg),

                        // Error Message
                        if (_errorMessage != null) _buildErrorMessage(l10n),

                        // Tab Content
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: IndexedStack(
                            index: _tabController.index,
                            children: [
                              _buildLoginForm(l10n),
                              _buildRegisterForm(l10n),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Divider
                        _buildDivider(l10n),

                        const SizedBox(height: AppSpacing.lg),

                        // Social Login
                        _buildSocialLogin(l10n),

                        const SizedBox(height: AppSpacing.xl),

                        // Terms
                        _buildTerms(l10n),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        // App Logo with glassmorphism
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.view_in_ar_rounded,
                size: 44,
                color: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Gradient title
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            l10n.appTitle,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.appTagline,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() {});
        },
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimaryLight,
        unselectedLabelColor: AppColors.textSecondaryLight,
        labelStyle:
            AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: l10n.auth_loginTab),
          Tab(text: l10n.auth_registerTab),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AppLocalizations l10n) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          // Email Field
          _ModernTextField(
            controller: _loginEmailController,
            label: l10n.auth_email,
            hint: l10n.auth_emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.auth_emailRequired;
              }
              if (!value.contains('@')) {
                return l10n.auth_emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Field
          _ModernTextField(
            controller: _loginPasswordController,
            label: l10n.auth_password,
            hint: l10n.auth_passwordHint,
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _login(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textTertiaryLight,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.auth_passwordRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(
                l10n.auth_forgotPassword,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Login Button
          _buildPrimaryButton(
            text: l10n.auth_login,
            onPressed: _isLoading ? null : _login,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AppLocalizations l10n) {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          // Name Field
          _ModernTextField(
            controller: _registerNameController,
            label: l10n.auth_name,
            hint: l10n.auth_nameHint,
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.auth_nameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Email Field
          _ModernTextField(
            controller: _registerEmailController,
            label: l10n.auth_email,
            hint: l10n.auth_emailHint,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.auth_emailRequired;
              }
              if (!value.contains('@')) {
                return l10n.auth_emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Field
          _ModernTextField(
            controller: _registerPasswordController,
            label: l10n.auth_password,
            hint: l10n.auth_passwordMinLength,
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textTertiaryLight,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.auth_passwordRequired;
              }
              if (value.length < 6) {
                return l10n.auth_passwordMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Confirm Password Field
          _ModernTextField(
            controller: _registerConfirmPasswordController,
            label: l10n.auth_confirmPassword,
            hint: l10n.auth_confirmPasswordHint,
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _register(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textTertiaryLight,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.auth_confirmPasswordRequired;
              }
              if (value != _registerPasswordController.text) {
                return l10n.auth_passwordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Register Button
          _buildPrimaryButton(
            text: l10n.auth_register,
            onPressed: _isLoading ? null : _register,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.primaryLight.withValues(alpha: 0.5),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            l10n.auth_or,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin(AppLocalizations l10n) {
    return Column(
      children: [
        // Google Button
        _SocialButton(
          icon: 'G',
          label: l10n.auth_continueWithGoogle,
          onTap: _isLoading ? null : _signInWithGoogle,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Apple Button
        _SocialButton(
          icon: '',
          isApple: true,
          label: l10n.auth_continueWithApple,
          onTap: _isLoading ? null : _signInWithApple,
        ),
      ],
    );
  }

  Widget _buildTerms(AppLocalizations l10n) {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        children: [
          TextSpan(
            text: l10n.auth_termsOfService,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: l10n.auth_privacyPolicy,
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  void _showForgotPasswordDialog() {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          l10n.auth_forgotPasswordTitle,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.auth_forgotPasswordDescription,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ModernTextField(
              controller: emailController,
              label: l10n.auth_email,
              hint: l10n.auth_emailHint,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.common_cancel,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await Supabase.instance.client.auth.resetPasswordForEmail(
                    email,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _showSuccessSnackbar(l10n.auth_resetLinkSent);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.auth_errorGeneric),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n.auth_send,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).then((_) {
      emailController.dispose();
    });
  }
}

/// Modern Text Field
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiaryLight,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  color: AppColors.textTertiaryLight,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Social Login Button
class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool isApple;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isApple = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isApple)
              const Icon(Icons.apple, size: 24)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: AppTypography.titleMedium.copyWith(
                      color: const Color(0xFF4285F4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
