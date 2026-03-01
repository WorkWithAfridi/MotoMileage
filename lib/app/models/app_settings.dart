import '../constants.dart';

class AppSettings {
  const AppSettings({
    required this.currencySymbol,
    required this.decimalPrecision,
    required this.defaultDistanceUnit,
    required this.defaultFuelUnit,
    required this.refillReminderInterval,
    required this.darkMode,
  });

  final String currencySymbol;
  final int decimalPrecision;
  final DistanceUnit defaultDistanceUnit;
  final FuelUnit defaultFuelUnit;
  final double refillReminderInterval;
  final bool darkMode;

  static const defaults = AppSettings(
    currencySymbol: 'USD',
    decimalPrecision: 2,
    defaultDistanceUnit: DistanceUnit.km,
    defaultFuelUnit: FuelUnit.liters,
    refillReminderInterval: 250,
    darkMode: false,
  );

  AppSettings copyWith({
    String? currencySymbol,
    int? decimalPrecision,
    DistanceUnit? defaultDistanceUnit,
    FuelUnit? defaultFuelUnit,
    double? refillReminderInterval,
    bool? darkMode,
  }) {
    return AppSettings(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      decimalPrecision: decimalPrecision ?? this.decimalPrecision,
      defaultDistanceUnit: defaultDistanceUnit ?? this.defaultDistanceUnit,
      defaultFuelUnit: defaultFuelUnit ?? this.defaultFuelUnit,
      refillReminderInterval:
          refillReminderInterval ?? this.refillReminderInterval,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currencySymbol': currencySymbol,
      'decimalPrecision': decimalPrecision,
      'defaultDistanceUnit': defaultDistanceUnit.name,
      'defaultFuelUnit': defaultFuelUnit.name,
      'refillReminderInterval': refillReminderInterval,
      'darkMode': darkMode,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      currencySymbol: map['currencySymbol'] as String? ?? defaults.currencySymbol,
      decimalPrecision: (map['decimalPrecision'] as num?)?.toInt() ??
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
      darkMode: map['darkMode'] as bool? ?? defaults.darkMode,
    );
  }
}
