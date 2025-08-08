import '../repositories/currency_repository.dart';

class GetCurrentRateUseCase {
  final CurrencyRepository repository;

  GetCurrentRateUseCase(this.repository);

  Future<double> call({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    return await repository.getCurrentRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
  }
}
