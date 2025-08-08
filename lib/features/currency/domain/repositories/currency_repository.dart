import '../entities/conversion_result_entity.dart';

abstract class CurrencyRepository {
  Map<String, String> get availableCurrencies;
  
  Future<ConversionResultEntity> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  });
  
  Future<double> getCurrentRate({
    required String fromCurrency,
    required String toCurrency,
  });
  
  bool isRateCached(String fromCurrency, String toCurrency);
  DateTime? getCacheTimestamp(String fromCurrency, String toCurrency);
  void clearCache();
}
