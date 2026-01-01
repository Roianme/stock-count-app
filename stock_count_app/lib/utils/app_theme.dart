import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized app theme configuration with consistent color schemes,
/// text styles, and component themes
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // ==================== Color Palette ====================

  // Primary colors
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Secondary/Accent colors
  static const Color accentColor = Color(0xFFFF9800); // Orange
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFB74D);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundWhite = Colors.white;
  static const Color surfaceColor = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Border and divider colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Location-specific accent colors
  static const Color hpAccentColor = Color(0xFF2196F3); // Blue
  static const Color cafeAccentColor = Color(0xFFFFC107); // Amber
  static const Color warehouseAccentColor = Color(0xFF4CAF50); // Green

  // Shadow color
  static const Color shadowColor = Color(0x0D000000); // Black with 5% opacity

  // ==================== Text Styles ====================

  // AppBar title
  static TextStyle get appBarTitle => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // Section titles
  static TextStyle get sectionTitle => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // Card titles
  static TextStyle get cardTitle => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // Body text
  static TextStyle get bodyText =>
      GoogleFonts.roboto(fontSize: 14, color: textSecondary);

  // Button text
  static TextStyle get buttonText => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textOnPrimary,
  );

  // Caption text
  static TextStyle get caption =>
      GoogleFonts.roboto(fontSize: 12, color: textHint);

  // Item name text
  static TextStyle get itemName => GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // Search hint text
  static TextStyle get searchHint =>
      GoogleFonts.roboto(fontSize: 16, color: textHint);

  // Large title (for location views)
  static TextStyle get largeTitle => GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  // Subtitle
  static TextStyle get subtitle =>
      GoogleFonts.roboto(fontSize: 14, color: textSecondary);

  // ==================== Decorations ====================

  /// Standard card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: shadowColor, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  /// Container decoration with custom color
  static BoxDecoration containerDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: shadowColor, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  /// Search bar decoration
  static BoxDecoration get searchBarDecoration => BoxDecoration(
    color: backgroundLight,
    borderRadius: BorderRadius.circular(12),
  );

  /// Status control border decoration
  static BoxDecoration get statusControlDecoration => BoxDecoration(
    border: Border.all(color: borderColor),
    borderRadius: BorderRadius.circular(8),
  );

  /// Light background decoration with accent color
  static BoxDecoration lightBackgroundDecoration(Color accentColor) =>
      BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      );

  // ==================== Input Decorations ====================

  /// Standard input decoration for text fields
  static InputDecoration get standardInputDecoration => InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  /// Search input decoration
  static InputDecoration get searchInputDecoration => InputDecoration(
    filled: true,
    fillColor: const Color(0xFFEEEEEE),
    hintStyle: searchHint,
    prefixIcon: const Icon(Icons.search, color: textHint),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  // ==================== Theme Data ====================

  /// Complete Material3 theme configuration
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundWhite,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: appBarTitle,
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: largeTitle,
      titleLarge: sectionTitle,
      titleMedium: cardTitle,
      bodyLarge: itemName,
      bodyMedium: bodyText,
      labelLarge: buttonText,
      bodySmall: caption,
    ),
    iconTheme: const IconThemeData(color: textPrimary),
    dividerColor: dividerColor,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

/// Extension on BuildContext for easy theme access
extension ThemeExtension on BuildContext {
  /// Access app theme helper
  AppThemeHelper get theme => AppThemeHelper(this);
}

/// Helper class for accessing theme-related properties via context
class AppThemeHelper {
  final BuildContext context;

  const AppThemeHelper(this.context);

  /// Get Material theme
  ThemeData get materialTheme => Theme.of(context);

  /// Get color scheme
  ColorScheme get colorScheme => materialTheme.colorScheme;

  // Quick access to commonly used colors
  Color get primary => AppTheme.primaryColor;
  Color get accent => AppTheme.accentColor;
  Color get background => AppTheme.backgroundLight;
  Color get surface => AppTheme.surfaceColor;
  Color get textPrimary => AppTheme.textPrimary;
  Color get textSecondary => AppTheme.textSecondary;
  Color get border => AppTheme.borderColor;

  // Quick access to text styles
  TextStyle get appBarTitle => AppTheme.appBarTitle;
  TextStyle get sectionTitle => AppTheme.sectionTitle;
  TextStyle get cardTitle => AppTheme.cardTitle;
  TextStyle get bodyText => AppTheme.bodyText;
  TextStyle get itemName => AppTheme.itemName;
  TextStyle get largeTitle => AppTheme.largeTitle;
  TextStyle get subtitle => AppTheme.subtitle;

  // Quick access to decorations
  BoxDecoration get cardDecoration => AppTheme.cardDecoration;
  BoxDecoration get searchBarDecoration => AppTheme.searchBarDecoration;
  BoxDecoration get statusControlDecoration => AppTheme.statusControlDecoration;
  BoxDecoration containerDecoration(Color color) =>
      AppTheme.containerDecoration(color);
  BoxDecoration lightBackgroundDecoration(Color accentColor) =>
      AppTheme.lightBackgroundDecoration(accentColor);

  // Input decorations
  InputDecoration get searchInputDecoration => AppTheme.searchInputDecoration;
  InputDecoration get standardInputDecoration =>
      AppTheme.standardInputDecoration;

  // Location-specific accent colors
  Color get hpAccent => AppTheme.hpAccentColor;
  Color get cafeAccent => AppTheme.cafeAccentColor;
  Color get warehouseAccent => AppTheme.warehouseAccentColor;

  // Status colors
  Color get success => AppTheme.successColor;
  Color get warning => AppTheme.warningColor;
  Color get error => AppTheme.errorColor;
  Color get info => AppTheme.infoColor;
}
