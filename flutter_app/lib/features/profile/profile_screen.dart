import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/credit_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/animated_widgets.dart';
import '../../shared/widgets/sheets_modals.dart';

/// Modern Profile Screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(robloxConnectionProvider.notifier).loadProfile();
    });
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      if ((offset - _scrollOffset).abs() < 4) return;
      setState(() {
        _scrollOffset = offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showEditProfileDialog() async {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '';
    final currentName = user?.userMetadata?['display_name'] as String? ??
        email.split('@').first;
    final controller = TextEditingController(text: currentName);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).profile_editProfileTitle),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Görünen ad',
            hintText: 'Adını gir',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      controller.dispose();
      return;
    }

    final nextName = controller.text.trim();
    controller.dispose();
    if (nextName.isEmpty) {
      _showErrorSnackbar('Görünen ad boş olamaz');
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingOverlay(message: 'Kaydediliyor...'),
    );

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'display_name': nextName}),
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {});
      _showSuccessSnackbar(AppLocalizations.of(context).profile_updateSuccess);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showErrorSnackbar(AppLocalizations.of(context).profile_updateError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final size = MediaQuery.of(context).size;

    final credits = ref.watch(creditsProvider);
    final robloxConnection = ref.watch(robloxConnectionProvider);
    final darkMode = ref.watch(darkModeProvider);

    ref.listen(robloxOAuthProvider, (previous, next) {
      if (next.status == OAuthStatus.success) {
        ref.read(robloxConnectionProvider.notifier).loadProfile();
        _showSuccessSnackbar('Roblox bağlantısı başarılı! 🎉');
        ref.read(robloxOAuthProvider.notifier).reset();
      } else if (next.status == OAuthStatus.error) {
        _showErrorSnackbar(next.message ?? 'Roblox bağlantısı başarısız.');
        ref.read(robloxOAuthProvider.notifier).reset();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -size.width * 0.5,
              left: -size.width * 0.3,
              child: Container(
                width: size.width * 1.2,
                height: size.width * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(isDark, topPadding),
                ),

                // Profile Card
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 100),
                    child: _buildProfileCard(isDark),
                  ),
                ),

                // Credits Card
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 200),
                    child: _buildCreditsCard(isDark, credits),
                  ),
                ),

                // Roblox Connection
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 300),
                    child: _buildRobloxConnection(isDark, robloxConnection),
                  ),
                ),

                // Premium Banner
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 400),
                    child: _buildPremiumBanner(isDark),
                  ),
                ),

                // Settings Section
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 500),
                    child: _buildSettingsSection(isDark, darkMode),
                  ),
                ),

                // Logout Button
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 600),
                    child: _buildLogoutButton(isDark),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),

            // Floating Header
            if (_scrollOffset > 50)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildFloatingHeader(isDark, topPadding),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, double topPadding) {
    return Container(
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.sm,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Profil',
              style: AppTypography.displaySmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _ModernIconButton(
            icon: Icons.settings_rounded,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(bool isDark, double topPadding) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + AppSpacing.sm,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceDark : Colors.white)
                .withValues(alpha: 0.9),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Profil',
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _ModernIconButton(
                icon: Icons.settings_rounded,
                onTap: () => context.push('/settings'),
                small: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'kullanici@email.com';
    final name = user?.userMetadata?['display_name'] as String? ??
        email.split('@').first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar with gradient border
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Name
            Text(
              name,
              style: AppTypography.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Email
            Text(
              email,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Edit Profile Button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showEditProfileDialog();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).profile_editProfile,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsCard(bool isDark, AsyncValue<CreditBalance> credits) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).profile_credits,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        credits.when(
                          data: (balance) => Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${balance.balance}',
                                style: AppTypography.displaySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 6, bottom: 6),
                                child: Text(
                                  'kredi',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          loading: () => const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          error: (_, __) => Text(
                            '--',
                            style: AppTypography.displaySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Buy Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showBuyCreditsSheet();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kredi Satın Al',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRobloxConnection(bool isDark, RobloxConnectionState connection) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: connection.isConnected
                ? AppColors.success.withValues(alpha: 0.3)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: connection.isConnected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: connection.isConnected
                    ? AppColors.success.withValues(alpha: 0.15)
                    : (isDark
                        ? AppColors.surfaceDark
                        : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.gamepad_rounded,
                color: connection.isConnected
                    ? AppColors.success
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                size: 26,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return Text(
                      l10n.profile_robloxAccount,
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: connection.isConnected
                              ? AppColors.success
                              : AppColors.textSecondaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Builder(builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        return Text(
                          connection.isConnected
                              ? connection.username ??
                                  l10n.profile_robloxConnected
                              : l10n.profile_robloxNotConnected,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            if (connection.isConnected)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(robloxConnectionProvider.notifier).disconnect();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.link_off_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final url = await ref
                      .read(robloxConnectionProvider.notifier)
                      .startOAuth();
                  if (url != null) {
                    final success = await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                    if (!success && mounted) {
                      _showErrorSnackbar('Bağlantı açılamadı');
                    }
                  } else if (mounted) {
                    _showErrorSnackbar('OAuth başlatılamadı');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Bağla',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
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

  Widget _buildPremiumBanner(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/premium');
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),

              // Content
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '👑 PREMIUM',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Builder(builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return Text(
                            l10n.profile_premium,
                            style: AppTypography.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                        const SizedBox(height: 4),
                        Builder(builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return Text(
                            l10n.profile_premiumSubtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(bool isDark, bool darkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).profile_settings,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Karanlık Mod',
                  trailing: Switch.adaptive(
                    value: darkMode,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      ref.read(darkModeProvider.notifier).state = value;
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Bildirimler',
                  onTap: () {},
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Dil',
                  subtitle: 'Türkçe',
                  onTap: () {},
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.history_rounded,
                  title: 'İşlem Geçmişi',
                  onTap: () {},
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Yardım & Destek',
                  onTap: () {},
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Hakkında',
                  subtitle: 'v1.0.0',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showLogoutDialog();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).profile_logout,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuyCreditsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Builder(builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(
                l10n.profile_title,
                style: AppTypography.displaySmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              );
            }),
            const SizedBox(height: AppSpacing.xl),

            _CreditPackage(
              credits: 50,
              price: '\$4.99',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            _CreditPackage(
              credits: 150,
              price: '\$9.99',
              bonus: 20,
              isPopular: true,
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            _CreditPackage(
              credits: 500,
              price: '\$29.99',
              bonus: 100,
              onTap: () {},
            ),

            SizedBox(
                height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          AppLocalizations.of(context).profile_logout,
          style: AppTypography.titleLarge.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Çıkış yapmak istediğinizden emin misiniz?',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: AppTypography.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              context.go('/login');
            },
            child: Text(
              AppLocalizations.of(context).profile_logout,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Modern Icon Button
class _ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool small;

  const _ModernIconButton({
    required this.icon,
    this.onTap,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = small ? 36.0 : 44.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          size: small ? 18 : 22,
        ),
      ),
    );
  }
}

/// Settings Tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: trailing == null ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings Divider
class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        height: 1,
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    );
  }
}

/// Credit Package Card
class _CreditPackage extends StatelessWidget {
  final int credits;
  final String price;
  final int? bonus;
  final bool isPopular;
  final VoidCallback? onTap;

  const _CreditPackage({
    required this.credits,
    required this.price,
    this.bonus,
    this.isPopular = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isPopular ? AppColors.primaryGradient : null,
          color:
              isPopular ? null : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: isPopular
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPopular
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.stars_rounded,
                color: isPopular ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$credits Kredi',
                        style: AppTypography.titleMedium.copyWith(
                          color: isPopular
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (bonus != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isPopular
                                ? Colors.white.withValues(alpha: 0.2)
                                : AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+$bonus bonus',
                            style: AppTypography.caption.copyWith(
                              color:
                                  isPopular ? Colors.white : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isPopular) ...[
                    const SizedBox(height: 2),
                    Text(
                      '⭐ En popüler',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              price,
              style: AppTypography.titleLarge.copyWith(
                color: isPopular
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
