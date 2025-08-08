import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/conversion_result_entity.dart';
import '../../domain/usecases/convert_currency_usecase.dart';
import '../../domain/usecases/get_current_rate_usecase.dart';

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

// BLoC
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final ConvertCurrencyUseCase convertCurrencyUseCase;
  final GetCurrentRateUseCase getCurrentRateUseCase;

  CurrencyBloc({
    required this.convertCurrencyUseCase,
    required this.getCurrentRateUseCase,
  }) : super(CurrencyInitial()) {
    on<ConvertCurrencyRequested>(_onConvertCurrencyRequested);
    on<GetCurrentRateRequested>(_onGetCurrentRateRequested);
  }

  Future<void> _onConvertCurrencyRequested(
    ConvertCurrencyRequested event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(CurrencyLoading());
    try {
      final result = await convertCurrencyUseCase(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
        amount: event.amount,
      );
      emit(CurrencyConversionSuccess(result));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  Future<void> _onGetCurrentRateRequested(
    GetCurrentRateRequested event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(CurrencyLoading());
    try {
      final rate = await getCurrentRateUseCase(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
      );
      
      // For now, we'll assume it's not cached since we don't have access to cache info here
      // In a real implementation, you might want to inject the repository to check cache status
      emit(CurrencyRateSuccess(
        fromCurrency: event.fromCurrency,
        toCurrency: event.toCurrency,
        rate: rate,
        isCached: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }
}
