import 'package:flutter/material.dart';

import '../constants.dart';

class AppTheme {
  static ThemeData fromPreset(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.midnightTeal:
        return _buildTheme(
          seed: const Color(0xFF0A7E8C),
          brightness: Brightness.dark,
          cardColor: const Color(0xFF1D2B34),
        );
      case AppThemePreset.oceanLight:
        return _buildTheme(
          seed: const Color(0xFF0A7E8C),
          brightness: Brightness.light,
          cardColor: const Color(0xFFF4F9FA),
        );
      case AppThemePreset.forestMist:
        return _buildTheme(
          seed: const Color(0xFF2D6A4F),
          brightness: Brightness.light,
          cardColor: const Color(0xFFF2FAF5),
        );
      case AppThemePreset.sunsetSand:
        return _buildTheme(
          seed: const Color(0xFFB85C38),
          brightness: Brightness.light,
          cardColor: const Color(0xFFFFF7F1),
        );
      case AppThemePreset.royalIndigo:
        return _buildTheme(
          seed: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
          cardColor: const Color(0xFF1E1B4B),
        );
      case AppThemePreset.roseBlush:
        return _buildTheme(
          seed: const Color(0xFFDB2777),
          brightness: Brightness.light,
          cardColor: const Color(0xFFFFF1F6),
        );
      case AppThemePreset.volcanicAsh:
        return _buildTheme(
          seed: const Color(0xFF7C2D12),
          brightness: Brightness.dark,
          cardColor: const Color(0xFF292524),
        );
      case AppThemePreset.arcticBlue:
        return _buildTheme(
          seed: const Color(0xFF0EA5E9),
          brightness: Brightness.light,
          cardColor: const Color(0xFFF0F9FF),
        );
      case AppThemePreset.emeraldNight:
        return _buildTheme(
          seed: const Color(0xFF059669),
          brightness: Brightness.dark,
          cardColor: const Color(0xFF022C22),
        );
      case AppThemePreset.citrusPop:
        return _buildTheme(
          seed: const Color(0xFFCA8A04),
          brightness: Brightness.light,
          cardColor: const Color(0xFFFEFCE8),
        );
      case AppThemePreset.lavenderHaze:
        return _buildTheme(
          seed: const Color(0xFF8B5CF6),
          brightness: Brightness.light,
          cardColor: const Color(0xFFF5F3FF),
        );
      case AppThemePreset.graphiteMono:
        return _buildTheme(
          seed: const Color(0xFF525252),
          brightness: Brightness.dark,
          cardColor: const Color(0xFF171717),
        );
      case AppThemePreset.iconEmberTeal:
        return _buildDualAccentTheme(
          primary: const Color(0xFFED4C00),
          secondary: const Color(0xFF14789A),
          brightness: Brightness.light,
          cardColor: const Color(0xFFFFF4EE),
        );
      case AppThemePreset.iconTealEmber:
        return _buildDualAccentTheme(
          primary: const Color(0xFF14789A),
          secondary: const Color(0xFFED4C00),
          brightness: Brightness.light,
          cardColor: const Color(0xFFEEF8FB),
        );
    }
  }

  static ThemeData _buildTheme({
    required Color seed,
    required Brightness brightness,
    required Color cardColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return _buildCommonTheme(
      colorScheme: colorScheme,
      brightness: brightness,
      cardColor: cardColor,
    );
  }

  static ThemeData _buildDualAccentTheme({
    required Color primary,
    required Color secondary,
    required Brightness brightness,
    required Color cardColor,
  }) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );
    final scheme = baseScheme.copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: secondary,
    );

    return _buildCommonTheme(
      colorScheme: scheme,
      brightness: brightness,
      cardColor: cardColor,
    );
  }

  static ThemeData _buildCommonTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required Color cardColor,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark
          ? colorScheme.surface
          : colorScheme.surfaceContainerLowest,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 0.8,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
        surfaceTintColor: Colors.transparent,
        color: cardColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          side: BorderSide(color: colorScheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: base.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: isDark ? 0 : 1,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: colorScheme.surfaceContainerLow,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 6 : 10,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        menuPadding: const EdgeInsets.symmetric(vertical: 8),
        textStyle: base.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        position: PopupMenuPosition.under,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
