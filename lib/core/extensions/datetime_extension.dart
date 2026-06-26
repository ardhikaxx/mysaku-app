import '../utils/date_formatter.dart';

extension DateTimeExtension on DateTime {
  String get toFullDate => DateFormatter.full(this);
  String get toShortDate => DateFormatter.short(this);
  String get toTime => DateFormatter.time(this);
  String get toRelative => DateFormatter.relative(this);
}
