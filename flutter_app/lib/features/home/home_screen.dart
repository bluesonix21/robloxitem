import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/asset_model.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/empty_error_states.dart';
import '../../shared/widgets/skeleton_widgets.dart';
import '../../shared/widgets/animated_widgets.dart';

/// Home Screen - Modern, Professional Landing Page
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if ((offset - _scrollOffset).abs() < 4) return;
    setState(() {
      _scrollOffset = offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final size = MediaQuery.of(context).size;

    final creditsAsync = ref.watch(creditsProvider);
    final creditsValue = creditsAsync.maybeWhen(
      data: (balance) => balance.balance,
      orElse: () => 0,
    );
    final assetsAsync = ref.watch(publicAssetsProvider);
    final publicAssets = assetsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <Asset>[],
    );
    final userAssetsAsync = ref.watch(userAssetsProvider);
    final recentAssets = userAssetsAsync.maybeWhen(
      data: (data) => data.take(5).toList(),
      orElse: () => const <Asset>[],
    );

    final aiAssets = publicAssets
        .where((asset) =>
            asset.isAIGenerated &&
            ((asset.textureUrl != null && asset.textureUrl!.isNotEmpty) ||
                (asset.thumbnailUrl != null && asset.thumbnailUrl!.isNotEmpty)))
        .take(6)
        .toList();

    final trendingAssets = publicAssets
        .where((asset) =>
            (asset.textureUrl != null && asset.textureUrl!.isNotEmpty) ||
            (asset.thumbnailUrl != null && asset.thumbnailUrl!.isNotEmpty))
        .take(10)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Stack(
          children: [
            // Animated Background Gradient
            _buildAnimatedBackground(isDark, size),

            // Main Content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Floating Header
                SliverToBoxAdapter(
                  child: _buildFloatingHeader(isDark, topPadding, creditsValue),
                ),

                // Hero Section with Search
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 100),
                    child: _buildHeroSection(isDark),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 200),
                    child: _buildQuickActions(context, isDark),
                  ),
                ),

                // Featured Banner
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 300),
                    child: _buildFeaturedBanner(context, isDark),
                  ),
                ),

                // AI Creations Section
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 400),
                    child: _buildSectionTitle(
                      context,
                      isDark,
                      '✨ AI ile Oluşturulanlar',
                      'Topluluk tarafından yaratılan muhteşem tasarımlar',
                      () => context.go('/discover'),
                    ),
                  ),
                ),

                // AI Creations Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: _buildAICreationsGrid(context, isDark, aiAssets, assetsAsync),
                ),

                // Trending Section
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 500),
                    child: Builder(builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return _buildSectionTitle(
                        context,
                        isDark,
                        l10n.home_trendingTitle,
                        l10n.home_trendingSubtitle,
                        () => context.go('/discover'),
                      );
                    }),
                  ),
                ),

                // Trending Horizontal List
                SliverToBoxAdapter(
                  child: _buildTrendingList(context, isDark, trendingAssets, assetsAsync),
                ),

                // Your Designs Section
                if (recentAssets.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: AnimatedFadeSlide(
                      delay: const Duration(milliseconds: 600),
                      child: Builder(builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        return _buildSectionTitle(
                          context,
                          isDark,
                          l10n.home_yourDesignsTitle,
                          l10n.home_yourDesignsSubtitle,
                          () => context.go('/my-designs'),
                        );
                      }),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildRecentDesigns(context, isDark, recentAssets, userAssetsAsync),
                  ),
                ],

                // Inspiration Section
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 700),
                    child: _buildInspirationSection(context, isDark),
                  ),
                ),

                // Bottom Padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark, Size size) {
    return Positioned(
      top: -100 + (_scrollOffset * 0.3),
      right: -50,
      child: Container(
        width: size.width * 0.8,
        height: size.width * 0.8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              AppColors.primary.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeader(bool isDark, double topPadding, int credits) {
    final isScrolled = _scrollOffset > 20;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.sm,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isScrolled
            ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withValues(alpha: 0.9)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isScrolled
                ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                : Colors.transparent,
            width: 0.5,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isScrolled ? 10 : 0,
            sigmaY: isScrolled ? 10 : 0,
          ),
          child: Row(
            children: [
              // Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.view_in_ar_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).home_greeting,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).home_title,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Credits Chip
              GestureDetector(
                onTap: () => context.push('/premium'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '$credits',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Profile Avatar
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark ? AppColors.cardDark : Colors.white,
                        isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Title
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return RichText(
                text: TextSpan(
                  style: AppTypography.displaySmall.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(text: l10n.home_heroTitle),
                  ],
                ),
              );
            }
          ),

          const SizedBox(height: AppSpacing.lg),

          // Search Bar
          GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Builder(builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Text(
                        l10n.home_searchHint,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      );
                    }),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_command_key,
                          size: 12,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          AppLocalizations.of(context).home_keyboardShortcut,
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Builder(builder: (context) {
              final l10n = AppLocalizations.of(context);
              return _ModernActionCard(
                icon: Icons.auto_awesome_rounded,
                title: l10n.home_createWithAI,
                subtitle: l10n.home_createWithAISubtitle,
                gradient: AppColors.aiGradient,
                iconBackground: const Color(0xFF7C3AED),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/create');
                },
              );
            }),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Builder(builder: (context) {
              final l10n = AppLocalizations.of(context);
              return _ModernActionCard(
                icon: Icons.dashboard_customize_rounded,
                title: l10n.home_templates,
                subtitle: l10n.home_templatesSubtitle,
                gradient: AppColors.primaryGradient,
                iconBackground: AppColors.primary,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/templates');
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/premium');
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.premiumGradient.colors.first.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: -40,
                child: Container(
                  width: 100,
                  height: 100,
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
                          Builder(builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.home_premiumLabel,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.sm),
                          Builder(builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            return Text(
                              l10n.home_premiumTitle,
                              style: AppTypography.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                          Builder(builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            return Text(
                              l10n.home_premiumSubtitle,
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.premiumGradient.colors.first,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    VoidCallback onSeeAll,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Builder(builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(
                l10n.common_seeAll,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAICreationsGrid(
    BuildContext context,
    bool isDark,
    List<Asset> assets,
    AsyncValue<List<Asset>> asyncValue,
  ) {
    if (asyncValue.isLoading) {
      return const SliverToBoxAdapter(
        child: SkeletonAssetGrid(itemCount: 6, crossAxisCount: 3),
      );
    }

    if (assets.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStates.noSearchResults(),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final asset = assets[index];
          final imageUrl =
              asset.thumbnailUrl ?? asset.textureUrl ?? asset.meshUrl ?? '';

          return AnimatedFadeSlide(
            delay: Duration(milliseconds: 100 * index),
            child: ModernAssetCard(
              imageUrl: imageUrl,
              isAI: asset.isAIGenerated,
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/asset/${asset.id}', extra: asset);
              },
            ),
          );
        },
        childCount: assets.length,
      ),
    );
  }

  Widget _buildTrendingList(
    BuildContext context,
    bool isDark,
    List<Asset> assets,
    AsyncValue<List<Asset>> asyncValue,
  ) {
    if (asyncValue.isLoading) {
      return const SizedBox(
        height: 220,
        child: SkeletonHorizontalList(itemCount: 4, itemWidth: 160),
      );
    }

    if (assets.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(
              l10n.discover_noTrending,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            );
          }),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: assets.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final asset = assets[index];
          final imageUrl =
              asset.thumbnailUrl ?? asset.textureUrl ?? asset.meshUrl ?? '';

          return AnimatedFadeSlide(
            delay: Duration(milliseconds: 50 * index),
            child: ModernTrendingCard(
              imageUrl: imageUrl,
              title: asset.name,
              rank: index + 1,
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/asset/${asset.id}', extra: asset);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentDesigns(
    BuildContext context,
    bool isDark,
    List<Asset> assets,
    AsyncValue<List<Asset>> asyncValue,
  ) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: assets.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final asset = assets[index];
          final imageUrl =
              asset.thumbnailUrl ?? asset.textureUrl ?? asset.meshUrl ?? '';

          return ModernRecentCard(
            imageUrl: imageUrl,
            title: asset.name,
            status: asset.status.name,
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/asset/${asset.id}', extra: asset);
            },
          );
        },
      ),
    );
  }

  Widget _buildInspirationSection(BuildContext context, bool isDark) {
    final inspirationData = [
      {'emoji': '🎭', 'key': 'animeCharacter'},
      {'emoji': '🤖', 'key': 'cyberpunkRobot'},
      {'emoji': '🌌', 'key': 'galaxyWings'},
      {'emoji': '🔥', 'key': 'fireEffect'},
      {'emoji': '❄️', 'key': 'iceCrystal'},
    ];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(
              l10n.home_inspirationTitle,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: inspirationData.map((item) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push('/search', extra: item['text']);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item['emoji']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Builder(builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        String text;
                        switch (item['key']) {
                          case 'animeCharacter':
                            text = l10n.inspiration_animeCharacter;
                            break;
                          case 'cyberpunkRobot':
                            text = l10n.inspiration_cyberpunkRobot;
                            break;
                          case 'galaxyWings':
                            text = l10n.inspiration_galaxyWings;
                            break;
                          case 'fireEffect':
                            text = l10n.inspiration_fireEffect;
                            break;
                          case 'iceCrystal':
                            text = l10n.inspiration_iceCrystal;
                            break;
                          default:
                            text = '';
                        }
                        return Text(
                          text,
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Modern Action Card
class _ModernActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color iconBackground;
  final VoidCallback? onTap;

  const _ModernActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.iconBackground,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: iconBackground.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Asset Card
class ModernAssetCard extends StatelessWidget {
  final String imageUrl;
  final bool isAI;
  final bool isPro;
  final VoidCallback? onTap;

  const ModernAssetCard({
    super.key,
    required this.imageUrl,
    this.isAI = false,
    this.isPro = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                  child: Icon(
                    Icons.view_in_ar_rounded,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                    size: 32,
                  ),
                ),
              ),

              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
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

              // Badges
              if (isAI || isPro)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: isAI ? AppColors.aiGradient : AppColors.proGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAI ? Icons.auto_awesome : Icons.workspace_premium,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isAI ? 'AI' : 'PRO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern Trending Card
class ModernTrendingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final int rank;
  final VoidCallback? onTap;

  const ModernTrendingCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rank,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
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
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight,
                        child: Icon(
                          Icons.view_in_ar_rounded,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                  // Rank badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: rank <= 3
                            ? AppColors.primaryGradient
                            : null,
                        color: rank > 3 ? (isDark ? AppColors.surfaceDark : Colors.white) : null,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            color: rank <= 3
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Builder(builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.discover_trend,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Recent Card
class ModernRecentCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String status;
  final VoidCallback? onTap;

  const ModernRecentCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context);
    Color statusColor;
    String statusText;
    switch (status) {
      case 'completed':
        statusColor = AppColors.success;
        statusText = l10n.status_completed;
        break;
      case 'processing':
        statusColor = AppColors.warning;
        statusText = l10n.status_processing;
        break;
      case 'draft':
        statusColor = AppColors.info;
        statusText = l10n.status_draft;
        break;
      default:
        statusColor = AppColors.textSecondaryLight;
        statusText = status;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.backgroundLight,
                    child: Icon(
                      Icons.view_in_ar_rounded,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
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
