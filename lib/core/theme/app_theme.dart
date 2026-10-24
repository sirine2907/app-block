import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the light and dark [ThemeData] for the app.
///
/// Headings use an elegant serif (Cormorant Garamond) and body copy uses a
/// clean sans-serif (Nunito Sans). Everything is soft: rounded cards, gentle
/// shadows and the blush palette.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.dustyRose,
      primary: AppColors.rose,
      secondary: AppColors.burgundy,
      surface: AppColors.cream,
      brightness: Brightness.light,
    );
    return _build(base, scheme, AppColors.inkLight, AppColors.blush);
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkRose,
      primary: AppColors.darkRose,
      secondary: AppColors.goldAccent,
      surface: AppColors.plumSurface,
      brightness: Brightness.dark,
    );
    return _build(base, scheme, AppColors.softCream, AppColors.plum);
  }

  static ThemeData _build(
    ThemeData base,
    ColorScheme scheme,
    Color bodyColor,
    Color scaffold,
  ) {
    final textTheme = _textTheme(base.textTheme, bodyColor);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: bodyColor,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: bodyColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 6,
        shadowColor: AppColors.rose.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: scheme.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.nunitoSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.6)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.burgundy,
        contentTextStyle: GoogleFonts.nunitoSans(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color color) {
    final serif = GoogleFonts.cormorantGaramondTextTheme(base);
    final sans = GoogleFonts.nunitoSansTextTheme(base);
    return base.copyWith(
      displayLarge: serif.displayLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: serif.displayMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: serif.headlineLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: serif.headlineMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: serif.headlineSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: serif.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: sans.bodyLarge?.copyWith(color: color),
      bodyMedium: sans.bodyMedium?.copyWith(color: color),
      bodySmall: sans.bodySmall?.copyWith(color: color.withValues(alpha: 0.7)),
      labelLarge: sans.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
