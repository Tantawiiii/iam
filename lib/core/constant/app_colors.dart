
import 'package:flutter/material.dart';

final class AppColors {
  // IAM Logo-Inspired Color Palette
  // Based on the vibrant gradient logo design
  
  // Primary Colors - Cyan to Teal (I letter gradient)
  static const Color primary = Color(0xFF06B6D4); // Bright Cyan
  static const Color primaryDark = Color(0xFF0891B2); // Darker Cyan
  static const Color primaryLight = Color(0xFF22D3EE); // Light Cyan
  static const Color primaryTeal = Color(0xFF14B8A6); // Teal
  
  // Secondary Colors - Yellow to Orange-Red (A letter gradient)
  static const Color secondary = Color(0xFFFCD34D); // Sunny Yellow
  static const Color secondaryOrange = Color(0xFFF97316); // Warm Orange
  static const Color secondaryRed = Color(0xFFEF4444); // Orange-Red
  
  // Accent Colors - Magenta to Deep Pink (M letter gradient)
  static const Color accent = Color(0xFFEC4899); // Vibrant Magenta
  static const Color accentPurple = Color(0xFFA855F7); // Purple
  static const Color accentPink = Color(0xFFF472B6); // Deep Pink
  
  // Background Colors - Dark Navy Blue (Logo background)
  static const Color background = Color(0xFF0F172A); // Dark Navy Blue
  static const Color backgroundLight = Color(0xFF1E293B); // Lighter Navy
  static const Color surface = Color(0xFF1E293B); // Card Surface
  static const Color surfaceVariant = Color(0xFF334155); // Variant Surface
  static const Color surfaceElevated = Color(0xFF475569); // Elevated Surface
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFCBD5E1); // Light Gray
  static const Color textTertiary = Color(0xFF94A3B8); // Medium Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on gradients
  static const Color textOnDark = Color(0xFF0F172A); // Dark text on light
  
  // Border & Divider Colors
  static const Color border = Color(0xFF334155);
  static const Color borderLight = Color(0xFF475569);
  static const Color divider = Color(0xFF334155);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
  static const Color shadowGlow = Color(0x4006B6D4); // Cyan glow
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayDark = Color(0xCC000000);
  static const Color overlayLight = Color(0x40000000);
  
  // Splash & Onboarding
  static const Color splashBackground = Color(0xFF0F172A);
  
  // Legacy Support (for gradual migration)
  static const Color primaryColor = primary;
  static const Color blackTextColor = textPrimary;
  static const Color greyTextColor = textSecondary;
  static const Color shadowColor = shadowMedium;
  static const Color errorBorderColor = error;
  static const Color textFieldBorderColor = border;
  static const Color whiteBackground = surface;
  static Color warningColor = warning.withAlpha(100);
  static Color overlayColor = overlay;
  static Color white = surface;
  
  // Premium Gradient Helpers - Based on Logo Colors
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryTeal],
    stops: [0.0, 1.0],
  );
  
  static LinearGradient get secondaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryOrange],
    stops: [0.0, 1.0],
  );
  
  static LinearGradient get accentGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentPink],
    stops: [0.0, 1.0],
  );
  
  static LinearGradient get purpleGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, accent],
    stops: [0.0, 1.0],
  );
  
  // Multi-color gradient (I-A-M inspired)
  static LinearGradient get brandGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondaryOrange, accent],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Horizontal gradient (Software Publishing text style)
  static LinearGradient get horizontalGradient => const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, accentPink],
    stops: [0.0, 1.0],
  );
  
  // Shimmer gradient for loading states
  static LinearGradient get shimmerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      surfaceVariant,
      surfaceElevated,
      surfaceVariant,
    ],
    stops: const [0.0, 0.5, 1.0],
  );
  
  // Glass morphism gradient
  static LinearGradient get glassGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      surface.withOpacity(0.8),
      surfaceVariant.withOpacity(0.6),
    ],
  );
}