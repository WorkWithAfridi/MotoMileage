import '../constants.dart';
import '../models/maintenance_entry.dart';
import '../services/local_storage_service.dart';

class MaintenanceRepository {
  MaintenanceRepository(this._storage);

  final LocalStorageService _storage;

  List<MaintenanceEntry> loadEntries(String bikeId) {
    final raw = _storage.getJsonList(StorageKeys.maintenance(bikeId));
    return raw.map(MaintenanceEntry.fromMap).toList();
  }

  Future<void> saveEntries(String bikeId, List<MaintenanceEntry> entries) {
    final payload = entries.map((entry) => entry.toMap()).toList();
    return _storage.setJsonList(StorageKeys.maintenance(bikeId), payload);
  }
}
