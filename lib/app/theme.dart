import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppGamingTheme {
  // --- DARK GAMING THEMES ---
  cyber(
    displayName: 'Cyberpunk',
    tagline: 'High-Tech Neon Cyber',
    description: 'Electric cyan with deep night abyss',
    primaryAccent: Color(0xFF00F0FF),
    secondaryAccent: Color(0xFF7000FF),
    background: Color(0xFF050811),
    surface: Color(0xFF0B1021),
    surfaceElevated: Color(0xFF131A36),
    surfaceHighlight: Color(0xFF1D2852),
    borderColor: Color(0xFF162245),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Color(0xFF050811),
    isLight: false,
  ),
  tactical(
    displayName: 'Tactical Spec-Ops',
    tagline: 'Stealth Matte Gunmetal',
    description: 'Hazard amber with military dark charcoal',
    primaryAccent: Color(0xFFFF9900),
    secondaryAccent: Color(0xFFE55A00),
    background: Color(0xFF111215),
    surface: Color(0xFF181A1F),
    surfaceElevated: Color(0xFF22252C),
    surfaceHighlight: Color(0xFF2E323C),
    borderColor: Color(0xFF282C36),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Color(0xFF111215),
    isLight: false,
  ),
  crimson(
    displayName: 'Bloodmoon Crimson',
    tagline: 'Dark Ruby Phantom',
    description: 'Vivid crimson with deep wine obsidian',
    primaryAccent: Color(0xFFFF2A4D),
    secondaryAccent: Color(0xFFFF6B8B),
    background: Color(0xFF0D0608),
    surface: Color(0xFF180C10),
    surfaceElevated: Color(0xFF26131A),
    surfaceHighlight: Color(0xFF381B26),
    borderColor: Color(0xFF301620),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Colors.white,
    isLight: false,
  ),
  emerald(
    displayName: 'Matrix Emerald',
    tagline: 'Cyber Jade & Toxic Green',
    description: 'Hyper emerald with deep forest black',
    primaryAccent: Color(0xFF00FF66),
    secondaryAccent: Color(0xFF00E5FF),
    background: Color(0xFF030D06),
    surface: Color(0xFF07170C),
    surfaceElevated: Color(0xFF0E2616),
    surfaceHighlight: Color(0xFF173D23),
    borderColor: Color(0xFF12301C),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Color(0xFF030D06),
    isLight: false,
  ),
  midnight(
    displayName: 'Nebula Void',
    tagline: 'Royal Amethyst Abyss',
    description: 'Electric violet with deep cosmic indigo',
    primaryAccent: Color(0xFFA855F7),
    secondaryAccent: Color(0xFF6366F1),
    background: Color(0xFF070512),
    surface: Color(0xFF0F0B24),
    surfaceElevated: Color(0xFF19133B),
    surfaceHighlight: Color(0xFF281E5E),
    borderColor: Color(0xFF221A4F),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Colors.white,
    isLight: false,
  ),
  sandstorm(
    displayName: 'Desert Gold',
    tagline: 'Solar Amber & Bronze Dune',
    description: 'Warm solar gold with dark bronze obsidian',
    primaryAccent: Color(0xFFF59E0B),
    secondaryAccent: Color(0xFFEA580C),
    background: Color(0xFF0E0B07),
    surface: Color(0xFF18130C),
    surfaceElevated: Color(0xFF261E13),
    surfaceHighlight: Color(0xFF3B2F1E),
    borderColor: Color(0xFF302618),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Color(0xFF0E0B07),
    isLight: false,
  ),
  arctic(
    displayName: 'Arctic Frost',
    tagline: 'Glacier Blue & Titanium Slate',
    description: 'Crisp ice blue with cold slate navy',
    primaryAccent: Color(0xFF38BDF8),
    secondaryAccent: Color(0xFF818CF8),
    background: Color(0xFF0A111F),
    surface: Color(0xFF111D33),
    surfaceElevated: Color(0xFF1C2D4D),
    surfaceHighlight: Color(0xFF2B416B),
    borderColor: Color(0xFF223557),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Color(0xFF0A111F),
    isLight: false,
  ),
  oled(
    displayName: 'OLED Minimal',
    tagline: 'Pure Absolute Pitch Black',
    description: 'Monochrome titanium with true black contrast',
    primaryAccent: Color(0xFFFFFFFF),
    secondaryAccent: Color(0xFF94A3B8),
    background: Color(0xFF000000),
    surface: Color(0xFF111113),
    surfaceElevated: Color(0xFF1A1A1E),
    surfaceHighlight: Color(0xFF29292F),
    borderColor: Color(0xFF222228),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Color(0xFF000000),
    isLight: false,
  ),

  // --- LIGHT GAMING THEMES ---
  esportsLight(
    displayName: 'Esports White',
    tagline: 'Titan Platinum & Cyan',
    description: 'Crisp porcelain slate with electric cyan accents',
    primaryAccent: Color(0xFF0284C7),
    secondaryAccent: Color(0xFF0EA5E9),
    background: Color(0xFFF1F5F9),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE2E8F0),
    surfaceHighlight: Color(0xFFCBD5E1),
    borderColor: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    buttonTextColor: Colors.white,
    isLight: true,
  ),
  solarDaybreak(
    displayName: 'Solar Daybreak',
    tagline: 'Desert Sand & Warm Amber',
    description: 'Warm parchment sand with radiant amber gold',
    primaryAccent: Color(0xFFD97706),
    secondaryAccent: Color(0xFFB45309),
    background: Color(0xFFFBF8F3),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF3EDE2),
    surfaceHighlight: Color(0xFFE6DCCE),
    borderColor: Color(0xFFE5DACB),
    textPrimary: Color(0xFF1C1917),
    textSecondary: Color(0xFF57534E),
    textMuted: Color(0xFF78716C),
    buttonTextColor: Colors.white,
    isLight: true,
  ),
  glacierLight(
    displayName: 'Glacier Light',
    tagline: 'Arctic Frost & Ice Blue',
    description: 'Cold frost white with vivid sky blue accents',
    primaryAccent: Color(0xFF0284C7),
    secondaryAccent: Color(0xFF38BDF8),
    background: Color(0xFFF0F9FF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE0F2FE),
    surfaceHighlight: Color(0xFFBAE6FD),
    borderColor: Color(0xFFBAE6FD),
    textPrimary: Color(0xFF0C4A6E),
    textSecondary: Color(0xFF0369A1),
    textMuted: Color(0xFF64748B),
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
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHighlight;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color buttonTextColor;
  final bool isLight;
}

class AppColors {
  // Static status colors across all themes
  static const Color successGreen = Color(0xFF00C853);
  static const Color successGreenDim = Color(0xFF00A858);
  static const Color warningAmber = Color(0xFFFFB800);
  static const Color warningAmberDim = Color(0xFFA87800);
  static const Color dangerRed = Color(0xFFFF3D5A);
  static const Color dangerRedDim = Color(0xFFA82838);

  // Default fallbacks
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color primaryCyan = Color(0xFF00F0FF);
  static const Color background = Color(0xFF050811);
  static const Color surface = Color(0xFF0B1021);
  static const Color surfaceElevated = Color(0xFF131A36);
  static const Color surfaceHighlight = Color(0xFF1D2852);
}

class GamerSalahTheme {
  static ThemeData getTheme(AppGamingTheme gamingTheme) {
    final primary = gamingTheme.primaryAccent;
    final bg = gamingTheme.background;
    final surf = gamingTheme.surface;
    final surfElevated = gamingTheme.surfaceElevated;
    final highlight = gamingTheme.surfaceHighlight;
    final border = gamingTheme.borderColor;
    final textPrim = gamingTheme.textPrimary;
    final textSec = gamingTheme.textSecondary;
    final textMut = gamingTheme.textMuted;
    final isLight = gamingTheme.isLight;

    return ThemeData(
      useMaterial3: true,
      brightness: isLight ? Brightness.light : Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: isLight ? Brightness.light : Brightness.dark,
        primary: primary,
        secondary: gamingTheme.secondaryAccent,
        surface: surf,
        error: AppColors.dangerRed,
        onPrimary: gamingTheme.buttonTextColor,
        onSecondary: gamingTheme.buttonTextColor,
        onSurface: textPrim,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: textPrim, letterSpacing: -1.5),
          displayMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: textPrim, letterSpacing: -1.0),
          displaySmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: textPrim, letterSpacing: -0.5),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrim),
          headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrim),
          headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrim),
          titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrim),
          titleMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrim),
          titleSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSec),
          bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textPrim),
          bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: textSec),
          bodySmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: textMut),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrim, letterSpacing: 0.5),
          labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSec),
          labelSmall: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: textMut, letterSpacing: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrim,
        ),
        iconTheme: IconThemeData(color: textPrim),
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: gamingTheme.buttonTextColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surf,
        selectedItemColor: primary,
        unselectedItemColor: textMut,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: textMut),
      ),
      dividerTheme: DividerThemeData(
        color: highlight,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return textMut;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.3);
          }
          return highlight;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: highlight,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.2),
      ),
    );
  }
}

class GlassmorphicDecoration {
  static BoxDecoration card({
    BuildContext? context,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1.0,
    double borderRadius = 16.0,
    List<BoxShadow>? glowShadows,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final bg = backgroundColor ?? (theme != null ? theme.colorScheme.surface : AppColors.surface);
    final border = borderColor ?? (theme != null ? theme.dividerTheme.color ?? AppColors.surfaceHighlight : AppColors.surfaceHighlight);

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: border.withValues(alpha: 0.6),
        width: borderWidth,
      ),
      boxShadow: glowShadows,
    );
  }

  static BoxDecoration neonCard({
    BuildContext? context,
    required Color glowColor,
    Color? backgroundColor,
    double borderRadius = 16.0,
    double glowIntensity = 0.25,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final bg = backgroundColor ?? (theme != null ? theme.colorScheme.surface : AppColors.surface);

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glowColor.withValues(alpha: 0.45),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: glowIntensity),
          blurRadius: 18,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: glowColor.withValues(alpha: glowIntensity * 0.4),
          blurRadius: 36,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration statusCard({
    BuildContext? context,
    required Color statusColor,
    Color? surfaceColor,
    double borderRadius = 16.0,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final bg = surfaceColor ?? (theme != null ? theme.colorScheme.surface : AppColors.surface);

    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          statusColor.withValues(alpha: 0.12),
          bg,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: statusColor.withValues(alpha: 0.35),
        width: 1,
      ),
    );
  }
}
