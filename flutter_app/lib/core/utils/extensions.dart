import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date formatting extensions
extension DateTimeExtension on DateTime {
  /// Format as "12 Oca 2024"
  String toShortDate() {
    return DateFormat('d MMM yyyy', 'tr').format(this);
  }

  /// Format as "12 Ocak 2024"
  String toLongDate() {
    return DateFormat('d MMMM yyyy', 'tr').format(this);
  }

  /// Format as "12:30"
  String toTime() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format as "12 Oca, 12:30"
  String toDateTimeShort() {
    return DateFormat('d MMM, HH:mm', 'tr').format(this);
  }

  /// Format as relative time (5 dakika önce, 1 saat önce, etc.)
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      return toShortDate();
    }
  }
}

/// String extensions
extension StringExtension on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Truncate with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check if string is valid URL
  bool get isValidUrl {
    return Uri.tryParse(this)?.hasAbsolutePath ?? false;
  }
}

/// Number extensions
extension NumberExtension on num {
  /// Format with K/M suffix (1.2K, 3.5M)
  String toCompact() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  /// Format as currency
  String toCurrency({String symbol = '\$'}) {
    return '$symbol${toStringAsFixed(2)}';
  }

  /// Format as percentage
  String toPercentage({int decimals = 0}) {
    return '${toStringAsFixed(decimals)}%';
  }

  /// Format with thousands separator
  String toFormattedNumber() {
    return NumberFormat('#,###').format(this);
  }
}

/// List extensions
extension ListExtension<T> on List<T> {
  /// Get item at index or null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Separate list into chunks
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

/// Color extensions
extension ColorExtension on Color {
  /// Lighten color by percentage (0-100)
  Color lighten([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final p = percent / 100;
    final a255 = (a * 255).round().clamp(0, 255).toInt();
    final r255 = (r * 255).round().clamp(0, 255).toInt();
    final g255 = (g * 255).round().clamp(0, 255).toInt();
    final b255 = (b * 255).round().clamp(0, 255).toInt();
    return Color.fromARGB(
      a255,
      r255 + ((255 - r255) * p).round(),
      g255 + ((255 - g255) * p).round(),
      b255 + ((255 - b255) * p).round(),
    );
  }

  /// Darken color by percentage (0-100)
  Color darken([int percent = 10]) {
    assert(percent >= 0 && percent <= 100);
    final p = 1 - percent / 100;
    final a255 = (a * 255).round().clamp(0, 255).toInt();
    final r255 = (r * 255).round().clamp(0, 255).toInt();
    final g255 = (g * 255).round().clamp(0, 255).toInt();
    final b255 = (b * 255).round().clamp(0, 255).toInt();
    return Color.fromARGB(
      a255,
      (r255 * p).round(),
      (g255 * p).round(),
      (b255 * p).round(),
    );
  }

  /// Convert to hex string
  String toHex({bool leadingHashSign = true}) {
    final r255 = (r * 255).round().clamp(0, 255).toInt();
    final g255 = (g * 255).round().clamp(0, 255).toInt();
    final b255 = (b * 255).round().clamp(0, 255).toInt();
    return '${leadingHashSign ? '#' : ''}'
        '${r255.toRadixString(16).padLeft(2, '0')}'
        '${g255.toRadixString(16).padLeft(2, '0')}'
        '${b255.toRadixString(16).padLeft(2, '0')}';
  }
}

/// BuildContext extensions
extension BuildContextExtension on BuildContext {
  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Get safe area padding
  EdgeInsets get safePadding => MediaQuery.of(this).padding;

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show loading dialog
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Yükleniyor...'),
          ],
        ),
      ),
    );
  }

  /// Hide any dialog
  void hideDialog() {
    Navigator.of(this).pop();
  }
}
