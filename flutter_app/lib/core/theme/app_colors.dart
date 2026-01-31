import 'package:flutter/material.dart';

/// RobloxUGC Creator Color System
/// Modern, vibrant color palette inspired by Customuse
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIMARY BRAND COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary Orange - Main CTA color (from screenshots)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A5C);
  static const Color primaryDark = Color(0xFFE55A2B);
  
  /// Secondary color - Purple accent
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA855F7);
  static const Color secondaryDark = Color(0xFF6D28D9);
  
  /// Tertiary color - Teal accent for variety
  static const Color tertiary = Color(0xFF14B8A6);
  static const Color tertiaryLight = Color(0xFF2DD4BF);
  
  /// Primary gradient for buttons and highlights
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A5C)],
  );

  /// Pro badge gradient (pink/purple from screenshots)
  static const LinearGradient proGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4D6D), Color(0xFFFF758F)],
  );

  /// AI badge gradient (purple/blue sparkle effect)
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
  );

  /// Crown/Premium gradient
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE040FB), Color(0xFFFF4081)],
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );
  
  /// Aurora background gradient for dark mode
  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
      Color(0xFF0F3460),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Subtle mesh gradient for premium backgrounds
  static const LinearGradient meshGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF5F2),
      Color(0xFFFFF9F7),
      Color(0xFFF8F9FA),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Dark mesh gradient
  static const LinearGradient meshGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF252542),
      Color(0xFF1F1F35),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ═══════════════════════════════════════════════════════════════════════════
  // GLOW & EFFECT COLORS (Premium UI)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary glow color for buttons and cards
  static Color get primaryGlow => primary.withValues(alpha: 0.4);
  
  /// Secondary glow color
  static Color get secondaryGlow => secondary.withValues(alpha: 0.4);
  
  /// Success glow
  static Color get successGlow => success.withValues(alpha: 0.4);
  
  /// Error glow
  static Color get errorGlow => error.withValues(alpha: 0.4);
  
  /// Premium gold glow for Pro features
  static const Color goldGlow = Color(0xFFFFD700);
  
  /// Neon accent for gaming feel
  static const Color neonAccent = Color(0xFF00F5D4);
  
  /// Soft white glow
  static Color get whiteGlow => Colors.white.withValues(alpha: 0.3);
  
  /// Subtle shadow colors
  static Color shadowLightColor = const Color(0xFF000000).withValues(alpha: 0.04);
  static Color shadowMediumColor = const Color(0xFF000000).withValues(alpha: 0.08);
  static Color shadowHeavyColor = const Color(0xFF000000).withValues(alpha: 0.12);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color textDisabledLight = Color(0xFFD1D5DB);
  
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);
  
  /// Card shadow for light theme - Multi-layer premium shadows
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: -2,
    ),
  ];
  
  /// Premium card shadow with colored glow
  static List<BoxShadow> cardShadowPremium = [
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 10),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -4,
    ),
  ];
  
  /// Soft shadow for subtle elevation
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
  
  /// Medium shadow for cards and buttons
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Heavy shadow for modals and bottom sheets
  static List<BoxShadow> shadowHeavy = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 30,
      offset: const Offset(0, 12),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Glow shadow for primary CTA buttons
  static List<BoxShadow> shadowGlowPrimary = [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 40,
      offset: const Offset(0, 10),
      spreadRadius: -5,
    ),
  ];
  
  /// Glow shadow for success states
  static List<BoxShadow> shadowGlowSuccess = [
    BoxShadow(
      color: success.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF252542);
  
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color textDisabledDark = Color(0xFF4B5563);
  
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerDark = Color(0xFF1F2937);
  
  /// Card shadow for dark theme - Multi-layer with depth
  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Dark theme premium glow
  static List<BoxShadow> cardShadowPremiumDark = [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 30,
      offset: const Offset(0, 10),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
  
  /// Glassmorphism shadow for elevated glass cards
  static List<BoxShadow> glassShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];
  
  /// Glassmorphism shadow for light theme
  static List<BoxShadow> glassShadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // 3D EDITOR SPECIFIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color editorBackground = Color(0xFF2D2D3A);
  static const Color editorGrid = Color(0xFF3D3D4A);
  static const Color editorHighlight = Color(0xFF00D9FF);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY COLORS (for template categories)
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color categoryHat = Color(0xFF8B5CF6);
  static const Color categoryHair = Color(0xFFEC4899);
  static const Color categoryFace = Color(0xFFF97316);
  static const Color categoryShirt = Color(0xFF06B6D4);
  static const Color categoryPants = Color(0xFF10B981);
  static const Color categoryAccessory = Color(0xFFF59E0B);
  static const Color categoryBack = Color(0xFF6366F1);
  static const Color categoryShoulders = Color(0xFFEF4444);

  // ═══════════════════════════════════════════════════════════════════════════
  // AVATAR MESH PREVIEW BACKGROUND
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color meshPreviewBg = Color(0xFFE8E8EC);
  static const Color meshPreviewBgDark = Color(0xFF2A2A3C);

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY ALIASES (for older widgets)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color surface = surfaceLight;
  static const Color border = borderLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;

  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get category color by type
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hat':
      case 'şapka':
        return categoryHat;
      case 'hair':
      case 'saç':
        return categoryHair;
      case 'face':
      case 'yüz':
        return categoryFace;
      case 'shirt':
      case 'gömlek':
        return categoryShirt;
      case 'pants':
      case 'pantolon':
        return categoryPants;
      case 'accessory':
      case 'aksesuar':
        return categoryAccessory;
      case 'back':
      case 'sırt':
        return categoryBack;
      case 'shoulders':
      case 'omuz':
        return categoryShoulders;
      default:
        return primary;
    }
  }
}
