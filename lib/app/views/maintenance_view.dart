import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../controllers/bike_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/maintenance_controller.dart';
import '../utils/formatters.dart';

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();
    final bikeController = Get.find<BikeController>();

    return Obx(() {
      final colorScheme = Theme.of(context).colorScheme;
      final entries = controller.entries;
      final sortedFuel = fuelController.entriesNewestFirst;
      final latestOdometer = sortedFuel.isEmpty ? 0.0 : sortedFuel.first.odometer;
      final distanceUnit =
          bikeController.activeBike?.distanceUnit == DistanceUnit.miles ? 'Miles' : 'KM';
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.customType ?? entry.type.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.deleteEntry(entry.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.date(entry.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _metricChip(
                          context,
                          'Odometer',
                          '${AppFormatters.number(entry.odometer)} $distanceUnit',
                        ),
                        _metricChip(
                          context,
                          'Next Due',
                          entry.nextDueOdometer == null
                              ? 'N/A'
                              : '${AppFormatters.number(entry.nextDueOdometer!)} $distanceUnit',
                        ),
                        if (entry.nextDueOdometer != null)
                          _metricChip(
                            context,
                            'Status',
                            latestOdometer >= entry.nextDueOdometer!
                                ? 'Due'
                                : '${AppFormatters.number(entry.nextDueOdometer! - latestOdometer)} $distanceUnit left',
                          ),
                      ],
                    ),
                    if (entry.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Note: ${entry.notes}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _metricChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
