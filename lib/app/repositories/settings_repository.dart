import '../constants.dart';
import '../models/app_settings.dart';
import '../services/local_storage_service.dart';

class SettingsRepository {
  SettingsRepository(this._storage);

  final LocalStorageService _storage;

  AppSettings loadSettings() {
    final raw = _storage.getJsonMap(StorageKeys.settings);
    if (raw == null) {
      return AppSettings.defaults;
    }
    return AppSettings.fromMap(raw);
  }

  Future<void> saveSettings(AppSettings settings) {
    return _storage.setJsonMap(StorageKeys.settings, settings.toMap());
  }
}
