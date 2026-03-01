import '../constants.dart';
import '../models/app_settings.dart';
import '../models/bike.dart';
import '../models/fuel_log_entry.dart';
import '../models/maintenance_entry.dart';
import '../services/local_storage_service.dart';

class DemoDataService {
  DemoDataService(this._storage);

  final LocalStorageService _storage;

  Future<void> populateDemoData() async {
    final now = DateTime.now();

    final bikes = [
      Bike(
        id: 'bike_demo_1',
        name: 'City Commuter',
        manufacturer: 'Honda',
        model: 'CBR 150R',
        year: 2022,
        distanceUnit: DistanceUnit.km,
        fuelUnit: FuelUnit.liters,
        createdAt: now.subtract(const Duration(days: 220)),
      ),
      Bike(
        id: 'bike_demo_2',
        name: 'Weekend Tourer',
        manufacturer: 'Yamaha',
        model: 'FZ-S V4',
        year: 2023,
        distanceUnit: DistanceUnit.km,
        fuelUnit: FuelUnit.liters,
        createdAt: now.subtract(const Duration(days: 180)),
      ),
    ];

    final settings = AppSettings.defaults.copyWith(
      currencySymbol: 'USD',
      decimalPrecision: 2,
      defaultDistanceUnit: DistanceUnit.km,
      defaultFuelUnit: FuelUnit.liters,
      refillReminderInterval: 220,
      themePreset: AppThemePreset.midnightTeal,
    );

    final bike1Fuel = _withCalculatedFields([
      FuelLogEntry(
        id: 'fuel_1',
        bikeId: 'bike_demo_1',
        odometer: 14520,
        fuelQuantity: 10.8,
        totalCost: 12.42,
        date: now.subtract(const Duration(days: 70)),
        fuelType: FuelType.petrol,
        stationName: 'City Pump A',
      ),
      FuelLogEntry(
        id: 'fuel_2',
        bikeId: 'bike_demo_1',
        odometer: 14768,
        fuelQuantity: 9.9,
        totalCost: 11.58,
        date: now.subtract(const Duration(days: 60)),
        fuelType: FuelType.octane,
        stationName: 'City Pump A',
      ),
      FuelLogEntry(
        id: 'fuel_3',
        bikeId: 'bike_demo_1',
        odometer: 15032,
        fuelQuantity: 10.4,
        totalCost: 12.17,
        date: now.subtract(const Duration(days: 50)),
        fuelType: FuelType.petrol,
        stationName: 'Highway Station',
      ),
      FuelLogEntry(
        id: 'fuel_4',
        bikeId: 'bike_demo_1',
        odometer: 15266,
        fuelQuantity: 9.5,
        totalCost: 11.12,
        date: now.subtract(const Duration(days: 41)),
        fuelType: FuelType.petrol,
      ),
      FuelLogEntry(
        id: 'fuel_5',
        bikeId: 'bike_demo_1',
        odometer: 15496,
        fuelQuantity: 9.6,
        totalCost: 11.42,
        date: now.subtract(const Duration(days: 33)),
        fuelType: FuelType.petrol,
      ),
      FuelLogEntry(
        id: 'fuel_6',
        bikeId: 'bike_demo_1',
        odometer: 15745,
        fuelQuantity: 10.1,
        totalCost: 12.35,
        date: now.subtract(const Duration(days: 24)),
        fuelType: FuelType.octane,
      ),
      FuelLogEntry(
        id: 'fuel_7',
        bikeId: 'bike_demo_1',
        odometer: 16018,
        fuelQuantity: 10.7,
        totalCost: 13.09,
        date: now.subtract(const Duration(days: 14)),
        fuelType: FuelType.octane,
      ),
      FuelLogEntry(
        id: 'fuel_8',
        bikeId: 'bike_demo_1',
        odometer: 16294,
        fuelQuantity: 11.0,
        totalCost: 13.53,
        date: now.subtract(const Duration(days: 3)),
        fuelType: FuelType.petrol,
        notes: 'Weekend long ride',
      ),
    ]);

    final bike2Fuel = _withCalculatedFields([
      FuelLogEntry(
        id: 'fuel_b2_1',
        bikeId: 'bike_demo_2',
        odometer: 4020,
        fuelQuantity: 8.4,
        totalCost: 9.95,
        date: now.subtract(const Duration(days: 65)),
        fuelType: FuelType.petrol,
      ),
      FuelLogEntry(
        id: 'fuel_b2_2',
        bikeId: 'bike_demo_2',
        odometer: 4240,
        fuelQuantity: 8.6,
        totalCost: 10.37,
        date: now.subtract(const Duration(days: 44)),
        fuelType: FuelType.petrol,
      ),
      FuelLogEntry(
        id: 'fuel_b2_3',
        bikeId: 'bike_demo_2',
        odometer: 4464,
        fuelQuantity: 8.9,
        totalCost: 10.96,
        date: now.subtract(const Duration(days: 20)),
        fuelType: FuelType.octane,
      ),
      FuelLogEntry(
        id: 'fuel_b2_4',
        bikeId: 'bike_demo_2',
        odometer: 4672,
        fuelQuantity: 8.3,
        totalCost: 10.21,
        date: now.subtract(const Duration(days: 5)),
        fuelType: FuelType.petrol,
      ),
    ]);

    final bike1Maintenance = [
      MaintenanceEntry(
        id: 'mnt_1',
        bikeId: 'bike_demo_1',
        type: MaintenanceType.oilChange,
        odometer: 15000,
        date: now.subtract(const Duration(days: 48)),
        notes: 'Engine oil replaced',
        nextDueOdometer: 16200,
      ),
      MaintenanceEntry(
        id: 'mnt_2',
        bikeId: 'bike_demo_1',
        type: MaintenanceType.chainLube,
        odometer: 15920,
        date: now.subtract(const Duration(days: 12)),
        notes: 'Chain cleaned and lubed',
        nextDueOdometer: 16420,
      ),
    ];

    final bike2Maintenance = [
      MaintenanceEntry(
        id: 'mnt_b2_1',
        bikeId: 'bike_demo_2',
        type: MaintenanceType.custom,
        customType: 'Brake Pad Check',
        odometer: 4300,
        date: now.subtract(const Duration(days: 30)),
        notes: 'Front pads at 40%',
        nextDueOdometer: 4900,
      ),
    ];

    await _storage.clear();

    await _storage.setJsonList(
      StorageKeys.bikes,
      bikes.map((bike) => bike.toMap()).toList(),
    );
    await _storage.setString(StorageKeys.activeBikeId, 'bike_demo_1');
    await _storage.setJsonMap(StorageKeys.settings, settings.toMap());

    await _storage.setJsonList(
      StorageKeys.fuelLogs('bike_demo_1'),
      bike1Fuel.map((entry) => entry.toMap()).toList(),
    );
    await _storage.setJsonList(
      StorageKeys.fuelLogs('bike_demo_2'),
      bike2Fuel.map((entry) => entry.toMap()).toList(),
    );

    await _storage.setJsonList(
      StorageKeys.maintenance('bike_demo_1'),
      bike1Maintenance.map((entry) => entry.toMap()).toList(),
    );
    await _storage.setJsonList(
      StorageKeys.maintenance('bike_demo_2'),
      bike2Maintenance.map((entry) => entry.toMap()).toList(),
    );
  }

  List<FuelLogEntry> _withCalculatedFields(List<FuelLogEntry> raw) {
    final sorted = [...raw]..sort((a, b) => a.date.compareTo(b.date));
    final calculated = <FuelLogEntry>[];

    for (var i = 0; i < sorted.length; i++) {
      final current = sorted[i];
      final previous = i == 0 ? null : calculated[i - 1];
      final pricePerUnit = current.fuelQuantity > 0
          ? current.totalCost / current.fuelQuantity
          : null;

      if (previous == null) {
        calculated.add(
          current.copyWith(
            tripDistance: null,
            clearTripDistance: true,
            mileage: null,
            clearMileage: true,
            pricePerUnit: pricePerUnit,
            clearPricePerUnit: pricePerUnit == null,
            costPerDistance: null,
            clearCostPerDistance: true,
          ),
        );
        continue;
      }

      final tripDistance = current.odometer - previous.odometer;
      final validTrip = tripDistance > 0;
      final mileage = validTrip && current.fuelQuantity > 0
          ? tripDistance / current.fuelQuantity
          : null;
      final costPerDistance = validTrip ? current.totalCost / tripDistance : null;

      calculated.add(
        current.copyWith(
          tripDistance: validTrip ? tripDistance : null,
          clearTripDistance: !validTrip,
          mileage: mileage,
          clearMileage: mileage == null,
          pricePerUnit: pricePerUnit,
          clearPricePerUnit: pricePerUnit == null,
          costPerDistance: costPerDistance,
          clearCostPerDistance: costPerDistance == null,
        ),
      );
    }

    return calculated;
  }
}
