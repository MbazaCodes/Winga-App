import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WingaColors {
  // Primary - Forest Green (from UI)
  static const Color primary = Color(0xFF1A5C2A);
  static const Color primaryDark = Color(0xFF0F3D1A);
  static const Color primaryLight = Color(0xFF2E7D40);
  static const Color primarySurface = Color(0xFFE8F5E9);

  // Gold Accent
  static const Color gold = Color(0xFFF9A825);
  static const Color goldLight = Color(0xFFFFF9C4);
  static const Color goldDark = Color(0xFFF57F17);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF1A5C2A);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color successText = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color inProgress = Color(0xFF1565C0);
  static const Color inProgressLight = Color(0xFFE3F2FD);
  static const Color pending = Color(0xFFF9A825);
  static const Color cancelled = Color(0xFFD32F2F);
  static const Color completed = Color(0xFF1A5C2A);

  // Border
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  // Shadows
  static const Color shadow = Color(0x1A000000);
  static const Color shadowMedium = Color(0x26000000);
}

class WingaTextStyles {
  static const String fontFamily = 'Inter';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: WingaColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: WingaColors.textPrimary,
    height: 1.2,
  );

  // Heading
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: WingaColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: WingaColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: WingaColors.textPrimary,
    height: 1.3,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: WingaColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: WingaColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: WingaColors.textLight,
    height: 1.5,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: WingaColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: WingaColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: WingaColors.textSecondary,
    height: 1.4,
  );
}

class WingaSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(vertical: 12.0);
}

class WingaRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
  static const double full = 100.0;

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(16.0));
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(14.0));
  static const BorderRadius chipRadius =
      BorderRadius.all(Radius.circular(100.0));
}

class WingaShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: WingaColors.shadow,
      blurRadius: 12,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> elevated = [
    BoxShadow(
      color: WingaColors.shadowMedium,
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> button = [
    BoxShadow(
      color: WingaColors.primary.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}

ThemeData buildWingaTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: WingaColors.primary,
      primary: WingaColors.primary,
      secondary: WingaColors.gold,
      surface: WingaColors.surface,
      background: WingaColors.background,
      error: WingaColors.error,
      onPrimary: WingaColors.white,
      onSecondary: WingaColors.white,
      onSurface: WingaColors.textPrimary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: WingaColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: WingaColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: WingaColors.textPrimary,
      ),
      iconTheme: IconThemeData(color: WingaColors.primary),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WingaColors.primary,
        foregroundColor: WingaColors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: WingaRadius.buttonRadius,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: WingaColors.primary,
        side: const BorderSide(color: WingaColors.primary, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: WingaRadius.buttonRadius,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WingaColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WingaRadius.sm),
        borderSide: const BorderSide(color: WingaColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WingaRadius.sm),
        borderSide: const BorderSide(color: WingaColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WingaRadius.sm),
        borderSide: const BorderSide(color: WingaColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(WingaRadius.sm),
        borderSide: const BorderSide(color: WingaColors.error, width: 1),
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: WingaColors.textLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: WingaColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WingaRadius.md),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: WingaColors.white,
      selectedItemColor: WingaColors.primary,
      unselectedItemColor: WingaColors.textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: WingaColors.borderLight,
      thickness: 1,
      space: 0,
    ),
  );
}
