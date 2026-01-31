import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import 'badges.dart';

/// Modern Template/Asset Card - Glassmorphism design
class AssetCard extends StatelessWidget {
  final String imageUrl;
  final String? title;
  final bool isPro;
  final bool isAI;
  final bool isNew;
  final bool isTrending;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final double? aspectRatio;
  final bool showFavoriteButton;

  const AssetCard({
    super.key,
    required this.imageUrl,
    this.title,
    this.isPro = false,
    this.isAI = false,
    this.isNew = false,
    this.isTrending = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.aspectRatio,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with badges
            AspectRatio(
              aspectRatio: aspectRatio ?? 1.0,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: title != null
                        ? const BorderRadius.vertical(top: Radius.circular(20))
                        : BorderRadius.circular(20),
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => _buildShimmer(isDark),
                            errorWidget: (context, url, error) =>
                                _buildErrorPlaceholder(isDark),
                          )
                        : _buildErrorPlaceholder(isDark),
                  ),

                  // Gradient overlay
                  if (title != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Badges (top-left)
                  if (isPro || isAI || isNew || isTrending)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        children: [
                          if (isPro) ...[
                            const ProBadge(),
                            const SizedBox(width: 4),
                          ],
                          if (isAI) ...[
                            const AIBadge(),
                            const SizedBox(width: 4),
                          ],
                          if (isNew) ...[
                            const NewBadge(),
                            const SizedBox(width: 4),
                          ],
                          if (isTrending) const TrendingBadge(),
                        ],
                      ),
                    ),

                  // Favorite button (top-right)
                  if (showFavoriteButton)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _ModernFavoriteButton(
                        isFavorite: isFavorite,
                        onTap: onFavorite,
                      ),
                    ),
                ],
              ),
            ),

            // Title (if provided)
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title!,
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? AppColors.surfaceDark : const Color(0xFFF5F5F5),
      child: Container(
        color: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
      ),
    );
  }

  Widget _buildErrorPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      child: Center(
        child: Icon(
          Icons.view_in_ar_rounded,
          size: 40,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
      ),
    );
  }
}

/// Modern Collection/Category Card
class CollectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;

  const CollectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors!,
                )
              : null,
          color: gradientColors == null
              ? (isDark ? AppColors.cardDark : Colors.white)
              : null,
          borderRadius: BorderRadius.circular(18),
          border: gradientColors == null
              ? Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: (gradientColors?.first ?? Colors.black)
                  .withValues(alpha: gradientColors != null ? 0.3 : (isDark ? 0.2 : 0.08)),
              blurRadius: gradientColors != null ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: gradientColors != null
                          ? Colors.white.withValues(alpha: 0.8)
                          : (isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: gradientColors != null
                          ? Colors.white
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Preview image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.view_in_ar_rounded,
                    color: gradientColors != null
                        ? Colors.white.withValues(alpha: 0.7)
                        : (isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Large Discovery Card - For featured items
class DiscoveryCard extends StatelessWidget {
  final String imageUrl;
  final String? title;
  final String? category;
  final bool isFavorite;
  final bool isAI;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const DiscoveryCard({
    super.key,
    required this.imageUrl,
    this.title,
    this.category,
    this.isFavorite = false,
    this.isAI = false,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              hasImage
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildShimmer(isDark),
                      errorWidget: (context, url, error) =>
                          _buildPlaceholder(isDark),
                    )
                  : _buildPlaceholder(isDark),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // AI Badge
              if (isAI)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.aiGradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Favorite button
              Positioned(
                top: 10,
                right: 10,
                child: _ModernFavoriteButton(
                  isFavorite: isFavorite,
                  onTap: onFavorite,
                ),
              ),

              // Info overlay
              if (title != null || category != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category!,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? AppColors.surfaceDark : const Color(0xFFF5F5F5),
      child: Container(
        color: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      child: Center(
        child: Icon(
          Icons.view_in_ar_rounded,
          size: 48,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
      ),
    );
  }
}

/// Modern Promo Banner Card
class PromoBannerCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;

  const PromoBannerCard({
    super.key,
    this.title,
    this.subtitle,
    this.onTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors ??
                const [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
          ),
          boxShadow: [
            BoxShadow(
              color: (gradientColors?.first ?? const Color(0xFF667EEA))
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: 30,
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
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            '✨ PREMIUM',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title ?? 'Sınırsız Erişim',
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
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
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: gradientColors?.first ?? const Color(0xFF667EEA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Favorite Button
class _ModernFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const _ModernFavoriteButton({
    required this.isFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isFavorite
              ? AppColors.error.withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Modern Skeleton/Shimmer Card
class SkeletonCard extends StatelessWidget {
  final double? aspectRatio;
  final bool showTitle;
  final double? height;

  const SkeletonCard({
    super.key,
    this.aspectRatio,
    this.showTitle = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
      highlightColor: isDark ? AppColors.surfaceDark : const Color(0xFFF5F5F5),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (aspectRatio != null)
              AspectRatio(
                aspectRatio: aspectRatio!,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
                    borderRadius: showTitle
                        ? const BorderRadius.vertical(top: Radius.circular(20))
                        : BorderRadius.circular(20),
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : const Color(0xFFE0E0E0),
                    borderRadius: showTitle
                        ? const BorderRadius.vertical(top: Radius.circular(20))
                        : BorderRadius.circular(20),
                  ),
                ),
              ),
            if (showTitle)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.borderDark
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.borderDark
                            : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Feature Card - For highlighting features
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors!,
                )
              : null,
          color: gradientColors == null
              ? (isDark ? AppColors.cardDark : Colors.white)
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (gradientColors?.first ?? Colors.black)
                  .withValues(alpha: gradientColors != null ? 0.3 : (isDark ? 0.2 : 0.08)),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: gradientColors != null
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: gradientColors != null ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: gradientColors != null
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: gradientColors != null
                      ? Colors.white.withValues(alpha: 0.8)
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Premium Glow Card with animated glow effect
class PremiumGlowCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? glowColor;
  final EdgeInsets padding;
  final double borderRadius;
  final bool isGlass;

  const PremiumGlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.glowColor,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.isGlass = true,
  });

  @override
  State<PremiumGlowCard> createState() => _PremiumGlowCardState();
}

class _PremiumGlowCardState extends State<PremiumGlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.15,
      end: 0.35,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGlowColor = widget.glowColor ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: effectiveGlowColor.withValues(alpha: _animation.value),
                  blurRadius: 40,
                  spreadRadius: -8,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: widget.isGlass
            ? ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: widget.padding,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.cardDark : Colors.white)
                          .withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
              )
            : Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: widget.child,
              ),
      ),
    );
  }
}
