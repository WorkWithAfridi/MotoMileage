import 'dart:io';

import 'package:flutter/material.dart';

import '../localization/localized_text.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../controllers/bike_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/maintenance_controller.dart';
import '../controllers/settings_controller.dart';
import '../data/app_tips_database.dart';
import '../services/backup_service.dart';
import '../services/csv_export_service.dart';
import '../services/demo_data_service.dart';
import '../services/local_storage_service.dart';
import 'fuel_station_report_view.dart';
import 'onboarding_view.dart';
import 'tips_view.dart';
import 'widgets/app_dropdown_form_field.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();
    final bikeController = Get.find<BikeController>();
    final maintenanceController = Get.find<MaintenanceController>();
    final backupService = Get.find<BackupService>();
    final csvService = Get.find<CsvExportService>();
    final demoDataService = Get.find<DemoDataService>();
    final storageService = Get.find<LocalStorageService>();

    return Obx(() {
      final current = controller.settings.value;
      final refillDistanceUnit = _distanceUnitLabel(
        current.defaultDistanceUnit,
      );
      return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      'Preferences',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: current.currencySymbol,
                      decoration: InputDecoration(
                        labelText: 'Currency Symbol'.tx,
                      ),
                      onChanged: (value) {
                        final trimmed = value.trim();
                        if (trimmed.isEmpty) return;
                        controller.updateCurrencySymbol(trimmed);
                      },
                    ),
                    const SizedBox(height: 18),
                    AppDropdownFormField<String>(
                      initialValue: AppTranslations.resolveLocale(
                        current.languageCode,
                        Get.deviceLocale,
                      ).languageCode,
                      decoration: InputDecoration(labelText: 'App Language'.tx),
                      items: [
                        ...AppTranslations.supportedLanguageCodes.map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: TrText(
                              AppTranslations.languageNames[code] ?? code,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        controller.updateLanguageCode(value);
                      },
                    ),
                    const SizedBox(height: 18),
                    AppDropdownFormField<int>(
                      initialValue: current.decimalPrecision,
                      decoration: InputDecoration(
                        labelText: 'Decimal Precision'.tx,
                      ),
                      items: const [0, 1, 2, 3, 4]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: TrText('$value'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateDecimalPrecision(value);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    AppDropdownFormField<DistanceUnit>(
                      initialValue: current.defaultDistanceUnit,
                      decoration: InputDecoration(
                        labelText: 'Default Distance Unit'.tx,
                      ),
                      items: DistanceUnit.values
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: TrText(unit.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateDefaultDistanceUnit(value);
                        }
                      },
                    ),
                    const SizedBox(height: 18),
                    AppDropdownFormField<FuelUnit>(
                      initialValue: current.defaultFuelUnit,
                      decoration: InputDecoration(
                        labelText: 'Default Fuel Unit'.tx,
                      ),
                      items: FuelUnit.values
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: TrText(unit.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateDefaultFuelUnit(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            const _TipsSectionCard(),
            const SizedBox(height: 4),
            const _FuelStationReportSectionCard(),
            const SizedBox(height: 4),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      'Reminders',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: current.refillReminderInterval.toString(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Refill Reminder Interval'.tx,
                        suffixText: refillDistanceUnit,
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          controller.updateRefillReminderInterval(parsed);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      'Learn',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    TrText(
                      'Revisit onboarding walkthrough anytime.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OnboardingView(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.explore_outlined),
                        label: const TrText('Open Onboarding'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      'Theme',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    AppDropdownFormField<AppThemePreset>(
                      initialValue: current.themePreset,
                      decoration: InputDecoration(labelText: 'Color Theme'.tx),
                      items: AppThemePreset.values
                          .map(
                            (preset) => DropdownMenuItem(
                              value: preset,
                              child: TrText(_themePresetLabel(preset)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateThemePreset(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      'Data Management',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    TrText(
                      'Export your data to a file or restore a local backup.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final csv = csvService.buildFuelLogsCsv(
                          fuelController.entries,
                        );
                        final dir = await getTemporaryDirectory();
                        final file = File('${dir.path}/fuel_logs.csv');
                        await file.writeAsString(csv);
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(file.path)],
                            text: 'Moto Mileage fuel logs CSV export'.tx,
                          ),
                        );
                      },
                      icon: const Icon(Icons.ios_share_outlined),
                      label: const TrText('Export Current Bike Logs (CSV)'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final json = backupService.exportBackupJson();
                        final dir = await getTemporaryDirectory();
                        final file = File(
                          '${dir.path}/motomileage_backup.json',
                        );
                        await file.writeAsString(json);
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(file.path)],
                            text: 'Moto Mileage backup JSON'.tx,
                          ),
                        );
                      },
                      icon: const Icon(Icons.backup_outlined),
                      label: const TrText('Backup All Data (JSON)'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final textController = TextEditingController();
                        final restored = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const TrText('Restore Backup'),
                            content: TextField(
                              controller: textController,
                              minLines: 6,
                              maxLines: 10,
                              decoration: InputDecoration(
                                hintText: 'Paste backup JSON'.tx,
                                border: OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const TrText('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const TrText('Restore'),
                              ),
                            ],
                          ),
                        );

                        if (restored != true) {
                          return;
                        }

                        try {
                          await backupService.restoreBackupJson(
                            textController.text,
                          );
                          controller.reload();
                          await bikeController.reload();
                          await fuelController.reloadActiveBike();
                          await maintenanceController.reloadActiveBike();
                          Get.snackbar(
                            'Restored'.tx,
                            'Backup restored successfully.'.tx,
                          );
                        } catch (_) {
                          Get.snackbar(
                            'Error'.tx,
                            'Backup JSON is invalid.'.tx,
                          );
                        }
                      },
                      icon: const Icon(Icons.restore_page_outlined),
                      label: const TrText('Restore From JSON Text'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      'Demo Tools',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () async {
                        final shouldPopulate = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const TrText('Load Demo Data'),
                            content: const TrText(
                              'This will replace your current local data with demo entries. Your current data will be lost forever. Are you sure?',
                            ),
                            actions: [
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const TrText('Replace & Load'),
                              ),
                              SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const TrText('Cancel'),
                              ),
                            ],
                          ),
                        );

                        if (shouldPopulate != true) {
                          return;
                        }

                        await demoDataService.populateDemoData();
                        controller.reload();
                        await bikeController.reload();
                        await fuelController.reloadActiveBike();
                        await maintenanceController.reloadActiveBike();
                        Get.snackbar(
                          'Demo Ready'.tx,
                          'Sample data loaded for testing.'.tx,
                        );
                      },
                      child: const TrText('Load Demo Data'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      'Danger Zone',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onErrorContainer,
                      ),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const TrText('Reset All Data'),
                            content: const TrText(
                              'This will permanently delete all bikes, fuel logs, maintenance logs, and settings from this device.',
                            ),
                            actions: [
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const TrText('Reset'),
                              ),
                              SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const TrText('Cancel'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed != true) {
                          return;
                        }

                        await storageService.clear();
                        controller.reload();
                        await bikeController.reload();
                        await fuelController.reloadActiveBike();
                        await maintenanceController.reloadActiveBike();
                        Get.snackbar(
                          'Data Reset'.tx,
                          'All local app data has been removed.'.tx,
                        );
                      },
                      child: const TrText('Reset All Data'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _themePresetLabel(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.midnightTeal:
        return 'Midnight Teal (Dark)'.tx;
      case AppThemePreset.oceanLight:
        return 'Ocean Light'.tx;
      case AppThemePreset.forestMist:
        return 'Forest Mist'.tx;
      case AppThemePreset.sunsetSand:
        return 'Sunset Sand'.tx;
      case AppThemePreset.royalIndigo:
        return 'Royal Indigo (Dark)'.tx;
      case AppThemePreset.roseBlush:
        return 'Rose Blush'.tx;
      case AppThemePreset.volcanicAsh:
        return 'Volcanic Ash (Dark)'.tx;
      case AppThemePreset.arcticBlue:
        return 'Arctic Blue'.tx;
      case AppThemePreset.emeraldNight:
        return 'Emerald Night (Dark)'.tx;
      case AppThemePreset.citrusPop:
        return 'Citrus Pop'.tx;
      case AppThemePreset.lavenderHaze:
        return 'Lavender Haze'.tx;
      case AppThemePreset.graphiteMono:
        return 'Graphite Mono (Dark)'.tx;
      case AppThemePreset.iconEmberTeal:
        return 'Ember & Teal'.tx;
      case AppThemePreset.iconTealEmber:
        return 'Teal & Ember'.tx;
    }
  }

  String _distanceUnitLabel(DistanceUnit unit) {
    return unit == DistanceUnit.miles ? 'MILES' : 'KM';
  }
}

class _TipsSectionCard extends StatelessWidget {
  const _TipsSectionCard();

  @override
  Widget build(BuildContext context) {
    final totalTips =
        AppTipsDatabase.fuelTips.length +
        AppTipsDatabase.maintenanceTips.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrText('Tips', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            TrText(
              'Browse local fuel and maintenance tip databases.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TrText(
              '$totalTips tips available',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const TipsView()));
                },
                icon: const Icon(Icons.menu_book_outlined),
                label: const TrText('Open Tips'),
              ),
            ),
            const SizedBox(height: 6),
            TrText(
              'Fuel DB: ${AppTipsDatabase.fuelTips.length}  |  Maintenance DB: ${AppTipsDatabase.maintenanceTips.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _FuelStationReportSectionCard extends StatelessWidget {
  const _FuelStationReportSectionCard();

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();
    final stations = fuelController.entries
        .map((entry) => (entry.stationName ?? '').trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrText(
              'Fuel Station Reports',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            TrText(
              'Analyze station-wise fuel usage, spend, and mileage performance.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TrText(
              '${stations.length} stations in current bike logs',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FuelStationReportView(),
                    ),
                  );
                },
                icon: const Icon(Icons.local_gas_station_outlined),
                label: const TrText('Open Fuel Station Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
