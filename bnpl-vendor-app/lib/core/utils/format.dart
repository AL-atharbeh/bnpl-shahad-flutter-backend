import 'package:intl/intl.dart';

double toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}') ?? 0;
}

int toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? 0;
}

/// Reads a field that the backend sends as either camelCase or snake_case.
dynamic pick(Map<String, dynamic> map, String camel, [String? snake]) =>
    map[camel] ?? (snake == null ? null : map[snake]);

final _money = NumberFormat('#,##0.##', 'en_US');
final _money2 = NumberFormat('#,##0.00', 'en_US');

String money(num value, String currency, {bool fixed = false}) =>
    '${(fixed ? _money2 : _money).format(value)} $currency';

String number(num value) => _money.format(value);

DateTime? parseDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

String shortDate(DateTime? date, String locale) =>
    date == null ? '—' : DateFormat('d MMM yyyy', locale).format(date);

String dateTime(DateTime? date, String locale) =>
    date == null ? '—' : DateFormat('d MMM yyyy, HH:mm', locale).format(date);

String time(DateTime? date) =>
    date == null ? '' : DateFormat('HH:mm').format(date);

/// Local Jordanian numbers (07…) become 9627…, the format the backend stores.
String normalizePhone(String raw) {
  var phone = raw.trim().replaceAll(RegExp(r'[\s-]'), '');
  if (phone.startsWith('07')) phone = '962${phone.substring(1)}';
  return phone;
}
