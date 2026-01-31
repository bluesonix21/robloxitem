import 'package:flutter/widgets.dart';

/// Design System Spacing Constants
/// Based on 4px grid system for consistent layouts
class AppSpacing {
  AppSpacing._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BASE UNITS (4px grid)
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const double xxs = 2.0;   // 0.5x
  static const double xs = 4.0;    // 1x
  static const double sm = 8.0;    // 2x
  static const double md = 12.0;   // 3x
  static const double base = 16.0; // 4x (default)
  static const double lg = 20.0;   // 5x
  static const double xl = 24.0;   // 6x
  static const double xxl = 32.0;  // 8x
  static const double xxxl = 40.0; // 10x
  static const double huge = 48.0; // 12x
  static const double massive = 64.0; // 16x

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC SPACING
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Screen horizontal padding
  static const double screenPaddingH = 16.0;
  
  /// Screen vertical padding (top/bottom safe areas)
  static const double screenPaddingV = 24.0;

  /// Combined screen padding (EdgeInsets)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingH,
    vertical: screenPaddingV,
  );
  
  /// Card internal padding
  static const double cardPadding = 16.0;
  
  /// Card internal padding (compact)
  static const double cardPaddingSm = 12.0;
  
  /// Gap between cards in a list
  static const double cardGap = 12.0;
  
  /// Gap between grid items
  static const double gridGap = 12.0;
  
  /// Section spacing (between major sections)
  static const double sectionGap = 24.0;
  
  /// Item spacing in a list
  static const double listItemGap = 12.0;
  
  /// Icon to text spacing
  static const double iconTextGap = 8.0;
  
  /// Button internal padding (horizontal)
  static const double buttonPaddingH = 24.0;
  
  /// Button internal padding (vertical)
  static const double buttonPaddingV = 14.0;
  
  /// Input field internal padding
  static const double inputPadding = 16.0;
  
  /// Chip internal padding
  static const double chipPadding = 12.0;
  
  /// Modal bottom sheet padding
  static const double sheetPadding = 24.0;
  
  /// Navigation bar height
  static const double navBarHeight = 80.0;
  
  /// App bar height
  static const double appBarHeight = 56.0;
  
  /// Tab bar height
  static const double tabBarHeight = 48.0;
  
  /// Search bar height
  static const double searchBarHeight = 48.0;
  
  /// Bottom safe area (approximate)
  static const double bottomSafeArea = 34.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // RADIUS ALIASES (legacy usage)
  // ═══════════════════════════════════════════════════════════════════════════

  static const double radiusSm = 8.0;
  static const double radiusXs = 4.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
}

/// Design System Border Radius Constants
class AppRadius {
  AppRadius._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BASE RADII
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double full = 999.0; // Pill shape

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC RADII
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Card corners
  static const double card = 20.0;
  
  /// Premium card corners - slightly more rounded
  static const double cardPremium = 24.0;
  
  /// Button corners
  static const double button = 14.0;
  
  /// Premium button corners
  static const double buttonPremium = 16.0;
  
  /// Input field corners
  static const double input = 12.0;
  
  /// Premium input corners
  static const double inputPremium = 14.0;
  
  /// Chip/Tag corners
  static const double chip = 20.0;
  
  /// Badge corners
  static const double badge = 8.0;
  
  /// Bottom sheet corners
  static const double sheet = 28.0;
  
  /// Dialog corners
  static const double dialog = 24.0;
  
  /// Image/thumbnail corners
  static const double image = 16.0;
  
  /// Avatar corners (circular)
  static const double avatar = 999.0;
  
  /// Icon button corners
  static const double iconButton = 12.0;
  
  /// 3D preview container
  static const double preview3D = 20.0;
  
  /// Glass card corners
  static const double glassCard = 24.0;
  
  /// Small component corners
  static const double small = 8.0;
  
  /// Medium component corners  
  static const double medium = 16.0;
  
  /// Large component corners
  static const double large = 24.0;
}

/// Design System Blur Values for Glassmorphism
class AppBlur {
  AppBlur._();
  
  /// Subtle blur - for light glass effects
  static const double subtle = 5.0;
  
  /// Light blur - for cards
  static const double light = 10.0;
  
  /// Medium blur - for modals
  static const double medium = 20.0;
  
  /// Heavy blur - for backgrounds
  static const double heavy = 40.0;
  
  /// Extreme blur - for immersive effects
  static const double extreme = 60.0;
}

/// Design System Opacity Values
class AppOpacity {
  AppOpacity._();
  
  /// Fully transparent
  static const double transparent = 0.0;
  
  /// Very subtle
  static const double verySubtle = 0.05;
  
  /// Subtle - for disabled states
  static const double subtle = 0.1;
  
  /// Light - for glassmorphism
  static const double light = 0.15;
  
  /// Medium - for overlays
  static const double medium = 0.3;
  
  /// Semi-transparent
  static const double semi = 0.5;
  
  /// High - for prominent overlays
  static const double high = 0.7;
  
  /// Mostly opaque
  static const double mostly = 0.85;
  
  /// Fully opaque
  static const double opaque = 1.0;
}

/// Design System Icon Sizes
class AppIconSize {
  AppIconSize._();

  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double base = 24.0;
  static const double lg = 28.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;
  
  /// Navigation bar icon
  static const double navBar = 24.0;
  
  /// App bar action icon
  static const double appBar = 24.0;
  
  /// Button icon
  static const double button = 20.0;
  
  /// Input prefix/suffix icon
  static const double input = 20.0;
  
  /// List item leading icon
  static const double listItem = 24.0;
  
  /// Badge icon (Pro, AI)
  static const double badge = 12.0;
  
  /// Empty state illustration
  static const double emptyState = 80.0;
}

/// Design System Animation Durations
class AppDuration {
  AppDuration._();

  static const Duration instant = Duration.zero;
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration slower = Duration(milliseconds: 400);
  static const Duration slowest = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  /// Page transition
  static const Duration pageTransition = Duration(milliseconds: 300);
  
  /// Modal sheet animation
  static const Duration sheetAnimation = Duration(milliseconds: 350);
  
  /// Button press feedback
  static const Duration buttonPress = Duration(milliseconds: 100);
  
  /// Loading skeleton pulse
  static const Duration shimmer = Duration(milliseconds: 1500);
  
  /// Progress indicator
  static const Duration progress = Duration(milliseconds: 500);
  
  /// Staggered animation delay
  static const Duration staggerDelay = Duration(milliseconds: 50);
  
  /// Spring animation
  static const Duration spring = Duration(milliseconds: 600);
  
  /// Micro-interaction
  static const Duration micro = Duration(milliseconds: 80);
}

/// Design System Animation Curves
class AppCurves {
  AppCurves._();
  
  /// Standard easing
  static const Curve standard = Curves.easeInOut;
  
  /// Entrance easing - elements entering screen
  static const Curve entrance = Curves.easeOutCubic;
  
  /// Exit easing - elements leaving screen
  static const Curve exit = Curves.easeInCubic;
  
  /// Emphasized easing - for important transitions
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  
  /// Spring curve - bouncy effect
  static const Curve spring = Curves.elasticOut;
  
  /// Bounce curve - for playful interactions
  static const Curve bounce = Curves.bounceOut;
  
  /// Smooth curve - for subtle transitions
  static const Curve smooth = Curves.easeInOutQuart;
  
  /// Decelerate - for scrolling
  static const Curve decelerate = Curves.decelerate;
  
  /// Fast out slow in - for expanding elements
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}

/// Design System Elevation/Shadow Levels
class AppElevation {
  AppElevation._();

  static const double none = 0.0;
  static const double low = 2.0;
  static const double medium = 4.0;
  static const double high = 8.0;
  static const double highest = 16.0;
  
  /// Card elevation
  static const double card = 2.0;
  
  /// Modal elevation
  static const double modal = 16.0;
  
  /// FAB elevation
  static const double fab = 6.0;
  
  /// Navigation bar elevation
  static const double navBar = 8.0;
}
