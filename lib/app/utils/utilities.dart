import 'package:intl/intl.dart';

class Utilities {
  Utilities._();

  static String formatTime(String dateTime) {
    DateTime date = DateTime.parse(dateTime);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }
}
