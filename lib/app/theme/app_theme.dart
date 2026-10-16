import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color background;
  final Color surface;
  final Color primary;
  final Color primaryDark;
  final Color sage;
  final Color lightSage;
  final Color beige;
  final Color chipBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color destructive;
  final Color destructiveBackground;

  const AppTokens({
    required this.background,
    required this.surface,
    required this.primary,
    required this.primaryDark,
    required this.sage,
    required this.lightSage,
    required this.beige,
    required this.chipBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.destructive,
    required this.destructiveBackground,
  });

  static AppTokens of(BuildContext context) =>
      Theme.of(context).extension<AppTokens>()!;

  @override
  ThemeExtension<AppTokens> copyWith({
    Color? background,
    Color? surface,
    Color? primary,
    Color? primaryDark,
    Color? sage,
    Color? lightSage,
    Color? beige,
    Color? chipBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? destructive,
    Color? destructiveBackground,
  }) {
    return AppTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      sage: sage ?? this.sage,
      lightSage: lightSage ?? this.lightSage,
      beige: beige ?? this.beige,
      chipBackground: chipBackground ?? this.chipBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      destructive: destructive ?? this.destructive,
      destructiveBackground:
          destructiveBackground ?? this.destructiveBackground,
    );
  }

  @override
  ThemeExtension<AppTokens> lerp(
    covariant ThemeExtension<AppTokens>? other,
    double t,
  ) {
    if (other is! AppTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      primary: c(primary, other.primary),
      primaryDark: c(primaryDark, other.primaryDark),
      sage: c(sage, other.sage),
      lightSage: c(lightSage, other.lightSage),
      beige: c(beige, other.beige),
      chipBackground: c(chipBackground, other.chipBackground),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      divider: c(divider, other.divider),
      destructive: c(destructive, other.destructive),
      destructiveBackground:
          c(destructiveBackground, other.destructiveBackground),
    );
  }
}

class AppTheme {
  static const lightTokens = AppTokens(
    background: Color(0xFFF7F5EF),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF4F805D),
    primaryDark: Color(0xFF28583C),
    sage: Color(0xFFA8BE9B),
    lightSage: Color(0xFFE8EFE3),
    beige: Color(0xFFF1EBDD),
    chipBackground: Color(0xFFF1EBDD),
    textPrimary: Color(0xFF17221D),
    textSecondary: Color(0xFF73786F),
    divider: Color(0xFFEAE9E3),
    destructive: Color(0xFFE54848),
    destructiveBackground: Color(0xFFFDE8E6),
  );

  static const darkTokens = AppTokens(
    background: Color(0xFF121813),
    surface: Color(0xFF1C241E),
    primary: Color(0xFF5F9A70),
    primaryDark: Color(0xFF8FC7A2),
    sage: Color(0xFF3A4A3D),
    lightSage: Color(0xFF243528),
    beige: Color(0xFF26302A),
    chipBackground: Color(0xFF26302A),
    textPrimary: Color(0xFFF0F2EC),
    textSecondary: Color(0xFF9BA69C),
    divider: Color(0xFF2C382E),
    destructive: Color(0xFFF06565),
    destructiveBackground: Color(0xFF3B2624),
  );

  static ThemeData get light => _build(lightTokens, Brightness.light);
  static ThemeData get dark => _build(darkTokens, Brightness.dark);

  static ThemeData _build(AppTokens t, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: t.primary,
      brightness: brightness,
      primary: t.primary,
      surface: t.surface,
      onSurface: t.textPrimary,
      error: t.destructive,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.background,
      extensions: [t],
    );
    final buttonBg = brightness == Brightness.dark ? t.primary : t.primaryDark;
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: t.textPrimary,
        displayColor: t.textPrimary,
        // Bundled so Malayalam names render even where the OS lacks the glyph.
        fontFamilyFallback: const ['NotoSansMalayalam'],
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        foregroundColor: t.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: t.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: t.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: t.textSecondary),
      ),
      dividerTheme: DividerThemeData(color: t.divider, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        hintStyle: TextStyle(color: t.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.primary, width: 1.5),
        ),
      ),
    );
  }
}
