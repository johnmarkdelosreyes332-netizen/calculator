import 'package:flutter/material.dart';

abstract final class AppColors {
  static const gold = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5D77A);
  static const darkGold = Color(0xFFB8860B);
  static const error = Color(0xFFB3261E);
}

enum AppAccent {
  gold(
    label: 'Gold',
    light: Color(0xFFD4AF37),
    dark: Color(0xFFF5D77A),
    text: Color(0xFF705300),
    muted: Color(0xFF80651A),
    tint: Color(0xFFFFF4D6),
  ),
  yellow(
    label: 'Yellow',
    light: Color(0xFFF2CC45),
    dark: Color(0xFFF7DB72),
    text: Color(0xFF806300),
    muted: Color(0xFF9A7C28),
    tint: Color(0xFFFFF7D8),
  ),
  blue(
    label: 'Blue',
    light: Color(0xFF5C8FE8),
    dark: Color(0xFF8CB4FF),
    text: Color(0xFF2855A0),
    muted: Color(0xFF567AB8),
    tint: Color(0xFFEAF2FF),
  ),
  orange(
    label: 'Orange',
    light: Color(0xFFF0954B),
    dark: Color(0xFFFFB36B),
    text: Color(0xFF9A4A0A),
    muted: Color(0xFFB87038),
    tint: Color(0xFFFFF0E1),
  ),
  pink(
    label: 'Pink',
    light: Color(0xFFE875A5),
    dark: Color(0xFFF49BC1),
    text: Color(0xFFA6386B),
    muted: Color(0xFFB95F88),
    tint: Color(0xFFFFF0F6),
  ),
  red(
    label: 'Red',
    light: Color(0xFFE56565),
    dark: Color(0xFFFF8585),
    text: Color(0xFFA52D36),
    muted: Color(0xFFB85159),
    tint: Color(0xFFFFF0F0),
  ),
  green(
    label: 'Green',
    light: Color(0xFF56A879),
    dark: Color(0xFF78D69F),
    text: Color(0xFF28734B),
    muted: Color(0xFF4C9870),
    tint: Color(0xFFEAF7EF),
  ),
  purple(
    label: 'Purple',
    light: Color(0xFF9872DE),
    dark: Color(0xFFB79BFF),
    text: Color(0xFF6343A7),
    muted: Color(0xFF8068B0),
    tint: Color(0xFFF2EDFF),
  );

  const AppAccent({
    required this.label,
    required this.light,
    required this.dark,
    required this.text,
    required this.muted,
    required this.tint,
  });

  final String label;
  final Color light;
  final Color dark;
  final Color text;
  final Color muted;
  final Color tint;
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.display,
    required this.muted,
    required this.mutedGold,
    required this.numberKey,
    required this.numberText,
    required this.utilityKey,
    required this.utilityText,
    required this.operatorKey,
    required this.operatorText,
    required this.accent,
    required this.accentHighlight,
    required this.outline,
    required this.error,
    required this.divider,
  });

  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color display;
  final Color muted;
  final Color mutedGold;
  final Color numberKey;
  final Color numberText;
  final Color utilityKey;
  final Color utilityText;
  final Color operatorKey;
  final Color operatorText;
  final Color accent;
  final Color accentHighlight;
  final Color outline;
  final Color error;
  final Color divider;

  static const dark = AppPalette(
    background: Color(0xFF0D0D0D),
    surface: Color(0xFF1A1A1A),
    surfaceRaised: Color(0xFF222222),
    display: AppColors.lightGold,
    muted: Color(0xFF9B927C),
    mutedGold: Color(0xFF8A7535),
    numberKey: Color(0xFF1A1A1A),
    numberText: AppColors.gold,
    utilityKey: Color(0xFF0D0D0D),
    utilityText: AppColors.lightGold,
    operatorKey: AppColors.gold,
    operatorText: Color(0xFF0D0D0D),
    accent: AppColors.gold,
    accentHighlight: AppColors.lightGold,
    outline: Color(0xFF8A7535),
    error: Color(0xFFFF8A80),
    divider: Color(0xFF222222),
  );

  static const light = AppPalette(
    background: Color(0xFFFFFBF2),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFF4D6),
    display: Color(0xFF6C4D00),
    muted: Color(0xFF736B58),
    mutedGold: Color(0xFF80651A),
    numberKey: Color(0xFFFFFFFF),
    numberText: Color(0xFF705300),
    utilityKey: Color(0xFFFFFBF2),
    utilityText: Color(0xFF705300),
    operatorKey: Color(0xFFD4AF37),
    operatorText: Color(0xFF241A00),
    accent: Color(0xFFD4AF37),
    accentHighlight: Color(0xFFF5D77A),
    outline: Color(0xFFB99A3B),
    error: Color(0xFFB3261E),
    divider: Color(0xFFE9DFC3),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? display,
    Color? muted,
    Color? mutedGold,
    Color? numberKey,
    Color? numberText,
    Color? utilityKey,
    Color? utilityText,
    Color? operatorKey,
    Color? operatorText,
    Color? accent,
    Color? accentHighlight,
    Color? outline,
    Color? error,
    Color? divider,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      display: display ?? this.display,
      muted: muted ?? this.muted,
      mutedGold: mutedGold ?? this.mutedGold,
      numberKey: numberKey ?? this.numberKey,
      numberText: numberText ?? this.numberText,
      utilityKey: utilityKey ?? this.utilityKey,
      utilityText: utilityText ?? this.utilityText,
      operatorKey: operatorKey ?? this.operatorKey,
      operatorText: operatorText ?? this.operatorText,
      accent: accent ?? this.accent,
      accentHighlight: accentHighlight ?? this.accentHighlight,
      outline: outline ?? this.outline,
      error: error ?? this.error,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      display: Color.lerp(display, other.display, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedGold: Color.lerp(mutedGold, other.mutedGold, t)!,
      numberKey: Color.lerp(numberKey, other.numberKey, t)!,
      numberText: Color.lerp(numberText, other.numberText, t)!,
      utilityKey: Color.lerp(utilityKey, other.utilityKey, t)!,
      utilityText: Color.lerp(utilityText, other.utilityText, t)!,
      operatorKey: Color.lerp(operatorKey, other.operatorKey, t)!,
      operatorText: Color.lerp(operatorText, other.operatorText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHighlight: Color.lerp(accentHighlight, other.accentHighlight, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      error: Color.lerp(error, other.error, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

abstract final class AppTheme {
  static AppPalette paletteOf(BuildContext context) =>
      Theme.of(context).extension<AppPalette>()!;

  static ThemeData dark(AppAccent accent) =>
      _buildTheme(Brightness.dark, accent);

  static ThemeData light(AppAccent accent) =>
      _buildTheme(Brightness.light, accent);

  static ThemeData _buildTheme(Brightness brightness, AppAccent accent) {
    final isDark = brightness == Brightness.dark;
    final accentColor = isDark ? accent.dark : accent.light;
    final neutralPalette = isDark ? AppPalette.dark : AppPalette.light;
    final palette = neutralPalette.copyWith(
      display: accent.dark,
      mutedGold: accent.dark,
      numberText: isDark ? accent.dark : accent.text,
      utilityText: isDark ? accent.dark : accent.text,
      operatorKey: accentColor,
      operatorText: isDark ? const Color(0xFF0D0D0D) : const Color(0xFF241A00),
      accent: accentColor,
      accentHighlight: isDark ? accent.light : accent.dark,
      outline: isDark ? accent.muted : accent.light,
      surfaceRaised: isDark ? neutralPalette.surfaceRaised : accent.tint,
      error: AppPalette.dark.error,
    );
    return _buildFromPalette(brightness, palette, accentColor);
  }

  static ThemeData _buildFromPalette(
    Brightness brightness,
    AppPalette palette,
    Color primary,
  ) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: palette.surface,
      primary: primary,
      onPrimary: brightness == Brightness.dark
          ? palette.operatorText
          : Colors.white,
      secondary: AppColors.darkGold,
      error: palette.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      extensions: [palette],
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.display,
        centerTitle: false,
        elevation: 0,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: palette.display),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: palette.display,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: palette.muted, fontSize: 15),
      ),
    );
  }
}
