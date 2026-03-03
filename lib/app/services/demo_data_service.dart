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
        name: 'Dhaka Commute',
        manufacturer: 'Honda',
        model: 'CBR 150R',
        year: 2022,
        distanceUnit: DistanceUnit.km,
        fuelUnit: FuelUnit.liters,
        createdAt: now.subtract(const Duration(days: 410)),
      ),
      Bike(
        id: 'bike_demo_2',
        name: 'Weekend Tourer',
        manufacturer: 'Yamaha',
        model: 'FZS FI V3',
        year: 2021,
        distanceUnit: DistanceUnit.km,
        fuelUnit: FuelUnit.liters,
        createdAt: now.subtract(const Duration(days: 360)),
      ),
      Bike(
        id: 'bike_demo_3',
        name: 'Office Run',
        manufacturer: 'TVS',
        model: 'Apache RTR 160 4V',
        year: 2020,
        distanceUnit: DistanceUnit.km,
        fuelUnit: FuelUnit.liters,
        createdAt: now.subtract(const Duration(days: 320)),
      ),
      Bike(
        id: 'bike_demo_4',
        name: 'District Rider',
        manufacturer: 'Bajaj',
        model: 'Pulsar N160',
        year: 2023,
        distanceUnit: DistanceUnit.km,
        fuelUnit: FuelUnit.liters,
        createdAt: now.subtract(const Duration(days: 250)),
      ),
    ];

    final settings = AppSettings.defaults.copyWith(
      currencySymbol: 'BDT',
      decimalPrecision: 2,
      defaultDistanceUnit: DistanceUnit.km,
      defaultFuelUnit: FuelUnit.liters,
      refillReminderInterval: 250,
      themePreset: AppThemePreset.arcticBlue,
    );

    final bike1Fuel = _buildFuelSeries(
      bikeId: 'bike_demo_1',
      idPrefix: 'fuel_dhaka',
      count: 22,
      startOdometer: 18240,
      startDate: now.subtract(const Duration(days: 270)),
      avgTripKm: 165,
      avgFuelLiters: 4.2,
      stationNames: const [
        'Padma Oil - Tejgaon',
        'Jamuna Filling - Farmgate',
        'Omera Pump - Banani',
        'Meghna Petroleum - Rampura',
        'Bashundhara Fuel - Badda',
      ],
      fuelTypes: const [
        FuelType.petrol,
        FuelType.octane,
        FuelType.petrol,
        FuelType.petrol,
        FuelType.octane,
      ],
      notesByIndex: {
        4: 'Heavy traffic week in Dhaka',
        11: 'Long ride to Narayanganj',
        19: 'Rainy day mileage drop',
      },
    );

    final bike2Fuel = _buildFuelSeries(
      bikeId: 'bike_demo_2',
      idPrefix: 'fuel_tour',
      count: 20,
      startOdometer: 9680,
      startDate: now.subtract(const Duration(days: 250)),
      avgTripKm: 190,
      avgFuelLiters: 4.5,
      stationNames: const [
        'Padma Oil - Uttara',
        'Jamuna Pump - Tongi',
        'Omera Pump - Gazipur Chourasta',
        'Meghna Fuel - Mymensingh Road',
        'TK Pump - Abdullahpur',
      ],
      fuelTypes: const [
        FuelType.petrol,
        FuelType.octane,
        FuelType.petrol,
        FuelType.octane,
      ],
      notesByIndex: {
        2: 'Weekend ride to Bhawal',
        8: 'Tour with pillion and luggage',
        16: 'Highway focused ride',
      },
    );

    final bike3Fuel = _buildFuelSeries(
      bikeId: 'bike_demo_3',
      idPrefix: 'fuel_office',
      count: 18,
      startOdometer: 24150,
      startDate: now.subtract(const Duration(days: 230)),
      avgTripKm: 135,
      avgFuelLiters: 3.7,
      stationNames: const [
        'Padma Oil - Mirpur 10',
        'Meghna Pump - Kazipara',
        'Jamuna Fuel - Agargaon',
        'Nitol Niloy Pump - Pallabi',
        'Omera Fuel - Kallyanpur',
      ],
      fuelTypes: const [
        FuelType.petrol,
        FuelType.petrol,
        FuelType.octane,
        FuelType.petrol,
      ],
      notesByIndex: {6: 'Office commute only', 14: 'Id holiday reduced usage'},
    );

    final bike4Fuel = _buildFuelSeries(
      bikeId: 'bike_demo_4',
      idPrefix: 'fuel_district',
      count: 17,
      startOdometer: 6280,
      startDate: now.subtract(const Duration(days: 210)),
      avgTripKm: 220,
      avgFuelLiters: 5.0,
      stationNames: const [
        'Padma Oil - Comilla Bypass',
        'Jamuna Pump - Daudkandi',
        'Meghna Fuel - Chattogram Gate',
        'Omera Pump - Feni',
        'TK Filling - Chandina',
      ],
      fuelTypes: const [
        FuelType.petrol,
        FuelType.octane,
        FuelType.petrol,
        FuelType.octane,
        FuelType.petrol,
      ],
      notesByIndex: {
        1: 'Trip to Cumilla',
        9: 'Long run to Chattogram',
        15: 'Higher fuel use with highway speed',
      },
    );

    final bike1Maintenance = [
      MaintenanceEntry(
        id: 'mnt_dhaka_1',
        bikeId: 'bike_demo_1',
        type: MaintenanceType.oilChange,
        odometer: 19880,
        date: now.subtract(const Duration(days: 180)),
        notes: '10W-30 synthetic oil change',
        nextDueOdometer: 21380,
      ),
      MaintenanceEntry(
        id: 'mnt_dhaka_2',
        bikeId: 'bike_demo_1',
        type: MaintenanceType.chainLube,
        odometer: 20920,
        date: now.subtract(const Duration(days: 95)),
        notes: 'Chain cleaned and lubed at home',
        nextDueOdometer: 21420,
      ),
      MaintenanceEntry(
        id: 'mnt_dhaka_3',
        bikeId: 'bike_demo_1',
        type: MaintenanceType.brakeService,
        odometer: 21480,
        date: now.subtract(const Duration(days: 42)),
        notes: 'Front brake pad replaced',
        nextDueOdometer: 24000,
      ),
      MaintenanceEntry(
        id: 'mnt_dhaka_4',
        bikeId: 'bike_demo_1',
        type: MaintenanceType.airFilter,
        odometer: 21610,
        date: now.subtract(const Duration(days: 28)),
        notes: 'Air filter cleaned',
        nextDueOdometer: 22610,
      ),
    ];

    final bike2Maintenance = [
      MaintenanceEntry(
        id: 'mnt_tour_1',
        bikeId: 'bike_demo_2',
        type: MaintenanceType.oilChange,
        odometer: 10850,
        date: now.subtract(const Duration(days: 160)),
        notes: 'Touring setup service',
        nextDueOdometer: 12350,
      ),
      MaintenanceEntry(
        id: 'mnt_tour_2',
        bikeId: 'bike_demo_2',
        type: MaintenanceType.sparkPlug,
        odometer: 11720,
        date: now.subtract(const Duration(days: 110)),
        notes: 'Spark plug replaced',
        nextDueOdometer: 15720,
      ),
      MaintenanceEntry(
        id: 'mnt_tour_3',
        bikeId: 'bike_demo_2',
        type: MaintenanceType.tireChange,
        odometer: 12440,
        date: now.subtract(const Duration(days: 64)),
        notes: 'Rear tire changed before long tour',
      ),
    ];

    final bike3Maintenance = [
      MaintenanceEntry(
        id: 'mnt_office_1',
        bikeId: 'bike_demo_3',
        type: MaintenanceType.chainLube,
        odometer: 24800,
        date: now.subtract(const Duration(days: 120)),
        notes: 'Quick chain service',
        nextDueOdometer: 25300,
      ),
      MaintenanceEntry(
        id: 'mnt_office_2',
        bikeId: 'bike_demo_3',
        type: MaintenanceType.batteryService,
        odometer: 25260,
        date: now.subtract(const Duration(days: 72)),
        notes: 'Battery water top-up and terminal clean',
      ),
      MaintenanceEntry(
        id: 'mnt_office_3',
        bikeId: 'bike_demo_3',
        type: MaintenanceType.custom,
        customType: 'Clutch Cable Adjustment',
        odometer: 25640,
        date: now.subtract(const Duration(days: 35)),
        notes: 'Cable tightened for smoother feel',
      ),
    ];

    final bike4Maintenance = [
      MaintenanceEntry(
        id: 'mnt_district_1',
        bikeId: 'bike_demo_4',
        type: MaintenanceType.coolantFlush,
        odometer: 7080,
        date: now.subtract(const Duration(days: 140)),
        notes: 'Coolant changed before summer rides',
        nextDueOdometer: 12080,
      ),
      MaintenanceEntry(
        id: 'mnt_district_2',
        bikeId: 'bike_demo_4',
        type: MaintenanceType.brakeService,
        odometer: 7930,
        date: now.subtract(const Duration(days: 86)),
        notes: 'Rear brake shoe replaced',
        nextDueOdometer: 10930,
      ),
      MaintenanceEntry(
        id: 'mnt_district_3',
        bikeId: 'bike_demo_4',
        type: MaintenanceType.airFilter,
        odometer: 8450,
        date: now.subtract(const Duration(days: 49)),
        notes: 'Air filter cleaning after dusty highway trip',
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
      StorageKeys.fuelLogs('bike_demo_3'),
      bike3Fuel.map((entry) => entry.toMap()).toList(),
    );
    await _storage.setJsonList(
      StorageKeys.fuelLogs('bike_demo_4'),
      bike4Fuel.map((entry) => entry.toMap()).toList(),
    );

    await _storage.setJsonList(
      StorageKeys.maintenance('bike_demo_1'),
      bike1Maintenance.map((entry) => entry.toMap()).toList(),
    );
    await _storage.setJsonList(
      StorageKeys.maintenance('bike_demo_2'),
      bike2Maintenance.map((entry) => entry.toMap()).toList(),
    );
    await _storage.setJsonList(
      StorageKeys.maintenance('bike_demo_3'),
      bike3Maintenance.map((entry) => entry.toMap()).toList(),
    );
    await _storage.setJsonList(
      StorageKeys.maintenance('bike_demo_4'),
      bike4Maintenance.map((entry) => entry.toMap()).toList(),
    );
  }

  List<FuelLogEntry> _buildFuelSeries({
    required String bikeId,
    required String idPrefix,
    required int count,
    required double startOdometer,
    required DateTime startDate,
    required double avgTripKm,
    required double avgFuelLiters,
    required List<String> stationNames,
    required List<FuelType> fuelTypes,
    required Map<int, String> notesByIndex,
  }) {
    final logs = <FuelLogEntry>[];
    var odometer = startOdometer;
    var date = startDate;

    for (var i = 0; i < count; i++) {
      final tripVariation = ((i % 5) - 2) * 9.0;
      final fuelVariation = ((i % 4) - 1.5) * 0.25;
      final trip = (avgTripKm + tripVariation).clamp(80, 340);
      final quantity = (avgFuelLiters + fuelVariation).clamp(2.2, 7.4);
      final type = fuelTypes[i % fuelTypes.length];
      final pricePerLiter = type == FuelType.octane ? 135.0 : 125.0;
      final cost = quantity * pricePerLiter;

      odometer += trip;
      date = date.add(Duration(days: 9 + (i % 4)));

      logs.add(
        FuelLogEntry(
          id: '${idPrefix}_${i + 1}',
          bikeId: bikeId,
          odometer: _round2(odometer),
          fuelQuantity: _round2(quantity),
          totalCost: _round2(cost),
          date: date,
          fuelType: type,
          stationName: stationNames[i % stationNames.length],
          notes: notesByIndex[i],
        ),
      );
    }

    return _withCalculatedFields(logs);
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
      final costPerDistance = validTrip
          ? current.totalCost / tripDistance
          : null;

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

  double _round2(double value) {
    return (value * 100).roundToDouble() / 100;
  }
}
