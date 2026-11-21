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

    final loaded = _repository.loadEntries(bikeId);
    _sortNewestFirst(loaded);
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

    final normalizedCustomType = type == MaintenanceType.custom
        ? _emptyToNull(customType)
        : null;
    final normalizedNotes = _emptyToNull(notes);

    entries.add(
      MaintenanceEntry(
        id: _uuid.v4(),
        bikeId: bikeId,
        type: type,
        customType: normalizedCustomType,
        odometer: odometer,
        date: date ?? DateTime.now(),
        notes: normalizedNotes,
        nextDueOdometer: nextDueOdometer,
      ),
    );
    _sortNewestFirst(entries);
    entries.refresh();

    await _repository.saveEntries(bikeId, entries);
  }

  Future<void> updateEntry({
    required String id,
    required MaintenanceType type,
    String? customType,
    required double odometer,
    required DateTime date,
    String? notes,
    double? nextDueOdometer,
  }) async {
    final bikeId = _bikeController.activeBikeId.value;
    if (bikeId == null) {
      return;
    }

    final index = entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return;
    }

    final normalizedCustomType = type == MaintenanceType.custom
        ? _emptyToNull(customType)
        : null;
    final normalizedNotes = _emptyToNull(notes);

    entries[index] = entries[index].copyWith(
      type: type,
      customType: normalizedCustomType,
      clearCustomType: normalizedCustomType == null,
      odometer: odometer,
      date: date,
      notes: normalizedNotes,
      clearNotes: normalizedNotes == null,
      nextDueOdometer: nextDueOdometer,
      clearNextDueOdometer: nextDueOdometer == null,
    );
    _sortNewestFirst(entries);
    entries.refresh();

    await _repository.saveEntries(bikeId, entries);
  }

  Future<void> deleteEntry(String id) async {
    final bikeId = _bikeController.activeBikeId.value;
    if (bikeId == null) {
      return;
    }

    entries.removeWhere((entry) => entry.id == id);
    _sortNewestFirst(entries);
    entries.refresh();
    await _repository.saveEntries(bikeId, entries);
  }

  List<MaintenanceEntry> dueEntries(double currentOdometer) {
    return entries
        .where(
          (entry) =>
              entry.nextDueOdometer != null &&
              currentOdometer >= entry.nextDueOdometer!,
        )
        .toList();
  }

  void _sortNewestFirst(List<MaintenanceEntry> items) {
    items.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) {
        return byDate;
      }
      return b.odometer.compareTo(a.odometer);
    });
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
