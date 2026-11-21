import 'package:flutter_test/flutter_test.dart';
import 'package:motomileage/app/constants.dart';
import 'package:motomileage/app/controllers/bike_controller.dart';
import 'package:motomileage/app/controllers/maintenance_controller.dart';
import 'package:motomileage/app/controllers/settings_controller.dart';
import 'package:motomileage/app/models/app_settings.dart';
import 'package:motomileage/app/models/bike.dart';
import 'package:motomileage/app/models/maintenance_entry.dart';
import 'package:motomileage/app/repositories/bike_repository.dart';
import 'package:motomileage/app/repositories/maintenance_repository.dart';
import 'package:motomileage/app/repositories/settings_repository.dart';
import 'package:motomileage/app/services/local_storage_service.dart';

void main() {
  test('updates every editable maintenance field and persists it', () async {
    final maintenanceRepository = _FakeMaintenanceRepository();
    final settingsController = SettingsController(_FakeSettingsRepository());
    final bikeController = BikeController(
      _FakeBikeRepository(),
      settingsController,
    );
    bikeController.activeBikeId.value = 'bike-1';
    final controller = MaintenanceController(
      maintenanceRepository,
      bikeController,
    );
    final originalDate = DateTime(2026, 1, 10);
    final updatedDate = DateTime(2026, 2, 12);

    await controller.addEntry(
      type: MaintenanceType.oilChange,
      odometer: 1000,
      date: originalDate,
      notes: 'Old note',
      nextDueOdometer: 2000,
    );
    final entryId = controller.entries.single.id;

    await controller.updateEntry(
      id: entryId,
      type: MaintenanceType.custom,
      customType: 'Valve clearance',
      odometer: 1250,
      date: updatedDate,
      notes: 'Checked and adjusted',
      nextDueOdometer: 6250,
    );

    final updated = controller.entries.single;
    expect(updated.id, entryId);
    expect(updated.bikeId, 'bike-1');
    expect(updated.type, MaintenanceType.custom);
    expect(updated.customType, 'Valve clearance');
    expect(updated.odometer, 1250);
    expect(updated.date, updatedDate);
    expect(updated.notes, 'Checked and adjusted');
    expect(updated.nextDueOdometer, 6250);
    expect(maintenanceRepository.savedEntries.single.toMap(), updated.toMap());
  });

  test('editing can clear optional maintenance fields', () async {
    final maintenanceRepository = _FakeMaintenanceRepository();
    final settingsController = SettingsController(_FakeSettingsRepository());
    final bikeController = BikeController(
      _FakeBikeRepository(),
      settingsController,
    );
    bikeController.activeBikeId.value = 'bike-1';
    final controller = MaintenanceController(
      maintenanceRepository,
      bikeController,
    );

    await controller.addEntry(
      type: MaintenanceType.custom,
      customType: 'Inspection',
      odometer: 1000,
      notes: 'Existing note',
      nextDueOdometer: 2000,
    );

    await controller.updateEntry(
      id: controller.entries.single.id,
      type: MaintenanceType.chainLube,
      odometer: 1100,
      date: DateTime(2026, 3, 1),
      notes: '   ',
    );

    final updated = controller.entries.single;
    expect(updated.customType, isNull);
    expect(updated.notes, isNull);
    expect(updated.nextDueOdometer, isNull);
  });
}

class _UnusedStorage extends LocalStorageService {}

class _FakeMaintenanceRepository extends MaintenanceRepository {
  _FakeMaintenanceRepository() : super(_UnusedStorage());

  List<MaintenanceEntry> savedEntries = [];

  @override
  List<MaintenanceEntry> loadEntries(String bikeId) => [];

  @override
  Future<void> saveEntries(
    String bikeId,
    List<MaintenanceEntry> entries,
  ) async {
    savedEntries = List<MaintenanceEntry>.from(entries);
  }
}

class _FakeBikeRepository extends BikeRepository {
  _FakeBikeRepository() : super(_UnusedStorage());

  @override
  List<Bike> loadBikes() => [];

  @override
  String? getActiveBikeId() => null;

  @override
  Future<void> saveBikes(List<Bike> bikes) async {}

  @override
  Future<void> setActiveBikeId(String? bikeId) async {}
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository() : super(_UnusedStorage());

  @override
  AppSettings loadSettings() => AppSettings.defaults;

  @override
  Future<void> saveSettings(AppSettings settings) async {}
}
