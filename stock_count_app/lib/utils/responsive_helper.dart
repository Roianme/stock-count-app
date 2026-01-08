import 'package:flutter/material.dart';

/// Centralized responsive design helper for orientation and screen sizing
class ResponsiveHelper {
  final BuildContext context;

  const ResponsiveHelper(this.context);

  /// Get the current screen orientation
  Orientation get orientation => MediaQuery.of(context).orientation;

  /// Check if device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;

  /// Check if device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;

  /// Get device screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Get device screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Check if screen is wide (tablet/desktop)
  bool get isWideScreen => screenWidth >= 900;

  /// Check if screen is extra wide (large tablet)
  bool get isExtraWideScreen => screenWidth >= 1200;

  /// Get responsive font size based on context
  double fontSize(double portraitSize, [double? landscapeSize]) {
    if (isLandscape && landscapeSize != null) {
      // Scale font based on screen width in landscape
      if (screenWidth >= 1200) return landscapeSize * 1.2;
      if (screenWidth >= 900) return landscapeSize * 1.1;
      return landscapeSize;
    }
    // Scale font based on screen width in portrait - with smaller sizes for small screens
    if (screenWidth < 400) return portraitSize * 0.85; // Very small phones
    if (screenWidth < 600) return portraitSize * 0.9; // Small phones
    if (screenWidth >= 1200) return portraitSize * 1.2; // Large tablets
    if (screenWidth >= 900) return portraitSize * 1.1; // Medium tablets
    return portraitSize;
  }

  /// Get responsive padding based on orientation
  EdgeInsets padding({double portraitValue = 16, double landscapeValue = 12}) {
    final value = isLandscape ? landscapeValue : portraitValue;
    return EdgeInsets.all(value);
  }

  /// Get responsive horizontal padding
  double horizontalPadding({
    double portraitValue = 16,
    double landscapeValue = 12,
  }) {
    return isLandscape ? landscapeValue : portraitValue;
  }

  /// Get responsive vertical padding
  double verticalPadding({
    double portraitValue = 16,
    double landscapeValue = 12,
  }) {
    return isLandscape ? landscapeValue : portraitValue;
  }

  /// Get responsive spacing value
  double spacing({double portraitValue = 16, double landscapeValue = 12}) {
    return isLandscape ? landscapeValue : portraitValue;
  }

  /// Get grid columns based on screen width
  int gridColumns() {
    if (isLandscape) {
      if (screenWidth >= 1400) return 5;
      if (screenWidth >= 1100) return 4;
      if (screenWidth >= 900) return 3;
      return 2;
    } else {
      if (screenWidth >= 1200) return 4;
      if (screenWidth >= 900) return 3;
      return 2;
    }
  }

  /// Get status control width for dropdowns
  double statusControlWidth() {
    return isWideScreen ? 170.0 : 130.0;
  }

  /// Get max content width for centered layouts
  double maxContentWidth({
    double portraitMax = 900,
    double landscapeMax = 1200,
  }) {
    final max = isLandscape ? landscapeMax : portraitMax;
    return screenWidth > max ? max : screenWidth;
  }

  /// Get responsive icon size
  double iconSize(double portraitSize, [double? landscapeSize]) {
    if (isLandscape && landscapeSize != null) {
      return landscapeSize;
    }
    // Scale icons based on screen width
    if (screenWidth >= 1200) return portraitSize * 0.85;
    if (screenWidth >= 900) return portraitSize * 0.9;
    return portraitSize;
  }

  /// Get app bar title based on space availability
  String compactTitle(String fullTitle, String compactTitle) {
    return isLandscape || screenWidth < 500 ? compactTitle : fullTitle;
  }

  /// Get responsive width constraint for list items
  double itemCardWidth() {
    final padding = horizontalPadding();
    return screenWidth - (padding * 2);
  }

  /// Calculate aspect ratio based on screen dimensions
  double calculateAspectRatio({
    required int columns,
    double targetHeight = 210.0,
  }) {
    final horizontalPadding = 32 + (columns - 1) * 16;
    final availableWidth = (screenWidth - horizontalPadding) / columns;
    return availableWidth / targetHeight;
  }
}

/// Extension on BuildContext for easy responsive access
extension ResponsiveContextExtension on BuildContext {
  /// Get responsive helper instance
  ResponsiveHelper get responsive => ResponsiveHelper(this);

  /// Quick access to orientation
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Quick check if landscape
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Quick check if portrait
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  /// Quick access to screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Quick access to screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Quick check if wide screen
  bool get isWideScreen => screenWidth >= 900;

  /// Quick check if extra wide screen
  bool get isExtraWideScreen => screenWidth >= 1200;

  /// Get responsive grid columns
  int get gridColumns => responsive.gridColumns();

  /// Get status control width
  double get statusControlWidth => responsive.statusControlWidth();

  /// Get max content width
  double maxContentWidth({
    double portraitMax = 900,
    double landscapeMax = 1200,
  }) => responsive.maxContentWidth(
    portraitMax: portraitMax,
    landscapeMax: landscapeMax,
  );
}
