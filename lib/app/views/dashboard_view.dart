import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../controllers/bike_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/settings_controller.dart';
import '../data/app_tips_database.dart';
import '../models/fuel_log_entry.dart';
import '../utils/formatters.dart';
import 'fuel_station_report_view.dart';
import 'tips_view.dart';
import 'widgets/summary_card.dart';

const double _dashboardPagePadding = 12;
const double _dashboardSectionSpacing = 12;
const double _dashboardSubsectionSpacing = 12;
const double _chartHeight = 300;
const double _chartCardPadding = 12;
const double _chartAxisNameSize = 18;
const double _lineYAxisReservedSize = 30;
const double _barYAxisReservedSize = 30;
const double _chartXAxisReservedSize = 30;
const double _chartAxisLabelSpace = 6;
const double _chartXLabelTopPadding = 6;
const double _lineChartPixelsPerPoint = 56;
const double _barChartPixelsPerPoint = 68;
const double _pieSectionRadius = 70;
const double _pieCenterSpaceRadius = 42;
const double _pieSectionsSpace = 2;
const double _pieAreaHorizontalPadding = 12;
const double _pieAreaVerticalPadding = 6;
const double _summaryGridSpacing = 4;
const double _summarySingleColumnBreakpoint = 430;
const double _summaryTripleColumnBreakpoint = 900;

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final fuelController = Get.find<FuelController>();
    final bikeController = Get.find<BikeController>();
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      final colorScheme = Theme.of(context).colorScheme;
      final viewportWidth =
          MediaQuery.of(context).size.width - (_dashboardPagePadding * 2);
      final summaryCrossAxisCount =
          viewportWidth >= _summaryTripleColumnBreakpoint
          ? 3
          : viewportWidth < _summarySingleColumnBreakpoint
          ? 1
          : 2;
      final currency = settingsController.settings.value.currencySymbol;
      final precision = settingsController.settings.value.decimalPrecision;
      final activeBike = bikeController.activeBike;
      final distanceUnit = _distanceUnitLabel(activeBike?.distanceUnit);
      final fuelUnit = _fuelUnitLabel(activeBike?.fuelUnit);
      final mileageUnit = '$distanceUnit/$fuelUnit';
      final costPerDistanceUnit = '$currency/$distanceUnit';
      final sortedEntries = [...fuelController.entries]
        ..sort((a, b) => a.date.compareTo(b.date));

      final mileageEntries = sortedEntries
          .where((entry) => (entry.mileage ?? 0) > 0)
          .toList();
      final mileageSpots = List<FlSpot>.generate(
        mileageEntries.length,
        (index) => FlSpot(index.toDouble(), mileageEntries[index].mileage!),
      );

      final quantityEntries = sortedEntries
          .where((entry) => entry.fuelQuantity > 0)
          .toList();
      final quantitySpots = List<FlSpot>.generate(
        quantityEntries.length,
        (index) =>
            FlSpot(index.toDouble(), quantityEntries[index].fuelQuantity),
      );

      final costPerDistanceEntries = sortedEntries
          .where((entry) => (entry.costPerDistance ?? 0) > 0)
          .toList();
      final costPerDistanceSpots = List<FlSpot>.generate(
        costPerDistanceEntries.length,
        (index) => FlSpot(
          index.toDouble(),
          costPerDistanceEntries[index].costPerDistance!,
        ),
      );

      final monthlyExpense = <DateTime, double>{};
      for (final entry in sortedEntries) {
        final month = DateTime(entry.date.year, entry.date.month);
        monthlyExpense[month] = (monthlyExpense[month] ?? 0) + entry.totalCost;
      }
      final expenseMonths = monthlyExpense.keys.toList()..sort();
      final expenseBars = List<BarChartGroupData>.generate(
        expenseMonths.length,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(toY: monthlyExpense[expenseMonths[index]] ?? 0),
          ],
        ),
      );

      final fuelTypeCostMap = <String, double>{};
      for (final entry in sortedEntries) {
        final type = entry.fuelType?.name.toUpperCase() ?? 'UNKNOWN';
        fuelTypeCostMap[type] = (fuelTypeCostMap[type] ?? 0) + entry.totalCost;
      }
      final fuelTypeSections = _fuelTypeSections(
        fuelTypeCostMap: fuelTypeCostMap,
        context: context,
      );
      final fuelTypeLegend = _fuelTypeLegend(fuelTypeCostMap: fuelTypeCostMap);
      final stationSnapshots = _buildStationSnapshots(sortedEntries);
      final tipOfTheDay = _tipOfTheDay();
      final performanceCards = <Widget>[
        SummaryCard(
          title: 'Average Mileage',
          value:
              '${AppFormatters.number(controller.averageMileage, precision: precision)} $mileageUnit',
          onInfoTap: () => _showCardInfo(
            context,
            title: 'Average Mileage',
            description:
                'Average of all valid mileage values from fuel entries after the first one.',
            formula:
                'Mileage per entry = Trip Distance / Fuel Quantity\nAverage Mileage = Sum of valid mileages / Number of valid mileage entries',
          ),
        ),
        SummaryCard(
          title: 'Latest Mileage',
          value:
              '${AppFormatters.number(controller.latestMileage, precision: precision)} $mileageUnit',
          onInfoTap: () => _showCardInfo(
            context,
            title: 'Latest Mileage',
            description:
                'Mileage value from your most recent fuel entry that has a valid trip calculation.',
            formula: 'Latest Mileage = Mileage of most recent valid fuel log',
          ),
        ),
        SummaryCard(
          title: 'Total Distance',
          value:
              '${AppFormatters.number(controller.totalDistance, precision: precision)} $distanceUnit',
        ),
        SummaryCard(
          title: 'Fuel Consumed',
          value:
              '${AppFormatters.number(controller.totalFuelConsumed, precision: precision)} $fuelUnit',
        ),
        SummaryCard(
          title: 'Total Refills',
          value: controller.totalRefills.toString(),
        ),
        SummaryCard(
          title: 'Best / Worst',
          value:
              '${AppFormatters.number(controller.bestMileage, precision: precision)} / ${AppFormatters.number(controller.worstMileage, precision: precision)} $mileageUnit',
        ),
      ];

      final costCards = <Widget>[
        SummaryCard(
          title: 'Fuel Cost',
          value:
              '$currency ${AppFormatters.number(controller.totalFuelCost, precision: precision)}',
        ),
        SummaryCard(
          title: 'This Month',
          value:
              '$currency ${AppFormatters.number(controller.thisMonthExpense, precision: precision)}',
        ),
        SummaryCard(
          title: 'Avg Refill Cost',
          value:
              '$currency ${AppFormatters.number(controller.averageRefillCost, precision: precision)}',
        ),
        SummaryCard(
          title: 'Avg Cost / Distance',
          value:
              '$costPerDistanceUnit ${AppFormatters.number(controller.averageCostPerDistance, precision: precision)}',
          onInfoTap: () => _showCardInfo(
            context,
            title: 'Average Cost per Distance',
            description:
                'Average fuel spending for each distance unit across valid entries.',
            formula:
                'Cost per distance (entry) = Total Cost / Trip Distance\nAverage = Sum of valid cost-per-distance values / Count',
          ),
        ),
        SummaryCard(
          title: 'Last 30 Days',
          value:
              '$currency ${AppFormatters.number(controller.last30DaysExpense, precision: precision)}',
          onInfoTap: () => _showCardInfo(
            context,
            title: 'Last 30 Days Expense',
            description:
                'Total fuel spending from entries in the most recent 30-day window.',
            formula:
                'Last 30 Days Expense = Sum of Total Cost for entries in last 30 days',
          ),
        ),
        SummaryCard(
          title: '30D Change',
          value:
              '${AppFormatters.number(controller.last30DaysExpenseChangePercent, precision: precision)}%',
          subtitle: 'vs previous 30 days',
          onInfoTap: () => _showCardInfo(
            context,
            title: '30-Day Change',
            description:
                'Compares current 30-day fuel expense against the previous 30-day period.',
            formula:
                'Change % = ((Current 30D Expense - Previous 30D Expense) / Previous 30D Expense) x 100',
          ),
        ),
      ];

      final fuelProfileCards = <Widget>[
        SummaryCard(
          title: 'Fuel Consumed',
          value:
              '${AppFormatters.number(controller.totalFuelConsumed, precision: precision)} $fuelUnit',
        ),
        SummaryCard(
          title: 'Avg Trip Distance',
          value:
              '${AppFormatters.number(controller.averageTripDistance, precision: precision)} $distanceUnit',
        ),
      ];

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(_dashboardPagePadding),
          children: [
            if (fuelController.shouldShowRefillReminder)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: colorScheme.tertiaryContainer,
                  child: ListTile(
                    title: Text(
                      'Refill Reminder',
                      style: TextStyle(color: colorScheme.onTertiaryContainer),
                    ),
                    subtitle: Text(
                      'Your refill interval threshold has been crossed.',
                      style: TextStyle(color: colorScheme.onTertiaryContainer),
                    ),
                  ),
                ),
              ),
            _buildSegmentTitle(context, 'Performance'),
            const SizedBox(height: _dashboardSubsectionSpacing),
            _buildSummarySegment(
              crossAxisCount: summaryCrossAxisCount,
              cards: performanceCards,
            ),
            const SizedBox(height: _dashboardSectionSpacing),
            _buildLineChartSection(
              context: context,
              title: 'Mileage Trend',
              spots: mileageSpots,
              sourceEntries: mileageEntries,
              yAxisTitle: 'Mileage',
              minWidth: viewportWidth,
              color: Theme.of(context).colorScheme.primary,
              infoDescription:
                  'Shows mileage per refill over time to highlight efficiency trends.',
              infoFormula:
                  'Mileage per entry = Trip Distance / Fuel Quantity\nEach point = one valid fuel log ordered by date',
            ),
            const SizedBox(height: _dashboardSectionSpacing),
            _buildSegmentTitle(context, 'Cost & Spending'),
            const SizedBox(height: _dashboardSubsectionSpacing),
            _buildSummarySegment(
              crossAxisCount: summaryCrossAxisCount,
              cards: costCards,
            ),
            const SizedBox(height: _dashboardSectionSpacing),
            _buildChartTitleWithInfo(
              context: context,
              title: 'Monthly Expense',
              onInfoTap: () => _showCardInfo(
                context,
                title: 'Monthly Expense',
                description:
                    'Shows how much you spend on fuel each month based on your logged entries.',
                formula:
                    'Monthly Expense = Sum of Total Cost for all entries in that month',
              ),
            ),
            const SizedBox(height: _dashboardSubsectionSpacing),
            SizedBox(
              height: _chartHeight,
              child: Card(
                child: expenseBars.isEmpty
                    ? const Center(child: Text('Not enough data'))
                    : Padding(
                        padding: const EdgeInsets.all(_chartCardPadding),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: _chartWidth(
                              pointCount: expenseBars.length,
                              minWidth: viewportWidth,
                              pixelsPerPoint: _barChartPixelsPerPoint,
                            ),
                            child: BarChart(
                              BarChartData(
                                minY: 0,
                                maxY: _barMaxY(expenseBars),
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: AxisTitles(
                                    axisNameWidget: const Text('Expense'),
                                    axisNameSize: _chartAxisNameSize,
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: _barYAxisReservedSize,
                                      interval: _barInterval(expenseBars),
                                      getTitlesWidget: (value, meta) =>
                                          SideTitleWidget(
                                            meta: meta,
                                            space: _chartAxisLabelSpace,
                                            child: Text(
                                              value.toStringAsFixed(0),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                            ),
                                          ),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    axisNameWidget: const Text('Month'),
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: _chartXAxisReservedSize,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >= expenseMonths.length) {
                                          return const SizedBox.shrink();
                                        }
                                        final label = DateFormat('MMM')
                                            .format(expenseMonths[index])
                                            .toUpperCase();
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: _chartXLabelTopPadding,
                                          ),
                                          child: Text(
                                            label,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
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
            const SizedBox(height: _dashboardSectionSpacing),
            _buildLineChartSection(
              context: context,
              title: 'Cost Per Distance Trend',
              spots: costPerDistanceSpots,
              sourceEntries: costPerDistanceEntries,
              yAxisTitle: 'Cost/Dist',
              minWidth: viewportWidth,
              color: Colors.deepOrange,
              infoDescription:
                  'Shows fuel cost efficiency over time as cost per distance unit.',
              infoFormula:
                  'Cost per distance (entry) = Total Cost / Trip Distance\nEach point = one valid fuel log ordered by date',
            ),
            const SizedBox(height: _dashboardSectionSpacing),
            _buildSegmentTitle(context, 'Fuel Profile'),
            const SizedBox(height: _dashboardSubsectionSpacing),
            _buildSummarySegment(
              crossAxisCount: summaryCrossAxisCount,
              cards: fuelProfileCards,
            ),
            const SizedBox(height: _dashboardSectionSpacing),
            _buildLineChartSection(
              context: context,
              title: 'Fuel Quantity Trend',
              spots: quantitySpots,
              sourceEntries: quantityEntries,
              yAxisTitle: 'Fuel Qty',
              minWidth: viewportWidth,
              color: Colors.teal,
              infoDescription:
                  'Shows how much fuel is filled on each logged refill over time.',
              infoFormula:
                  'Each point = Fuel Quantity value from one fuel entry, ordered by date',
            ),
            const SizedBox(height: _dashboardSectionSpacing),
            _buildChartTitleWithInfo(
              context: context,
              title: 'Fuel Type Cost Split',
              onInfoTap: () => _showCardInfo(
                context,
                title: 'Fuel Type Cost Split',
                description:
                    'Shows the share of total fuel spending by fuel type.',
                formula:
                    'Type Share % = (Total Cost for Fuel Type / Total Fuel Cost) x 100',
              ),
            ),
            const SizedBox(height: _dashboardSubsectionSpacing),
            SizedBox(
              height: _chartHeight,
              child: Card(
                clipBehavior: Clip.hardEdge,
                child: fuelTypeSections.isEmpty
                    ? const Center(child: Text('Not enough data'))
                    : Padding(
                        padding: const EdgeInsets.all(_chartCardPadding),
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: _pieAreaHorizontalPadding,
                                  vertical: _pieAreaVerticalPadding,
                                ),
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: _pieSectionsSpace,
                                    centerSpaceRadius: _pieCenterSpaceRadius,
                                    sections: fuelTypeSections,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: _dashboardSubsectionSpacing),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Wrap(
                                spacing: 10,
                                runSpacing: _dashboardSubsectionSpacing,
                                children: fuelTypeLegend
                                    .map(
                                      (item) => Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: item.value,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: _chartAxisLabelSpace,
                                          ),
                                          Text(item.key),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: _dashboardSectionSpacing),
            Text(
              'Fuel Station Snapshot',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: _dashboardSubsectionSpacing),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FuelStationReportView(),
                  ),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: stationSnapshots.isEmpty
                      ? const Text('No station-based entries yet.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top stations by total spend',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            ...stationSnapshots
                                .take(3)
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.station,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${item.refills} refills',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '$currency ${AppFormatters.number(item.totalCost, precision: precision)}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            Text(
                              'Most used station: ${stationSnapshots.first.station}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: _dashboardSectionSpacing),
            Text(
              'Tip of the Day',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: _dashboardSubsectionSpacing),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TipsView()));
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipOfTheDay.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tipOfTheDay.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummarySegment({
    required int crossAxisCount,
    required List<Widget> cards,
  }) {
    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: _summaryGridSpacing,
      crossAxisSpacing: _summaryGridSpacing,
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  void _showCardInfo(
    BuildContext context, {
    required String title,
    required String description,
    required String formula,
  }) {
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Text(
                'How this metric is derived',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(formula, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildLineChartSection({
    required BuildContext context,
    required String title,
    required List<FlSpot> spots,
    required List<FuelLogEntry> sourceEntries,
    required String yAxisTitle,
    required double minWidth,
    required Color color,
    required String infoDescription,
    required String infoFormula,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChartTitleWithInfo(
          context: context,
          title: title,
          onInfoTap: () => _showCardInfo(
            context,
            title: title,
            description: infoDescription,
            formula: infoFormula,
          ),
        ),
        const SizedBox(height: _dashboardSubsectionSpacing),
        SizedBox(
          height: _chartHeight,
          child: Card(
            child: spots.isEmpty
                ? const Center(child: Text('Not enough data'))
                : Padding(
                    padding: const EdgeInsets.all(_chartCardPadding),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: _chartWidth(
                          pointCount: spots.length,
                          minWidth: minWidth,
                          pixelsPerPoint: _lineChartPixelsPerPoint,
                        ),
                        child: LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: spots.length > 1
                                ? (spots.length - 1).toDouble()
                                : 1,
                            minY: _lineMinY(spots),
                            maxY: _lineMaxY(spots),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                axisNameWidget: Text(yAxisTitle),
                                axisNameSize: _chartAxisNameSize,
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: _lineYAxisReservedSize,
                                  interval: _lineInterval(spots),
                                  getTitlesWidget: (value, meta) =>
                                      SideTitleWidget(
                                        meta: meta,
                                        space: _chartAxisLabelSpace,
                                        child: Text(
                                          value.toStringAsFixed(0),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                        ),
                                      ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                axisNameWidget: const Text('Month'),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: _chartXAxisReservedSize,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final label = _entryMonthLabel(
                                      value: value,
                                      entries: sourceEntries,
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: _chartXLabelTopPadding,
                                      ),
                                      child: Text(
                                        label,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                dotData: const FlDotData(show: false),
                                barWidth: 3,
                                color: color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartTitleWithInfo({
    required BuildContext context,
    required String title,
    required VoidCallback onInfoTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 4),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onInfoTap,
          child: Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              '?',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _entryMonthLabel({
    required double value,
    required List<FuelLogEntry> entries,
  }) {
    final index = value.toInt();
    if (index < 0 ||
        index >= entries.length ||
        (value - index.toDouble()).abs() > 0.01) {
      return '';
    }

    final current = entries[index].date;
    final isFirst = index == 0;
    final isLast = index == entries.length - 1;

    if (isFirst || isLast) {
      return DateFormat('MMM').format(current).toUpperCase();
    }

    final previous = entries[index - 1].date;
    final changedMonth =
        current.month != previous.month || current.year != previous.year;
    if (!changedMonth) {
      return '';
    }

    return DateFormat('MMM').format(current).toUpperCase();
  }

  List<PieChartSectionData> _fuelTypeSections({
    required Map<String, double> fuelTypeCostMap,
    required BuildContext context,
  }) {
    if (fuelTypeCostMap.isEmpty) {
      return [];
    }

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];

    final total = fuelTypeCostMap.values.fold(0.0, (sum, value) => sum + value);
    final entries = fuelTypeCostMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return List<PieChartSectionData>.generate(entries.length, (index) {
      final item = entries[index];
      final percent = total <= 0 ? 0 : (item.value / total) * 100;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: item.value,
        radius: _pieSectionRadius,
        title: '${percent.toStringAsFixed(0)}%',
        titleStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }

  List<MapEntry<String, Color>> _fuelTypeLegend({
    required Map<String, double> fuelTypeCostMap,
  }) {
    if (fuelTypeCostMap.isEmpty) {
      return [];
    }
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];
    final entries = fuelTypeCostMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return List<MapEntry<String, Color>>.generate(
      entries.length,
      (index) => MapEntry(entries[index].key, colors[index % colors.length]),
    );
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
    final max = bars
        .map((group) => group.barRods.first.toY)
        .reduce((a, b) => a > b ? a : b);
    if (max <= 4) return 1;
    return (max / 4).clamp(1, 999999).toDouble();
  }

  double _barMaxY(List<BarChartGroupData> bars) {
    if (bars.isEmpty) return 1;
    final max = bars
        .map((group) => group.barRods.first.toY)
        .reduce((a, b) => a > b ? a : b);
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

  double _chartWidth({
    required int pointCount,
    required double minWidth,
    required double pixelsPerPoint,
  }) {
    if (pointCount <= 1) return minWidth;
    final computed = pointCount * pixelsPerPoint;
    return computed < minWidth ? minWidth : computed;
  }

  String _distanceUnitLabel(DistanceUnit? unit) {
    return unit == DistanceUnit.miles ? 'Miles' : 'KM';
  }

  String _fuelUnitLabel(FuelUnit? unit) {
    return unit == FuelUnit.gallons ? 'Gallons' : 'Liters';
  }

  List<_StationSnapshot> _buildStationSnapshots(List<FuelLogEntry> entries) {
    final grouped = <String, List<FuelLogEntry>>{};
    for (final entry in entries) {
      final station = entry.stationName?.trim() ?? '';
      if (station.isEmpty) continue;
      grouped.putIfAbsent(station, () => <FuelLogEntry>[]).add(entry);
    }

    final rows = grouped.entries.map((group) {
      final logs = group.value;
      return _StationSnapshot(
        station: group.key,
        refills: logs.length,
        totalCost: logs.fold(0.0, (sum, item) => sum + item.totalCost),
      );
    }).toList();

    rows.sort((a, b) => b.totalCost.compareTo(a.totalCost));
    return rows;
  }

  AppTip _tipOfTheDay() {
    final allTips = [
      ...AppTipsDatabase.fuelTips,
      ...AppTipsDatabase.maintenanceTips,
    ];
    if (allTips.isEmpty) {
      return const AppTip(
        title: 'No tips available',
        description: 'Tips database is empty.',
      );
    }

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % allTips.length;
    return allTips[index];
  }
}

class _StationSnapshot {
  const _StationSnapshot({
    required this.station,
    required this.refills,
    required this.totalCost,
  });

  final String station;
  final int refills;
  final double totalCost;
}
