import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Toast notification types
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Toast notification position
enum ToastPosition {
  top,
  bottom,
}

/// Toast notification model
class ToastNotification {
  final String message;
  final String? title;
  final ToastType type;
  final Duration duration;
  final VoidCallback? action;
  final String? actionLabel;
  final bool dismissible;
  final IconData? customIcon;

  const ToastNotification({
    required this.message,
    this.title,
    this.type = ToastType.info,
    this.duration = const Duration(seconds: 3),
    this.action,
    this.actionLabel,
    this.dismissible = true,
    this.customIcon,
  });
}

/// Toast notification manager - singleton to manage toast queue
class ToastManager {
  static final ToastManager _instance = ToastManager._internal();
  factory ToastManager() => _instance;
  ToastManager._internal();

  final List<ToastNotification> _queue = [];
  OverlayEntry? _currentOverlay;
  bool _isShowing = false;

  /// Show a toast notification
  void show(
    BuildContext context,
    ToastNotification notification, {
    ToastPosition position = ToastPosition.bottom,
  }) {
    _queue.add(notification);
    if (!_isShowing) {
      _showNext(context, position);
    }
  }

  /// Show success toast
  void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    show(
      context,
      ToastNotification(
        message: message,
        title: title,
        type: ToastType.success,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show error toast
  void showError(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    show(
      context,
      ToastNotification(
        message: message,
        title: title ?? 'Hata',
        type: ToastType.error,
        duration: duration ?? const Duration(seconds: 4),
        action: action,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show warning toast
  void showWarning(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    show(
      context,
      ToastNotification(
        message: message,
        title: title,
        type: ToastType.warning,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
    );
  }

  /// Show info toast
  void showInfo(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? action,
    String? actionLabel,
  }) {
    show(
      context,
      ToastNotification(
        message: message,
        title: title,
        type: ToastType.info,
        duration: duration ?? const Duration(seconds: 3),
        action: action,
        actionLabel: actionLabel,
      ),
    );
  }

  void _showNext(BuildContext context, ToastPosition position) {
    if (_queue.isEmpty) {
      _isShowing = false;
      return;
    }

    _isShowing = true;
    final notification = _queue.removeAt(0);

    _currentOverlay = OverlayEntry(
      builder: (context) => _ToastWidget(
        notification: notification,
        position: position,
        onDismiss: () {
          _dismiss();
          _showNext(context, position);
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);

    // Auto dismiss
    Future.delayed(notification.duration, () {
      if (!context.mounted) {
        return;
      }
      if (_currentOverlay != null) {
        _dismiss();
        _showNext(context, position);
      }
    });
  }

  void _dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Clear all pending toasts
  void clearAll() {
    _queue.clear();
    _dismiss();
    _isShowing = false;
  }
}

/// Internal toast widget
class _ToastWidget extends StatefulWidget {
  final ToastNotification notification;
  final ToastPosition position;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.notification,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    final slideBegin = widget.position == ToastPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);

    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final notification = widget.notification;

    final config = _getTypeConfig(notification.type);

    return Positioned(
      top: widget.position == ToastPosition.top
          ? mediaQuery.padding.top + AppSpacing.md
          : null,
      bottom: widget.position == ToastPosition.bottom
          ? mediaQuery.padding.bottom + AppSpacing.xl
          : null,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: GestureDetector(
            onHorizontalDragEnd: notification.dismissible
                ? (details) {
                    if (details.primaryVelocity!.abs() > 100) {
                      _dismiss();
                    }
                  }
                : null,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: config.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: config.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notification.customIcon ?? config.icon,
                        color: config.color,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // Content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notification.title != null) ...[
                            Text(
                              notification.title!,
                              style: AppTypography.titleSmall.copyWith(
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            notification.message,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Action button
                    if (notification.action != null &&
                        notification.actionLabel != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      TextButton(
                        onPressed: () {
                          notification.action!();
                          _dismiss();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          notification.actionLabel!,
                          style: AppTypography.labelMedium.copyWith(
                            color: config.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    // Close button
                    if (notification.dismissible) ...[
                      const SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ToastConfig _getTypeConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case ToastType.error:
        return _ToastConfig(
          color: AppColors.error,
          icon: Icons.error_outline,
        );
      case ToastType.warning:
        return _ToastConfig(
          color: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case ToastType.info:
        return _ToastConfig(
          color: AppColors.info,
          icon: Icons.info_outline,
        );
    }
  }
}

class _ToastConfig {
  final Color color;
  final IconData icon;

  const _ToastConfig({
    required this.color,
    required this.icon,
  });
}

/// Snackbar helper - for simpler notifications using built-in snackbar
class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final config = _getConfig(type);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: ToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: ToastType.error, duration: const Duration(seconds: 4));
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: ToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: ToastType.info);
  }

  static _ToastConfig _getConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case ToastType.error:
        return _ToastConfig(
          color: AppColors.error,
          icon: Icons.error_outline,
        );
      case ToastType.warning:
        return _ToastConfig(
          color: const Color(0xFFF59E0B),
          icon: Icons.warning_amber_outlined,
        );
      case ToastType.info:
        return _ToastConfig(
          color: AppColors.info,
          icon: Icons.info_outline,
        );
    }
  }
}

/// In-app notification banner for important persistent messages
class NotificationBanner extends StatelessWidget {
  final String message;
  final String? title;
  final ToastType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const NotificationBanner({
    super.key,
    required this.message,
    this.title,
    this.type = ToastType.info,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getConfig();

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            config.icon,
            color: config.color,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(
                  color: config.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ],
        ],
      ),
    );
  }

  _ToastConfig _getConfig() {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case ToastType.error:
        return _ToastConfig(
          color: AppColors.error,
          icon: Icons.error_outline,
        );
      case ToastType.warning:
        return _ToastConfig(
          color: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case ToastType.info:
        return _ToastConfig(
          color: AppColors.info,
          icon: Icons.info_outline,
        );
    }
  }
}

/// Extension for easy toast access
extension ToastExtension on BuildContext {
  void showSuccessToast(String message, {String? title}) {
    ToastManager().showSuccess(this, message, title: title);
  }

  void showErrorToast(String message, {String? title}) {
    ToastManager().showError(this, message, title: title);
  }

  void showWarningToast(String message, {String? title}) {
    ToastManager().showWarning(this, message, title: title);
  }

  void showInfoToast(String message, {String? title}) {
    ToastManager().showInfo(this, message, title: title);
  }
}
