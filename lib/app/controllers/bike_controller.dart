import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/bike.dart';
import '../repositories/bike_repository.dart';
import 'settings_controller.dart';

class BikeController extends GetxController {
  BikeController(this._repository, this._settingsController);

  final BikeRepository _repository;
  final SettingsController _settingsController;
  final Uuid _uuid = const Uuid();

  final RxList<Bike> bikes = <Bike>[].obs;
  final RxnString activeBikeId = RxnString();

  Bike? get activeBike {
    final id = activeBikeId.value;
    if (id == null) {
      return null;
    }
    return bikes.firstWhereOrNull((bike) => bike.id == id);
  }

  @override
  void onInit() {
    super.onInit();
    bikes.assignAll(_repository.loadBikes());
    final persistedActiveId = _repository.getActiveBikeId();

    if (persistedActiveId != null &&
        bikes.any((bike) => bike.id == persistedActiveId)) {
      activeBikeId.value = persistedActiveId;
      return;
    }

    if (bikes.isNotEmpty) {
      activeBikeId.value = bikes.first.id;
      _repository.setActiveBikeId(activeBikeId.value);
    }
  }

  Future<void> addBike({
    required String name,
    required String manufacturer,
    required String model,
    int? year,
    DistanceUnit? distanceUnit,
    FuelUnit? fuelUnit,
  }) async {
    final defaults = _settingsController.settings.value;
    final bike = Bike(
      id: _uuid.v4(),
      name: name,
      manufacturer: manufacturer,
      model: model,
      year: year,
      distanceUnit: distanceUnit ?? defaults.defaultDistanceUnit,
      fuelUnit: fuelUnit ?? defaults.defaultFuelUnit,
      createdAt: DateTime.now(),
    );

    bikes.add(bike);
    await _repository.saveBikes(bikes);

    if (activeBikeId.value == null) {
      await setActiveBike(bike.id);
    }
  }

  Future<void> updateBike(Bike updatedBike) async {
    final index = bikes.indexWhere((bike) => bike.id == updatedBike.id);
    if (index == -1) {
      return;
    }

    bikes[index] = updatedBike;
    bikes.refresh();
    await _repository.saveBikes(bikes);
  }

  Future<void> deleteBike(String bikeId) async {
    bikes.removeWhere((bike) => bike.id == bikeId);
    await _repository.saveBikes(bikes);
    await _repository.deleteBikeScopedData(bikeId);

    if (activeBikeId.value == bikeId) {
      final fallback = bikes.isEmpty ? null : bikes.first.id;
      await setActiveBike(fallback);
    }
  }

  Future<void> setActiveBike(String? bikeId) async {
    activeBikeId.value = bikeId;
    await _repository.setActiveBikeId(bikeId);
  }
}
