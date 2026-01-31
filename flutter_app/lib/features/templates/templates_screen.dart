import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/asset_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/empty_error_states.dart';
import '../../shared/widgets/skeleton_widgets.dart';
import '../../shared/widgets/animated_widgets.dart';

/// Templates Screen - Modern Browse template categories
class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  String _selectedCategory = 'Tümü';
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final List<Map<String, dynamic>> _featuredCollections = [
    {
      'title': 'Anime Styles',
      'subtitle': '50+ Şablon',
      'emoji': '🎭',
      'gradient': [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
    },
    {
      'title': 'Cyberpunk',
      'subtitle': '30+ Şablon',
      'emoji': '🤖',
      'gradient': [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
    },
    {
      'title': 'Fantasy',
      'subtitle': '45+ Şablon',
      'emoji': '🐉',
      'gradient': [const Color(0xFF00B894), const Color(0xFF55EFC4)],
    },
    {
      'title': 'Streetwear',
      'subtitle': '25+ Şablon',
      'emoji': '👟',
      'gradient': [const Color(0xFFFD79A8), const Color(0xFFE84393)],
    },
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final size = MediaQuery.of(context).size;
    final assetsAsync = ref.watch(publicAssetsProvider);
    final assets = assetsAsync.value ?? [];
    final grouped = _groupAssets(assets);
    final categories = ['Tümü', ...grouped.keys];

    if (!categories.contains(_selectedCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedCategory = 'Tümü');
        }
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Stack(
          children: [
            // Background gradient
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.2,
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

                // Search Bar
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 100),
                    child: _buildSearchBar(isDark),
                  ),
                ),

                // Featured Collections
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 200),
                    child: _buildFeaturedCollections(isDark),
                  ),
                ),

                // Premium Banner
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 300),
                    child: _buildPremiumBanner(isDark),
                  ),
                ),

                // Category Filter
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 400),
                    child: _buildCategoryFilter(isDark, categories),
                  ),
                ),

                // Templates Grid
                _buildTemplatesGrid(isDark, assetsAsync, grouped),

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).home_templates,
                      style: AppTypography.displaySmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).home_templatesSubtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Filter Button
              _ModernIconButton(
                icon: Icons.tune_rounded,
                onTap: () {},
              ),
            ],
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
                  AppLocalizations.of(context).home_templates,
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
              const SizedBox(width: AppSpacing.sm),
              _ModernIconButton(
                icon: Icons.tune_rounded,
                onTap: () {},
                small: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
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
                padding: const EdgeInsets.all(8),
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
                child: Text(
                  AppLocalizations.of(context).search_hint,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '500+ şablon',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCollections(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(
                '✨ Öne Çıkan Koleksiyonlar',
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
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _featuredCollections.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final collection = _featuredCollections[index];
              return _CollectionCard(
                title: collection['title'],
                subtitle: collection['subtitle'],
                emoji: collection['emoji'],
                gradientColors: collection['gradient'],
                onTap: () {
                  HapticFeedback.selectionClick();
                },
              );
            },
          ),
        ),
      ],
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
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667EEA),
                const Color(0xFF764BA2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -20,
                top: -20,
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
                right: 40,
                bottom: -30,
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
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Premium Şablonlar',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Özel tasarımları kilitle',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
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

  Widget _buildCategoryFilter(bool isDark, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Text(
            '📦 Kategoriler',
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedCategory;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    color: isSelected
                        ? null
                        : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    category,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatesGrid(
    bool isDark,
    AsyncValue<List<Asset>> assetsAsync,
    Map<String, List<Asset>> grouped,
  ) {
    if (assetsAsync.isLoading) {
      return const SliverPadding(
        padding: EdgeInsets.all(AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: SkeletonAssetGrid(itemCount: 6, crossAxisCount: 2),
        ),
      );
    }

    if (assetsAsync.hasError) {
      return SliverToBoxAdapter(
        child: ErrorStates.generic(
          onRetry: () => ref.invalidate(publicAssetsProvider),
        ),
      );
    }

    if (grouped.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStates.noTemplates(
          onAction: () => context.push('/create'),
        ),
      );
    }

    // Get templates based on selected category
    List<Asset> templates = [];
    if (_selectedCategory == 'Tümü') {
      templates = grouped.values.expand((e) => e).take(20).toList();
    } else if (grouped.containsKey(_selectedCategory)) {
      templates = grouped[_selectedCategory]!;
    }

    if (templates.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStates.noSearchResults(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final template = templates[index];
            final imageUrl = template.thumbnailUrl ??
                template.textureUrl ??
                template.meshUrl ??
                '';

            return AnimatedFadeSlide(
              delay: Duration(milliseconds: 50 * index),
              child: _ModernTemplateCard(
                imageUrl: imageUrl,
                name: template.name,
                category: template.categoryLabel,
                isAI: template.isAIGenerated,
                isPro: !template.isPublic,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push('/asset/${template.id}', extra: template);
                },
              ),
            );
          },
          childCount: templates.length,
        ),
      ),
    );
  }

  Map<String, List<Asset>> _groupAssets(List<Asset> assets) {
    final grouped = <String, List<Asset>>{};
    for (final asset in assets) {
      final key = asset.categoryLabel;
      grouped.putIfAbsent(key, () => []).add(asset);
    }
    return grouped;
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

/// Featured Collection Card
class _CollectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _CollectionCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Template Card
class _ModernTemplateCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String category;
  final bool isAI;
  final bool isPro;
  final VoidCallback? onTap;

  const _ModernTemplateCard({
    required this.imageUrl,
    required this.name,
    required this.category,
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
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
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

                  // Badges
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        if (isAI)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.aiGradient,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isPro)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.proGradient,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 14,
                        color: Colors.white,
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
                    name,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
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
