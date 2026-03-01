import 'dart:convert';

import '../constants.dart';
import '../models/bike.dart';
import '../services/local_storage_service.dart';

class BackupService {
  BackupService(this._storage);

  final LocalStorageService _storage;

  String exportBackupJson() {
    final bikesRaw = _storage.getJsonList(StorageKeys.bikes);
    final bikes = bikesRaw.map(Bike.fromMap).toList();

    final payload = <String, dynamic>{
      StorageKeys.bikes: bikesRaw,
      StorageKeys.activeBikeId: _storage.getString(StorageKeys.activeBikeId),
      StorageKeys.settings: _storage.getJsonMap(StorageKeys.settings),
      'fuelLogs': <String, dynamic>{},
      'maintenance': <String, dynamic>{},
    };

    for (final bike in bikes) {
      payload['fuelLogs'][bike.id] = _storage.getJsonList(StorageKeys.fuelLogs(bike.id));
      payload['maintenance'][bike.id] =
          _storage.getJsonList(StorageKeys.maintenance(bike.id));
    }

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> restoreBackupJson(String jsonContent) async {
    final decoded = jsonDecode(jsonContent);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup file format.');
    }

    await _storage.clear();

    final bikesRaw = (decoded[StorageKeys.bikes] as List?)
            ?.whereType<Map>()
            .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
            .toList() ??
        <Map<String, dynamic>>[];
    await _storage.setJsonList(StorageKeys.bikes, bikesRaw);

    final activeBikeId = decoded[StorageKeys.activeBikeId] as String?;
    if (activeBikeId != null) {
      await _storage.setString(StorageKeys.activeBikeId, activeBikeId);
    }

    final settings = decoded[StorageKeys.settings];
    if (settings is Map<String, dynamic>) {
      await _storage.setJsonMap(StorageKeys.settings, settings);
    }

    final fuelLogs = decoded['fuelLogs'];
    if (fuelLogs is Map<String, dynamic>) {
      for (final entry in fuelLogs.entries) {
        final logs = (entry.value as List?)
                ?.whereType<Map>()
                .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
                .toList() ??
            <Map<String, dynamic>>[];
        await _storage.setJsonList(StorageKeys.fuelLogs(entry.key), logs);
      }
    }

    final maintenance = decoded['maintenance'];
    if (maintenance is Map<String, dynamic>) {
      for (final entry in maintenance.entries) {
        final logs = (entry.value as List?)
                ?.whereType<Map>()
                .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
                .toList() ??
            <Map<String, dynamic>>[];
        await _storage.setJsonList(StorageKeys.maintenance(entry.key), logs);
      }
    }
  }
}
