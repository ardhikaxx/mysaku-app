import 'package:intl/intl.dart';

class DateFormatter {
  static final _full = DateFormat('dd MMMM yyyy', 'id_ID');
  static final _short = DateFormat('dd MMM yyyy', 'id_ID');
  static final _time = DateFormat('HH:mm', 'id_ID');

  static String full(DateTime date) => _full.format(date);
  static String short(DateTime date) => _short.format(date);
  static String time(DateTime date) => _time.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays <= 7 && diff.inDays > 1) return '${diff.inDays} hari lalu';
    return short(date);
  }
}
