import '../../domain/entities/conversion_result_entity.dart';

class ConversionResultModel extends ConversionResultEntity {
  const ConversionResultModel({
    required super.fromCurrency,
    required super.toCurrency,
    required super.originalAmount,
    required super.convertedAmount,
    required super.exchangeRate,
    required super.timestamp,
    required super.isCached,
  });

  factory ConversionResultModel.fromApiResponse({
    required String fromCurrency,
    required String toCurrency,
    required double originalAmount,
    required double convertedAmount,
    required double exchangeRate,
    required DateTime timestamp,
    required bool isCached,
  }) {
    return ConversionResultModel(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      originalAmount: originalAmount,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      timestamp: timestamp,
      isCached: isCached,
    );
  }
}
