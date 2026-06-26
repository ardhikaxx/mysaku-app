import '../utils/currency_formatter.dart';

extension CurrencyExtension on num {
  String get toIDR => CurrencyFormatter.format(toDouble());
  String get toCompactIDR => CurrencyFormatter.formatCompact(toDouble());
}
