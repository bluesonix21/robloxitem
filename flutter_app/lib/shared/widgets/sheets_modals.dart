import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'buttons.dart';

/// Custom bottom sheet wrapper with drag handle and animations
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showDragHandle;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsets? padding;
  final double? maxHeight;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.onClose,
    this.padding,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (showDragHandle)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Header with title
          if (title != null || showCloseButton)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: AppTypography.headlineSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  if (showCloseButton)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      onPressed: onClose ?? () => Navigator.pop(context),
                    ),
                ],
              ),
            ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: padding ??
                  EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg + bottomPadding,
                  ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  /// Show bottom sheet helper
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
    bool enableDrag = true,
    bool isDismissible = true,
    double? maxHeight,
  }) {
    HapticFeedback.lightImpact();

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }
}

/// Action sheet item
class ActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isDestructive;
  final bool showChevron;

  const ActionSheetItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.isDestructive = false,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive
        ? AppColors.error
        : iconColor ??
            (isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        color: isDestructive
                            ? AppColors.error
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right,
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

/// Action sheet with multiple options
class ActionSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final List<ActionSheetItem> actions;
  final String? cancelText;

  const ActionSheet({
    super.key,
    this.title,
    this.message,
    required this.actions,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message != null) ...[
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        ...actions,
        if (cancelText != null) ...[
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            text: cancelText!,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ],
    );
  }

  static Future<void> show({
    required BuildContext context,
    String? title,
    String? message,
    required List<ActionSheetItem> actions,
    String? cancelText,
  }) {
    return AppBottomSheet.show(
      context: context,
      title: title,
      child: ActionSheet(
        message: message,
        actions: actions,
        cancelText: cancelText,
      ),
    );
  }
}

/// Confirmation dialog
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Onayla',
    this.cancelText = 'İptal',
    required this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      title: Text(
        title,
        style: AppTypography.headlineSmall.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Onayla',
    String cancelText = 'İptal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () {},
      ),
    );
  }
}

/// Success/Error result modal
class ResultModal extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String? message;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? action;

  const ResultModal({
    super.key,
    required this.isSuccess,
    required this.title,
    this.message,
    this.buttonText = 'Tamam',
    this.onButtonPressed,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: (isSuccess ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            size: 48,
            color: isSuccess ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Title
        Text(
          title,
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),

        // Message
        if (message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Action or Button
        if (action != null)
          action!
        else
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: buttonText,
              onPressed: onButtonPressed ?? () => Navigator.pop(context),
            ),
          ),
      ],
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'Tamam',
    VoidCallback? onButtonPressed,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: ResultModal(
        isSuccess: true,
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'Tekrar Dene',
    VoidCallback? onButtonPressed,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: ResultModal(
        isSuccess: false,
        title: title,
        message: message,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }
}

/// Loading overlay modal
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final double? progress;

  const LoadingOverlay({
    super.key,
    this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.xxl),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress != null)
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: AppColors.borderLight,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                        ),
                        Text(
                          '${(progress! * 100).toInt()}%',
                          style: AppTypography.labelMedium,
                        ),
                      ],
                    ),
                  )
                else
                  const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    message!,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, {String? message, double? progress}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingOverlay(
        message: message,
        progress: progress,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Tooltip/Info popup
class InfoTooltip extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;

  const InfoTooltip({
    super.key,
    required this.title,
    required this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppColors.shadowMd,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
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
    );
  }
}
