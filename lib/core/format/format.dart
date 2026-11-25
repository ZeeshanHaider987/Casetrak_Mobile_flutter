import 'package:intl/intl.dart';

String formatDate(DateTime value) => DateFormat('d MMM y').format(value);

String formatDateTime(DateTime value) => DateFormat('d MMM y, HH:mm').format(value);

String formatMoney(double amount, String currencyCode) {
  return NumberFormat.simpleCurrency(name: currencyCode).format(amount);
}
