import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Modern Onboarding Screen with glassmorphism and animations
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _iconController;
  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.view_in_ar_rounded,
      emoji: '🎨',
      title: 'AI ile 3D Model Oluştur',
      description:
          'Sadece bir metin girerek profesyonel 3D modeller oluşturun. AI destekli tasarım gücüyle hayal gücünüzü gerçeğe dönüştürün.',
      gradient: AppColors.primaryGradient,
      bgColor: const Color(0xFFFFF5F0),
    ),
    OnboardingPage(
      icon: Icons.palette_rounded,
      emoji: '✨',
      title: 'Düzenle & Özelleştir',
      description:
          'Güçlü 3D editörümüzle modellerinizi düzenleyin, renkleri değiştirin ve benzersiz tasarımlar yaratın.',
      gradient: const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      bgColor: const Color(0xFFF5F3FF),
    ),
    OnboardingPage(
      icon: Icons.rocket_launch_rounded,
      emoji: '🚀',
      title: 'Roblox\'a Yayınla',
      description:
          'Tasarımlarınızı tek tıkla Roblox\'a yükleyin. Milyonlarca oyuncuya ulaşın ve tasarımlarınızı satın.',
      gradient: const LinearGradient(
        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      bgColor: const Color(0xFFF0FDFA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    _iconRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOut),
    );

    _iconController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _iconController.reset();
    _iconController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final currentPage = _pages[_currentPage];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: currentPage.bgColor,
        body: Stack(
          children: [
            // Animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                color: currentPage.bgColor,
              ),
            ),

            // Background decoration orbs
            Positioned(
              top: -size.width * 0.4,
              right: -size.width * 0.3,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      currentPage.gradient.colors.first.withValues(alpha: 0.2),
                      currentPage.gradient.colors.first.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -size.width * 0.3,
              left: -size.width * 0.2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      currentPage.gradient.colors.last.withValues(alpha: 0.15),
                      currentPage.gradient.colors.last.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Column(
              children: [
                // Skip Button
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + AppSpacing.sm,
                    right: AppSpacing.lg,
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: _completeOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Atla',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], size);
                    },
                  ),
                ),

                // Bottom section
                Container(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    bottomPadding + AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _buildIndicator(index),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Button
                      _buildNextButton(currentPage),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container
          AnimatedBuilder(
            animation: _iconController,
            builder: (context, child) {
              return Transform.scale(
                scale: _iconScale.value,
                child: Transform.rotate(
                  angle: _iconRotation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              page.gradient.colors.first.withValues(alpha: 0.3),
                              page.gradient.colors.first.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),

                      // Main icon container
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: page.gradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: page.gradient.colors.first.withValues(alpha: 0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glassmorphism effect
                            ClipOval(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                            Icon(
                              page.icon,
                              size: 64,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      // Floating emoji
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            page.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondaryLight,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;
    final page = _pages[_currentPage];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 10,
      height: 10,
      decoration: BoxDecoration(
        gradient: isActive ? page.gradient : null,
        color: isActive ? null : Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: page.gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildNextButton(OnboardingPage page) {
    final isLast = _currentPage == _pages.length - 1;

    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: page.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: page.gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Başla' : 'Devam Et',
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String emoji;
  final String title;
  final String description;
  final LinearGradient gradient;
  final Color bgColor;

  OnboardingPage({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
    required this.bgColor,
  });
}
