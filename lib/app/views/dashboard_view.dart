import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/formatters.dart';
import 'widgets/summary_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      final currency = settingsController.settings.value.currencySymbol;
      final precision = settingsController.settings.value.decimalPrecision;
      final mileageSpots = controller.mileageTrendSpots();
      final expenseBars = controller.monthlyExpenseBars();

      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (fuelController.shouldShowRefillReminder)
            Card(
              color: Colors.amber.shade100,
              child: const ListTile(
                title: Text('Refill Reminder'),
                subtitle: Text('Your refill interval threshold has been crossed.'),
              ),
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
                value: AppFormatters.number(
                  controller.averageMileage,
                  precision: precision,
                ),
              ),
              SummaryCard(
                title: 'Total Distance',
                value: AppFormatters.number(
                  controller.totalDistance,
                  precision: precision,
                ),
              ),
              SummaryCard(
                title: 'Fuel Consumed',
                value: AppFormatters.number(
                  controller.totalFuelConsumed,
                  precision: precision,
                ),
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
            height: 200,
            child: Card(
              child: mileageSpots.isEmpty
                  ? const Center(child: Text('Not enough data'))
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: true),
                          titlesData: const FlTitlesData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: mileageSpots,
                              isCurved: true,
                              dotData: const FlDotData(show: false),
                              barWidth: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Monthly Expense', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Card(
              child: expenseBars.isEmpty
                  ? const Center(child: Text('Not enough data'))
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: true),
                          titlesData: const FlTitlesData(show: false),
                          barGroups: expenseBars,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      );
    });
  }
}
