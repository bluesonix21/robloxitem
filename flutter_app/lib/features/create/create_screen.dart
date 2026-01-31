import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/job_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/animated_widgets.dart';

/// Create Screen - Modern AI Generation Interface
class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocus = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  String _selectedProvider = 'MESHY';
  String _selectedCategory = 'accessory';
  String _selectedStyle = 'realistic';
  bool _isGenerating = false;
  bool _showAdvanced = false;

  final List<Map<String, dynamic>> _providers = [
    {
      'id': 'MESHY',
      'name': 'Meshy',
      'icon': Icons.blur_on_rounded,
      'description': 'High quality & detail',
      'time': '~2-3 dk',
      'gradient': AppColors.aiGradient,
    },
    {
      'id': 'TRIPO',
      'name': 'Tripo',
      'icon': Icons.view_in_ar_rounded,
      'description': 'Ultra fast generation',
      'time': '~30 sn',
      'gradient': AppColors.primaryGradient,
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {'id': 'accessory', 'icon': Icons.watch_rounded, 'emoji': '⌚'},
    {'id': 'hat', 'icon': Icons.face_rounded, 'emoji': '🎩'},
    {'id': 'hair', 'icon': Icons.content_cut_rounded, 'emoji': '💇'},
    {'id': 'clothing', 'icon': Icons.checkroom_rounded, 'emoji': '👕'},
    {'id': 'back', 'icon': Icons.backpack_rounded, 'emoji': '🎒'},
    {
      'id': 'face',
      'icon': Icons.face_retouching_natural_rounded,
      'emoji': '👤'
    },
    {'id': 'weapon', 'icon': Icons.sports_esports_rounded, 'emoji': '🗡️'},
  ];

  final List<Map<String, dynamic>> _styles = [
    {
      'id': 'realistic',
      'name': 'Realistic',
      'icon': Icons.photo_camera_rounded
    },
    {'id': 'anime', 'name': 'Anime', 'icon': Icons.animation_rounded},
    {'id': 'cartoon', 'name': 'Cartoon', 'icon': Icons.brush_rounded},
    {'id': 'voxel', 'name': 'Voxel', 'icon': Icons.grid_view_rounded},
  ];

  final List<Map<String, dynamic>> _promptSuggestions = [
    {'emoji': '🤖', 'text': 'Cyberpunk robot kaskı, neon mavi ışıklar'},
    {'emoji': '🔥', 'text': 'Ateş kanatları, gerçekçi alev efekti'},
    {'emoji': '✨', 'text': 'Anime tarzı kristal taç, parıldayan'},
    {'emoji': '🐉', 'text': 'Ejderha zırhı, altın detaylar'},
    {'emoji': '🌙', 'text': 'Ay ışığı pelerin, mistik parıltı'},
    {'emoji': '⚔️', 'text': 'Samuray kılıcı, katana, parlak çelik'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _promptController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _promptFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final size = MediaQuery.of(context).size;

    final creditsAsync = ref.watch(creditsProvider);
    final credits = creditsAsync.maybeWhen(
      data: (balance) => balance.balance,
      orElse: () => 0,
    );

    final provider =
        _selectedProvider == 'TRIPO' ? AIProvider.tripo : AIProvider.meshy;
    final estimatedCost = provider == AIProvider.meshy
        ? AppConstants.defaultMeshyCost
        : AppConstants.defaultTripoCost;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Stack(
          children: [
            // Background Gradient Orb
            Positioned(
              top: -size.width * 0.5,
              left: -size.width * 0.3,
              child: Container(
                width: size.width,
                height: size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED)
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      const Color(0xFF7C3AED).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Column(
              children: [
                // Header
                _buildHeader(isDark, topPadding, credits),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),

                        // AI Badge
                        AnimatedFadeSlide(
                          delay: const Duration(milliseconds: 100),
                          child: _buildAIBadge(isDark),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Prompt Input
                        AnimatedFadeSlide(
                          delay: const Duration(milliseconds: 200),
                          child: _buildPromptInput(isDark),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Prompt Suggestions
                        AnimatedFadeSlide(
                          delay: const Duration(milliseconds: 300),
                          child: _buildPromptSuggestions(isDark),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // AI Provider Selection
                        AnimatedFadeSlide(
                          delay: const Duration(milliseconds: 400),
                          child: _buildProviderSelection(isDark),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Category Selection
                        AnimatedFadeSlide(
                          delay: const Duration(milliseconds: 500),
                          child: _buildCategorySelection(isDark),
                        ),

                        // Advanced Options
                        if (_showAdvanced) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          AnimatedFadeSlide(
                            delay: const Duration(milliseconds: 600),
                            child: _buildStyleSelection(isDark),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // Advanced Toggle
                        _buildAdvancedToggle(isDark),

                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Generate Button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(isDark, bottomPadding, estimatedCost),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, double topPadding, int credits) {
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
                  AppLocalizations.of(context).create_title,
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hayalindeki 3D modeli yaz',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Credits
          Container(
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
        ],
      ),
    );
  }

  Widget _buildAIBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C3AED).withValues(alpha: 0.15),
            const Color(0xFFDB2777).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: AppColors.aiGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.aiGradient.createShader(bounds),
            child: Builder(builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Text(
                l10n.create_aiPowered,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Text(
            l10n.create_promptLabel,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _promptFocus.hasFocus
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: _promptFocus.hasFocus ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _promptFocus.hasFocus
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                controller: _promptController,
                focusNode: _promptFocus,
                maxLines: 4,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).create_promptHint,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                ),
              ),
              // Character counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tips
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Builder(builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return Text(
                            l10n.create_promptTip,
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          );
                        }),
                      ],
                    ),
                    Text(
                      '${_promptController.text.length}/500',
                      style: AppTypography.caption.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromptSuggestions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Text(
            l10n.create_inspiration,
            style: AppTypography.labelMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _promptSuggestions.map((suggestion) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _promptController.text = suggestion['text'];
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
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      suggestion['emoji']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      suggestion['text']!.split(',').first,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProviderSelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Provider',
          style: AppTypography.titleMedium.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: _providers.map((provider) {
            final isSelected = provider['id'] == _selectedProvider;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedProvider = provider['id'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: provider != _providers.last ? AppSpacing.md : 0,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? null
                        : (isDark ? AppColors.cardDark : Colors.white),
                    gradient: isSelected ? provider['gradient'] : null,
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? (provider['gradient'] as LinearGradient)
                                .colors
                                .first
                                .withValues(alpha: 0.4)
                            : Colors.black
                                .withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: isSelected ? 15 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.backgroundLight),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          provider['icon'],
                          size: 26,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        provider['name'],
                        style: AppTypography.titleSmall.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider['description'],
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.backgroundLight),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider['time'],
                              style: AppTypography.caption.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
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
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: AppTypography.titleMedium.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
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
                  width: 75,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category['emoji'],
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['id'],
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Text(
            l10n.create_style,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: _styles.map((style) {
            final isSelected = style['id'] == _selectedStyle;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedStyle = style['id'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: style != _styles.last ? AppSpacing.sm : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        style['icon'],
                        size: 22,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        style['name'],
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedToggle(bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAdvanced = !_showAdvanced;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showAdvanced
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _showAdvanced ? 'Hide advanced options' : 'Advanced options',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark, double bottomPadding, int cost) {
    final hasPrompt = _promptController.text.trim().isNotEmpty;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: bottomPadding + AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceDark : Colors.white)
                .withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cost info
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.info,
                        size: 18,
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
                              l10n.create_estimatedCost,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.info,
                              ),
                            );
                          }),
                          Builder(builder: (context) {
                            final l10n = AppLocalizations.of(context);
                            return Text(
                              l10n.create_creditsWillBeUsed(cost),
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Generate Button
              GestureDetector(
                onTap: hasPrompt && !_isGenerating ? _handleGenerate : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: hasPrompt && !_isGenerating
                        ? AppColors.aiGradient
                        : null,
                    color: hasPrompt && !_isGenerating
                        ? null
                        : (isDark
                            ? AppColors.surfaceDark
                            : AppColors.borderLight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: hasPrompt && !_isGenerating
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7C3AED)
                                  .withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGenerating)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _isGenerating
                            ? 'Generating...'
                            : AppLocalizations.of(context).create_title,
                        style: AppTypography.titleSmall.copyWith(
                          color: Colors.white,
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

  Future<void> _handleGenerate() async {
    if (_promptController.text.trim().isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isGenerating = true;
    });

    final provider =
        _selectedProvider == 'TRIPO' ? AIProvider.tripo : AIProvider.meshy;

    final job = await ref.read(jobsProvider.notifier).createJob(
          prompt: _promptController.text.trim(),
          provider: provider,
          style: _selectedStyle.toLowerCase(),
        );

    if (!mounted) return;

    setState(() {
      _isGenerating = false;
    });

    if (job == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Could not start process'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            const Text('AI generation started! ✨'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    _promptController.clear();
  }
}
