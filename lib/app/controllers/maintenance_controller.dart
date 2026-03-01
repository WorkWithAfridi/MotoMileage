import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/maintenance_entry.dart';
import '../repositories/maintenance_repository.dart';
import 'bike_controller.dart';

class MaintenanceController extends GetxController {
  MaintenanceController(this._repository, this._bikeController);

  final MaintenanceRepository _repository;
  final BikeController _bikeController;
  final Uuid _uuid = const Uuid();

  final RxList<MaintenanceEntry> entries = <MaintenanceEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    ever<String?>(_bikeController.activeBikeId, _loadForBike);
    _loadForBike(_bikeController.activeBikeId.value);
  }

  Future<void> _loadForBike(String? bikeId) async {
    if (bikeId == null) {
      entries.clear();
      return;
    }

    final loaded = _repository.loadEntries(bikeId)
      ..sort((a, b) => b.date.compareTo(a.date));
    entries.assignAll(loaded);
  }

  Future<void> addEntry({
    required MaintenanceType type,
    String? customType,
    required double odometer,
    DateTime? date,
    String? notes,
    double? nextDueOdometer,
  }) async {
    final bikeId = _bikeController.activeBikeId.value;
    if (bikeId == null) {
      return;
    }

    entries.insert(
      0,
      MaintenanceEntry(
        id: _uuid.v4(),
        bikeId: bikeId,
        type: type,
        customType: customType,
        odometer: odometer,
        date: date ?? DateTime.now(),
        notes: notes,
        nextDueOdometer: nextDueOdometer,
      ),
    );

    await _repository.saveEntries(bikeId, entries);
  }

  Future<void> deleteEntry(String id) async {
    final bikeId = _bikeController.activeBikeId.value;
    if (bikeId == null) {
      return;
    }

    entries.removeWhere((entry) => entry.id == id);
    await _repository.saveEntries(bikeId, entries);
  }

  List<MaintenanceEntry> dueEntries(double currentOdometer) {
    return entries
        .where((entry) =>
            entry.nextDueOdometer != null &&
            currentOdometer >= entry.nextDueOdometer!)
        .toList();
  }
}
