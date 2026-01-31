import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';

/// Modern Settings Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final darkMode = ref.watch(darkModeProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: topPadding + AppSpacing.md,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.2 : 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).settings_title,
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.md),

                // Appearance Section
                _buildSectionHeader(AppLocalizations.of(context).settings_appearance, isDark),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF1F2937), Color(0xFF374151)],
                      ),
                      title: AppLocalizations.of(context).settings_darkMode,
                      description: AppLocalizations.of(context).settings_darkModeDescription,
                      trailing: _ModernSwitch(
                        value: darkMode,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          ref.read(darkModeProvider.notifier).state = value;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Notifications Section
                _buildSectionHeader(AppLocalizations.of(context).settings_notifications, isDark),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      iconGradient: AppColors.primaryGradient,
                      title: AppLocalizations.of(context).settings_pushNotifications,
                      description: 'İş tamamlandığında bildirim al',
                      trailing: _ModernSwitch(
                        value: true,
                        onChanged: (value) {},
                      ),
                    ),
                    _SettingsDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.email_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      ),
                      title: AppLocalizations.of(context).settings_emailNotifications,
                      description: 'Önemli güncellemeler için e-posta al',
                      trailing: _ModernSwitch(
                        value: false,
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // AI Settings Section
                _buildSectionHeader(AppLocalizations.of(context).settings_aiSettings, isDark),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.auto_awesome_rounded,
                      iconGradient: AppColors.aiGradient,
                      title: AppLocalizations.of(context).settings_defaultProvider,
                      subtitle: 'Meshy',
                      onTap: () => _showProviderPicker(context, isDark),
                    ),
                    _SettingsDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.high_quality_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFFEAB308), Color(0xFFCA8A04)],
                      ),
                      title: AppLocalizations.of(context).settings_defaultQuality,
                      subtitle: 'Yüksek',
                      onTap: () => _showQualityPicker(context, isDark),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Storage Section
                _buildSectionHeader(AppLocalizations.of(context).settings_storage, isDark),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.cached_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                      ),
                      title: AppLocalizations.of(context).settings_clearCache,
                      subtitle: '125 MB kullanılıyor',
                      onTap: () => _clearCache(context, isDark),
                    ),
                    _SettingsDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.download_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                      ),
                      title: 'İndirilen Dosyalar',
                      subtitle: '3 dosya',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // About Section
                _buildSectionHeader(AppLocalizations.of(context).settings_about, isDark),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                      ),
                      title: AppLocalizations.of(context).settings_appVersion,
                      subtitle: '1.0.0 (Build 1)',
                      showChevron: false,
                    ),
                    _SettingsDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                      ),
                      title: AppLocalizations.of(context).settings_termsOfService,
                      onTap: () {},
                    ),
                    _SettingsDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                      ),
                      title: AppLocalizations.of(context).settings_privacyPolicy,
                      onTap: () {},
                    ),
                    _SettingsDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconGradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      ),
                      title: AppLocalizations.of(context).settings_helpSupport,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color:
              isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showProviderPicker(BuildContext context, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModernBottomSheet(
        isDark: isDark,
        title: 'AI Sağlayıcı Seçin',
        children: [
          _ProviderOption(
            icon: Icons.auto_awesome,
            name: 'Meshy',
            description: 'Hızlı ve kaliteli',
            isSelected: true,
            gradient: AppColors.aiGradient,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ProviderOption(
            icon: Icons.view_in_ar,
            name: 'Tripo',
            description: 'Detaylı modeller',
            isSelected: false,
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
            ),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showQualityPicker(BuildContext context, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModernBottomSheet(
        isDark: isDark,
        title: 'Kalite Seçin',
        children: [
          _QualityOption(
            label: 'Düşük',
            description: 'Daha hızlı, daha az kredi',
            isSelected: false,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          _QualityOption(
            label: 'Orta',
            description: 'Dengeli performans',
            isSelected: false,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          _QualityOption(
            label: 'Yüksek',
            description: 'En iyi kalite',
            isSelected: true,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _clearCache(BuildContext context, bool isDark) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Önbelleği Temizle',
          style: AppTypography.titleLarge.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '125 MB önbellek temizlenecek. Bu işlem geri alınamaz.',
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Önbellek temizlendi'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Temizle',
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
}

/// Settings Card Container
class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

/// Settings Tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final LinearGradient iconGradient;
  final String title;
  final String? description;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.iconGradient,
    required this.title,
    this.description,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconGradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  (showChevron && onTap != null
                      ? Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        )
                      : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings Divider
class _SettingsDivider extends StatelessWidget {
  final bool isDark;

  const _SettingsDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 1,
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    );
  }
}

/// Modern Switch
class _ModernSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ModernSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          gradient: value ? AppColors.primaryGradient : null,
          color: value ? null : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern Bottom Sheet
class _ModernBottomSheet extends StatelessWidget {
  final bool isDark;
  final String title;
  final List<Widget> children;

  const _ModernBottomSheet({
    required this.isDark,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
          SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

/// Provider Option
class _ProviderOption extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final bool isSelected;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ProviderOption({
    required this.icon,
    required this.name,
    required this.description,
    required this.isSelected,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.cardDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? gradient.colors.first
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Quality Option
class _QualityOption extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _QualityOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.cardDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
