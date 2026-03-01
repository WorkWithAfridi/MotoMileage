import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/fuel_controller.dart';
import '../controllers/maintenance_controller.dart';
import '../utils/formatters.dart';

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();

    return Obx(() {
      final colorScheme = Theme.of(context).colorScheme;
      final entries = controller.entries;
      final latestOdometer =
          fuelController.entries.isEmpty ? 0.0 : fuelController.entries.last.odometer;
      final due = controller.dueEntries(latestOdometer);

      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (due.isNotEmpty)
            Card(
              color: colorScheme.tertiaryContainer,
              child: ListTile(
                title: Text(
                  '${due.length} maintenance reminder(s)',
                  style: TextStyle(color: colorScheme.onTertiaryContainer),
                ),
                subtitle: Text(
                  'Your bike has crossed next due odometer.',
                  style: TextStyle(color: colorScheme.onTertiaryContainer),
                ),
              ),
            ),
          if (entries.isEmpty)
            const Card(
              child: ListTile(title: Text('No maintenance entries yet.')),
            ),
          ...entries.map(
            (entry) => Card(
              child: ListTile(
                title: Text(entry.customType ?? entry.type.name),
                subtitle: Text(
                  '${AppFormatters.date(entry.date)}\nOdometer: ${entry.odometer} | Next Due: ${entry.nextDueOdometer?.toString() ?? 'N/A'}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => controller.deleteEntry(entry.id),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
