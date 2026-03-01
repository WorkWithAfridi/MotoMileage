class StorageKeys {
  static const bikes = 'bikes';
  static const activeBikeId = 'active_bike_id';
  static const settings = 'settings';
  static const onboardingSeen = 'onboarding_seen';

  static String fuelLogs(String bikeId) => 'fuel_logs_$bikeId';
  static String maintenance(String bikeId) => 'maintenance_$bikeId';
}

enum DistanceUnit { km, miles }

enum FuelUnit { liters, gallons }

enum FuelType { petrol, diesel, octane, electric, custom }

enum MaintenanceType {
  oilChange,
  chainLube,
  brakeService,
  airFilter,
  sparkPlug,
  coolantFlush,
  tireChange,
  batteryService,
  custom,
}

extension MaintenanceTypeX on MaintenanceType {
  String get label {
    switch (this) {
      case MaintenanceType.oilChange:
        return 'Oil Change';
      case MaintenanceType.chainLube:
        return 'Chain Lube';
      case MaintenanceType.brakeService:
        return 'Brake Service';
      case MaintenanceType.airFilter:
        return 'Air Filter';
      case MaintenanceType.sparkPlug:
        return 'Spark Plug';
      case MaintenanceType.coolantFlush:
        return 'Coolant Flush';
      case MaintenanceType.tireChange:
        return 'Tire Change';
      case MaintenanceType.batteryService:
        return 'Battery Service';
      case MaintenanceType.custom:
        return 'Custom';
    }
  }
}

enum AppThemePreset {
  midnightTeal,
  oceanLight,
  forestMist,
  sunsetSand,
  royalIndigo,
  roseBlush,
  volcanicAsh,
  arcticBlue,
  emeraldNight,
  citrusPop,
  lavenderHaze,
  graphiteMono,
  iconEmberTeal,
  iconTealEmber,
}
