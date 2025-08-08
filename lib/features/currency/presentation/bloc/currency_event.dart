import 'package:equatable/equatable.dart';

// Events
abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class ConvertCurrencyRequested extends CurrencyEvent {
  final String fromCurrency;
  final String toCurrency;
  final double amount;

  const ConvertCurrencyRequested({
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, amount];
}

class GetCurrentRateRequested extends CurrencyEvent {
  final String fromCurrency;
  final String toCurrency;

  const GetCurrentRateRequested({
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency];
}
