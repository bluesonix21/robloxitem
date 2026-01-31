import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Main App Shell with Bottom Navigation
/// Matches the Customuse-style navigation with 5 tabs:
/// Anasayfa, Tasarımım, Oluştur, Şablonlar, Keşfet
class MainAppShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const MainAppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: _buildBottomNav(isDark),
        extendBody: true,
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Anasayfa',
                isSelected: widget.currentIndex == 0,
                onTap: () => widget.onTabSelected(0),
              ),
              _NavItem(
                icon: Icons.folder_outlined,
                activeIcon: Icons.folder,
                label: 'Tasarımım',
                isSelected: widget.currentIndex == 1,
                onTap: () => widget.onTabSelected(1),
              ),
              // Center Create Button (larger, highlighted)
              _CreateButton(
                isSelected: widget.currentIndex == 2,
                onTap: () => widget.onTabSelected(2),
              ),
              _NavItem(
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view,
                label: 'Şablonlar',
                isSelected: widget.currentIndex == 3,
                onTap: () => widget.onTabSelected(3),
              ),
              _NavItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Keşfet',
                isSelected: widget.currentIndex == 4,
                onTap: () => widget.onTabSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual Navigation Item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppDuration.fast,
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.navLabel.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Center Create Button - Larger with plus icon
class _CreateButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CreateButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? AppColors.primaryGradient
                  : null,
              color: isSelected
                  ? null
                  : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
              shape: BoxShape.circle,
              border: isSelected
                  ? null
                  : Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      width: 1.5,
                    ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.add,
              size: 28,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Oluştur',
            style: AppTypography.navLabel.copyWith(
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
