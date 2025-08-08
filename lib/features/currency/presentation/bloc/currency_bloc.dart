import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/convert_currency_usecase.dart';
import '../../domain/usecases/get_current_rate_usecase.dart';
import 'currency_event.dart';
import 'currency_state.dart';

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
