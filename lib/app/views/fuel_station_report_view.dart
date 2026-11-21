import 'package:flutter/material.dart';

import '../localization/localized_text.dart';
import 'package:get/get.dart';

import '../constants.dart';
import '../controllers/bike_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/fuel_log_entry.dart';
import '../utils/formatters.dart';

class FuelStationReportView extends GetView<FuelController> {
  const FuelStationReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final bikeController = Get.find<BikeController>();
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const TrText('Fuel Station Report'),
        actions: [
          IconButton(
            tooltip: 'How this report works'.tx,
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showReportInfo(context),
          ),
        ],
      ),
      body: Obx(() {
        final bike = bikeController.activeBike;
        final entries = controller.entries;
        final currency = settingsController.settings.value.currencySymbol;
        final precision = settingsController.settings.value.decimalPrecision;
        final fuelUnit = _fuelUnitLabel(bike?.fuelUnit);
        final distanceUnit = _distanceUnitLabel(bike?.distanceUnit);
        final mileageUnit = '$distanceUnit/$fuelUnit';

        if (bike == null) {
          return const Center(
            child: TrText('Select a bike to view station report.'),
          );
        }

        if (entries.isEmpty) {
          return const Center(
            child: TrText('No fuel logs available for station report.'),
          );
        }

        final reportRows = _buildReportRows(entries);
        if (reportRows.isEmpty) {
          return const Center(
            child: TrText('No station names found in fuel entries.'),
          );
        }

        final mostUsed = reportRows.reduce(
          (a, b) => a.refills >= b.refills ? a : b,
        );
        final highestSpend = reportRows.reduce(
          (a, b) => a.totalCost >= b.totalCost ? a : b,
        );
        final bestMileage = reportRows
            .where((item) => item.averageMileage != null)
            .fold<_StationReportRow?>(null, (best, current) {
              if (best == null) return current;
              return (current.averageMileage ?? 0) > (best.averageMileage ?? 0)
                  ? current
                  : best;
            });
        final maxCost = reportRows
            .map((item) => item.totalCost)
            .reduce((a, b) => a > b ? a : b);

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _summaryChip(
                      context,
                      'Stations',
                      reportRows.length.toString(),
                    ),
                    _summaryChip(context, 'Most Used', mostUsed.station),
                    _summaryChip(
                      context,
                      'Highest Spend',
                      highestSpend.station,
                    ),
                    if (bestMileage != null)
                      _summaryChip(
                        context,
                        'Best Avg Mileage',
                        bestMileage.station,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...reportRows.map((row) {
              final spendRatio = maxCost <= 0 ? 0.0 : row.totalCost / maxCost;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrText(
                        row.station,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      TrText(
                        'Last refill: ${AppFormatters.date(row.lastRefill)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(value: spendRatio, minHeight: 7),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _metricChip(
                            context,
                            'Refills',
                            row.refills.toString(),
                          ),
                          _metricChip(
                            context,
                            'Fuel',
                            '${AppFormatters.number(row.totalFuel, precision: precision)} $fuelUnit',
                          ),
                          _metricChip(
                            context,
                            'Cost',
                            '$currency ${AppFormatters.number(row.totalCost, precision: precision)}',
                          ),
                          _metricChip(
                            context,
                            'Avg Price/$fuelUnit',
                            '$currency ${AppFormatters.number(row.averagePricePerUnit, precision: precision)}',
                          ),
                          if (row.totalDistance > 0)
                            _metricChip(
                              context,
                              'Distance',
                              '${AppFormatters.number(row.totalDistance, precision: precision)} $distanceUnit',
                            ),
                          _metricChip(
                            context,
                            'Avg Mileage',
                            row.averageMileage == null
                                ? 'N/A'
                                : '${AppFormatters.number(row.averageMileage!, precision: precision)} $mileageUnit',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  List<_StationReportRow> _buildReportRows(List<FuelLogEntry> entries) {
    final grouped = <String, List<FuelLogEntry>>{};
    for (final entry in entries) {
      final station = entry.stationName?.trim();
      if (station == null || station.isEmpty) {
        continue;
      }
      grouped.putIfAbsent(station, () => <FuelLogEntry>[]).add(entry);
    }

    final rows = grouped.entries.map((group) {
      final logs = group.value..sort((a, b) => a.date.compareTo(b.date));
      final refills = logs.length;
      final totalFuel = logs.fold(0.0, (sum, e) => sum + e.fuelQuantity);
      final totalCost = logs.fold(0.0, (sum, e) => sum + e.totalCost);
      final totalDistance = logs.fold(
        0.0,
        (sum, e) => sum + (e.tripDistance ?? 0),
      );
      final mileageValues = logs
          .where((e) => e.mileage != null && e.mileage! > 0)
          .map((e) => e.mileage!)
          .toList();
      final averageMileage = mileageValues.isEmpty
          ? null
          : mileageValues.reduce((a, b) => a + b) / mileageValues.length;
      final avgPricePerUnit = totalFuel > 0 ? totalCost / totalFuel : 0.0;
      final lastRefill = logs.last.date;

      return _StationReportRow(
        station: group.key,
        refills: refills,
        totalFuel: totalFuel,
        totalCost: totalCost,
        totalDistance: totalDistance,
        averageMileage: averageMileage,
        averagePricePerUnit: avgPricePerUnit,
        lastRefill: lastRefill,
      );
    }).toList();

    rows.sort((a, b) => b.totalCost.compareTo(a.totalCost));
    return rows;
  }

  Widget _summaryChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '${label.tx}: ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: value.tx,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
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
              text: '${label.tx}: ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: value.tx,
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

  String _distanceUnitLabel(DistanceUnit? unit) {
    return unit == DistanceUnit.miles ? 'Miles' : 'KM';
  }

  String _fuelUnitLabel(FuelUnit? unit) {
    return unit == FuelUnit.gallons ? 'Gallons' : 'Liters';
  }

  void _showReportInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrText(
                'How Station Report Is Calculated',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              TrText(
                'Each station groups entries by Station Name from fuel logs of the active bike only.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TrText('Metrics', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              TrText(
                'Refills: Number of entries for that station.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TrText(
                'Fuel: Sum of Fuel Quantity across that station.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TrText(
                'Cost: Sum of Total Cost across that station.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TrText(
                'Avg Price/Unit: Total Cost / Total Fuel.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TrText(
                'Distance: Sum of Trip Distance where available.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TrText(
                'Avg Mileage: Average of valid mileage values for that station.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TrText(
                'Last Refill: Latest date among entries for that station.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              TrText(
                'Stations are sorted by total spend (highest first).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StationReportRow {
  const _StationReportRow({
    required this.station,
    required this.refills,
    required this.totalFuel,
    required this.totalCost,
    required this.totalDistance,
    required this.averageMileage,
    required this.averagePricePerUnit,
    required this.lastRefill,
  });

  final String station;
  final int refills;
  final double totalFuel;
  final double totalCost;
  final double totalDistance;
  final double? averageMileage;
  final double averagePricePerUnit;
  final DateTime lastRefill;
}
