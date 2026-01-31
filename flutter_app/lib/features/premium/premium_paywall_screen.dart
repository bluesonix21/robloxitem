import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/sheets_modals.dart';

/// Modern Premium Paywall Screen with glassmorphism
class PremiumPaywallScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final String? featureTitle;

  const PremiumPaywallScreen({
    super.key,
    this.onClose,
    this.featureTitle,
  });

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen>
    with SingleTickerProviderStateMixin {
  int _selectedPlanIndex = 1; // Default to yearly (best value)
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  final List<_PricingPlan> _plans = [
    _PricingPlan(
      id: 'monthly',
      name: 'Monthly',
      price: 49.99,
      period: '/month',
      credits: 500,
      savings: null,
    ),
    _PricingPlan(
      id: 'yearly',
      name: 'Yearly',
      price: 399.99,
      period: '/year',
      credits: 7500,
      savings: '33%',
      isPopular: true,
    ),
    _PricingPlan(
      id: 'lifetime',
      name: 'Lifetime',
      price: 999.99,
      period: '',
      credits: -1, // Unlimited
      savings: 'One-time',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                isDark ? AppColors.backgroundDark : const Color(0xFF0F0F23),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background decorations
              Positioned(
                top: -size.width * 0.5,
                left: -size.width * 0.3,
                child: Container(
                  width: size.width * 1.2,
                  height: size.width * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD700).withValues(alpha: 0.15),
                        const Color(0xFFFFD700).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.width * 0.4,
                right: -size.width * 0.3,
                child: Container(
                  width: size.width,
                  height: size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                children: [
                  // Close button
                  Padding(
                    padding: EdgeInsets.only(
                      top: topPadding + AppSpacing.sm,
                      right: AppSpacing.md,
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (widget.onClose != null) {
                            widget.onClose!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        bottomPadding + AppSpacing.lg,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Header
                          _buildHeader(),

                          const SizedBox(height: AppSpacing.xl),

                          // Features
                          _buildFeatures(),

                          const SizedBox(height: AppSpacing.xl),

                          // Pricing plans
                          _buildPricingPlans(),

                          const SizedBox(height: AppSpacing.xl),

                          // CTA Button
                          _buildCTAButton(),

                          const SizedBox(height: AppSpacing.lg),

                          // Terms
                          _buildTerms(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            children: [
              // Crown icon with glow
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFD700).withValues(alpha: 0.3),
                          const Color(0xFFFFD700).withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),

                  // Main icon container
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glassmorphism effect
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.workspace_premium_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  // Floating sparkles
                  Positioned(
                    top: 20,
                    right: 25,
                    child: Text('✨', style: TextStyle(fontSize: 24)),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Text('⭐', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title with gradient
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.premiumGradient.createShader(bounds),
                child: Text(
                  'Go Premium',
                  style: AppTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                widget.featureTitle != null
                    ? 'Go Premium to use ${widget.featureTitle}'
                    : 'Take your designs to the next level\nwith unlimited access and premium features',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatures() {
    final features = [
      ('✨', 'Unlimited AI Generation', '500+ credits per month'),
      ('🎨', 'Premium Templates', 'Access premium collections'),
      ('🚀', 'Priority Queue', 'Priority in AI processing'),
      ('☁️', 'Unlimited Storage', 'Store all your designs'),
      ('👑', 'Badge & Profile', 'Stand out with premium badge'),
      ('💬', 'Priority Support', '24/7 special support'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < features.length - 1 ? AppSpacing.md : 0,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      feature.$1,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.$2,
                        style: AppTypography.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        feature.$3,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      children: List.generate(_plans.length, (index) {
        final plan = _plans[index];
        final isSelected = _selectedPlanIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPlanIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.premiumGradient : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Radio indicator
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white38,
                        width: 2,
                      ),
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Plan info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (plan.isPopular) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '⭐ Most Popular',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.credits == -1
                              ? 'Unlimited credits'
                              : '${plan.credits} kredi',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₺',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${plan.price.toInt()}',
                            style: AppTypography.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (plan.period.isNotEmpty)
                        Text(
                          plan.period,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      if (plan.savings != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            plan.savings!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCTAButton() {
    final selectedPlan = _plans[_selectedPlanIndex];

    return GestureDetector(
      onTap: _isProcessing ? null : _handleCheckout,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Premium\'a Geç - ₺${selectedPlan.price.toInt()}',
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout() async {
    if (_isProcessing) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingOverlay(message: 'Starting payment...'),
    );

    final plan = _plans[_selectedPlanIndex];
    final service = ref.read(premiumServiceProvider);
    final result = await service.createCheckout(planId: plan.id);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final url = result.data!.checkoutUrl;
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment page could not be opened')),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error ?? 'Payment could not be started')),
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        Text(
          '7 days free trial • Cancel anytime',
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white60,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            text: 'Satın alarak ',
            style: AppTypography.caption.copyWith(
              color: Colors.white38,
            ),
            children: [
              TextSpan(
                text: 'Kullanım Koşulları',
                style: AppTypography.caption.copyWith(
                  color: Colors.white60,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: ' ve '),
              TextSpan(
                text: 'Gizlilik Politikası',
                style: AppTypography.caption.copyWith(
                  color: Colors.white60,
                  decoration: TextDecoration.underline,
                ),
              ),
              const TextSpan(text: '\'nı kabul etmiş olursunuz.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PricingPlan {
  final String id;
  final String name;
  final double price;
  final String period;
  final int credits;
  final String? savings;
  final bool isPopular;

  _PricingPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.credits,
    this.savings,
    this.isPopular = false,
  });
}
