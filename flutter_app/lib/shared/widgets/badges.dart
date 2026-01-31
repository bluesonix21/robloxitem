import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Pro Badge (Pink gradient badge like in screenshots)
class ProBadge extends StatelessWidget {
  final double? fontSize;
  final EdgeInsets? padding;

  const ProBadge({
    super.key,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        gradient: AppColors.proGradient,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4D6D).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            size: fontSize ?? 10,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            'Pro',
            style: AppTypography.badge.copyWith(
              fontSize: fontSize ?? 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// AI Badge (Purple gradient with sparkle icon)
class AIBadge extends StatelessWidget {
  final String? label;
  final double? fontSize;
  final EdgeInsets? padding;

  const AIBadge({
    super.key,
    this.label,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: fontSize ?? 10,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            label ?? 'Yapay Zeka',
            style: AppTypography.badge.copyWith(
              fontSize: fontSize ?? 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium Crown Badge (for unlimited access promo)
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE040FB).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.workspace_premium,
        size: 16,
        color: Colors.white,
      ),
    );
  }
}

/// Status Badge (for job status, etc.)
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  Color get backgroundColor {
    switch (type) {
      case StatusType.success:
        return AppColors.successLight;
      case StatusType.warning:
        return AppColors.warningLight;
      case StatusType.error:
        return AppColors.errorLight;
      case StatusType.info:
        return AppColors.infoLight;
      case StatusType.pending:
        return AppColors.dividerLight;
    }
  }

  Color get textColor {
    switch (type) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.info;
      case StatusType.pending:
        return AppColors.textSecondaryLight;
    }
  }

  IconData get icon {
    switch (type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.error:
        return Icons.error;
      case StatusType.info:
        return Icons.info;
      case StatusType.pending:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.badge.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

enum StatusType { success, warning, error, info, pending }

/// Category Tag Badge
class CategoryBadge extends StatelessWidget {
  final String category;
  final bool isSmall;

  const CategoryBadge({
    super.key,
    required this.category,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getCategoryColor(category);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppSpacing.sm : AppSpacing.md,
        vertical: isSmall ? 3 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        category,
        style: (isSmall ? AppTypography.labelSmall : AppTypography.badge)
            .copyWith(color: color),
      ),
    );
  }
}

/// Polygon Count Badge (shows 0k/4k style)
class PolygonBadge extends StatelessWidget {
  final int current;
  final int max;

  const PolygonBadge({
    super.key,
    required this.current,
    this.max = 4000,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverLimit = current > max;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withValues(alpha: 0.9)
            : AppColors.surfaceLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D cube icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isOverLimit
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.view_in_ar,
              size: 16,
              color: isOverLimit ? AppColors.error : AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${_formatNumber(current)} / ${_formatNumber(max)}',
            style: AppTypography.counter.copyWith(
              color: isOverLimit
                  ? AppColors.error
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }
}

/// New badge (for new templates/items)
class NewBadge extends StatelessWidget {
  const NewBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Text(
        'YENİ',
        style: AppTypography.badge.copyWith(color: Colors.white),
      ),
    );
  }
}

/// Trending/Hot badge
class TrendingBadge extends StatelessWidget {
  const TrendingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF4757)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            'Trend',
            style: AppTypography.badge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
