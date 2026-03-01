import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/fuel_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/formatters.dart';
import 'widgets/fuel_entry_form_sheet.dart';

class FuelLogsView extends GetView<FuelController> {
  const FuelLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final entries = controller.entries;
      final currency = settings.settings.value.currencySymbol;
      final precision = settings.settings.value.decimalPrecision;

      if (entries.isEmpty) {
        return const Center(child: Text('No fuel entries yet.'));
      }

      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Card(
            child: ListTile(
              title: Text(
                'Odo ${AppFormatters.number(entry.odometer, precision: precision)} | $currency ${AppFormatters.number(entry.totalCost, precision: precision)}',
              ),
              subtitle: Text(
                '${AppFormatters.date(entry.date)}\nMileage: ${entry.mileage == null ? 'N/A' : AppFormatters.number(entry.mileage!, precision: precision)}',
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => FuelEntryFormSheet(entry: entry),
                    );
                  } else if (value == 'delete') {
                    await controller.deleteEntry(entry.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
