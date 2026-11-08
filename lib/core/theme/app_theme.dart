import 'package:flutter/material.dart';

/// Tema do LocalTube: escuro por padrão, destaque vermelho, Roboto e
/// cantos arredondados.
abstract final class AppTheme {
  static const accent = Color(0xFFE53935);
  static const thumbRadius = 12.0;

  static const _darkBg = Color(0xFF0F0F0F);
  static const _darkSurface = Color(0xFF1F1F1F);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accent,
      onPrimary: Colors.white,
      surface: _darkBg,
      surfaceContainerLowest: _darkBg,
      surfaceContainerLow: const Color(0xFF181818),
      surfaceContainer: _darkSurface,
      surfaceContainerHigh: const Color(0xFF272727),
      surfaceContainerHighest: const Color(0xFF303030),
      onSurface: const Color(0xFFF1F1F1),
      onSurfaceVariant: const Color(0xFFAAAAAA),
      secondaryContainer: const Color(0xFF3A3A3A),
      onSecondaryContainer: Colors.white,
    );
    return _base(scheme);
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      onPrimary: Colors.white,
      surface: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF9F9F9),
      surfaceContainer: const Color(0xFFF2F2F2),
      surfaceContainerHigh: const Color(0xFFE5E5E5),
      onSurface: const Color(0xFF0F0F0F),
      onSurfaceVariant: const Color(0xFF606060),
      secondaryContainer: const Color(0xFFE5E5E5),
      onSecondaryContainer: const Color(0xFF0F0F0F),
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 12,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.onSurface,
        labelStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w500),
        secondaryLabelStyle:
            TextStyle(color: scheme.surface, fontWeight: FontWeight.w500),
        showCheckmark: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(48, 40),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        inactiveTrackColor: Colors.white24,
        overlayShape: SliderComponentShape.noOverlay,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: accent),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
    );
  }
}
