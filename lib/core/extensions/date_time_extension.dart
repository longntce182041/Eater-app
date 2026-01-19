import 'package:intl/intl.dart';

/// Extension methods for DateTime objects.
extension DateTimeExtension on DateTime {
  /// Formats date as 'yyyy-MM-dd'.
  String toDateString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Formats date as 'MMM dd, yyyy'.
  String toDisplayString() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Formats date and time as 'MMM dd, yyyy HH:mm'.
  String toDisplayDateTimeString() {
    return DateFormat('MMM dd, yyyy HH:mm').format(this);
  }

  /// Formats time as 'HH:mm'.
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// Returns true if the date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if the date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if the date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Returns the start of the day (00:00:00).
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Returns the end of the day (23:59:59).
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Returns the start of the week (Monday).
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// Returns the end of the week (Sunday).
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }
}
