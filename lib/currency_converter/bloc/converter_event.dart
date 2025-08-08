import 'package:equatable/equatable.dart';

abstract class ConverterEvent extends Equatable {
  const ConverterEvent();

  @override
  List<Object?> get props => [];
}

class ConvertCurrencyRequested extends ConverterEvent {
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

class GetCurrentRateRequested extends ConverterEvent {
  final String fromCurrency;
  final String toCurrency;

  const GetCurrentRateRequested({
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency];
}

class InitializeCurrencies extends ConverterEvent {
  final Map<String, String> currencies;

  const InitializeCurrencies(this.currencies);

  @override
  List<Object?> get props => [currencies];
}

class FromCurrencyChanged extends ConverterEvent {
  final String currency;

  const FromCurrencyChanged(this.currency);

  @override
  List<Object?> get props => [currency];
}

class ToCurrencyChanged extends ConverterEvent {
  final String currency;

  const ToCurrencyChanged(this.currency);

  @override
  List<Object?> get props => [currency];
}

class SwapCurrencies extends ConverterEvent {}

class AmountChanged extends ConverterEvent {
  final String amount;

  const AmountChanged(this.amount);

  @override
  List<Object?> get props => [amount];
}

class QuickAmountSelected extends ConverterEvent {
  final double amount;

  const QuickAmountSelected(this.amount);

  @override
  List<Object?> get props => [amount];
}
