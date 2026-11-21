import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/fuel_log_entry.dart';
import '../repositories/fuel_repository.dart';
import 'bike_controller.dart';
import 'settings_controller.dart';

class FuelController extends GetxController {
  FuelController(
    this._repository,
    this._bikeController,
    this._settingsController,
  );

  final FuelRepository _repository;
  final BikeController _bikeController;
  final SettingsController _settingsController;
  final Uuid _uuid = const Uuid();

  final RxList<FuelLogEntry> entries = <FuelLogEntry>[].obs;

  List<FuelLogEntry> get entriesNewestFirst {
    final sorted = [...entries];
    sorted.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) {
        return byDate;
      }
      return b.odometer.compareTo(a.odometer);
    });
    return sorted;
  }

  String? get activeBikeId => _bikeController.activeBikeId.value;

  @override
  void onInit() {
    super.onInit();
    ever<String?>(_bikeController.activeBikeId, _loadForBike);
    reloadActiveBike();
  }

  Future<void> reloadActiveBike() {
    return _loadForBike(_bikeController.activeBikeId.value);
  }

  Future<void> _loadForBike(String? bikeId) async {
    if (bikeId == null) {
      entries.clear();
      return;
    }

    final loaded = _repository.loadFuelLogs(bikeId);
    loaded.sort((a, b) => a.date.compareTo(b.date));
    entries.assignAll(loaded);
  }

  Future<void> addEntry({
    required double odometer,
    required double fuelQuantity,
    required double totalCost,
    DateTime? date,
    FuelType? fuelType,
    String? stationName,
    String? notes,
  }) async {
    final bikeId = activeBikeId;
    if (bikeId == null) {
      return;
    }

    entries.add(
      FuelLogEntry(
        id: _uuid.v4(),
        bikeId: bikeId,
        odometer: odometer,
        fuelQuantity: fuelQuantity,
        totalCost: totalCost,
        date: date ?? DateTime.now(),
        fuelType: fuelType,
        stationName: _emptyToNull(stationName),
        notes: _emptyToNull(notes),
      ),
    );

    await _persistWithRecalculation();
  }

  Future<void> updateEntry({
    required String id,
    required double odometer,
    required double fuelQuantity,
    required double totalCost,
    required DateTime date,
    FuelType? fuelType,
    String? stationName,
    String? notes,
  }) async {
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return;
    }

    entries[index] = entries[index].copyWith(
      odometer: odometer,
      fuelQuantity: fuelQuantity,
      totalCost: totalCost,
      date: date,
      fuelType: fuelType,
      clearFuelType: fuelType == null,
      stationName: _emptyToNull(stationName),
      clearStationName: _emptyToNull(stationName) == null,
      notes: _emptyToNull(notes),
      clearNotes: _emptyToNull(notes) == null,
    );

    entries.refresh();
    await _persistWithRecalculation();
  }

  Future<void> deleteEntry(String id) async {
    entries.removeWhere((entry) => entry.id == id);
    await _persistWithRecalculation();
  }

  double get thisMonthExpense {
    final now = DateTime.now();
    return entries
        .where(
          (entry) =>
              entry.date.year == now.year && entry.date.month == now.month,
        )
        .fold(0, (sum, entry) => sum + entry.totalCost);
  }

  bool get shouldShowRefillReminder {
    if (entries.length < 2) {
      return false;
    }

    final interval = _settingsController.settings.value.refillReminderInterval;
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    final last = sorted.last;
    final baseline = sorted[sorted.length - 2];
    return (last.odometer - baseline.odometer) >= interval;
  }

  Future<void> _persistWithRecalculation() async {
    final bikeId = activeBikeId;
    if (bikeId == null) {
      return;
    }

    final sorted = [...entries]
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) {
          return byDate;
        }
        return a.odometer.compareTo(b.odometer);
      });

    final recalculated = <FuelLogEntry>[];

    for (var i = 0; i < sorted.length; i++) {
      final current = sorted[i];
      final previous = i == 0 ? null : recalculated[i - 1];

      final pricePerUnit = current.fuelQuantity > 0
          ? current.totalCost / current.fuelQuantity
          : null;

      if (previous == null) {
        recalculated.add(
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

      recalculated.add(
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

    entries.assignAll(recalculated);
    await _repository.saveFuelLogs(bikeId, recalculated);
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
