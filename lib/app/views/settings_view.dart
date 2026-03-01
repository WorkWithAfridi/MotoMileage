import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../controllers/bike_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/maintenance_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/backup_service.dart';
import '../services/csv_export_service.dart';
import '../services/demo_data_service.dart';
import '../services/local_storage_service.dart';

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
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: current.currencySymbol,
                    decoration: const InputDecoration(labelText: 'Currency Symbol'),
                    onFieldSubmitted: controller.updateCurrencySymbol,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: current.decimalPrecision,
                    decoration: const InputDecoration(labelText: 'Decimal Precision'),
                    items: const [0, 1, 2, 3, 4]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateDecimalPrecision(value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<DistanceUnit>(
                    initialValue: current.defaultDistanceUnit,
                    decoration:
                        const InputDecoration(labelText: 'Default Distance Unit'),
                    items: DistanceUnit.values
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateDefaultDistanceUnit(value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<FuelUnit>(
                    initialValue: current.defaultFuelUnit,
                    decoration: const InputDecoration(labelText: 'Default Fuel Unit'),
                    items: FuelUnit.values
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateDefaultFuelUnit(value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: current.refillReminderInterval.toString(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Refill Reminder Interval',
                    ),
                    onFieldSubmitted: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        controller.updateRefillReminderInterval(parsed);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AppThemePreset>(
                    initialValue: current.themePreset,
                    decoration: const InputDecoration(labelText: 'Color Theme'),
                    items: AppThemePreset.values
                        .map(
                          (preset) => DropdownMenuItem(
                            value: preset,
                            child: Text(_themePresetLabel(preset)),
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
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () async {
              final csv = csvService.buildFuelLogsCsv(fuelController.entries);
              final dir = await getTemporaryDirectory();
              final file = File('${dir.path}/fuel_logs.csv');
              await file.writeAsString(csv);
              await SharePlus.instance.share(
                ShareParams(
                  files: [XFile(file.path)],
                  text: 'Moto Mileage fuel logs CSV export',
                ),
              );
            },
            child: const Text('Export Current Bike Logs (CSV)'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () async {
              final json = backupService.exportBackupJson();
              final dir = await getTemporaryDirectory();
              final file = File('${dir.path}/motomileage_backup.json');
              await file.writeAsString(json);
              await SharePlus.instance.share(
                ShareParams(
                  files: [XFile(file.path)],
                  text: 'Moto Mileage backup JSON',
                ),
              );
            },
            child: const Text('Backup All Data (JSON)'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () async {
              final textController = TextEditingController();
              final restored = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Restore Backup'),
                  content: TextField(
                    controller: textController,
                    minLines: 6,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Paste backup JSON',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              );

              if (restored != true) {
                return;
              }

              try {
                await backupService.restoreBackupJson(textController.text);
                controller.reload();
                await bikeController.reload();
                await fuelController.reloadActiveBike();
                await maintenanceController.reloadActiveBike();
                Get.snackbar('Restored', 'Backup restored successfully.');
              } catch (_) {
                Get.snackbar('Error', 'Backup JSON is invalid.');
              }
            },
            child: const Text('Restore From JSON Text'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final shouldPopulate = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Load Demo Data'),
                  content: const Text(
                    'This will replace your current local data with demo entries.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Replace & Load'),
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
              Get.snackbar('Demo Ready', 'Sample data loaded for testing.');
            },
            child: const Text('Debug: Load Demo Data'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset All Data'),
                  content: const Text(
                    'This will permanently delete all bikes, fuel logs, maintenance logs, and settings from this device.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Reset'),
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

              Get.snackbar('Data Reset', 'All local app data has been removed.');
            },
            child: const Text('Reset All Data'),
          ),
        ],
      );
    });
  }

  String _themePresetLabel(AppThemePreset preset) {
    switch (preset) {
      case AppThemePreset.midnightTeal:
        return 'Midnight Teal (Dark)';
      case AppThemePreset.oceanLight:
        return 'Ocean Light';
      case AppThemePreset.forestMist:
        return 'Forest Mist';
      case AppThemePreset.sunsetSand:
        return 'Sunset Sand';
      case AppThemePreset.royalIndigo:
        return 'Royal Indigo (Dark)';
      case AppThemePreset.roseBlush:
        return 'Rose Blush';
      case AppThemePreset.volcanicAsh:
        return 'Volcanic Ash (Dark)';
      case AppThemePreset.arcticBlue:
        return 'Arctic Blue';
      case AppThemePreset.emeraldNight:
        return 'Emerald Night (Dark)';
      case AppThemePreset.citrusPop:
        return 'Citrus Pop';
      case AppThemePreset.lavenderHaze:
        return 'Lavender Haze';
      case AppThemePreset.graphiteMono:
        return 'Graphite Mono (Dark)';
      case AppThemePreset.iconEmberTeal:
        return 'Ember & Teal';
      case AppThemePreset.iconTealEmber:
        return 'Teal & Ember';
    }
  }
}
