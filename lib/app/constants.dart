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

enum MaintenanceType { oilChange, chainLube, custom }
