import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );
    return _baseTheme(base).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F6FB),
    );
  }

  /// OLED-friendly black with cyan / violet accents.
  static ThemeData dark() {
    const surface = Color(0xFF050508);
    const surfaceHigh = Color(0xFF101014);
    final scheme = ColorScheme.dark(
      surface: surface,
      onSurface: const Color(0xFFECECF1),
      surfaceContainerHighest: surfaceHigh,
      primary: const Color(0xFF22D3EE),
      onPrimary: const Color(0xFF001418),
      primaryContainer: const Color(0xFF0D3A42),
      onPrimaryContainer: const Color(0xFFB8F4FF),
      secondary: const Color(0xFFC4B5FD),
      onSecondary: const Color(0xFF1E1438),
      secondaryContainer: const Color(0xFF2D2640),
      onSecondaryContainer: const Color(0xFFE8E0FF),
      tertiary: const Color(0xFF34D399),
      onTertiary: const Color(0xFF00180C),
      outline: const Color(0xFF2E2E36),
      outlineVariant: const Color(0xFF232329),
      error: const Color(0xFFFF8A80),
      onError: const Color(0xFF420002),
    );
    return _baseTheme(scheme).copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceHigh.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
        ),
      ),
    );
  }

  static ThemeData _baseTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: const ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: const ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.65)),
        ),
      ),
    );
  }
}
