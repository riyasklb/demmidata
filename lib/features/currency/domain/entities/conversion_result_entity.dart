class ConversionResultEntity {
  final String fromCurrency;
  final String toCurrency;
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;
  final DateTime timestamp;
  final bool isCached;

  const ConversionResultEntity({
    required this.fromCurrency,
    required this.toCurrency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.timestamp,
    required this.isCached,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionResultEntity &&
          runtimeType == other.runtimeType &&
          fromCurrency == other.fromCurrency &&
          toCurrency == other.toCurrency &&
          originalAmount == other.originalAmount &&
          convertedAmount == other.convertedAmount &&
          exchangeRate == other.exchangeRate &&
          timestamp == other.timestamp &&
          isCached == other.isCached;

  @override
  int get hashCode =>
      fromCurrency.hashCode ^
      toCurrency.hashCode ^
      originalAmount.hashCode ^
      convertedAmount.hashCode ^
      exchangeRate.hashCode ^
      timestamp.hashCode ^
      isCached.hashCode;
}
