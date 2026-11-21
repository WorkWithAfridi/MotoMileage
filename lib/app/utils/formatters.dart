import 'package:intl/intl.dart';
import 'package:get/get.dart';

class AppFormatters {
  static String number(double value, {int precision = 2}) {
    return NumberFormat.decimalPattern(
      Get.locale?.toLanguageTag(),
    ).format(double.parse(value.toStringAsFixed(precision)));
  }

  static String date(DateTime value) {
    return DateFormat.yMMMd(Get.locale?.toLanguageTag()).format(value);
  }
}
