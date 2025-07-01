import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMMM dd, yyyy - hh:mm a').format(dateTime);
  }

  // Format only time without date
  static String formatTimeOnly(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Compare accurately with current time
  static bool isOverdue(DateTime? date, DateTime? time) {
    final now = DateTime.now();

    // If have both time and date
    if (time != null) {
      return time.isBefore(now);
    }

    // If only have dete
    if (date != null) {
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      return endOfDay.isBefore(now);
    }

    return false;
  }

  // Helper method to format display time/date
  static String formatDisplayDateTime(DateTime? date, DateTime? time) {
    if (time != null) {
      // If pick time
      if (date != null) {
        // If pick both time and date
        return formatDateTime(time);
      } else {
        // Only pick time
        return formatTimeOnly(time);
      }
    } else if (date != null) {
      // Only pick date
      return formatDate(date);
    }

    return 'No date set';
  }
}
