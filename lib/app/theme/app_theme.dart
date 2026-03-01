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
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData _buildDualAccentTheme({
    required Color primary,
    required Color secondary,
    required Brightness brightness,
    required Color cardColor,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: brightness),
    );

    final scheme = base.colorScheme.copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: secondary,
    );

    return base.copyWith(
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
