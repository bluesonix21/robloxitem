import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'buttons.dart';

/// Empty state widget for lists, grids, etc.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customIcon;
  final bool compact;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.customIcon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          customIcon ??
              Container(
                width: compact ? 60 : 100,
                height: compact ? 60 : 100,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.cardDark : AppColors.surface)
                      .withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: compact ? 32 : 48,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),

          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),

          // Title
          Text(
            title,
            style: (compact ? AppTypography.titleMedium : AppTypography.headlineSmall)
                .copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          // Description
          if (description != null) ...[
            SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
            Text(
              description!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Action Button
          if (actionText != null && onAction != null) ...[
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.xl),
            PrimaryButton(
              text: actionText!,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

/// Pre-defined empty states
class EmptyStates {
  /// No designs yet
  static Widget noDesigns({VoidCallback? onAction}) => EmptyStateWidget(
        icon: Icons.brush_outlined,
        title: 'Henüz tasarımın yok',
        description: 'AI ile ilk 3D modelini oluştur veya şablonlardan başla.',
        actionText: 'Yeni Oluştur',
        onAction: onAction,
      );

  /// No templates found
  static Widget noTemplates({VoidCallback? onAction}) => EmptyStateWidget(
        icon: Icons.grid_view_outlined,
        title: 'Şablon bulunamadı',
        description: 'Aradığınız kriterlere uygun şablon yok.',
        actionText: 'Filtreleri Temizle',
        onAction: onAction,
      );

  /// No search results
  static Widget noSearchResults({String? query}) => EmptyStateWidget(
        icon: Icons.search_off_outlined,
        title: 'Sonuç bulunamadı',
        description: query != null
            ? '"$query" için sonuç bulunamadı. Farklı kelimeler deneyin.'
            : 'Aramanızla eşleşen sonuç yok.',
      );

  /// No favorites
  static Widget noFavorites({VoidCallback? onAction}) => EmptyStateWidget(
        icon: Icons.favorite_outline,
        title: 'Favorilerin boş',
        description: 'Beğendiğin tasarımları favorilere ekle.',
        actionText: 'Keşfet',
        onAction: onAction,
      );

  /// No drafts
  static Widget noDrafts({VoidCallback? onAction}) => EmptyStateWidget(
        icon: Icons.edit_note_outlined,
        title: 'Taslak yok',
        description: 'Yarım kalan çalışmalarınız burada görünecek.',
        actionText: 'Yeni Başla',
        onAction: onAction,
      );

  /// No published
  static Widget noPublished({VoidCallback? onAction}) => EmptyStateWidget(
        icon: Icons.cloud_upload_outlined,
        title: 'Yayında tasarım yok',
        description: 'Roblox\'a yüklediğin tasarımlar burada görünecek.',
        actionText: 'Yayınla',
        onAction: onAction,
      );

  /// No credits
  static Widget noCredits({VoidCallback? onAction}) => EmptyStateWidget(
        icon: Icons.stars_outlined,
        title: 'Kredin bitti',
        description: 'AI ile model oluşturmak için kredi satın al.',
        actionText: 'Kredi Al',
        onAction: onAction,
      );

  /// No connection
  static Widget noConnection({VoidCallback? onAction}) => EmptyStateWidget(
        icon: Icons.wifi_off_outlined,
        title: 'Bağlantı yok',
        description: 'İnternet bağlantınızı kontrol edin.',
        actionText: 'Tekrar Dene',
        onAction: onAction,
      );

  /// No Roblox connection
  static Widget noRobloxConnection({VoidCallback? onAction}) => EmptyStateWidget(
        icon: Icons.gamepad_outlined,
        title: 'Roblox bağlı değil',
        description: 'Tasarımlarını Roblox\'a yüklemek için hesabını bağla.',
        actionText: 'Roblox\'u Bağla',
        onAction: onAction,
      );
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final String? retryText;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool compact;

  const ErrorStateWidget({
    super.key,
    this.title,
    this.message,
    this.retryText,
    this.onRetry,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: compact ? 60 : 80,
            height: compact ? 60 : 80,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline_rounded,
              size: compact ? 32 : 40,
              color: AppColors.error,
            ),
          ),

          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),

          // Title
          Text(
            title ?? 'Bir hata oluştu',
            style: (compact ? AppTypography.titleMedium : AppTypography.headlineSmall)
                .copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          // Message
          if (message != null) ...[
            SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Retry Button
          if (onRetry != null) ...[
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.xl),
            SecondaryButton(
              text: retryText ?? 'Tekrar Dene',
              onPressed: onRetry,
              icon: Icons.refresh_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

/// Pre-defined error states
class ErrorStates {
  /// Network error
  static Widget network({VoidCallback? onRetry}) => ErrorStateWidget(
        icon: Icons.wifi_off_rounded,
        title: 'Bağlantı hatası',
        message: 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
        retryText: 'Tekrar Dene',
        onRetry: onRetry,
      );

  /// Server error
  static Widget server({VoidCallback? onRetry}) => ErrorStateWidget(
        icon: Icons.cloud_off_rounded,
        title: 'Sunucu hatası',
        message: 'Bir sorun oluştu. Lütfen daha sonra tekrar deneyin.',
        retryText: 'Tekrar Dene',
        onRetry: onRetry,
      );

  /// Auth error
  static Widget auth({VoidCallback? onRetry}) => ErrorStateWidget(
        icon: Icons.lock_outline_rounded,
        title: 'Oturum süresi doldu',
        message: 'Güvenliğiniz için yeniden giriş yapmanız gerekiyor.',
        retryText: 'Giriş Yap',
        onRetry: onRetry,
      );

  /// Rate limit error
  static Widget rateLimit({VoidCallback? onRetry}) => ErrorStateWidget(
        icon: Icons.timer_outlined,
        title: 'Çok fazla istek',
        message: 'Lütfen biraz bekleyin ve tekrar deneyin.',
        retryText: 'Tekrar Dene',
        onRetry: onRetry,
      );

  /// Generic error
  static Widget generic({String? message, VoidCallback? onRetry}) =>
      ErrorStateWidget(
        title: 'Bir hata oluştu',
        message: message ?? 'Beklenmeyen bir hata oluştu.',
        retryText: 'Tekrar Dene',
        onRetry: onRetry,
      );

  /// Job failed
  static Widget jobFailed({VoidCallback? onRetry}) => ErrorStateWidget(
        icon: Icons.construction_rounded,
        title: 'Üretim başarısız',
        message: 'AI modeli oluşturulamadı. Kredileriniz iade edildi.',
        retryText: 'Tekrar Dene',
        onRetry: onRetry,
      );

  /// Publish failed
  static Widget publishFailed({VoidCallback? onRetry}) => ErrorStateWidget(
        icon: Icons.cloud_off_rounded,
        title: 'Yayınlama başarısız',
        message: 'Roblox\'a yükleme sırasında bir hata oluştu.',
        retryText: 'Tekrar Dene',
        onRetry: onRetry,
      );
}

/// Inline error message (for forms, etc.)
class InlineError extends StatelessWidget {
  final String message;
  final IconData? icon;

  const InlineError({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline_rounded,
            color: AppColors.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline warning message
class InlineWarning extends StatelessWidget {
  final String message;
  final IconData? icon;

  const InlineWarning({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline info message
class InlineInfo extends StatelessWidget {
  final String message;
  final IconData? icon;

  const InlineInfo({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.info_outline_rounded,
            color: AppColors.info,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.info : AppColors.info.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Success message
class InlineSuccess extends StatelessWidget {
  final String message;
  final IconData? icon;

  const InlineSuccess({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
