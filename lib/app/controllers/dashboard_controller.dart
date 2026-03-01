import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../models/fuel_log_entry.dart';
import 'fuel_controller.dart';

class DashboardController extends GetxController {
  DashboardController(this._fuelController);

  final FuelController _fuelController;

  List<FuelLogEntry> get _entries => _fuelController.entries;

  double get averageMileage {
    final values = _entries
        .map((entry) => entry.mileage)
        .whereType<double>()
        .where((value) => value > 0)
        .toList();

    if (values.isEmpty) {
      return 0;
    }

    final total = values.fold(0.0, (sum, value) => sum + value);
    return total / values.length;
  }

  double get totalDistance {
    final values = _entries
        .map((entry) => entry.tripDistance)
        .whereType<double>()
        .where((value) => value > 0)
        .toList();
    return values.fold(0.0, (sum, value) => sum + value);
  }

  double get totalFuelConsumed {
    return _entries.fold(0.0, (sum, entry) => sum + entry.fuelQuantity);
  }

  double get totalFuelCost {
    return _entries.fold(0.0, (sum, entry) => sum + entry.totalCost);
  }

  double get thisMonthExpense => _fuelController.thisMonthExpense;

  int get totalRefills => _entries.length;

  double get averageRefillCost {
    if (_entries.isEmpty) {
      return 0;
    }
    return totalFuelCost / _entries.length;
  }

  double get averageTripDistance {
    final values = _entries
        .map((entry) => entry.tripDistance)
        .whereType<double>()
        .where((value) => value > 0)
        .toList();
    if (values.isEmpty) {
      return 0;
    }
    return values.fold(0.0, (sum, value) => sum + value) / values.length;
  }

  double get averageCostPerDistance {
    final values = _entries
        .map((entry) => entry.costPerDistance)
        .whereType<double>()
        .where((value) => value > 0)
        .toList();
    if (values.isEmpty) {
      return 0;
    }
    return values.fold(0.0, (sum, value) => sum + value) / values.length;
  }

  double get latestMileage {
    final latest = [..._entries]
      ..sort((a, b) => b.date.compareTo(a.date));
    return latest.firstWhereOrNull((entry) => (entry.mileage ?? 0) > 0)?.mileage ??
        0;
  }

  double get last30DaysExpense {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    return _entries
        .where((entry) => entry.date.isAfter(from))
        .fold(0.0, (sum, entry) => sum + entry.totalCost);
  }

  double get previous30DaysExpense {
    final now = DateTime.now();
    final recentFrom = now.subtract(const Duration(days: 30));
    final olderFrom = now.subtract(const Duration(days: 60));
    return _entries
        .where(
          (entry) => entry.date.isAfter(olderFrom) && entry.date.isBefore(recentFrom),
        )
        .fold(0.0, (sum, entry) => sum + entry.totalCost);
  }

  double get last30DaysExpenseChangePercent {
    final previous = previous30DaysExpense;
    if (previous <= 0) {
      return 0;
    }
    return ((last30DaysExpense - previous) / previous) * 100;
  }

  double get bestMileage {
    final values = _entries
        .map((entry) => entry.mileage)
        .whereType<double>()
        .where((value) => value > 0)
        .toList();

    if (values.isEmpty) {
      return 0;
    }

    return values.reduce((a, b) => a > b ? a : b);
  }

  double get worstMileage {
    final values = _entries
        .map((entry) => entry.mileage)
        .whereType<double>()
        .where((value) => value > 0)
        .toList();

    if (values.isEmpty) {
      return 0;
    }

    return values.reduce((a, b) => a < b ? a : b);
  }

  List<FlSpot> mileageTrendSpots() {
    final mileageEntries = _entries
        .where((entry) => entry.mileage != null && entry.mileage! > 0)
        .toList();

    return List<FlSpot>.generate(
      mileageEntries.length,
      (index) => FlSpot(index.toDouble(), mileageEntries[index].mileage!),
    );
  }

  List<BarChartGroupData> monthlyExpenseBars() {
    final grouped = <int, double>{};

    for (final entry in _entries) {
      final key = (entry.date.year * 100) + entry.date.month;
      grouped[key] = (grouped[key] ?? 0) + entry.totalCost;
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return List<BarChartGroupData>.generate(sortedKeys.length, (index) {
      final key = sortedKeys[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: grouped[key] ?? 0),
        ],
      );
    });
  }
}
