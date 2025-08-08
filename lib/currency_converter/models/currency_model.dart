class CurrencyModel {
  final String fromCurrency;
  final String toCurrency;
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;
  final DateTime timestamp;
  final bool isCached;
  final bool isStale;

  const CurrencyModel({
    required this.fromCurrency,
    required this.toCurrency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.timestamp,
    required this.isCached,
    this.isStale = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyModel &&
          runtimeType == other.runtimeType &&
          fromCurrency == other.fromCurrency &&
          toCurrency == other.toCurrency &&
          originalAmount == other.originalAmount &&
          convertedAmount == other.convertedAmount &&
          exchangeRate == other.exchangeRate &&
          timestamp == other.timestamp &&
          isCached == other.isCached &&
          isStale == other.isStale;

  @override
  int get hashCode =>
      fromCurrency.hashCode ^
      toCurrency.hashCode ^
      originalAmount.hashCode ^
      convertedAmount.hashCode ^
      exchangeRate.hashCode ^
      timestamp.hashCode ^
      isCached.hashCode ^
      isStale.hashCode;
}
