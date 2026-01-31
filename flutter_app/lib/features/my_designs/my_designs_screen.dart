import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/api/api_config.dart';
import '../../data/models/asset_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/empty_error_states.dart';
import '../../shared/widgets/skeleton_widgets.dart';
import '../../shared/widgets/animated_widgets.dart';
import '../../shared/widgets/sheets_modals.dart';

/// My Designs Screen - Modern User's created designs
class MyDesignsScreen extends ConsumerStatefulWidget {
  const MyDesignsScreen({super.key});

  @override
  ConsumerState<MyDesignsScreen> createState() => _MyDesignsScreenState();
}

class _MyDesignsScreenState extends ConsumerState<MyDesignsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(Asset asset) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Design',
      message:
          'This design will be permanently deleted. Do you want to continue?',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed != true) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingOverlay(message: 'Siliniyor...'),
    );

    try {
      await ref.read(assetRepositoryProvider).deleteAsset(asset);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ref.invalidate(userAssetsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Design deleted')),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final size = MediaQuery.of(context).size;
    final assetsAsync = ref.watch(userAssetsProvider);
    final allAssets = assetsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <Asset>[],
    );
    final drafts = allAssets
        .where((asset) =>
            asset.status == AssetStatus.draft ||
            asset.status == AssetStatus.processing)
        .toList();
    final published = allAssets
        .where((asset) => asset.status == AssetStatus.published)
        .toList();
    final isLoading = assetsAsync.isLoading;
    final hasError = assetsAsync.hasError;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(isDark, topPadding),
                ),

                // Stats Cards
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 100),
                    child: _buildStatsCards(
                      isDark,
                      allAssets.length,
                      drafts.length,
                      published.length,
                    ),
                  ),
                ),

                // Tab Bar
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 200),
                    child: _buildTabBar(
                      isDark,
                      allAssets.length,
                      drafts.length,
                      published.length,
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildDesignsList(
                    allAssets,
                    isDark,
                    isLoading: isLoading,
                    hasError: hasError,
                    emptyMessage: 'No designs yet',
                  ),
                  _buildDesignsList(
                    drafts,
                    isDark,
                    isLoading: isLoading,
                    hasError: hasError,
                    emptyMessage: 'No draft designs',
                  ),
                  _buildDesignsList(
                    published,
                    isDark,
                    isLoading: isLoading,
                    hasError: hasError,
                    emptyMessage: 'No published designs',
                  ),
                ],
              ),
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
        floatingActionButton: _buildFAB(isDark),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).home_yourDesignsTitle,
                  style: AppTypography.displaySmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).home_yourDesignsSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          _ModernIconButton(
            icon: Icons.search_rounded,
            onTap: () => context.push('/search'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ModernIconButton(
            icon: Icons.sort_rounded,
            onTap: () {},
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
                  AppLocalizations.of(context).home_yourDesignsTitle,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _ModernIconButton(
                icon: Icons.search_rounded,
                onTap: () => context.push('/search'),
                small: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDark, int total, int drafts, int published) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.folder_rounded,
              iconColor: AppColors.primary,
              value: '$total',
              label: 'Toplam',
              gradient: AppColors.primaryGradient,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
              icon: Icons.edit_note_rounded,
              iconColor: AppColors.warning,
              value: '$drafts',
              label: 'Taslak',
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
                icon: Icons.cloud_done_rounded,
                iconColor: AppColors.success,
                value: '$published',
                label: AppLocalizations.of(context).status_published),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, int total, int drafts, int published) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.all(4),
        tabs: [
          _TabWithBadge(
              label: AppLocalizations.of(context).common_all, count: total),
          _TabWithBadge(
              label: AppLocalizations.of(context).status_draft, count: drafts),
          _TabWithBadge(
              label: AppLocalizations.of(context).status_published,
              count: published),
        ],
      ),
    );
  }

  Widget _buildDesignsList(
    List<Asset> designs,
    bool isDark, {
    required bool isLoading,
    required bool hasError,
    required String emptyMessage,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SkeletonAssetGrid(itemCount: 6, crossAxisCount: 2),
      );
    }

    if (hasError) {
      return ErrorStates.generic(
        onRetry: () => ref.invalidate(userAssetsProvider),
      );
    }

    if (designs.isEmpty) {
      return EmptyStates.noDesigns(
        onAction: () => context.go('/create'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        120,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.75,
      ),
      itemCount: designs.length,
      itemBuilder: (context, index) {
        final design = designs[index];
        return AnimatedFadeSlide(
          delay: Duration(milliseconds: 50 * index),
          child: _ModernDesignCard(
            asset: design,
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/asset/${design.id}', extra: design);
            },
            onMore: () {
              HapticFeedback.selectionClick();
              _showDesignOptions(context, design);
            },
          ),
        );
      },
    );
  }

  Widget _buildFAB(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.aiGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.go('/create');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          AppLocalizations.of(context).create_title,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDesignOptions(BuildContext context, Asset design) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DesignOptionsSheet(
        design: design,
        onDelete: () => _handleDelete(design),
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

/// Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Gradient? gradient;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: gradient != null
            ? null
            : (isDark ? AppColors.cardDark : Colors.white),
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gradient != null ? iconColor : Colors.black).withValues(
                alpha: gradient != null ? 0.3 : (isDark ? 0.2 : 0.05)),
            blurRadius: gradient != null ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: gradient != null
                  ? Colors.white.withValues(alpha: 0.2)
                  : iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: gradient != null ? Colors.white : iconColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: gradient != null
                  ? Colors.white
                  : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: gradient != null
                  ? Colors.white.withValues(alpha: 0.8)
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab With Badge
class _TabWithBadge extends StatelessWidget {
  final String label;
  final int count;

  const _TabWithBadge({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern Design Card
class _ModernDesignCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const _ModernDesignCard({
    required this.asset,
    this.onTap,
    this.onMore,
  });

  Color get statusColor {
    switch (asset.status) {
      case AssetStatus.completed:
        return AppColors.success;
      case AssetStatus.processing:
        return AppColors.warning;
      case AssetStatus.published:
        return AppColors.info;
      case AssetStatus.failed:
        return AppColors.error;
      case AssetStatus.draft:
        return AppColors.textSecondaryLight;
    }
  }

  String get statusLabel => asset.status.displayName;

  String get createdAtLabel =>
      '${asset.createdAt.day}/${asset.createdAt.month}/${asset.createdAt.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl =
        asset.thumbnailUrl ?? asset.textureUrl ?? asset.meshUrl ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholder(isDark),
                          )
                        : _buildPlaceholder(isDark),
                  ),

                  // Status Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (asset.status == AssetStatus.processing)
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            Icon(
                              _getStatusIcon(),
                              size: 10,
                              color: Colors.white,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // More Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onMore,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Processing overlay
                  if (asset.status == AssetStatus.processing)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        createdAtLabel,
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                      const Spacer(),
                      if (asset.isAIGenerated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.aiGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      child: Icon(
        Icons.view_in_ar_rounded,
        color:
            isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        size: 40,
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (asset.status) {
      case AssetStatus.completed:
        return Icons.check_circle_rounded;
      case AssetStatus.published:
        return Icons.cloud_done_rounded;
      case AssetStatus.failed:
        return Icons.error_rounded;
      case AssetStatus.draft:
        return Icons.edit_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }
}

/// Design Options Bottom Sheet
class _DesignOptionsSheet extends StatelessWidget {
  final Asset design;
  final VoidCallback onDelete;

  const _DesignOptionsSheet({
    required this.design,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.view_in_ar_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.name,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        design.status.displayName,
                        style: AppTypography.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Options
          _ModernOptionTile(
            icon: Icons.edit_rounded,
            label: 'Edit',
            onTap: () {
              Navigator.pop(context);
              context.push('/editor/${design.id}');
            },
          ),
          _ModernOptionTile(
            icon: Icons.visibility_rounded,
            label: 'Preview in Roblox',
            onTap: () {
              Navigator.pop(context);
              final url = ApiConfig.buildRobloxDeepLink(design.id);
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
          ),
          _ModernOptionTile(
            icon: Icons.cloud_upload_rounded,
            label: 'Upload to Roblox',
            onTap: () {
              Navigator.pop(context);
              context.push('/asset/${design.id}', extra: design);
            },
          ),
          _ModernOptionTile(
            icon: Icons.download_rounded,
            label: 'Download (GLB)',
            onTap: () {
              Navigator.pop(context);
              final url = design.meshUrl ?? design.textureUrl;
              if (url == null || url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No downloadable file'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
          ),
          _ModernOptionTile(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {
              Navigator.pop(context);
              final url = design.meshUrl ?? design.textureUrl;
              if (url == null || url.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No shareable link'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                return;
              }
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Link copied'),
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
          ),

          const Divider(height: 1),

          _ModernOptionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Sil',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),

          SizedBox(height: bottomPadding + AppSpacing.md),
        ],
      ),
    );
  }
}

/// Modern Option Tile
class _ModernOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ModernOptionTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isDestructive ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTypography.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
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
