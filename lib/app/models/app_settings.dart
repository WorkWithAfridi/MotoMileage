import '../constants.dart';

class AppSettings {
  const AppSettings({
    required this.currencySymbol,
    required this.decimalPrecision,
    required this.defaultDistanceUnit,
    required this.defaultFuelUnit,
    required this.refillReminderInterval,
    required this.themePreset,
    this.languageCode,
  });

  final String currencySymbol;
  final int decimalPrecision;
  final DistanceUnit defaultDistanceUnit;
  final FuelUnit defaultFuelUnit;
  final double refillReminderInterval;
  final AppThemePreset themePreset;
  final String? languageCode;

  static const defaults = AppSettings(
    currencySymbol: 'USD',
    decimalPrecision: 2,
    defaultDistanceUnit: DistanceUnit.km,
    defaultFuelUnit: FuelUnit.liters,
    refillReminderInterval: 250,
    themePreset: AppThemePreset.arcticBlue,
    languageCode: null,
  );

  AppSettings copyWith({
    String? currencySymbol,
    int? decimalPrecision,
    DistanceUnit? defaultDistanceUnit,
    FuelUnit? defaultFuelUnit,
    double? refillReminderInterval,
    AppThemePreset? themePreset,
    String? languageCode,
    bool clearLanguageCode = false,
  }) {
    return AppSettings(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      defaultDistanceUnit: defaultDistanceUnit ?? this.defaultDistanceUnit,
      defaultFuelUnit: defaultFuelUnit ?? this.defaultFuelUnit,
      refillReminderInterval:
          refillReminderInterval ?? this.refillReminderInterval,
      themePreset: themePreset ?? this.themePreset,
      languageCode: clearLanguageCode
          ? null
          : languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currencySymbol': currencySymbol,
      'decimalPrecision': decimalPrecision,
      'defaultDistanceUnit': defaultDistanceUnit.name,
      'defaultFuelUnit': defaultFuelUnit.name,
      'refillReminderInterval': refillReminderInterval,
      'themePreset': themePreset.name,
      'languageCode': languageCode,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final legacyDarkMode = map['darkMode'] as bool?;

    return AppSettings(
      currencySymbol:
          map['currencySymbol'] as String? ?? defaults.currencySymbol,
      decimalPrecision:
          (map['decimalPrecision'] as num?)?.toInt() ??
          defaults.decimalPrecision,
      defaultDistanceUnit: DistanceUnit.values.firstWhere(
        (value) => value.name == map['defaultDistanceUnit'],
        orElse: () => defaults.defaultDistanceUnit,
      ),
      defaultFuelUnit: FuelUnit.values.firstWhere(
        (value) => value.name == map['defaultFuelUnit'],
        orElse: () => defaults.defaultFuelUnit,
      ),
      refillReminderInterval:
          (map['refillReminderInterval'] as num?)?.toDouble() ??
          defaults.refillReminderInterval,
      themePreset: _parseThemePreset(
        map['themePreset'] as String?,
        legacyDarkMode: legacyDarkMode,
      ),
      languageCode: map['languageCode'] as String?,
    );
  }

  static AppThemePreset _parseThemePreset(
    String? value, {
    required bool? legacyDarkMode,
  }) {
    if (value != null) {
      return AppThemePreset.values.firstWhere(
        (item) => item.name == value,
        orElse: () => defaults.themePreset,
      );
    }

    if (legacyDarkMode != null) {
      return legacyDarkMode
          ? AppThemePreset.arcticBlue
          : AppThemePreset.oceanLight;
    }

    return defaults.themePreset;
  }
}
