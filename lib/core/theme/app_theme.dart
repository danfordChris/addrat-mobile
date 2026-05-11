import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Tokens ──────────────────────────────────────────────

class AppColors {
  AppColors._();

  static const primary       = Color(0xFF3D6FFF);
  static const bgBase        = Color(0xFF0A0E1A);
  static const bgSurface     = Color(0xFF131929);
  static const bgCard        = Color(0xFF1E2B45);
  static const textPrimary   = Color(0xFFF2F4FF);
  static const textSecondary = Color(0xFF8B9BB4);
  static const success       = Color(0xFF1FCF8A);
  static const warning       = Color(0xFFFFB547);
  static const error         = Color(0xFFFF4D6A);
  static const borderDefault = Color(0xFF1E2B45);
  static const borderFocus   = Color(0xFF3D6FFF);

  static const lightBg      = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard    = Color(0xFFFFFFFF);
  static const lightBorder  = Color(0xFFE2E8F0);
  static const lightText    = Color(0xFF0F172A);
  static const lightTextSub = Color(0xFF64748B);

  static const primaryContainer  = Color(0xFFEEF2FF);
  static const primaryDark       = Color(0xFF1141A8);
  static const successContainer  = Color(0xFFD1FAE5);
  static const errorContainer    = Color(0xFFFFEBEB);
  static const warningContainer  = Color(0xFFFEF3C7);

  // Legacy aliases — kept only for AppTheme internal use
  static const primaryLight        = primary;
  static const accent              = Color(0xFFF59E0B);
  static const surface             = lightBg;
  static const surfaceVariant      = Color(0xFFF1F5F9);
  static const cardBg              = lightCard;
  static const divider             = lightBorder;
  static const textTertiary        = Color(0xFF94A3B8);
  static const darkSurface         = bgBase;
  static const darkSurfaceVariant  = bgSurface;
  static const darkCard            = bgCard;
  static const darkDivider         = borderDefault;
  static const darkTextPrimary     = textPrimary;
  static const darkTextSecondary   = textSecondary;
  static const teal                = Color(0xFF0D9488);
  static const lightBlue           = primaryContainer;
}

// ── Spacing Tokens ────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}

// ── Radius Tokens ─────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const xs   = 4.0;
  static const sm   = 8.0;
  static const md   = 12.0;
  static const lg   = 16.0;
  static const xl   = 24.0;
  static const pill = 999.0;
  static const full = pill;
}

// ── Shadow Tokens ─────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(color: Color(0x403D6FFF), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

// ── Theme ─────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge:  GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.5, height: 1.1),
      displayMedium: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.3, height: 1.1),
      displaySmall:  GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: -0.2, height: 1.15),
      headlineLarge: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.3, height: 1.15),
      headlineMedium:GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: -0.2, height: 1.2),
      headlineSmall: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface, height: 1.25),
      titleLarge:    GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface, height: 1.3),
      titleMedium:   GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface, height: 1.35),
      titleSmall:    GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface, height: 1.4),
      bodyLarge:     GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface, height: 1.5),
      bodyMedium:    GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant, height: 1.5),
      bodySmall:     GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant, letterSpacing: 0.1, height: 1.4),
      labelLarge:    GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: 0.1),
      labelMedium:   GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: 0.2),
      labelSmall:    GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: onSurfaceVariant, letterSpacing: 0.4),
    );
  }

  static ThemeData get dark => _buildDark();
  static ThemeData get light => _buildLight();

  static ThemeData _buildDark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.success,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.successContainer,
      onSecondaryContainer: const Color(0xFF064E3B),
      tertiary: AppColors.warning,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.warningContainer,
      onTertiaryContainer: const Color(0xFF78350F),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.textSecondary,
      outlineVariant: AppColors.borderDefault,
      surfaceContainerHighest: AppColors.bgCard,
      surfaceContainer: AppColors.bgSurface,
      scrim: Colors.black,
    );

    return _build(brightness: Brightness.dark, scheme: scheme, scaffoldBg: AppColors.bgBase);
  }

  static ThemeData _buildLight() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.success,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.successContainer,
      onSecondaryContainer: const Color(0xFF064E3B),
      tertiary: AppColors.warning,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.warningContainer,
      onTertiaryContainer: const Color(0xFF78350F),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: AppColors.lightBg,
      onSurface: AppColors.lightText,
      onSurfaceVariant: AppColors.lightTextSub,
      outline: AppColors.lightTextSub,
      outlineVariant: AppColors.lightBorder,
      surfaceContainerHighest: AppColors.lightCard,
      surfaceContainer: AppColors.lightCard,
      scrim: Colors.black,
    );

    return _build(brightness: Brightness.light, scheme: scheme, scaffoldBg: AppColors.lightBg);
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldBg,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: _textTheme(scheme.onSurface, scheme.onSurfaceVariant),
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: scheme.surfaceContainerHighest,

      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: scheme.onSurface),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          elevation: 0,
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(double.infinity, 56),
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
        floatingLabelStyle: TextStyle(color: scheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
        errorStyle: TextStyle(color: scheme.error, fontSize: 12),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        elevation: 0,
        height: 68,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(color: active ? scheme.primary : scheme.onSurfaceVariant, size: 22);
        }),
      ),

      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 0),

      snackBarTheme: SnackBarThemeData(
        contentTextStyle: TextStyle(color: scheme.onPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
    );
  }
}
