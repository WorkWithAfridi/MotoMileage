import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../controllers/bike_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/formatters.dart';
import 'widgets/fuel_entry_form_sheet.dart';

class FuelLogsView extends GetView<FuelController> {
  const FuelLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final bikeController = Get.find<BikeController>();

    return Obx(() {
      final entries = controller.entriesNewestFirst;
      final currency = settings.settings.value.currencySymbol;
      final precision = settings.settings.value.decimalPrecision;
      final bike = bikeController.activeBike;
      final distanceUnit = _distanceUnitLabel(bike?.distanceUnit);
      final fuelUnit = _fuelUnitLabel(bike?.fuelUnit);
      final mileageUnit = '$distanceUnit/$fuelUnit';
      final costPerDistanceUnit = '$currency/$distanceUnit';

      if (entries.isEmpty) {
        return const Center(child: Text('No fuel entries yet.'));
      }

      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4 ),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 220 + (index * 20).clamp(0, 160)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 12 * (1 - value)), child: child),
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(AppFormatters.date(entry.date), style: Theme.of(context).textTheme.titleMedium)),
                        PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          offset: const Offset(0, 4),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await showModalBottomSheet<void>(
                                context: context,
                                showDragHandle: true,
                                isScrollControlled: true,
                                builder: (_) => FuelEntryFormSheet(entry: entry),
                              );
                            } else if (value == 'delete') {
                              await controller.deleteEntry(entry.id);
                            }
                          },
                          itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Odometer: ${AppFormatters.number(entry.odometer, precision: precision)} $distanceUnit',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _metricChip(context, 'Fuel', '${AppFormatters.number(entry.fuelQuantity, precision: precision)} $fuelUnit'),
                        _metricChip(context, 'Cost', '$currency ${AppFormatters.number(entry.totalCost, precision: precision)}'),
                        _metricChip(
                          context,
                          'Mileage',
                          entry.mileage == null ? 'N/A' : '${AppFormatters.number(entry.mileage!, precision: precision)} $mileageUnit',
                        ),
                        _metricChip(
                          context,
                          'Trip',
                          entry.tripDistance == null ? 'N/A' : '${AppFormatters.number(entry.tripDistance!, precision: precision)} $distanceUnit',
                        ),
                        if (entry.pricePerUnit != null)
                          _metricChip(context, 'Price/$fuelUnit', '$currency ${AppFormatters.number(entry.pricePerUnit!, precision: precision)}'),
                        if (entry.costPerDistance != null)
                          _metricChip(
                            context,
                            'Cost/$distanceUnit',
                            '${AppFormatters.number(entry.costPerDistance!, precision: precision)} $costPerDistanceUnit',
                          ),
                      ],
                    ),
                    if (entry.fuelType != null || (entry.stationName?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 10),
                      Text(
                        [
                          if (entry.fuelType != null) 'Type: ${entry.fuelType!.name.toUpperCase()}',
                          if (entry.stationName?.isNotEmpty ?? false) 'Station: ${entry.stationName}',
                        ].join('  |  '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (entry.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 6),
                      Text('Note: ${entry.notes}', maxLines: 3, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _metricChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            TextSpan(
              text: value,
              style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  String _distanceUnitLabel(DistanceUnit? unit) {
    return unit == DistanceUnit.miles ? 'Miles' : 'KM';
  }

  String _fuelUnitLabel(FuelUnit? unit) {
    return unit == FuelUnit.gallons ? 'Gallons' : 'Liters';
  }
}
