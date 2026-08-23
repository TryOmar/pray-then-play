import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Balanced 11-Theme Matrix for Pray Then Play
/// 5 Dark Themes, 5 Light Themes, 1 Mixed/Utility Theme
enum AppGamingTheme {
  // --- 6 DARK & TACTICAL THEMES ---
  forest(
    displayName: 'Forest',
    tagline: 'Signature Emerald Green',
    description: 'Deep moss obsidian with luminous emerald accents',
    primaryAccent: Color(0xFF10B981),
    secondaryAccent: Color(0xFF34D399),
    background: Color(0xFF08140E),
    backgroundSecondary: Color(0xFF040A07),
    surface: Color(0xFF0F2117),
    surfaceElevated: Color(0xFF183324),
    surfaceHighlight: Color(0xFF234934),
    borderColor: Color(0xFF1B3B2A),
    textPrimary: Color(0xFFECFDF5),
    textSecondary: Color(0xFFA7F3D0),
    textMuted: Color(0xFF6EE7B7),
    buttonTextColor: Color(0xFF08140E),
    isLight: false,
  ),
  midnight(
    displayName: 'Midnight',
    tagline: 'Deep Calm Evening',
    description: 'Deep navy obsidian with soothing blue accents',
    primaryAccent: Color(0xFF38BDF8),
    secondaryAccent: Color(0xFF818CF8),
    background: Color(0xFF0B1020),
    backgroundSecondary: Color(0xFF070B16),
    surface: Color(0xFF111827),
    surfaceElevated: Color(0xFF1F2937),
    surfaceHighlight: Color(0xFF374151),
    borderColor: Color(0xFF1E293B),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Color(0xFF0B1020),
    isLight: false,
  ),
  crimson(
    displayName: 'Crimson',
    tagline: 'Signature Gaming Dark',
    description: 'Deep ruby obsidian with vibrant crimson passion',
    primaryAccent: Color(0xFFFF2E51),
    secondaryAccent: Color(0xFFFF6B8B),
    background: Color(0xFF0D0B0E),
    backgroundSecondary: Color(0xFF080609),
    surface: Color(0xFF171219),
    surfaceElevated: Color(0xFF261824),
    surfaceHighlight: Color(0xFF3B2238),
    borderColor: Color(0xFF2D192B),
    textPrimary: Color(0xFFFFF1F2),
    textSecondary: Color(0xFFFDA4AF),
    textMuted: Color(0xFFF43F5E),
    buttonTextColor: Colors.white,
    isLight: false,
  ),
  ember(
    displayName: 'Ember',
    tagline: 'Warm Charcoal Evening',
    description: 'Dark roasted charcoal with warm solar amber glow',
    primaryAccent: Color(0xFFF59E0B),
    secondaryAccent: Color(0xFFEA580C),
    background: Color(0xFF14100E),
    backgroundSecondary: Color(0xFF0C0908),
    surface: Color(0xFF1E1815),
    surfaceElevated: Color(0xFF2E221D),
    surfaceHighlight: Color(0xFF453229),
    borderColor: Color(0xFF362720),
    textPrimary: Color(0xFFFFFBEB),
    textSecondary: Color(0xFFFDE68A),
    textMuted: Color(0xFFFBBF24),
    buttonTextColor: Color(0xFF14100E),
    isLight: false,
  ),
  tactical(
    displayName: 'Tactical',
    tagline: 'Military Spec-Ops Utility',
    description: 'Matte slate charcoal with high-visibility hazard lime',
    primaryAccent: Color(0xFF84CC16),
    secondaryAccent: Color(0xFFEAB308),
    background: Color(0xFF121517),
    backgroundSecondary: Color(0xFF0B0D0E),
    surface: Color(0xFF1A1E22),
    surfaceElevated: Color(0xFF252B31),
    surfaceHighlight: Color(0xFF353D45),
    borderColor: Color(0xFF2A323A),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Color(0xFF121517),
    isLight: false,
  ),
  oled(
    displayName: 'OLED Minimal',
    tagline: 'Pure True Black',
    description: 'True black battery saver with high contrast razor lines',
    primaryAccent: Color(0xFFFFFFFF),
    secondaryAccent: Color(0xFFA1A1AA),
    background: Color(0xFF000000),
    backgroundSecondary: Color(0xFF050505),
    surface: Color(0xFF0A0A0A),
    surfaceElevated: Color(0xFF141414),
    surfaceHighlight: Color(0xFF222222),
    borderColor: Color(0xFF1F1F1F),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF71717A),
    buttonTextColor: Color(0xFF000000),
    isLight: false,
  ),

  // --- 5 LIGHT THEMES ---
  dawn(
    displayName: 'Dawn',
    tagline: 'Signature Sunrise Light',
    description: 'Warm morning cream with sunrise coral and rose glow',
    primaryAccent: Color(0xFFF97316),
    secondaryAccent: Color(0xFFE11D48),
    background: Color(0xFFFDF6F0),
    backgroundSecondary: Color(0xFFF7EBE1),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFCEEE3),
    surfaceHighlight: Color(0xFFF7DDD0),
    borderColor: Color(0xFFF3D5C5),
    textPrimary: Color(0xFF2A1B18),
    textSecondary: Color(0xFF6C4E47),
    textMuted: Color(0xFF9C776F),
    buttonTextColor: Colors.white,
    isLight: true,
  ),
  arctic(
    displayName: 'Arctic',
    tagline: 'Cool Clean Modern',
    description: 'Crisp glacial white with focused royal blue accents',
    primaryAccent: Color(0xFF2563EB),
    secondaryAccent: Color(0xFF0284C7),
    background: Color(0xFFF4F8FC),
    backgroundSecondary: Color(0xFFEBF1F8),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE7EFF7),
    surfaceHighlight: Color(0xFFD5E4F2),
    borderColor: Color(0xFFD8E6F3),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Colors.white,
    isLight: true,
  ),
  sand(
    displayName: 'Sand',
    tagline: 'Warm Calm Ivory',
    description: 'Warm dune ivory with refined desert gold accents',
    primaryAccent: Color(0xFFB45309),
    secondaryAccent: Color(0xFFD97706),
    background: Color(0xFFF7F1E5),
    backgroundSecondary: Color(0xFFEDE5D4),
    surface: Color(0xFFFFFDF8),
    surfaceElevated: Color(0xFFEFE6D4),
    surfaceHighlight: Color(0xFFE4D7C0),
    borderColor: Color(0xFFE5DAC4),
    textPrimary: Color(0xFF292318),
    textSecondary: Color(0xFF635745),
    textMuted: Color(0xFF8C7D69),
    buttonTextColor: Colors.white,
    isLight: true,
  ),
  sky(
    displayName: 'Sky',
    tagline: 'Fresh Daylight Focus',
    description: 'Bright daylight sky with vibrant cyan & deep navy typography',
    primaryAccent: Color(0xFF0284C7),
    secondaryAccent: Color(0xFF06B6D4),
    background: Color(0xFFEBF3FA),
    backgroundSecondary: Color(0xFFDFEDF7),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFDCE8F5),
    surfaceHighlight: Color(0xFFC8DCF0),
    borderColor: Color(0xFFCEE0F3),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF334155),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Colors.white,
    isLight: true,
  ),
  lavender(
    displayName: 'Lavender',
    tagline: 'Modern Soft Violet',
    description: 'Soft lavender mist with elegant deep purple accents',
    primaryAccent: Color(0xFF7C3AED),
    secondaryAccent: Color(0xFF9333EA),
    background: Color(0xFFF5F3FF),
    backgroundSecondary: Color(0xFFECE7FF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEDE9FE),
    surfaceHighlight: Color(0xFFDDD6FE),
    borderColor: Color(0xFFE0D7FE),
    textPrimary: Color(0xFF1E1B4B),
    textSecondary: Color(0xFF4C1D95),
    textMuted: Color(0xFF6B7280),
    buttonTextColor: Colors.white,
    isLight: true,
  );

  const AppGamingTheme({
    required this.displayName,
    required this.tagline,
    required this.description,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.background,
    required this.backgroundSecondary,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHighlight,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.buttonTextColor,
    required this.isLight,
  });

  final String displayName;
  final String tagline;
  final String description;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color background;
  final Color backgroundSecondary;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHighlight;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color buttonTextColor;
  final bool isLight;

  /// Balanced alternating Dark & Light sequence for preview lists
  static const List<AppGamingTheme> orderedThemes = [
    AppGamingTheme.forest,    // Dark (Emerald Green)
    AppGamingTheme.dawn,      // Light (Sunrise Coral)
    AppGamingTheme.midnight,  // Dark (Deep Navy Obsidian)
    AppGamingTheme.arctic,    // Light (Glacial Royal Blue)
    AppGamingTheme.crimson,   // Dark (Gaming Ruby Red)
    AppGamingTheme.sand,      // Light (Desert Gold Ivory)
    AppGamingTheme.ember,     // Dark (Warm Charcoal Amber)
    AppGamingTheme.sky,       // Light (Daylight Sky Cyan)
    AppGamingTheme.tactical,  // Dark / Spec-Ops (Hazard Lime)
    AppGamingTheme.lavender,  // Light (Soft Violet Mist)
    AppGamingTheme.oled,      // Dark / Spec-Ops (Pure True Black)
  ];

  ThemeTokens get tokens => ThemeTokens(this);
}

/// Rich Design Token Engine isolating semantic meaning from theme accents
class ThemeTokens {
  final AppGamingTheme theme;

  const ThemeTokens(this.theme);

  // Backgrounds & Surfaces
  Color get background => theme.background;
  Color get backgroundSecondary => theme.backgroundSecondary;
  Color get surface => theme.surface;
  Color get surfaceElevated => theme.surfaceElevated;
  Color get surfaceHighlight => theme.surfaceHighlight;
  Color get borderColor => theme.borderColor;

  // Accents
  Color get primaryAccent => theme.primaryAccent;
  Color get secondaryAccent => theme.secondaryAccent;

  // Typography
  Color get textPrimary => theme.textPrimary;
  Color get textSecondary => theme.textSecondary;
  Color get textMuted => theme.textMuted;
  Color get buttonTextColor => theme.buttonTextColor;
  bool get isLight => theme.isLight;

  // SEMANTIC COLORS (Independent of theme accent so meaning remains 100% consistent)
  Color get semanticSuccess =>
      theme.isLight ? const Color(0xFF059669) : const Color(0xFF10B981);
  Color get semanticSuccessDim =>
      theme.isLight ? const Color(0xFFD1FAE5) : const Color(0xFF064E3B);

  Color get semanticWarning =>
      theme.isLight ? const Color(0xFFD97706) : const Color(0xFFF59E0B);
  Color get semanticWarningDim =>
      theme.isLight ? const Color(0xFFFEF3C7) : const Color(0xFF78350F);

  Color get semanticDanger =>
      theme.isLight ? const Color(0xFFDC2626) : const Color(0xFFEF4444);
  Color get semanticDangerDim =>
      theme.isLight ? const Color(0xFFFEE2E2) : const Color(0xFF7F1D1D);

  Color get semanticPrayer =>
      theme.isLight ? const Color(0xFF0284C7) : const Color(0xFF06B6D4);
  Color get semanticPrayerDim =>
      theme.isLight ? const Color(0xFFE0F2FE) : const Color(0xFF083344);
}

/// Global backward-compatible status colors
class AppColors {
  // Static status colors across all themes
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenDim = Color(0xFF059669);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningAmberDim = Color(0xFFD97706);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerRedDim = Color(0xFFDC2626);

  // Default fallbacks
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color primaryCyan = Color(0xFF38BDF8);
  static const Color background = Color(0xFF0B1020);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF1F2937);
  static const Color surfaceHighlight = Color(0xFF374151);
}

class PrayThenPlayTheme {
  static ThemeData buildTheme(AppGamingTheme gamingTheme) => getTheme(gamingTheme);

  static ThemeData getTheme(AppGamingTheme gamingTheme) {
    final isLight = gamingTheme.isLight;
    final isOled = gamingTheme == AppGamingTheme.oled;

    return ThemeData(
      useMaterial3: true,
      splashFactory: InkRipple.splashFactory,
      brightness: isLight ? Brightness.light : Brightness.dark,
      primaryColor: gamingTheme.primaryAccent,
      scaffoldBackgroundColor: gamingTheme.background,
      canvasColor: gamingTheme.background,
      dividerColor: gamingTheme.borderColor,
      colorScheme: ColorScheme(
        brightness: isLight ? Brightness.light : Brightness.dark,
        primary: gamingTheme.primaryAccent,
        onPrimary: gamingTheme.buttonTextColor,
        secondary: gamingTheme.secondaryAccent,
        onSecondary: Colors.white,
        surface: gamingTheme.surface,
        onSurface: gamingTheme.textPrimary,
        error: AppColors.dangerRed,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
      ).apply(
        bodyColor: gamingTheme.textPrimary,
        displayColor: gamingTheme.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: gamingTheme.background,
        foregroundColor: gamingTheme.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
          statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: gamingTheme.background,
          systemNavigationBarIconBrightness:
              isLight ? Brightness.dark : Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: gamingTheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isOled ? const Color(0xFF222222) : gamingTheme.borderColor,
            width: 1,
          ),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: gamingTheme.textPrimary,
        ),
        contentTextStyle: GoogleFonts.outfit(
          fontSize: 13.5,
          color: gamingTheme.textSecondary,
          height: 1.4,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: gamingTheme.surface,
        surfaceTintColor: Colors.transparent,
        constraints: const BoxConstraints(maxWidth: 640),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: gamingTheme.surfaceElevated,
        labelStyle: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: gamingTheme.textPrimary,
        ),
        side: BorderSide(
          color: isOled ? const Color(0xFF222222) : gamingTheme.borderColor,
          width: 0.8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      cardTheme: CardThemeData(
        color: gamingTheme.surface,
        elevation: isLight ? 1 : 0,
        shadowColor:
            isLight ? Colors.black.withValues(alpha: 0.05) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isOled ? const Color(0xFF222222) : gamingTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: gamingTheme.borderColor,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gamingTheme.primaryAccent,
          foregroundColor: gamingTheme.buttonTextColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gamingTheme.primaryAccent,
          side: BorderSide(
            color: gamingTheme.primaryAccent.withValues(alpha: 0.6),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gamingTheme.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gamingTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gamingTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: gamingTheme.primaryAccent, width: 1.5),
        ),
        hintStyle: TextStyle(color: gamingTheme.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: gamingTheme.textSecondary, fontSize: 14),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gamingTheme.primaryAccent;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(gamingTheme.buttonTextColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: gamingTheme.borderColor, width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gamingTheme.buttonTextColor;
          }
          return gamingTheme.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gamingTheme.primaryAccent;
          }
          return gamingTheme.surfaceHighlight.withValues(alpha: 0.6);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return gamingTheme.borderColor.withValues(alpha: 0.5);
        }),
        trackOutlineWidth: WidgetStateProperty.all(1.0),
        overlayColor: WidgetStateProperty.all(
            gamingTheme.primaryAccent.withValues(alpha: 0.12)),
      ),
    );
  }
}

// Backwards compatibility class alias
typedef GamerSalahTheme = PrayThenPlayTheme;

/// Atmosphere-aware Glassmorphic & Surface Decorations
class GlassmorphicDecoration {
  static BoxDecoration card({
    BuildContext? context,
    double radius = 16,
    Color? customBorder,
    Color? customColor,
    bool glow = false,
  }) {
    if (context != null) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      if (isDark) {
        return BoxDecoration(
          color: customColor ??
              theme.colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: customBorder ??
                (theme.dividerTheme.color ?? const Color(0xFF1E293B)),
            width: 1,
          ),
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.18),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        );
      }

      // Light theme surface: soft subtle shadow, clean white card
      return BoxDecoration(
        color: customColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: customBorder ??
              (theme.dividerTheme.color ?? const Color(0xFFE2E8F0)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (glow)
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.12),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      );
    }

    // Default fallback if context is omitted
    return BoxDecoration(
      color: customColor ?? const Color(0xFF111827),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: customBorder ?? const Color(0xFF1E293B),
        width: 1,
      ),
      boxShadow: glow
          ? [
              const BoxShadow(
                color: Color(0x3338BDF8),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ]
          : null,
    );
  }

  static BoxDecoration statusCard({
    required Color statusColor,
    double borderRadius = 16,
    BuildContext? context,
  }) {
    final isDark =
        context == null || Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: statusColor.withValues(alpha: isDark ? 0.1 : 0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: statusColor.withValues(alpha: isDark ? 0.35 : 0.28),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: statusColor.withValues(alpha: isDark ? 0.12 : 0.06),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static BoxDecoration neonCard({
    BuildContext? context,
    required Color glowColor,
    double borderRadius = 16,
    Color? backgroundColor,
    Color? borderColor,
    double glowIntensity = 0.18,
    double borderWidth = 1.0,
  }) {
    final isDark =
        context == null || Theme.of(context).brightness == Brightness.dark;
    final defaultBg = context != null
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFF111827);
    final defaultBorder = context != null
        ? (borderColor ??
            glowColor.withValues(alpha: isDark ? 0.35 : 0.28))
        : (borderColor ?? glowColor.withValues(alpha: 0.35));

    return BoxDecoration(
      color: backgroundColor ?? defaultBg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: defaultBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor
              .withValues(alpha: isDark ? glowIntensity : glowIntensity * 0.6),
          blurRadius: 18,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static Widget frosted({
    required Widget child,
    double blur = 10,
    double radius = 16,
    Color? color,
    Border? border,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}
