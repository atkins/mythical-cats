import 'package:intl/intl.dart';

/// Utility for formatting large numbers in abbreviated form
class NumberFormatter {
  static final _suffixes = [
    '', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No', 'Dc'
  ];

  /// Format number with abbreviations (1.5K, 2.3M, etc.)
  static String format(double value, {int decimalPlaces = 1}) {
    if (value < 1000) {
      // For small numbers, only show decimal if it's not a whole number
      if (value == value.floor()) {
        return value.floor().toString();
      }
      return value.toStringAsFixed(1);
    }

    int magnitude = 0;
    double reduced = value;

    while (reduced >= 1000 && magnitude < _suffixes.length - 1) {
      reduced /= 1000;
      magnitude++;
    }

    return '${reduced.toStringAsFixed(decimalPlaces)}${_suffixes[magnitude]}';
  }

  /// Format number with commas (1,234,567)
  static String formatWithCommas(double value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value.floor());
  }

  /// Format as per-second rate
  static String formatRate(double value) {
    return '${format(value)}/sec';
  }
}
