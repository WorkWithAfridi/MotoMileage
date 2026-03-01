import '../constants.dart';
import '../models/bike.dart';
import '../services/local_storage_service.dart';

class BikeRepository {
  BikeRepository(this._storage);

  final LocalStorageService _storage;

  List<Bike> loadBikes() {
    final raw = _storage.getJsonList(StorageKeys.bikes);
    return raw.map(Bike.fromMap).toList();
  }

  Future<void> saveBikes(List<Bike> bikes) {
    final payload = bikes.map((bike) => bike.toMap()).toList();
    return _storage.setJsonList(StorageKeys.bikes, payload);
  }

  String? getActiveBikeId() {
    return _storage.getString(StorageKeys.activeBikeId);
  }

  Future<void> setActiveBikeId(String? bikeId) async {
    if (bikeId == null) {
      await _storage.remove(StorageKeys.activeBikeId);
      return;
    }
    await _storage.setString(StorageKeys.activeBikeId, bikeId);
  }

  Future<void> deleteBikeScopedData(String bikeId) async {
    await _storage.remove(StorageKeys.fuelLogs(bikeId));
    await _storage.remove(StorageKeys.maintenance(bikeId));
  }
}
