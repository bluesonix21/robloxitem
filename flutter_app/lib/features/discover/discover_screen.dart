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

/// Discover/Explore Screen - Modern Gallery View
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'all';
  String _sortBy = 'popular';
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'emoji': '✨'},
    {'id': 'popular', 'emoji': '🔥'},
    {'id': 'new', 'emoji': '🆕'},
    {'id': 'accessory', 'emoji': '⌚'},
    {'id': 'clothing', 'emoji': '👕'},
    {'id': 'hair', 'emoji': '💇'},
    {'id': 'hat', 'emoji': '🎩'},
    {'id': 'weapon', 'emoji': '⚔️'},
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
    final assets = assetsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const <Asset>[],
    );
    final galleryItems = assets
        .where((asset) =>
            (asset.textureUrl != null && asset.textureUrl!.isNotEmpty) ||
            (asset.thumbnailUrl != null && asset.thumbnailUrl!.isNotEmpty))
        .take(30)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -size.width * 0.4,
              left: -size.width * 0.2,
              child: Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF6B6B)
                          .withValues(alpha: isDark ? 0.12 : 0.06),
                      const Color(0xFFFF6B6B).withValues(alpha: 0),
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

                // Category Filter
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 100),
                    child: _buildCategoryFilter(isDark),
                  ),
                ),

                // Sort Options
                SliverToBoxAdapter(
                  child: AnimatedFadeSlide(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSortOptions(isDark),
                  ),
                ),

                // Gallery Grid
                _buildGalleryGrid(isDark, assetsAsync, galleryItems),

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(
                    l10n.discover_title,
                    style: AppTypography.displaySmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(
                    l10n.discover_subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  );
                }),
              ],
            ),
          ),
          _ModernIconButton(
            icon: Icons.search_rounded,
            onTap: () => context.push('/search'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ModernIconButton(
            icon: Icons.tune_rounded,
            onTap: _showFilterSheet,
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
                child: Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(
                    l10n.discover_title,
                    style: AppTypography.titleLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ),
              _ModernIconButton(
                icon: Icons.search_rounded,
                onTap: () => context.push('/search'),
                small: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ModernIconButton(
                icon: Icons.tune_rounded,
                onTap: _showFilterSheet,
                small: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category['id'] == _selectedCategory;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedCategory = category['id'];
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category['emoji'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Builder(builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    String categoryName;
                    switch (category['id']) {
                      case 'all':
                        categoryName = l10n.discover_categoryAll;
                        break;
                      case 'popular':
                        categoryName = l10n.discover_categoryPopular;
                        break;
                      case 'new':
                        categoryName = l10n.discover_categoryNew;
                        break;
                      case 'accessory':
                        categoryName = l10n.discover_categoryAccessory;
                        break;
                      case 'clothing':
                        categoryName = l10n.discover_categoryClothing;
                        break;
                      case 'hair':
                        categoryName = l10n.discover_categoryHair;
                        break;
                      case 'hat':
                        categoryName = l10n.discover_categoryHat;
                        break;
                      case 'weapon':
                        categoryName = l10n.discover_categoryWeapon;
                        break;
                      default:
                        categoryName = category['id'];
                    }
                    return Text(
                      categoryName,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortOptions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(
              l10n.discover_gallery,
              style: AppTypography.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          const Spacer(),
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return _SortChip(
              label: l10n.discover_sortPopular,
              isSelected: _sortBy == 'popular',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _sortBy = 'popular');
              },
            );
          }),
          const SizedBox(width: AppSpacing.sm),
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return _SortChip(
              label: l10n.discover_sortNewest,
              isSelected: _sortBy == 'newest',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _sortBy = 'newest');
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid(
    bool isDark,
    AsyncValue<List<Asset>> assetsAsync,
    List<Asset> items,
  ) {
    if (assetsAsync.isLoading) {
      return const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyStates.noSearchResults(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverToBoxAdapter(
        child: _ModernMasonryGrid(
          items: items,
          onItemTap: (asset) {
            HapticFeedback.selectionClick();
            context.push('/asset/${asset.id}', extra: asset);
          },
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedCategory: _selectedCategory,
        sortBy: _sortBy,
        onApply: (category, sort) {
          setState(() {
            _selectedCategory = category;
            _sortBy = sort;
          });
        },
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

/// Sort Chip
class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Modern Masonry Grid
class _ModernMasonryGrid extends StatelessWidget {
  final List<Asset> items;
  final ValueChanged<Asset> onItemTap;

  const _ModernMasonryGrid({
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // Split items into two columns
    final leftColumn = <Asset>[];
    final rightColumn = <Asset>[];

    for (int i = 0; i < items.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(items[i]);
      } else {
        rightColumn.add(items[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AnimatedFadeSlide(
                  delay: Duration(milliseconds: 50 * entry.key),
                  child: _DiscoverCard(
                    asset: entry.value,
                    height: _getRandomHeight(entry.key),
                    onTap: () => onItemTap(entry.value),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 30), // Offset for masonry effect
              ...rightColumn.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AnimatedFadeSlide(
                    delay: Duration(milliseconds: 50 * entry.key + 50),
                    child: _DiscoverCard(
                      asset: entry.value,
                      height: _getRandomHeight(entry.key + 1),
                      onTap: () => onItemTap(entry.value),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  double _getRandomHeight(int index) {
    final heights = [180.0, 220.0, 200.0, 240.0, 190.0];
    return heights[index % heights.length];
  }
}

/// Discover Card
class _DiscoverCard extends StatelessWidget {
  final Asset asset;
  final double height;
  final VoidCallback? onTap;

  const _DiscoverCard({
    required this.asset,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl =
        asset.thumbnailUrl ?? asset.textureUrl ?? asset.meshUrl ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
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

            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
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

            // Info overlay
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // AI Badge
            if (asset.isAIGenerated)
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
          ],
        ),
      ),
    );
  }
}

/// Filter Bottom Sheet
class _FilterBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final String sortBy;
  final void Function(String category, String sort) onApply;

  const _FilterBottomSheet({
    required this.selectedCategory,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _category;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _sort = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);

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
                Text(
                  l10n.discover_filterTitle,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _category = 'all';
                      _sort = 'popular';
                    });
                  },
                  child: Text(
                    l10n.discover_reset,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.discover_sort,
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _FilterOption(
                        label: 'En Popüler',
                        icon: Icons.trending_up_rounded,
                        isSelected: _sort == 'popular',
                        onTap: () => setState(() => _sort = 'popular'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _FilterOption(
                        label: 'En Yeni',
                        icon: Icons.schedule_rounded,
                        isSelected: _sort == 'newest',
                        onTap: () => setState(() => _sort = 'newest'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Apply Button
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: bottomPadding + AppSpacing.lg,
            ),
            child: GestureDetector(
              onTap: () {
                widget.onApply(_category, _sort);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Uygula',
                    style: AppTypography.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter Option
class _FilterOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
