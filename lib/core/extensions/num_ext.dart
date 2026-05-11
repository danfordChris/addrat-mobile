import 'package:intl/intl.dart';

extension NumExt on num {
  static final _tzsFormat =
      NumberFormat.currency(locale: 'en_TZ', symbol: 'TZS ', decimalDigits: 0);

  String toTZS() => _tzsFormat.format(this);

  String toTZSCompact() {
    if (abs() >= 1000000000) {
      return 'TZS ${(this / 1000000000).toStringAsFixed(1)}B';
    }
    if (abs() >= 1000000) {
      return 'TZS ${(this / 1000000).toStringAsFixed(1)}M';
    }
    if (abs() >= 1000) {
      return 'TZS ${(this / 1000).toStringAsFixed(1)}K';
    }
    return toTZS();
  }

  String toPercent({int decimals = 0}) =>
      '${(this * 100).toStringAsFixed(decimals)}%';
}
