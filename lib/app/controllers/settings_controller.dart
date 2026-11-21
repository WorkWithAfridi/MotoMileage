import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  final Rx<AppSettings> settings = AppSettings.defaults.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() {
    settings.value = _repository.loadSettings();
  }

  Future<void> updateSettings(AppSettings next) async {
    settings.value = next;
    await _repository.saveSettings(next);
  }

  Future<void> updateCurrencySymbol(String symbol) {
    return updateSettings(settings.value.copyWith(currencySymbol: symbol));
  }

  Future<void> updateDecimalPrecision(int precision) {
    return updateSettings(settings.value.copyWith(decimalPrecision: precision));
  }

  Future<void> updateDefaultDistanceUnit(DistanceUnit unit) {
    return updateSettings(settings.value.copyWith(defaultDistanceUnit: unit));
  }

  Future<void> updateDefaultFuelUnit(FuelUnit unit) {
    return updateSettings(settings.value.copyWith(defaultFuelUnit: unit));
  }

  Future<void> updateRefillReminderInterval(double interval) {
    return updateSettings(
      settings.value.copyWith(refillReminderInterval: interval),
    );
  }

  Future<void> updateThemePreset(AppThemePreset preset) {
    return updateSettings(settings.value.copyWith(themePreset: preset));
  }

  Future<void> updateLanguageCode(String languageCode) async {
    await updateSettings(settings.value.copyWith(languageCode: languageCode));
    await Get.updateLocale(Locale(languageCode));
  }
}
