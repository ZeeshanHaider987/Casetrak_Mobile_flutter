/// Seeded `forex_rate` table. Amounts in different currencies are converted
/// through this table before they are added.
class ForexTable {
  ForexTable(this.perGbp);

  /// Units of each currency per 1 GBP.
  final Map<String, double> perGbp;

  factory ForexTable.seeded() {
    return ForexTable(const {
      'GBP': 1,
      'USD': 1.27,
      'EUR': 1.16,
      'AED': 4.65,
    });
  }

  double convert(double amount, String from, String to) {
    if (from == to) return amount;
    final fromPerGbp = perGbp[from];
    final toPerGbp = perGbp[to];
    if (fromPerGbp == null || toPerGbp == null) {
      throw StateError('Missing forex_rate for $from or $to');
    }
    final inGbp = amount / fromPerGbp;
    return inGbp * toPerGbp;
  }
}

class Money {
  const Money(this.amount, this.currencyCode);

  final double amount;
  final String currencyCode;
}

/// Sums [amounts] in [targetCurrency]. A single currency is added directly.
/// Mixed currencies are converted with [forex] first.
({double total, bool converted}) sumMoney(
  List<Money> amounts, {
  required String targetCurrency,
  required ForexTable forex,
}) {
  if (amounts.isEmpty) return (total: 0, converted: false);
  final converted = amounts.any((item) => item.currencyCode != targetCurrency);
  var total = 0.0;
  for (final item in amounts) {
    total += converted
        ? forex.convert(item.amount, item.currencyCode, targetCurrency)
        : item.amount;
  }
  return (total: total, converted: converted);
}
