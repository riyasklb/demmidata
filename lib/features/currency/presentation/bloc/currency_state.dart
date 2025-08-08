import 'package:equatable/equatable.dart';
import '../../domain/entities/conversion_result_entity.dart';

// States
abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyConversionSuccess extends CurrencyState {
  final ConversionResultEntity result;

  const CurrencyConversionSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class CurrencyRateSuccess extends CurrencyState {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final bool isCached;
  final DateTime? timestamp;

  const CurrencyRateSuccess({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.isCached,
    this.timestamp,
  });

  @override
  List<Object?> get props => [fromCurrency, toCurrency, rate, isCached, timestamp];
}

class CurrencyError extends CurrencyState {
  final String message;

  const CurrencyError(this.message);

  @override
  List<Object?> get props => [message];
}
