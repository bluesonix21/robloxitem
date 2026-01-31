import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

/// Primary CTA Button with gradient background
/// Used for main actions like "Yayınla", "Oluştur", etc.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: AppIconSize.button, color: Colors.white),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          text,
          style: AppTypography.buttonMedium.copyWith(color: Colors.white),
        ),
      ],
    );

    return Container(
      height: height ?? 52,
      width: isExpanded ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: onPressed != null && !isLoading
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.5),
                  AppColors.primaryLight.withValues(alpha: 0.5),
                ],
              ),
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: onPressed != null && !isLoading
            ? AppColors.shadowGlowPrimary
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: icon != null ? AppSpacing.lg : AppSpacing.xl,
            ),
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}

/// Secondary/Outline Button
/// Used for secondary actions like "Özel olarak kaydet"
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isExpanded;
  final IconData? icon;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isExpanded = false,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height ?? 52,
      width: isExpanded ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: icon != null ? AppSpacing.lg : AppSpacing.xl,
            ),
            child: Row(
              mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: AppIconSize.button,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  text,
                  style: AppTypography.buttonMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glow Button with animated glow effect for premium CTAs
class GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isExpanded;
  final IconData? icon;
  final Color? glowColor;
  final double glowIntensity;

  const GlowButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isExpanded = false,
    this.icon,
    this.glowColor,
    this.glowIntensity = 0.5,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: widget.glowIntensity,
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
    final effectiveGlowColor = widget.glowColor ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return RepaintBoundary(
          child: Container(
            height: 52,
            width: widget.isExpanded ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.buttonPremium),
              boxShadow: [
                BoxShadow(
                  color: effectiveGlowColor.withValues(alpha: _animation.value),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: effectiveGlowColor.withValues(alpha: _animation.value * 0.5),
                  blurRadius: 60,
                  spreadRadius: -10,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(AppRadius.buttonPremium),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.icon != null ? AppSpacing.lg : AppSpacing.xl,
            ),
            child: Row(
              mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: AppIconSize.button, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  widget.text,
                  style: AppTypography.buttonMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon Button with circular/rounded background
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final bool hasBorder;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.iconSize = 24,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.cardDark : AppColors.surfaceLight);
    final fgColor = iconColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: hasBorder
            ? Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              )
            : null,
        boxShadow: AppColors.shadowMedium,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Icon(icon, size: iconSize, color: fgColor),
          ),
        ),
      ),
    );
  }
}

/// Text Button with optional icon
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.primary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSize.button, color: textColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: AppTypography.buttonMedium.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Action chip button (for category filters, etc.)
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = selectedColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        padding: EdgeInsets.symmetric(
          horizontal: icon != null ? AppSpacing.md : AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : (isDark ? AppColors.cardDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppIconSize.sm,
                color: isSelected
                    ? activeColor
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTypography.categoryChip.copyWith(
                color: isSelected
                    ? activeColor
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
