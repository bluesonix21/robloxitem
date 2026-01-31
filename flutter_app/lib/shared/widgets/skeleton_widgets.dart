import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Base shimmer wrapper
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
      highlightColor:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

/// Skeleton box placeholder
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton circle placeholder
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton text line placeholder
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width ?? double.infinity,
      height: height,
      borderRadius: height / 2,
    );
  }
}

/// Skeleton paragraph (multiple lines)
class SkeletonParagraph extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;

  const SkeletonParagraph({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        // Last line is shorter
        final isLast = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: SkeletonLine(
            height: lineHeight,
            width: isLast ? 120 : null,
          ),
        );
      }),
    );
  }
}

/// Skeleton card for assets/templates
class SkeletonAssetCard extends StatelessWidget {
  final double? aspectRatio;
  final bool showTitle;

  const SkeletonAssetCard({
    super.key,
    this.aspectRatio,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio ?? 1.0,
              child: SkeletonBox(
                borderRadius: showTitle
                    ? AppSpacing.radiusMd
                    : AppSpacing.radiusMd,
              ),
            ),
            if (showTitle)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(height: 12, width: 100),
                    const SizedBox(height: 6),
                    SkeletonLine(height: 10, width: 60),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton grid for asset lists
class SkeletonAssetGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool showTitle;

  const SkeletonAssetGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.0,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonAssetCard(
        aspectRatio: 1.0,
        showTitle: showTitle,
      ),
    );
  }
}

/// Skeleton list tile
class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final bool hasSubtitle;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.hasSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingH,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (hasLeading) ...[
              const SkeletonCircle(size: 48),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLine(height: 14, width: 120),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 6),
                    const SkeletonLine(height: 12, width: 80),
                  ],
                ],
              ),
            ),
            if (hasTrailing)
              const SkeletonBox(width: 60, height: 32),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for horizontal list
class SkeletonHorizontalList extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final double spacing;

  const SkeletonHorizontalList({
    super.key,
    this.itemCount = 4,
    this.itemWidth = 120,
    this.itemHeight = 120,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ShimmerWrapper(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
          itemCount: itemCount,
          separatorBuilder: (_, __) => SizedBox(width: spacing),
          itemBuilder: (context, index) => SkeletonBox(
            width: itemWidth,
            height: itemHeight,
            borderRadius: AppSpacing.radiusMd,
          ),
        ),
      ),
    );
  }
}

/// Skeleton for collection card
class SkeletonCollectionCard extends StatelessWidget {
  const SkeletonCollectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              width: 160,
              height: 100,
              borderRadius: AppSpacing.radiusMd,
            ),
            const SizedBox(height: 8),
            const SkeletonLine(height: 12, width: 100),
            const SizedBox(height: 4),
            const SkeletonLine(height: 10, width: 60),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for promo banner
class SkeletonPromoBanner extends StatelessWidget {
  const SkeletonPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
        child: SkeletonBox(
          height: 140,
          borderRadius: AppSpacing.radiusLg,
        ),
      ),
    );
  }
}

/// Skeleton for profile header
class SkeletonProfileHeader extends StatelessWidget {
  const SkeletonProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: [
          const SkeletonCircle(size: 100),
          const SizedBox(height: AppSpacing.md),
          const SkeletonLine(height: 20, width: 150),
          const SizedBox(height: 8),
          const SkeletonLine(height: 14, width: 200),
          const SizedBox(height: AppSpacing.md),
          SkeletonBox(width: 120, height: 36, borderRadius: 18),
        ],
      ),
    );
  }
}

/// Skeleton for credits card
class SkeletonCreditsCard extends StatelessWidget {
  const SkeletonCreditsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
        child: SkeletonBox(
          height: 160,
          borderRadius: AppSpacing.radiusLg,
        ),
      ),
    );
  }
}

/// Skeleton for editor toolbar
class SkeletonEditorToolbar extends StatelessWidget {
  const SkeletonEditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            const SkeletonCircle(size: 40),
            const SizedBox(width: 8),
            const SkeletonCircle(size: 40),
            const SizedBox(width: 8),
            const SkeletonCircle(size: 40),
            const Spacer(),
            SkeletonBox(width: 100, height: 36, borderRadius: 18),
          ],
        ),
      ),
    );
  }
}

/// Full page loading skeleton
class FullPageSkeleton extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const FullPageSkeleton({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text('Yükleniyor...'),
        ],
      ),
    );
  }
}
