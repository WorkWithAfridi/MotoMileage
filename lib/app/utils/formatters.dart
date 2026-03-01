import 'package:intl/intl.dart';

class AppFormatters {
  static String number(double value, {int precision = 2}) {
    return NumberFormat.decimalPattern().format(
      double.parse(value.toStringAsFixed(precision)),
    );
  }

  static String date(DateTime value) {
    return DateFormat('dd MMM yyyy').format(value);
  }
}
