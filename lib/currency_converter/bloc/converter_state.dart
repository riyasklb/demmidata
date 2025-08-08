import 'package:equatable/equatable.dart';
import '../models/currency_model.dart';

abstract class ConverterState extends Equatable {
  const ConverterState();

  @override
  List<Object?> get props => [];
}

class ConverterInitial extends ConverterState {}

class ConverterLoading extends ConverterState {}

class ConverterConversionSuccess extends ConverterState {
  final CurrencyModel result;

  const ConverterConversionSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class ConverterRateSuccess extends ConverterState {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final bool isCached;
  final DateTime? timestamp;

  const ConverterRateSuccess({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.isCached,
    this.timestamp,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, rate, isCached, timestamp];
}

class ConverterError extends ConverterState {
  final String message;

  const ConverterError(this.message);

  @override
  List<Object?> get props => [message];
}

class CurrencySelectorLoaded extends ConverterState {
  final Map<String, String> currencies;
  final String fromCurrency;
  final String toCurrency;

  const CurrencySelectorLoaded({
    required this.currencies,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [currencies, fromCurrency, toCurrency];

  CurrencySelectorLoaded copyWith({
    Map<String, String>? currencies,
    String? fromCurrency,
    String? toCurrency,
  }) {
    return CurrencySelectorLoaded(
      currencies: currencies ?? this.currencies,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
    );
  }
}

class AmountInputLoaded extends ConverterState {
  final String amount;
  final String? validationError;

  const AmountInputLoaded({
    required this.amount,
    this.validationError,
  });

  @override
  List<Object?> get props => [amount, validationError];

  AmountInputLoaded copyWith({
    String? amount,
    String? validationError,
  }) {
    return AmountInputLoaded(
      amount: amount ?? this.amount,
      validationError: validationError ?? this.validationError,
    );
  }
}
