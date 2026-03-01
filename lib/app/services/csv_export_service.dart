import 'package:intl/intl.dart';

import '../models/fuel_log_entry.dart';

class CsvExportService {
  String buildFuelLogsCsv(List<FuelLogEntry> entries) {
    const headers = [
      'Date',
      'Odometer',
      'Fuel Quantity',
      'Total Cost',
      'Mileage',
      'Fuel Type',
      'Station Name',
      'Notes',
    ];

    final rows = <String>[headers.join(',')];
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    for (final entry in entries) {
      rows.add([
        _escape(formatter.format(entry.date)),
        entry.odometer.toString(),
        entry.fuelQuantity.toString(),
        entry.totalCost.toString(),
        entry.mileage?.toString() ?? '',
        entry.fuelType?.name ?? '',
        _escape(entry.stationName ?? ''),
        _escape(entry.notes ?? ''),
      ].join(','));
    }

    return rows.join('\n');
  }

  String _escape(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
