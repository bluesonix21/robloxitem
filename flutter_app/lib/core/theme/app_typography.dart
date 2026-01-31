import 'package:flutter/material.dart';

/// RobloxUGC Creator Typography System
/// Modern, clean typography with fluid scaling
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════════════════════════════
  // FONT FAMILIES
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const String fontFamilyDisplay = 'SF Pro Display';
  static const String fontFamilyText = 'SF Pro Text';
  static const String fontFamilyFallback = 'Roboto';

  // ═══════════════════════════════════════════════════════════════════════════
  // FONT WEIGHTS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPLAY STYLES (Large headings)
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 40,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 28,
    fontWeight: semibold,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADING STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 24,
    fontWeight: semibold,
    height: 1.35,
    letterSpacing: -0.1,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 20,
    fontWeight: semibold,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 18,
    fontWeight: semibold,
    height: 1.4,
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // TITLE STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 18,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.1,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 14,
    fontWeight: medium,
    height: 1.45,
    letterSpacing: 0.1,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.2,
  );

  /// Caption text (alias for bodySmall)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.2,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LABEL STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 10,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: semibold,
    height: 1.25,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 14,
    fontWeight: semibold,
    height: 1.25,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 12,
    fontWeight: semibold,
    height: 1.25,
    letterSpacing: 0.3,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Badge text (Pro, AI, etc.)
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 10,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Price display
  static const TextStyle price = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 20,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.2,
  );

  /// Credits display
  static const TextStyle credits = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 24,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.3,
  );

  /// Navigation label
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 11,
    fontWeight: medium,
    height: 1.2,
    letterSpacing: 0.3,
  );

  /// Tab bar label
  static const TextStyle tabLabel = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 13,
    fontWeight: semibold,
    height: 1.3,
    letterSpacing: 0.2,
  );

  /// Category chip
  static const TextStyle categoryChip = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 13,
    fontWeight: medium,
    height: 1.3,
    letterSpacing: 0.1,
  );

  /// Search placeholder
  static const TextStyle searchHint = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 15,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Empty state message
  static const TextStyle emptyState = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 15,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.1,
  );

  /// Counter (like polygon count 0k/4k)
  static const TextStyle counter = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 12,
    fontWeight: semibold,
    height: 1.2,
    letterSpacing: 0,
  );
}
