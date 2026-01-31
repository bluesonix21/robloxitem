import 'package:flutter/services.dart';

/// Haptic feedback helper
class HapticHelper {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void vibrate() => HapticFeedback.vibrate();
}

/// Debouncer for search and other inputs
class Debouncer {
  final int milliseconds;
  VoidCallback? _action;
  bool _isDebouncing = false;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _action = action;
    if (!_isDebouncing) {
      _isDebouncing = true;
      Future.delayed(Duration(milliseconds: milliseconds), () {
        _isDebouncing = false;
        _action?.call();
      });
    }
  }

  void cancel() {
    _action = null;
    _isDebouncing = false;
  }
}

/// Throttler for rate limiting
class Throttler {
  final int milliseconds;
  bool _isThrottling = false;

  Throttler({this.milliseconds = 500});

  void run(VoidCallback action) {
    if (!_isThrottling) {
      action();
      _isThrottling = true;
      Future.delayed(Duration(milliseconds: milliseconds), () {
        _isThrottling = false;
      });
    }
  }
}

/// Validation helpers
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta gerekli';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Geçerli bir e-posta girin';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu alan'} gerekli';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? 'Bu alan'} en az $minLength karakter olmalı';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Bu alan'} en fazla $maxLength karakter olabilir';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }
}

/// Image helper for handling asset URLs
class ImageHelper {
  /// Get placeholder image URL
  static String placeholder({int width = 400, int height = 400}) {
    return 'https://via.placeholder.com/${width}x$height';
  }

  /// Get 3D model thumbnail URL
  static String modelThumbnail(String modelId) {
    // Return placeholder for now, implement actual storage URL logic
    return 'https://via.placeholder.com/400x400?text=3D+Model';
  }

  /// Check if URL is valid image
  static bool isValidImageUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final path = uri.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp');
  }
}

/// Number formatting helpers
class NumberHelper {
  /// Format polygon count
  static String formatPolygons(int count, {int max = 4000}) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k / ${(max / 1000).toStringAsFixed(0)}k';
    }
    return '$count / $max';
  }

  /// Format credits
  static String formatCredits(int credits) {
    if (credits >= 1000) {
      return '${(credits / 1000).toStringAsFixed(1)}K';
    }
    return credits.toString();
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

/// Clipboard helper
class ClipboardHelper {
  static Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<String?> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
