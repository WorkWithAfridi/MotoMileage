import '../constants.dart';
import '../models/fuel_log_entry.dart';
import '../services/local_storage_service.dart';

class FuelRepository {
  FuelRepository(this._storage);

  final LocalStorageService _storage;

  List<FuelLogEntry> loadFuelLogs(String bikeId) {
    final raw = _storage.getJsonList(StorageKeys.fuelLogs(bikeId));
    return raw.map(FuelLogEntry.fromMap).toList();
  }

  Future<void> saveFuelLogs(String bikeId, List<FuelLogEntry> entries) {
    final payload = entries.map((entry) => entry.toMap()).toList();
    return _storage.setJsonList(StorageKeys.fuelLogs(bikeId), payload);
  }
}
