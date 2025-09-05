import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the application.
class AppTheme {
  AppTheme._();

  // Royal Luxury Color Palette - Updated for AL KABBUS AI
  static const Color royalBlue = Color(0xFF1E3A8A); // Deep royal blue
  static const Color royalBlueLight = Color(0xFF3B82F6); // Lighter royal blue
  static const Color royalPurple = Color(0xFF6B21A8); // Royal purple
  static const Color royalPurpleLight = Color(
    0xFF8B5CF6,
  ); // Lighter royal purple
  static const Color luxuryGold = Color(0xFFFFD700); // Luxury gold
  static const Color luxuryGoldLight = Color(0xFFFDE047); // Light luxury gold
  static const Color deepNavy = Color(0xFF0F1629); // Deep navy background
  static const Color royalSurface = Color(0xFF1E293B); // Royal surface color
  static const Color aiBlue = Color(0xFF06B6D4); // AI accent blue
  static const Color aiGlow = Color(0xFF0EA5E9); // AI glow effect

  // Updated text colors for royal theme
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFE2E8F0); // Light gray
  static const Color textTertiary = Color(0xFF94A3B8); // Muted gray
  static const Color textAccent = Color(0xFFFFD700); // Gold accent text

  // Professional Trading Dark Color Palette (kept for backward compatibility)
  static const Color primaryDark = deepNavy; // Updated to royal navy
  static const Color secondaryDark = royalSurface; // Updated to royal surface
  static const Color accentGreen = Color(0xFF10B981); // Enhanced green
  static const Color warningRed = Color(0xFFEF4444); // Enhanced red
  static const Color goldColor = luxuryGold; // Use luxury gold
  static const Color surfaceColor = Color(0xFF334155); // Royal surface
  static const Color borderColor = Color(0xFF475569); // Royal border

  // Light theme colors (minimal usage as per dark-first approach)
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);

  /// Dark theme (primary theme for royal AI trading application)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: royalBlue,
      onPrimary: textPrimary,
      primaryContainer: royalSurface,
      onPrimaryContainer: textPrimary,
      secondary: luxuryGold,
      onSecondary: deepNavy,
      secondaryContainer: surfaceColor,
      onSecondaryContainer: textPrimary,
      tertiary: royalPurple,
      onTertiary: textPrimary,
      tertiaryContainer: surfaceColor,
      onTertiaryContainer: textPrimary,
      error: warningRed,
      onError: textPrimary,
      surface: deepNavy,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: borderColor,
      outlineVariant: borderColor.withValues(alpha: 0.5),
      shadow: Colors.black.withValues(alpha: 0.3),
      scrim: Colors.black.withValues(alpha: 0.5),
      inverseSurface: textPrimary,
      onInverseSurface: deepNavy,
      inversePrimary: royalBlue,
    ),
    scaffoldBackgroundColor: deepNavy,
    cardColor: royalSurface,
    dividerColor: borderColor.withValues(alpha: 0.3),

    // AppBar Theme - Royal and luxurious
    appBarTheme: AppBarTheme(
      backgroundColor: deepNavy,
      foregroundColor: textPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
      actionsIconTheme: const IconThemeData(color: luxuryGold, size: 24),
    ),

    // Card Theme - Royal elevated cards
    cardTheme: CardThemeData(
      color: royalSurface,
      elevation: 4.0,
      shadowColor: royalBlue.withValues(alpha: 0.2),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: royalBlue.withValues(alpha: 0.3), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom Navigation Theme - Royal style
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: royalSurface,
      selectedItemColor: luxuryGold,
      unselectedItemColor: textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 12.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    ),

    // Tab Bar Theme - Luxury style
    tabBarTheme: TabBarThemeData(
      labelColor: luxuryGold,
      unselectedLabelColor: textTertiary,
      indicatorColor: luxuryGold,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      dividerColor: Colors.transparent,
    ),

    // Floating Action Button Theme - Royal style
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: royalBlue,
      foregroundColor: textPrimary,
      elevation: 6.0,
      focusElevation: 8.0,
      hoverElevation: 8.0,
      highlightElevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    ),

    // Button Themes - Royal luxury style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textPrimary,
        backgroundColor: royalBlue,
        disabledForegroundColor: textTertiary,
        disabledBackgroundColor: surfaceColor,
        elevation: 4.0,
        shadowColor: royalBlue.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: luxuryGold,
        disabledForegroundColor: textTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        side: const BorderSide(color: luxuryGold, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: aiBlue,
        disabledForegroundColor: textTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Text Theme - Royal typography
    textTheme: _buildTextTheme(isDark: true),

    // Input Decoration Theme - Royal input fields
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceColor,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: royalBlue.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: luxuryGold, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: warningRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: warningRed, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textTertiary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.inter(
        color: warningRed,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Switch Theme - Royal style
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return luxuryGold;
        }
        return textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return royalBlue.withValues(alpha: 0.4);
        }
        return borderColor;
      }),
    ),

    // Checkbox Theme - Royal style
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return luxuryGold;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(deepNavy),
      side: const BorderSide(color: luxuryGold, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),

    // Radio Theme - Royal style
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return luxuryGold;
        }
        return borderColor;
      }),
    ),

    // Progress Indicator Theme - Royal AI style
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: aiBlue,
      linearTrackColor: surfaceColor,
      circularTrackColor: surfaceColor,
    ),

    // Slider Theme - Royal style
    sliderTheme: SliderThemeData(
      activeTrackColor: luxuryGold,
      thumbColor: luxuryGold,
      overlayColor: luxuryGold.withValues(alpha: 0.2),
      inactiveTrackColor: surfaceColor,
      trackHeight: 4.0,
    ),

    // Tooltip Theme - Royal style
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: royalSurface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: luxuryGold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: royalBlue.withValues(alpha: 0.2),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar Theme - Royal style
    snackBarTheme: SnackBarThemeData(
      backgroundColor: royalSurface,
      contentTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: luxuryGold,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: royalBlue.withValues(alpha: 0.3)),
      ),
      elevation: 6.0,
    ),

    // List Tile Theme - Royal progressive disclosure
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: royalBlue.withValues(alpha: 0.1),
      iconColor: textSecondary,
      textColor: textPrimary,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),

    // Divider Theme - Royal style
    dividerTheme: DividerThemeData(
      color: royalBlue.withValues(alpha: 0.3),
      thickness: 1.0,
      space: 1.0,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: royalSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: luxuryGold.withValues(alpha: 0.3)),
      ),
    ),
  );

  /// Light theme (updated with royal colors)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: royalBlue,
      onPrimary: primaryLight,
      primaryContainer: backgroundLight,
      onPrimaryContainer: textPrimaryLight,
      secondary: luxuryGold,
      onSecondary: primaryLight,
      secondaryContainer: surfaceLight,
      onSecondaryContainer: textPrimaryLight,
      tertiary: royalPurple,
      onTertiary: primaryLight,
      tertiaryContainer: surfaceLight,
      onTertiaryContainer: textPrimaryLight,
      error: warningRed,
      onError: primaryLight,
      surface: primaryLight,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      outline: textSecondaryLight,
      outlineVariant: textSecondaryLight.withValues(alpha: 0.5),
      shadow: Colors.black.withValues(alpha: 0.1),
      scrim: Colors.black.withValues(alpha: 0.3),
      inverseSurface: deepNavy,
      onInverseSurface: textPrimary,
      inversePrimary: royalBlue,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: surfaceLight,
    dividerColor: textSecondaryLight.withValues(alpha: 0.3),
    textTheme: _buildTextTheme(isDark: false),
    dialogTheme: DialogThemeData(backgroundColor: surfaceLight),
  );

  /// Helper method to build text theme with Inter font family
  static TextTheme _buildTextTheme({required bool isDark}) {
    final Color primaryTextColor = isDark ? textPrimary : textPrimaryLight;
    final Color secondaryTextColor =
        isDark ? textSecondary : textSecondaryLight;
    final Color tertiaryTextColor = isDark ? textTertiary : textSecondaryLight;

    return TextTheme(
      // Display styles - Inter Bold for headings
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles - Inter SemiBold for section headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles - Inter Medium for card titles
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles - Inter Regular for content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles - Inter Medium for buttons and labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: tertiaryTextColor,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Custom text styles for AI trading data - JetBrains Mono for numerical precision
  static TextStyle tradingDataLarge = GoogleFonts.jetBrainsMono(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle tradingDataMedium = GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    letterSpacing: 0,
    height: 1.2,
  );

  static TextStyle tradingDataSmall = GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Profit/Loss color helpers
  static Color getProfitLossColor(double value) {
    return value >= 0 ? accentGreen : warningRed;
  }

  /// Royal gradient helpers for advanced UI effects
  static LinearGradient get royalPrimaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [royalBlue, royalPurple.withValues(alpha: 0.8)],
      );

  static LinearGradient get aiGlowGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          aiBlue.withValues(alpha: 0.4),
          aiGlow.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      );

  static LinearGradient get aiBlueGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [aiBlue, aiGlow.withValues(alpha: 0.8)],
      );

  static LinearGradient get luxuryGoldGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [luxuryGold, luxuryGoldLight.withValues(alpha: 0.8)],
      );

  /// Animation durations for consistent royal motion design
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration luxuryAnimation = Duration(milliseconds: 800);

  /// Royal border radius constants
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double luxuryRadius = 20.0;

  /// Royal spacing constants
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
  static const double luxurySpacing = 40.0;
}
