import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: r'$');
final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

String formatCurrency(num? value) => _currencyFormat.format((value ?? 0).toDouble());

String formatDate(String? isoString) {
  if (isoString == null) return '-';
  try {
    return _dateTimeFormat.format(DateTime.parse(isoString).toLocal());
  } catch (_) {
    return isoString;
  }
}
