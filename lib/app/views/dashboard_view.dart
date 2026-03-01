import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/fuel_log_entry.dart';
import '../utils/formatters.dart';
import 'widgets/summary_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      final viewportWidth = MediaQuery.of(context).size.width - 24;
      final currency = settingsController.settings.value.currencySymbol;
      final precision = settingsController.settings.value.decimalPrecision;
      final mileageEntries = fuelController.entries.where((entry) => entry.mileage != null && entry.mileage! > 0).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      final mileageSpots = List<FlSpot>.generate(mileageEntries.length, (index) => FlSpot(index.toDouble(), mileageEntries[index].mileage!));

      final monthlyExpense = <DateTime, double>{};
      for (final entry in fuelController.entries) {
        final month = DateTime(entry.date.year, entry.date.month);
        monthlyExpense[month] = (monthlyExpense[month] ?? 0) + entry.totalCost;
      }
      final expenseMonths = monthlyExpense.keys.toList()..sort();
      final expenseBars = List<BarChartGroupData>.generate(
        expenseMonths.length,
        (index) => BarChartGroupData(
          x: index,
          barRods: [BarChartRodData(toY: monthlyExpense[expenseMonths[index]] ?? 0)],
        ),
      );
      final lineChartWidth = _chartWidth(pointCount: mileageSpots.length, minWidth: viewportWidth, pixelsPerPoint: 56);
      final barChartWidth = _chartWidth(pointCount: expenseBars.length, minWidth: viewportWidth, pixelsPerPoint: 68);
      final lineMinY = _lineMinY(mileageSpots);
      final lineMaxY = _lineMaxY(mileageSpots);

      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (fuelController.shouldShowRefillReminder)
            Card(
              color: Colors.amber.shade100,
              child: const ListTile(title: Text('Refill Reminder'), subtitle: Text('Your refill interval threshold has been crossed.')),
            ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.7,
            children: [
              SummaryCard(
                title: 'Average Mileage',
                value: AppFormatters.number(controller.averageMileage, precision: precision),
              ),
              SummaryCard(
                title: 'Total Distance',
                value: AppFormatters.number(controller.totalDistance, precision: precision),
              ),
              SummaryCard(
                title: 'Fuel Consumed',
                value: AppFormatters.number(controller.totalFuelConsumed, precision: precision),
              ),
              SummaryCard(
                title: 'Fuel Cost',
                value: '$currency ${AppFormatters.number(controller.totalFuelCost, precision: precision)}',
              ),
              SummaryCard(
                title: 'This Month',
                value: '$currency ${AppFormatters.number(controller.thisMonthExpense, precision: precision)}',
              ),
              SummaryCard(
                title: 'Best / Worst',
                value:
                    '${AppFormatters.number(controller.bestMileage, precision: precision)} / ${AppFormatters.number(controller.worstMileage, precision: precision)}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Mileage Trend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: Card(
              child: mileageSpots.isEmpty
                  ? const Center(child: Text('Not enough data'))
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: lineChartWidth,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: mileageSpots.length > 1 ? (mileageSpots.length - 1).toDouble() : 1,
                              minY: lineMinY,
                              maxY: lineMaxY,
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: true),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  axisNameWidget: const Text('Mileage'),
                                  axisNameSize: 18,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 36,
                                    interval: _lineInterval(mileageSpots),
                                    getTitlesWidget: (value, meta) => SideTitleWidget(
                                      meta: meta,
                                      space: 6,
                                      child: Text(value.toStringAsFixed(0), style: Theme.of(context).textTheme.labelSmall),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: const Text('Month'),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final label = _lineMonthLabel(value: value, mileageEntries: mileageEntries);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineBarsData: [LineChartBarData(spots: mileageSpots, isCurved: true, dotData: const FlDotData(show: false), barWidth: 3)],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Monthly Expense', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: Card(
              child: expenseBars.isEmpty
                  ? const Center(child: Text('Not enough data'))
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: barChartWidth,
                          child: BarChart(
                            BarChartData(
                              minY: 0,
                              maxY: _barMaxY(expenseBars),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: true),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  axisNameWidget: const Text('Expense'),
                                  axisNameSize: 18,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 36,
                                    interval: _barInterval(expenseBars),
                                    getTitlesWidget: (value, meta) => SideTitleWidget(
                                      meta: meta,
                                      space: 6,
                                      child: Text(value.toStringAsFixed(0), style: Theme.of(context).textTheme.labelSmall),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: const Text('Month'),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 || index >= expenseMonths.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final label = DateFormat('MMM').format(expenseMonths[index]).toUpperCase();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: expenseBars,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      );
    });
  }

  String _lineMonthLabel({required double value, required List<FuelLogEntry> mileageEntries}) {
    final index = value.toInt();
    if (index < 0 || index >= mileageEntries.length || (value - index.toDouble()).abs() > 0.01) {
      return '';
    }

    final current = mileageEntries[index].date;
    final isFirst = index == 0;
    final isLast = index == mileageEntries.length - 1;

    if (isFirst || isLast) {
      return DateFormat('MMM').format(current).toUpperCase();
    }

    final previous = mileageEntries[index - 1].date;
    final changedMonth = current.month != previous.month || current.year != previous.year;

    if (!changedMonth) {
      return '';
    }

    return DateFormat('MMM').format(current).toUpperCase();
  }

  double _lineInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final values = spots.map((spot) => spot.y).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    if (range <= 2) return 1;
    return (range / 4).clamp(1, 999999).toDouble();
  }

  double _barInterval(List<BarChartGroupData> bars) {
    if (bars.isEmpty) return 1;
    final max = bars.map((group) => group.barRods.first.toY).reduce((a, b) => a > b ? a : b);
    if (max <= 4) return 1;
    return (max / 4).clamp(1, 999999).toDouble();
  }

  double _barMaxY(List<BarChartGroupData> bars) {
    if (bars.isEmpty) return 1;
    final max = bars.map((group) => group.barRods.first.toY).reduce((a, b) => a > b ? a : b);
    if (max <= 0) return 1;
    return max * 1.15;
  }

  double _lineMinY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    final min = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final max = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs();
    final padding = range == 0 ? (min.abs() * 0.1).clamp(1, 10) : range * 0.15;
    final value = min - padding;
    return value < 0 ? 0 : value;
  }

  double _lineMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    final min = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final max = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs();
    final padding = range == 0 ? (max.abs() * 0.1).clamp(1, 10) : range * 0.15;
    return max + padding;
  }

  double _chartWidth({required int pointCount, required double minWidth, required double pixelsPerPoint}) {
    if (pointCount <= 1) return minWidth;
    final computed = pointCount * pixelsPerPoint;
    return computed < minWidth ? minWidth : computed;
  }
}
