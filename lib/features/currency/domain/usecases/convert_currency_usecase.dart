import '../entities/conversion_result_entity.dart';
import '../repositories/currency_repository.dart';

class ConvertCurrencyUseCase {
  final CurrencyRepository repository;

  ConvertCurrencyUseCase(this.repository);

  Future<ConversionResultEntity> call({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    return await repository.convertCurrency(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
    );
  }
}
