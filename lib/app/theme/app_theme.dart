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
}
