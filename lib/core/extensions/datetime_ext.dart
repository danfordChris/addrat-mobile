import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  static final _displayFormat = DateFormat('dd MMM yyyy');
  static final _dueDateFormat = DateFormat('dd MMM yyyy');

  String toDisplayDate() => _displayFormat.format(this);

  String toDueDate() => 'Due ${_dueDateFormat.format(this)}';

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  int daysUntil() => difference(DateTime.now()).inDays;
}
